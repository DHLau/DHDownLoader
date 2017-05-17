//
//  DHDownLoaderManager.m
//  DHDownLoader
//
//  Created by LDH on 17/5/17.
//  Copyright © 2017年 DHLau. All rights reserved.
//

#import "DHDownLoaderManager.h"
#import "NSString+MD5.h"

@interface DHDownLoaderManager ()<NSCopying,NSMutableCopying>

@property (nonatomic, strong) NSMutableDictionary *downLoadInfo;

@end

static DHDownLoaderManager *_shareInstance;

@implementation DHDownLoaderManager

#pragma mark - Singleton
+ (instancetype)shareInstance
{
    if(_shareInstance == nil) {
        _shareInstance = [[self alloc] init];
    }
    return _shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    if (_shareInstance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [super allocWithZone:zone];
        });
    }
    return _shareInstance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _shareInstance;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return _shareInstance;
}

- (void)downLoader:(NSURL *)url downLoadInfo:(DownLoadInfoType)downLoadInfo progress:(ProgressBlockType)progressBlock success:(SuccessBlockType)successBlock failed:(FailedBlockType)failedBlock
{
    NSString *urlMD5 = [url.absoluteString md5];
    
    DHDownLoader *downLoader = self.downLoadInfo[urlMD5];
    if (downLoader == nil) {
        downLoader = [[DHDownLoader alloc] init];
        self.downLoadInfo[urlMD5] = downLoader;
    }
    
    __weak typeof (self) weakSelf = self;
    [downLoader downLoader:url downLoadInfo:downLoadInfo progress:progressBlock success:^(NSString *filePath) {
        [weakSelf.downLoadInfo removeObjectForKey:urlMD5];
        successBlock(filePath);
    } failed:failedBlock];
}

- (void)pauseWithURL:(NSURL *)url
{
    NSString *urlMD5 = [url.absoluteString md5];
    DHDownLoader *downLoader = self.downLoadInfo[urlMD5];
    [downLoader pauseCurrentTask];
}

- (void)resumeWithURL:(NSURL *)url
{
    NSString *urlMD5 = [url.absoluteString md5];
    DHDownLoader *downLoader = self.downLoadInfo[urlMD5];
    [downLoader resumeCurrentTask];
}

- (void)cancelWithURL:(NSURL *)url
{
    NSString *urlMD5 = [url.absoluteString md5];
    DHDownLoader *downLoader = self.downLoadInfo[urlMD5];
    [downLoader cancelCurrentTask];
}

- (void)pauseAll
{
    [self.downLoadInfo.allValues performSelector:@selector(pauseCurrentTask) withObject:nil];
}

- (void)resumeAll {
    [self.downLoadInfo.allValues performSelector:@selector(resumeCurrentTask) withObject:nil];
}

@end
