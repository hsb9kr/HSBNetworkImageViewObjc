//
//  ViewController.m
//  DemoHSBNetworkImageView
//
//  Created by hsb9kr on 2017. 11. 3..
//  Copyright © 2017년 hsb9kr. All rights reserved.
//

#import "ViewController.h"
#import "HSBNetworkImageView.h"

@interface ViewController () <HSBNetworkImageDelegate>
@property (weak, nonatomic) IBOutlet HSBNetworkImageView *imageView;
@property (weak, nonatomic) IBOutlet HSBNetworkImageView *imageView2;
@property (weak, nonatomic) IBOutlet HSBNetworkImageView *imageView3;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _imageView.timeoutInterval = 1;
    _imageView2.timeoutInterval = 1;
    _imageView3.timeoutInterval = 1;
    
    [_imageView imageWithURLString:@"https://wallpapershome.com/images/wallpapers/hd-5120x2880-abstract-wormhole-spiral-13573.jpg"];
    [_imageView2 imageWithURLString:@"https://wallpapershome.com/images/wallpapers/abstract-5120x2880-iphone-wallpaper-4k-5k-lines-3d-12741.jpg"];
    [_imageView3 imageWithURLString:@"https://wallpapershome.com/images/wallpapers/typography-5120x2880-5k-4k-wallpaper-font-abstract-pink-shape-3d-13116.jpg"];
}

- (IBAction)reload:(id)sender {
    _imageView.image = nil;
    _imageView2.image = nil;
    _imageView3.image = nil;
    [_imageView reload];
    [_imageView2 reload];
    [_imageView3 reload];
}

#pragma mark <HSBNetworkImageDelegate>

- (UIView *)hsbImageViewAddRetryView:(HSBNetworkImageView *)imageView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    view.backgroundColor = UIColor.redColor;
    return view;
}

- (void)hsbImageView:(HSBNetworkImageView *)imageView beforeRequest:(NSURLRequest *)request userInfo:(id)userInfo {
    
}

- (void)hsbImageView:(HSBNetworkImageView *)imageView error:(NSError *)error userInfo:(id)userInfo {
    
}

- (void)hsbImageView:(HSBNetworkImageView *)imageView receiveResponse:(NSURLResponse *)response userInfo:(id)userInfo {
    
}

- (void)hsbImageView:(HSBNetworkImageView *)imageView image:(UIImage *)image url:(NSURL *)url userInfo:(id)userInfo isCached:(BOOL)isCached {
    
}

- (void)hsbImageView:(HSBNetworkImageView *)imageView dataTask:(NSURLSessionDataTask *)dataTask currentByteLength:(NSUInteger)currentLength totalByteLength:(NSUInteger)totalLength didReceivedData:(NSData *)data userInfo:(id)userInfo {
    
}

@end
