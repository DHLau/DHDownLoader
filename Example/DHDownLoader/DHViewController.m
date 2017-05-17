//
//  DHViewController.m
//  DHDownLoader
//
//  Created by DHLau on 05/16/2017.
//  Copyright (c) 2017 DHLau. All rights reserved.
//

#import "DHViewController.h"
#import "DHDownLoaderManager.h"

@interface DHViewController ()

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURL *url2;

@end

@implementation DHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}
- (IBAction)download:(id)sender {
    self.url = [NSURL URLWithString:@"http://s1.music.126.net/download/osx/NeteaseMusic_1.5.3_544_web.dmg"];
    
    self.url2 = [NSURL URLWithString:@"http://free2.macx.cn:8281/tools/photo/Sip44.dmg"];
    
    [[DHDownLoaderManager shareInstance] downLoader:self.url downLoadInfo:^(long long totalSize) {
        NSLog(@"url-下载信息--%lld", totalSize);
    } progress:^(float progress) {
        NSLog(@"url-下载进度--%f", progress);
    } success:^(NSString *filePath) {
        NSLog(@"url-下载成功--路径:%@", filePath);
    } failed:^{
        NSLog(@"url-下载失败了");
    }];
    
//    [[DHDownLoaderManager shareInstance] downLoader:self.url2 downLoadInfo:^(long long totalSize) {
//        NSLog(@"url2-下载信息--%lld", totalSize);
//    } progress:^(float progress) {
//        NSLog(@"url2-下载进度--%f", progress);
//    } success:^(NSString *filePath) {
//        NSLog(@"url2-下载成功--路径:%@", filePath);
//    } failed:^{
//        NSLog(@"url2-下载失败了");
//    }];
    
}
- (IBAction)pause:(id)sender {
    [[DHDownLoaderManager shareInstance] pauseWithURL:self.url];
}
- (IBAction)cancel:(id)sender {
    [[DHDownLoaderManager shareInstance] cancelWithURL:self.url2];
}


@end
