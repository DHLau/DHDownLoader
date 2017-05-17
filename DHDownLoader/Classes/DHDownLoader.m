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
@property (nonatomic, weak) NSURLSessionDataTask *dataTask;
@end

@implementation DHDownLoader

- (void)downLoader:(NSURL *)url downLoadInfo:(DownLoadInfoType)downLoadInfo progress:(ProgressBlockType)progressBlock success:(SuccessBlockType)successBlock failed:(FailedBlockType)failedBlock
{
    self.downLoadInfo = downLoadInfo;
    self.progressChange = progressBlock;
    self.successBlock = successBlock;
    self.failedBlock = failedBlock;
    
    [self downLoader:url];
}

- (void)downLoader:(NSURL *)url
{
    if ([url isEqual:self.dataTask.originalRequest.URL]) {
        if (self.state == DHDownLoadStatePause) {
            [self resumeCurrentTask];
            return;
        }
    }
    [self cancelCurrentTask];
    
    
    NSString *fileName = url.lastPathComponent;
    
    self.downLoadedPath = [kCachePath stringByAppendingPathComponent:fileName];
    self.downLoadingPath = [kTmpPath stringByAppendingPathComponent:fileName];
    
    if ([DHFileTool fileExists:self.downLoadedPath]) {
        self.state = DHDownLoadStateSuccess;
        return;
    }
    
    if (![DHFileTool fileSize:self.downLoadingPath]) {
        [self downLoadWithURL:url offset:0];
        return;
    }
    
    _tmpSize = [DHFileTool fileSize:self.downLoadingPath];
    [self downLoadWithURL:url offset:_tmpSize];
    
}

// 暂停任务
- (void)pauseCurrentTask
{
    if (self.state == DHDownLoadStateDownLoading) {
        self.state = DHDownLoadStatePause;
        [self.dataTask suspend];
    }
}

// 继续任务
- (void)resumeCurrentTask
{
    if (self.dataTask && self.state == DHDownLoadStatePause) {
        [self.dataTask resume];
        self.state = DHDownLoadStateDownLoading;
    }
}

// 取消当前任务
- (void)cancelCurrentTask
{
    self.state = DHDownLoadStatePause;
    [self.session invalidateAndCancel];
    self.session = nil;
}

// 取消并清空
- (void)cancelAndClean
{
    [self cancelCurrentTask];
    [DHFileTool removeFile:self.downLoadingPath];
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
    
    if (_tmpSize == _totalSize) {
        [DHFileTool moveFile:self.downLoadingPath toPath:self.downLoadedPath];
        completionHandler(NSURLSessionResponseCancel);
        self.state = DHDownLoadStateSuccess;
    }
    
    if (_tmpSize > _totalSize) {
        [DHFileTool removeFile:self.downLoadingPath];
        [self downLoader:response.URL];
        completionHandler(NSURLSessionResponseCancel);
        return;
    }
    self.state = DHDownLoadStateDownLoading;
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.downLoadingPath append:YES];
    [self.outputStream open];
    completionHandler(NSURLSessionResponseAllow);
}

// 当用户确定， 继续接收数据时候调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    _tmpSize += data.length;
    self.progress = 1.0 * _tmpSize / _totalSize;
    [self.outputStream write:data.bytes maxLength:data.length];
}

// 请求完成 != 请求失败或者成功
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error == nil) {
        [DHFileTool moveFile:self.downLoadingPath toPath:self.downLoadedPath];
        self.state = DHDownLoadStateSuccess;
    } else {
        if (error.code == -999) {
            self.state = DHDownLoadStatePause;
        } else {
            self.state = DHDownLoadStateFailed;
        }
    }
    [self.outputStream close];
}


#pragma mark - 私有方法
- (void)downLoadWithURL:(NSURL *)url offset:(long long)offset {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",offset] forHTTPHeaderField:@"Range"];
    
    self.dataTask = [self.session dataTaskWithRequest:request];
    [self resumeCurrentTask];
}

- (void)setState:(DHDownLoadState)state
{
    if (_state == state) {
        return;
    }
    _state = state;
    
    if (self.stateChange) {
        self.stateChange(_state);
    }
    if (_state == DHDownLoadStateSuccess && self.successBlock) {
        self.successBlock(self.downLoadedPath);
    }
    if (_state == DHDownLoadStateFailed && self.failedBlock) {
        self.failedBlock();
    }
}

- (void)setProgress:(float)progress
{
    _progress = progress;
    if (self.progressChange) {
        self.progressChange(_progress);
    }
}

#pragma mark - Lazy

- (NSURLSession *)session
{
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}


@end
