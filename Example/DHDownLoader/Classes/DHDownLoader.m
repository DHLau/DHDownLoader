//
//  DHDownLoader.m
//  DHDownLoader
//
//  Created by LDH on 17/5/16.
//  Copyright © 2017年 DHLau. All rights reserved.
//

#import "DHDownLoader.h"
#import "DHFileTool.h"

#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kTmpPath NSTemporaryDirectory()


@interface DHDownLoader ()<NSURLSessionDataDelegate>
{
    long long _tmpSize;
    long long _totalSize;
}
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, copy) NSString *downLoadedPath;
@property (nonatomic, copy) NSString *downLoadingPath;
@property (nonatomic, strong) NSOutputStream *outputStream;
@end

@implementation DHDownLoader

- (NSURLSession *)session
{
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (void)downLoader:(NSURL *)url
{
    NSString *fileName = url.lastPathComponent;
    
    self.downLoadingPath = [kCachePath stringByAppendingPathComponent:fileName];
    self.downLoadedPath = [kTmpPath stringByAppendingPathComponent:fileName];
    
    if ([DHFileTool fileExists:self.downLoadedPath]) {
        return;
    }
    
    if (![DHFileTool fileSize:self.downLoadingPath]) {
        [self downLoadWithURL:url offset:0];
        return;
    }
    
    _tmpSize = [DHFileTool fileSize:self.downLoadingPath];
    [self downLoadWithURL:url offset:_tmpSize];
    
}

#pragma mark - NSURLSessionDataDelegate
// 刚刚收到相应 -》 可以拿到响应头
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    _totalSize = [response.allHeaderFields[@"content-Length"] longLongValue];
    NSString *contentRangeStr = response.allHeaderFields[@"content-Range"];
    if (contentRangeStr.length != 0) {
        _totalSize = [[contentRangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
    
    if (_tmpSize > _totalSize) {
        [DHFileTool removeFile:self.downLoadingPath];
        [self downLoader:response.URL];
        completionHandler(NSURLSessionResponseCancel);
        return;
    }
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.downLoadingPath append:YES];
    completionHandler(NSURLSessionResponseAllow);
}

// 当用户确定， 继续接收数据时候调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self.outputStream write:data.bytes maxLength:data.length];
}

// 请求完成 != 请求失败或者成功
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [self.outputStream close];
}


#pragma mark - 私有方法
- (void)downLoadWithURL:(NSURL *)url offset:(long long)offset {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",offset] forHTTPHeaderField:@"Range"];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request];
    
    [dataTask resume];
}


@end
