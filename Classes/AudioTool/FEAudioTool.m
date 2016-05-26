//
//  BSAudioTool.m
//  
//
//  Created by 王聪 on 1/14/16.
//  Copyright © 2016 王聪. All rights reserved.
//
#import "FEAudioTool.h"

@implementation FEAudioTool
/**
 *存放所有的音乐播放器
 */
static NSMutableDictionary *_musices;
+(NSMutableDictionary *)musices
{
    if (_musices==nil) {
        _musices=[NSMutableDictionary dictionary];
    }
    return _musices;
}

+(BOOL)playMusic:(NSString *)filename
{
    if (!filename) return NO;//如果没有传入文件名，那么直接返回
    //1.取出对应的播放器
    AVAudioPlayer *player=[self musices][filename];
    
    //2.如果播放器没有创建，那么就进行初始化
    if (!player) {
        //2.1音频文件的URL
        NSURL *url = [[NSBundle mainBundle]URLForResource:filename withExtension:nil];
        if (!url) return NO;//如果url为空，那么直接返回
        
        //AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:url options:nil];
        
        //CMTime audioDuration = audioAsset.duration;
        
        //float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
        //NSLog(@"audioDuration Seconds=%f", audioDurationSeconds);
        
        //2.2创建播放器
        player=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
        
        //2.3缓冲
        if (![player prepareToPlay]) return NO;//如果缓冲失败，那么就直接返回
        
        //2.4存入字典
        [self musices][filename]=player;
    }
    
    //3.播放
    if (![player isPlaying]) {
        //如果当前没处于播放状态，那么就播放
        return [player play];
    }
    
    return YES;//正在播放，那么就返回YES
}

+(BOOL)playMusic:(NSString *)filename withLoop:(NSInteger) loop
{
    if (!filename) return NO;//如果没有传入文件名，那么直接返回
    //1.取出对应的播放器
    AVAudioPlayer *player=[self musices][filename];
    
    //2.如果播放器没有创建，那么就进行初始化
    if (!player) {
        //2.1音频文件的URL
        NSURL *url = [[NSBundle mainBundle]URLForResource:filename withExtension:nil];//[[NSURL alloc] initFileURLWithPath:filename];
        if (!url) return NO;//如果url为空，那么直接返回
        
       // AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:url options:nil];
        
        //CMTime audioDuration = audioAsset.duration;
        
       // float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
        //NSLog(@"audioDuration Seconds=%f", audioDurationSeconds);
        
        //2.2创建播放器
        player=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
        
        player.numberOfLoops = loop;
        
        //2.3缓冲
        if (![player prepareToPlay]) return NO;//如果缓冲失败，那么就直接返回
        
        //2.4存入字典
        [self musices][filename]=player;
    }
    
    //3.播放
    if (![player isPlaying]) {
        //如果当前没处于播放状态，那么就播放
        player.numberOfLoops = loop;
        return [player play];
    }
    
    return YES;//正在播放，那么就返回YES
}

+(void)pauseMusic:(NSString *)filename
{
    if (!filename) return;//如果没有传入文件名，那么就直接返回
    
    //1.取出对应的播放器
    AVAudioPlayer *player=[self musices][filename];
    
    //2.暂停
    [player pause];//如果palyer为空，那相当于[nil pause]，因此这里可以不用做处理
    
}

+(void)stopMusic:(NSString *)filename
{
    if (!filename) return;//如果没有传入文件名，那么就直接返回
    
    //1.取出对应的播放器
    AVAudioPlayer *player=[self musices][filename];
    
    //2.停止
    [player stop];
    
    //3.将播放器从字典中移除
    [[self musices] removeObjectForKey:filename];
}


+ (void)fileAttriutes:(NSString *)filename
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filename error:nil];
    NSArray *keys;
    id key, value;
    keys = [fileAttributes allKeys];
    int count = [keys count];
    //NSLog(@"count=%d",count);
    for (int i = 0; i < count; i++)
    {
        key = [keys objectAtIndex: i];
        value = [fileAttributes objectForKey: key];
        NSLog (@"Key: %@ for value: %@", key, value);
    }
}

+(NSTimeInterval)durationOfMusic:(NSString *)filename
{
    NSURL *url = [[NSURL alloc] initFileURLWithPath:filename];
    if (!url) return -1.0f;//如果url为空，那么直接返回
    
    AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:url options:nil];
    
    CMTime audioDuration = audioAsset.duration;
    
    float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
    return audioDurationSeconds;
}

@end