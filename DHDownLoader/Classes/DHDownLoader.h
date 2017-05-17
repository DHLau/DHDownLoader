//
//  DHDownLoader.h
//  DHDownLoader
//
//  Created by LDH on 17/5/16.
//  Copyright © 2017年 DHLau. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DHDownLoadState) {
    DHDownLoadStatePause,
    DHDownLoadStateDownLoading,
    DHDownLoadStateSuccess,
    DHDownLoadStateFailed
};

typedef void(^DownLoadInfoType)(long long totalSize);
typedef void(^ProgressBlockType)(float progress);
typedef void(^SuccessBlockType)(NSString *filePath);
typedef void(^FailedBlockType)();
typedef void(^StateChangeType)(DHDownLoadState state);


@interface DHDownLoader : NSObject

- (void)downLoader:(NSURL *)url;

- (void)downLoader:(NSURL *)url downLoadInfo:(DownLoadInfoType)downLoadInfo progress:(ProgressBlockType)progressBlock success:(SuccessBlockType)successBlock failed:(FailedBlockType)failedBlock;

- (void)resumeCurrentTask;

- (void)pauseCurrentTask;

- (void)cancelCurrentTask;

- (void)cancelAndClean;

@property (nonatomic, assign, readonly) DHDownLoadState state;
@property (nonatomic, assign, readonly) float progress;
@property (nonatomic, copy) DownLoadInfoType downLoadInfo;
@property (nonatomic, copy) StateChangeType stateChange;
@property (nonatomic, copy) ProgressBlockType progressChange;
@property (nonatomic, copy) SuccessBlockType successBlock;
@property (nonatomic, copy) FailedBlockType failedBlock;


@end
