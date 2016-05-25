//
//  FEEffectData.m
//  FaceEffectDemo
//
//  Created by Viktor Pih on 16/3/29.
//  Copyright © 2016年 Viktor Pih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StaticEyesParamData.h"
#import "common.h"
#import "FEAudioTool.h"

#define ARRAY_LENTH 10

@interface StaticEyesParamData()
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
}

@property (nonatomic, strong) NSDictionary *paramsDic;
@property (nonatomic, strong) FESmallEyesFilter *smallEyesFilter;
@property (nonatomic, assign) NSInteger num;
@property (nonatomic, strong) NSMutableDictionary *picCache;

@property (nonatomic, assign) int triggerFrame;
@property (nonatomic, assign) BOOL isChanged;

- (void) setupFromPath:(NSString*)paramsName glsl:(NSString *)glslName;
- (NSDictionary*) parsingParamsFromURL:(NSURL*) url;

@end

@implementation StaticEyesParamData
- (void) setupFromPath:(NSString*)paramsName glsl:(NSString *)glslName
{
    // 得到参数
    NSLog(@"paramsName=%@",paramsName);
    NSLog(@"glslName=%@",glslName);
    
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
    NSString *tmp = [glslString stringByReplacingOccurrencesOfString:@"size_to_be_replaced" withString:[NSString stringWithFormat:@"%d",inputNumber-1]];
    //NSLog(@"TMP=%@",tmp);
    
    //NSLog(@"inputNumber=%d",inputNumber);
    if(self.smallEyesFilter == nil)
    {
        //NSLog(@"inputNumber=%d",inputNumber);
        self.smallEyesFilter = [[FESmallEyesFilter alloc] initWithInputNumber:inputNumber fragmentShaderFromString:tmp];
    }
    
    self.tips = self.paramsDic[@"tips"];
    NSLog(@"tips=%@",self.tips);
    
    /////////////////////////////////////////////////
    // 加载资源
    NSArray *reslist = self.paramsDic[@"reslist"];
    
    //NSLog(@"count=%d",[reslist count]);
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
        //NSLog(@"fullscreens=%d",fullscreens[i]);
        
        NSArray *centerIndexArray = reslist[i][@"rotateCenterIndex"];
        centersNum[i] = [centerIndexArray count];
        for(int j=0; j<centersNum[i]; j++)
        {
            centers[i][j] = [centerIndexArray[j] intValue];
        }
         
        int frameCount = [reslist[i][@"frameCount"] intValue];
        framecount[i] = frameCount;
        //NSLog(@"framecount=%d",framecount[i]);
        
        
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
            step[i] = kRate*duration[i]/framecount[i];
        }
        
        NSArray *timeRange = [reslist[i] objectForKey:@"triggerRange"];
        if(timeRange != nil)
        {
            startFrame[i] = [[timeRange objectAtIndex:0] intValue];
            stopFrame[i] = [[timeRange objectAtIndex:1] intValue];
            NSLog(@"[%d,%d]",startFrame[i],stopFrame[i]);
        }
        else
        {
            startFrame[i] = -2;
            stopFrame[i] = -2;
            NSLog(@"默认范围");
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
                [[_picCache objectForKey:key] removeTarget:self.smallEyesFilter];
            }
            
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
            
            NSString *imageStr=[NSString stringWithFormat:@"%@_%03d",_filenames[i],index[i]];
            GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:imageStr]];
            // 加载图片
            [pic addTarget:self.smallEyesFilter atTextureLocation:i+1];
            [pic processImage];
            
            [_picCache setObject:pic forKey:key];
            index[i] += step[i];
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
    
    //NSLog(@"%@", resultString[@"reslist"]);
    
    return resultString;
}

+ (StaticEyesParamData*) dataFromPath:(NSString*)paramsName glsl:(NSString *)glslName
{
    StaticEyesParamData *data = [[StaticEyesParamData alloc] initWithPath:paramsName glsl:glslName];
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
    
    [self setEyesArrPersons:arrPersons];
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
                for (int j = 0; j < centersNum[i]; j++) {
                    CGPoint point_tmp = CGPointFromString(points[centers[i][j]]);
                    x += point_tmp.x;
                    y += point_tmp.y;
                }

                point[i].x = x/centersNum[i];
                point[i].y = y/centersNum[i];
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
                    [FEAudioTool  playMusic:self.audioFileName];
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
                    [FEAudioTool  playMusic:self.audioFileName];
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
                    [FEAudioTool  playMusic:self.audioFileName];
                }
            }
        }
#endif
    }
    
    [self.smallEyesFilter setPointLeftValue:leftPoint];
    [self.smallEyesFilter setPointRightValue:rightPoint];
    [self.smallEyesFilter setRollValue:roll];
    [self.smallEyesFilter setRatiosValue:ratios length:lenth];
    [self.smallEyesFilter setHeightRatiosValue:heightratios length:lenth];
    [self.smallEyesFilter setAlignPointValue:alignPoint lenth:lenth];
    [self.smallEyesFilter setCentersValue:point lenth:lenth];
    [self.smallEyesFilter setFullscreensValue:fullscreens length:lenth];
    [self.smallEyesFilter setTriggersValue:trigger length:lenth];
    [self.smallEyesFilter setTriggerValue:triggerTmp];
}

- (void) setEyesArrPersons:(NSArray*) arrPersons
{
    //NSInteger roll = 0;
    CGPoint centerPoint = CGPointZero;
    CGPoint leftFacePoint = CGPointZero;
    CGPoint rightFacePoint = CGPointZero;
    CGPoint eyesA[12];
    CGPoint eyesB[12];
    CGPoint mouth[12];
    
    for (NSDictionary *dicPerson in arrPersons) {
        if ([dicPerson objectForKey:POINTS_KEY]) {
            NSArray *points = [dicPerson objectForKey:POINTS_KEY];
            CGPoint point_tmp;
            for(int i = 50;i >= 39; i--)
            {
                point_tmp = CGPointFromString(points[i]);
                eyesA[50-i].x = point_tmp.x;
                eyesA[50-i].y = point_tmp.y;
            }
            
            for(int i = 62;i >= 51; i--)
            {
                point_tmp = CGPointFromString(points[i]);
                eyesB[62-i].x = point_tmp.x;
                eyesB[62-i].y = point_tmp.y;
            }
            
            for(int i = 86;i >= 75; i--)
            {
                point_tmp = CGPointFromString(points[i]);
                mouth[86-i].x = point_tmp.x;
                mouth[86-i].y = point_tmp.y;
            }
            
            point_tmp = CGPointFromString(points[98]);
            centerPoint.x = point_tmp.x;
            centerPoint.y = point_tmp.y;
            
            point_tmp = CGPointFromString(points[3]);
            leftFacePoint.x = point_tmp.x;
            leftFacePoint.y = point_tmp.y;
            
            point_tmp = CGPointFromString(points[15]);
            rightFacePoint.x = point_tmp.x;
            rightFacePoint.y = point_tmp.y;
        }
    }
    
    [self.smallEyesFilter setCenterValue:centerPoint];
    [self.smallEyesFilter setFaceLeftValue:leftFacePoint];
    [self.smallEyesFilter setFaceRightValue:rightFacePoint];
    [self.smallEyesFilter setEyesValue:eyesA lenth:12 leftOrRight:YES];
    [self.smallEyesFilter setEyesValue:eyesB lenth:12 leftOrRight:NO];
    [self.smallEyesFilter setMouthValue:mouth lenth:12];
}

@end
