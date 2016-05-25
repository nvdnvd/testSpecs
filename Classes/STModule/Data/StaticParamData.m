//
//  FEEffectData.m
//  FaceEffectDemo
//
//  Created by Viktor Pih on 16/3/29.
//  Copyright © 2016年 Viktor Pih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StaticParamData.h"
#import "common.h"
#import "FEAudioTool.h"

#define ARRAY_LENTH 10

@interface StaticParamData()
{
    NSMutableArray<GPUImagePicture*> *_pictures; // 素材
    NSMutableArray<NSDictionary*> *_items;
    
    NSMutableArray *_filenames;

    int centers[ARRAY_LENTH][ARRAY_LENTH];
    int centersNum[ARRAY_LENTH];
    float ratios[ARRAY_LENTH];
    int fullscreens[ARRAY_LENTH];
    float heightratios[ARRAY_LENTH];
    int framecount[ARRAY_LENTH];
    int duration[ARRAY_LENTH];
    CGPoint alignPoint[ARRAY_LENTH];
    int trigger[ARRAY_LENTH];
    int index[ARRAY_LENTH];
    int step[ARRAY_LENTH];
    int startFrame[ARRAY_LENTH];
    int stopFrame[ARRAY_LENTH];
    int loop;
    
    int totalFrameCount;//完整动画的播放帧数
}

@property (nonatomic, strong) NSDictionary *paramsDic;
@property (nonatomic, strong) FEPictureFilter *pictureFilter;
@property (nonatomic, assign) NSInteger num;
@property (nonatomic, strong) NSMutableDictionary *picCache;

@property (nonatomic, assign) int triggerFrame;
@property (nonatomic, assign) BOOL isChanged;

- (void) setupFromPath:(NSString*)paramsName glsl:(NSString *)glslName;
- (NSDictionary*) parsingParamsFromURL:(NSURL*) url;

@end

@implementation StaticParamData
- (void) setupFromPath:(NSString*)paramsName glsl:(NSString *)glslName
{
    // 得到参数
    //NSURL *paramsURL = [NSURL URLWithString:[path stringByAppendingPathComponent:filename]];
    NSURL *paramsURL = [[NSBundle mainBundle] URLForResource:paramsName withExtension:@""];
    self.paramsDic = [self parsingParamsFromURL:paramsURL];
    
    /////////////////////////////////////////////////
    static NSString* lastAudioFilename;
    if(lastAudioFilename!=nil)
    {
        NSLog(@"last Audio File name:%@", lastAudioFilename);
        [FEAudioTool  stopMusic:lastAudioFilename];
    }
    if([self.paramsDic objectForKey:@"audio"]!=nil)
    {
        self.audioFileName = [self.paramsDic objectForKey:@"audio"];
        lastAudioFilename = self.audioFileName;
    }
    loop = [[self.paramsDic objectForKey:@"loop"] intValue];
    
    // 生成filter
    NSInteger inputNumber = [self.paramsDic[@"reslist"] count] + 1;
    self.num = inputNumber-1;

    //NSURL *glslURL1 = [NSURL URLWithString:[path stringByAppendingPathComponent:@"glsl_static"]];
    NSURL *glslURL = [[NSBundle mainBundle] URLForResource:glslName withExtension:@""];
    NSData *data = [NSData dataWithContentsOfURL:glslURL];
    NSString *glslString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *tmp = [glslString stringByReplacingOccurrencesOfString:@"size_to_be_replaced" withString:[NSString stringWithFormat:@"%ld",inputNumber-1]];
    
    //NSLog(@"inputNumber=%d",inputNumber);
    if(self.pictureFilter == nil)
    {
        self.pictureFilter = [[FEPictureFilter alloc] initWithInputNumber:inputNumber fragmentShaderFromString:tmp];
    }
    
    self.tips = self.paramsDic[@"tips"];
    NSLog(@"tips=%@",self.tips);
    
    /////////////////////////////////////////////////
    // 加载资源
    NSArray *reslist = self.paramsDic[@"reslist"];
    totalFrameCount = 0;
    
    for (int i=0; i<[reslist count]; i++) {
        NSString *filename = reslist[i][@"fileName"];
        [_filenames addObject:filename];
        
        NSInteger width = [reslist[i][@"width"] integerValue];
        NSInteger height = [reslist[i][@"height"] integerValue];
        float fratio = ((CGFloat)width)/height;
        ratios[i] = fratio;
        
        float heightratio = [reslist[i][@"heightRatio"] floatValue];
        heightratios[i] = heightratio;
        
        int ifullscreen = [reslist[i][@"fullScreen"] intValue];
        fullscreens[i] = ifullscreen;
        
        NSArray *centerIndexArray = reslist[i][@"rotateCenterIndex"];
        centersNum[i] = [centerIndexArray count];
        for(int j=0; j<centersNum[i]; j++)
        {
            centers[i][j] = [centerIndexArray[j] intValue];
        }
         
        int frameCount = [reslist[i][@"frameCount"] intValue];
        framecount[i] = frameCount;
        if(totalFrameCount<frameCount)
        {
            totalFrameCount = frameCount;
        }
        
        int durationPerPicture = [reslist[i][@"duration"] intValue];
        duration[i] = durationPerPicture;
        
        int alignX = [reslist[i][@"alignX"] intValue];
        int alignY = [reslist[i][@"alignY"] intValue];
        alignPoint[i]=CGPointMake(1.0-(alignX*1.0f)/width, (alignY*1.0f)/height);
        
        trigger[i] = [reslist[i][@"trigger"] intValue];
        
        index[i] = 0;
        if(framecount[i] == 1)
        {
            step[i] = 0;
        }
        else
        {
            if(frameCount<kRate)
            {
                step[i] = 1;
            }
            else
            {
                step[i] = kRate*duration[i]/framecount[i];
            }
        }
        
        NSArray *timeRange = [reslist[i] objectForKey:@"triggerRange"];
        if(timeRange != nil)
        {
            startFrame[i] = [[timeRange objectAtIndex:0] intValue];
            stopFrame[i] = [[timeRange objectAtIndex:1] intValue];
        }
        else
        {
            startFrame[i] = -2;
            stopFrame[i] = -2;
        }
    }
}

