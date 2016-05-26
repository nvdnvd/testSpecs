//
//  BSAudioTool.h
//
//
//  Created by 王聪 on 1/12/16.
//  Copyright © 2016 王聪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface FEAudioTool : NSObject
/**
 *播放音乐文件
 */
+(BOOL)playMusic:(NSString *)filename;

+(BOOL)playMusic:(NSString *)filename withLoop:(NSInteger) loop;
/**
 *暂停播放
 */
+(void)pauseMusic:(NSString *)filename;
/**
 *播放音乐文件
 */
+(void)stopMusic:(NSString *)filename;

+(NSTimeInterval)durationOfMusic:(NSString *)filename;
@end