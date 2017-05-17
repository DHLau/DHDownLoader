//
//  DHFileTool.h
//  DHDownLoader
//
//  Created by LDH on 17/5/16.
//  Copyright © 2017年 DHLau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHFileTool : NSObject
+ (BOOL)fileExists:(NSString *)filePath;
+ (long long)fileSize:(NSString *)filePath;
+ (void)moveFile:(NSString *)fromPath toPath:(NSString *)toPath;
+ (void)removeFile:(NSString *)filePath;
@end
