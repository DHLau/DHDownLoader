//
//  DHDownLoaderManager.h
//  DHDownLoader
//
//  Created by LDH on 17/5/17.
//  Copyright © 2017年 DHLau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHDownLoader.h"

@interface DHDownLoaderManager : NSObject

+ (instancetype)shareInstance;

- (void)downLoader:(NSURL *)url downLoadInfo:(DownLoadInfoType)downLoadInfo progress:(ProgressBlockType)progressBlock success:(SuccessBlockType)successBlock failed:(FailedBlockType)failedBlock;

- (void)pauseWithURL:(NSURL *)url;
- (void)resumeWithURL:(NSURL *)url;
- (void)cancelWithURL:(NSURL *)url;

- (void)pauseAll;
- (void)resumeAll;

@end