- (void)updateFramePicture:(int)frameIndex
{
    for (int i=0; i<self.num; i++)
    {
        if((_filenames[i]!=nil)&&([_filenames[i] length]>0))
        {
            NSString *key = [NSString stringWithFormat:@"%d",i];
            if([_picCache objectForKey:key] != nil)
            {
                [[_picCache objectForKey:key] removeTarget:self.pictureFilter];
            }
            
            if(frameIndex>totalFrameCount)
            {
                frameIndex = frameIndex%totalFrameCount;
            }
            
            //NSLog(@"frameindex=%ld",frameIndex);
            
            //动画大于总帧数，从头再来
            if((index[i]>=framecount[i])&&(stopFrame[i]!=-1))
            {
                index[i] = 0;
                continue;
            }
            else if((index[i]>=framecount[i])&&(stopFrame[i]==-1))
            {
                index[i] = framecount[i]-1;
                step[i] = 0;
            }
                        
            //动画持续的情况
            if(startFrame[i]!=-2&&stopFrame[i]!=-2&&stopFrame[i]!=-1)
            {
                NSString *imageStr;
                if((startFrame[i] <= frameIndex)&&(stopFrame[i]>=frameIndex-1))
                {
                    imageStr=[NSString stringWithFormat:@"%@_%03d",_filenames[i],index[i]];
                    //NSLog(@"imagestr=%@",imageStr);
                }
                else
                {
                    imageStr=[NSString stringWithFormat:@"%@_000",_filenames[i]];
                }
                GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:imageStr]];
                // 加载图片
                [pic addTarget:self.pictureFilter atTextureLocation:i+1];
                [pic processImage];
                
                [_picCache setObject:pic forKey:key];
                index[i] += step[i];
            }
            else if(stopFrame[i]==-1)
            {
                NSLog(@"startFrame[i]＝%d,frameIndex=%d",startFrame[i],frameIndex);
                NSString *imageStr;
                if(startFrame[i] <= frameIndex)
                {
                    imageStr=[NSString stringWithFormat:@"%@_%03d",_filenames[i],index[i]];
                }
                else//start frame < frameIndex
                {
                    imageStr=[NSString stringWithFormat:@"transparent"];
                }
                NSLog(@"imagestr=%@",imageStr);
                
                GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:imageStr]];
                // 加载图片
                [pic addTarget:self.pictureFilter atTextureLocation:i+1];
                [pic processImage];
                
                [_picCache setObject:pic forKey:key];
                index[i] += step[i];
            }
            else
            {
                NSString *imageStr=[NSString stringWithFormat:@"%@_%03d",_filenames[i],index[i]];
                //NSLog(@"imagestr = %@",imageStr);
                GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:imageStr]];
                // 加载图片
                [pic addTarget:self.pictureFilter atTextureLocation:i+1];
                [pic processImage];
                
                [_picCache setObject:pic forKey:key];
                index[i] += step[i];
            }
        }
    }
}

- (void)removeFramePicture
{
    for (int i=0; i<self.num; i++)
    {
        if((_filenames[i]!=nil)&&([_filenames[i] length]>0))
        {
            NSString *key = [NSString stringWithFormat:@"%d",i];
            if([_picCache objectForKey:key] != nil)
            {
                [[_picCache objectForKey:key] removeAllTargets];
                [[_picCache objectForKey:key] setEnabled:NO];
            }
        }
    }
    
    
}

