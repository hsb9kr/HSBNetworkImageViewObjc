//
//  RedImageView.m
//  imageNetwork
//
//  Created by hsb9kr on 2017. 8. 28..
//  Copyright © 2017년 hsb9kr. All rights reserved.
//

#import "HSBNetworkImageView.h"

@interface HSBNetworkImageView () {
    NSMutableData *_data;
    NSUInteger _expectedContentLength;
    NSURLSession *_session;
    NSURLSessionTask *_task;
}
@end

@interface HSBNetworkImageView (NSURLSession) <NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>
@end

@implementation HSBNetworkImageView
@dynamic state;
@dynamic url;

+ (NSCache *)defaultCache {
    static NSCache *defaultCache = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultCache = [[NSCache alloc] init];
        defaultCache.countLimit = INFINITY;
        defaultCache.totalCostLimit = 100 * 1024 * 1024;
    });
    
    return defaultCache;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_retryView && _delegateFlage.retryView) {
        self.userInteractionEnabled = YES;
        _retryView = [_delegate hsbImageViewAddRetryView:self];
        _retryView.translatesAutoresizingMaskIntoConstraints = NO;
        _retryView.userInteractionEnabled = YES;
        _retryView.hidden = YES;
        [self addSubview:_retryView];
        
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_retryView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_retryView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_retryView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_retryView.bounds.size.width];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_retryView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_retryView.bounds.size.height];
        [_retryView addConstraints:@[width, height]];
        [self addConstraints:@[centerX, centerY]];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(retryViewTapGestureAction:)];
        [_retryView addGestureRecognizer:tapGesture];
    }
}

- (void)setDelegate:(id<HSBNetworkImageDelegate>)delegate {
    _delegate = delegate;
    _delegateFlage.success = [_delegate respondsToSelector:@selector(hsbImageView:image:url:userInfo:isCached:)];
    _delegateFlage.error = [_delegate respondsToSelector:@selector(hsbImageView:error:userInfo:)];
    _delegateFlage.received = [_delegate respondsToSelector:@selector(hsbImageView:dataTask:currentByteLength:totalByteLength:didReceivedData:userInfo:)];
    _delegateFlage.request = [_delegate respondsToSelector:@selector(hsbImageView:beforeRequest:userInfo:)];
    _delegateFlage.response = [_delegate respondsToSelector:@selector(hsbImageView:receiveResponse:userInfo:)];
    _delegateFlage.retryView = [_delegate respondsToSelector:@selector(hsbImageViewAddRetryView:)];
}

- (HSBNetworkImageViewState)state {
    if (_task) {
        switch (_task.state) {
            case NSURLSessionTaskStateCanceling:
            case NSURLSessionTaskStateCompleted:
                return HSBNetworkImageViewStateNone;
            case NSURLSessionTaskStateSuspended:
            case NSURLSessionTaskStateRunning:
                return HSBNetworkImageViewStateRequesting;
        }
    }
    return HSBNetworkImageViewStateNone;
}

- (NSURL *)url {
    return _url;
}

#pragma mark - Inspectable

- (void)setBorderColor:(UIColor *)borderColor {
    self.layer.borderColor = borderColor.CGColor;
}

- (UIColor *)borderColor {
    return [[UIColor alloc] initWithCGColor:self.layer.borderColor];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    self.layer.borderWidth = borderWidth;
}

- (CGFloat)borderWidth {
    return self.layer.borderWidth;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
    self.clipsToBounds = cornerRadius > 0;
}

- (CGFloat)cornerRadius {
    return self.layer.cornerRadius;
}

- (BOOL)useCache {
    return _cache != nil;
}

- (void)setUseCache:(BOOL)useCache {
    if (useCache) {
        _cache = HSBNetworkImageView.defaultCache;
    } else {
        _cache = nil;
    }
}

#pragma mark <Public>

- (void)imageWithURLString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    [self imageWithURL:url];
}

- (void)imageWithURL:(NSURL *)url {
    _url = url;
    _data = nil;
    if (!url) {
        if (_delegateFlage.error) {
            NSError *error = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:@{@"description": @"url is nil"}];
            [_delegate hsbImageView:self error:error userInfo:_userInfo];
        }
        return;
    }
    [self reload];
}

- (void)invalidateSession {
    [_session invalidateAndCancel];
}

- (void)reload {
    if (!_url) return;
    
    if (_cache) {
        NSPurgeableData *cacheData = [_cache objectForKey:_url.absoluteString];
        if (cacheData) {
            [cacheData beginContentAccess];
            _data = cacheData;
            [cacheData endContentAccess];
        }
        if (_data && _data.length != 0 && (self.image = [UIImage imageWithData:_data])) {
            if (_delegateFlage.success) {
                [_delegate hsbImageView:self image:self.image url: _url userInfo:_userInfo isCached:YES];
            }
            return;
        }
    }
    
    if (_task) {
        switch (_task.state) {
            case NSURLSessionTaskStateCanceling:
            case NSURLSessionTaskStateCompleted:
            case NSURLSessionTaskStateSuspended:
                break;
            case NSURLSessionTaskStateRunning:
                [_task cancel];
                [_session invalidateAndCancel];
                break;
        }
    }
    if (_timeoutInterval <= 0) {
        _timeoutInterval = 30.f;
    }
    _session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration delegate:self delegateQueue:NSOperationQueue.mainQueue];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:_url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:_timeoutInterval];
    _data = [NSMutableData new];
    _task = [_session dataTaskWithRequest: request];
    if (_delegateFlage.request) [_delegate hsbImageView:self beforeRequest:request userInfo:_userInfo];
    [_task resume];
}

#pragma mark <Touch>

- (void)retryViewTapGestureAction:(UITapGestureRecognizer *)recognizer {
    if (!_url) return;
    _retryView.hidden = YES;
    [self reload];
}

@end

@implementation HSBNetworkImageView (NSURLSession)

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    _expectedContentLength = (NSUInteger)response.expectedContentLength;
    completionHandler(NSURLSessionResponseAllow);
    _retryView.hidden = YES;
    if (_delegateFlage.response) [_delegate hsbImageView:self receiveResponse:response userInfo:_userInfo];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [_data appendData:data];
    if (_delegateFlage.received) [_delegate hsbImageView:self dataTask:dataTask currentByteLength:_data.length totalByteLength:_expectedContentLength didReceivedData:data userInfo:_userInfo];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [_session finishTasksAndInvalidate];
    if (error || _data.length != _expectedContentLength) {
        if (!error) return;
        if (error.code == -999) return;
        _retryView.hidden = NO;
        if (_delegateFlage.error) [_delegate hsbImageView:self error:error userInfo:_userInfo];
        return;
    }
    if (_cache) {
        NSPurgeableData *purgeableData = [NSPurgeableData dataWithData:_data];
        [_cache setObject: purgeableData forKey: task.response.URL.absoluteString cost: purgeableData.length];
    }
    self.image = [UIImage imageWithData:_data];
    if (_delegateFlage.success) [_delegate hsbImageView:self image:self.image url: task.response.URL userInfo:_userInfo isCached:NO];
}

@end
