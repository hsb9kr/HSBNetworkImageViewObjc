//
//  RedImageView.h
//  imageNetwork
//
//  Created by hsb9kr on 2017. 8. 28..
//  Copyright © 2017년 hsb9kr. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HSBNetworkImageDelegate;

typedef enum : NSUInteger {
    HSBNetworkImageViewStateRequesting,
    HSBNetworkImageViewStateNone
} HSBNetworkImageViewState;

IB_DESIGNABLE
@interface HSBNetworkImageView : UIImageView {
@private
    NSURL *_url;
    UIView *_retryView;
    struct {
        unsigned int success    :1;
        unsigned int error      :1;
        unsigned int received   :1;
        unsigned int request    :1;
        unsigned int response   :1;
        unsigned int retryView  :1;
    }_delegateFlage;
}

@property (weak, nonatomic) id userInfo;
@property (weak, nonatomic) IBOutlet id<HSBNetworkImageDelegate> delegate;
@property (weak, nonatomic) NSCache *cache;
@property (nonatomic) IBInspectable NSTimeInterval timeoutInterval;
@property (strong, nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) HSBNetworkImageViewState state;

@property (strong, nonatomic) IBInspectable UIColor *borderColor;
@property (nonatomic) IBInspectable CGFloat borderWidth;
@property (nonatomic) IBInspectable CGFloat cornerRadius;
@property (nonatomic) IBInspectable BOOL useCache;

+ (NSCache *)defaultCache;

- (void)imageWithURLString:(NSString *)urlString;
- (void)imageWithURL:(NSURL *)url;
- (void)invalidateSession;
- (void)reload;
@end

@protocol HSBNetworkImageDelegate <NSObject>
@optional
- (void)hsbImageView:(HSBNetworkImageView *)imageView beforeRequest:(NSURLRequest *)request userInfo:(id)userInfo;
- (void)hsbImageView:(HSBNetworkImageView *)imageView receiveResponse:(NSURLResponse *)response userInfo:(id)userInfo;
- (void)hsbImageView:(HSBNetworkImageView *)imageView dataTask:(NSURLSessionDataTask *)dataTask currentByteLength:(NSUInteger)currentLength totalByteLength:(NSUInteger)totalLength didReceivedData:(NSData *)data userInfo:(id)userInfo;
- (void)hsbImageView:(HSBNetworkImageView *)imageView image:(UIImage *)image url:(NSURL *)url userInfo:(id)userInfo isCached:(BOOL)isCached;
- (void)hsbImageView:(HSBNetworkImageView *)imageView error:(NSError *)error userInfo:(id)userInfo;

- (UIView *)hsbImageViewAddRetryView:(HSBNetworkImageView *)imageView;
@end