- (NSDictionary*) parsingParamsFromURL:(NSURL*) url
{
    NSError *error = nil;
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    id resultString = [NSJSONSerialization JSONObjectWithData:data
                                                      options:NSJSONReadingMutableLeaves
                                                        error:&error];
    if (error)
    {
        NSLog(@"dic->%@",error);
    }
    
    return resultString;
}

+ (StaticParamData*) dataFromPath:(NSString*)paramsName glsl:(NSString *)glslName
{
    StaticParamData *data = [[StaticParamData alloc] initWithPath:paramsName glsl:glslName];
    return data;
}

- (id) init
{
    if ((self = [super init]))
    {
        _pictures = [NSMutableArray array];
        _picCache = [NSMutableDictionary new];
        _filenames = [NSMutableArray new];
        
    }
    return self;
}

- (id) initWithPath:(NSString*)paramsName glsl:(NSString *)glslName
{
    if ((self = [self init]))
    {
        [self setupFromPath:paramsName glsl:glslName];
    }
    return self;
}

- (void) setArrPersons:(NSArray*) arrPersons
{
    NSInteger roll = 0;
    CGPoint point[ARRAY_LENTH];
    int lenth = self.num;
    CGPoint leftPoint = CGPointZero;
    CGPoint rightPoint = CGPointZero;
    int triggerTmp = -1;
    
    for (NSDictionary *dicPerson in arrPersons) {
        if ([dicPerson objectForKey:POINTS_KEY]) {
            triggerTmp = 0;
            if(loop == 1)
            {
                [FEAudioTool  playMusic:self.audioFileName];
            }
            NSArray *points = [dicPerson objectForKey:POINTS_KEY];
            
            for (int i = 0 ; i<lenth; i++) {
                CGFloat x = 0;
                CGFloat y = 0;
                //NSLog(@"NUM=%d",centersNum[i]);
                for (int j = 0; j < centersNum[i]; j++) {
                    CGPoint point_tmp = CGPointFromString(points[centers[i][j]]);
                    x += point_tmp.x;
                    y += point_tmp.y;
                }
                //CGPoint point_tmp = CGPointFromString(points[centers[i]]);
                //NSLog(@"CENTERS=%d",centers[i]);
                point[i].x = x/centersNum[i];
                point[i].y = y/centersNum[i];
                //NSLog(@"xxxx[%f,%f]",point[i].x,point[i].y);
            }
            
            leftPoint = CGPointFromString(points[0]);
            rightPoint = CGPointFromString(points[18]);
        }
        if ([dicPerson objectForKey:ROLL_KEY]) {
            roll = [[dicPerson objectForKey:ROLL_KEY] integerValue];
        }
#ifdef EXTEND_KEY
        if ([dicPerson objectForKey:OPEN_MOUTH_KEY])
        {
            if([[dicPerson objectForKey:OPEN_MOUTH_KEY] intValue] == 1)
            {
                triggerTmp = 5;
                if(loop == 2)
                {
                    //[FEAudioTool  playMusic:self.audioFileName];
                }
            }
        }
        if ([dicPerson objectForKey:ENLARGE_EYE_KEY])
        {
            if([[dicPerson objectForKey:ENLARGE_EYE_KEY] intValue] == 1)
            {
                triggerTmp = 4;
                if(loop == 2)
                {
                    //[FEAudioTool  playMusic:self.audioFileName];
                }
            }
        }
        if ([dicPerson objectForKey:FORWORD_MOUTH_KEY])
        {
            if([[dicPerson objectForKey:FORWORD_MOUTH_KEY] intValue] == 1)
            {
                triggerTmp = 6;
                if(loop == 2)
                {
                    //[FEAudioTool  playMusic:self.audioFileName];
                }
            }
        }
#endif
    }
    
    //NSLog(@"trigeer=%d",triggerTmp);
    [self.pictureFilter setPointLeftValue:leftPoint];
    [self.pictureFilter setPointRightValue:rightPoint];
    [self.pictureFilter setRollValue:roll];
    [self.pictureFilter setRatiosValue:ratios length:lenth];
    [self.pictureFilter setHeightRatiosValue:heightratios length:lenth];
    [self.pictureFilter setAlignPointValue:alignPoint lenth:lenth];
    [self.pictureFilter setCentersValue:point lenth:lenth];
    [self.pictureFilter setFullscreensValue:fullscreens length:lenth];
    [self.pictureFilter setTriggersValue:trigger length:lenth];
    [self.pictureFilter setTriggerValue:triggerTmp];
}

@end
