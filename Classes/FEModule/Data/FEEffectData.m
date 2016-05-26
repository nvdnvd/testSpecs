//
//  FEEffectData.m
//  FaceEffectDemo
//
//  Created by Viktor Pih on 16/3/29.
//  Copyright © 2016年 Viktor Pih. All rights reserved.
//

#import "FEEffectData.h"
#import "common.h"

#import "FEFaceDetect.h"

@interface FEEffectData()
{
    NSMutableArray<GPUImagePicture*> *_pictures; // 素材
}

@property (nonatomic,strong) NSDictionary *paramsDic;
@property (nonatomic, strong) FEEffectFilter *filter;

- (void) setupFromPath:(NSString*)paramsName glsl:(NSString *)glslName
;
- (NSDictionary*) parsingParamsFromURL:(NSURL*) url;

@end

@implementation FEEffectData
- (void) setupFromPath:(NSString*)paramsName glsl:(NSString *)glslName
{
    /////////////////////////////////////////////////
    // 得到参数
    //NSURL *paramsURL = [NSURL URLWithString:[path stringByAppendingPathComponent:fileName]];
    //self.paramsDic = [self parsingParamsFromURL:paramsURL];
    NSURL *paramsURL = [[NSBundle mainBundle] URLForResource:paramsName withExtension:@""];
    self.paramsDic = [self parsingParamsFromURL:paramsURL];
    
    /////////////////////////////////////////////////
    // 生成filter
    NSInteger inputNumber = [self.paramsDic[@"reslist"] count] + 1;
    
    NSURL *glslURL = [[NSBundle mainBundle] URLForResource:glslName withExtension:@""];
    NSData *data = [NSData dataWithContentsOfURL:glslURL];
    NSString *glslString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    self.filter = [[FEEffectFilter alloc] initWithInputNumber:inputNumber fragmentShaderFromString:glslString];
    
    /////////////////////////////////////////////////
    // 加载资源
    NSArray *reslist = self.paramsDic[@"reslist"];
    for (int i=0; i<[reslist count]; i++) {
        //NSURL *picURL = [NSURL URLWithString:[path stringByAppendingPathComponent:reslist[i]]];
        NSURL *picURL = [[NSBundle mainBundle] URLForResource:reslist[i] withExtension:@""];
        GPUImagePicture *pic = [[GPUImagePicture alloc] initWithURL:picURL];
        [_pictures addObject:pic];
        
        // 加载图片
        [pic addTarget:self.filter atTextureLocation:i+1];
        [pic processImage];
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
    
    NSLog(@"%@", resultString[@"reslist"]);
    
    return resultString;
}

+ (FEEffectData*) dataFromPath:(NSString*)paramsFile glsl:(NSString *)glslFile
{
    FEEffectData *data = [[FEEffectData alloc] initWithPath:paramsFile glsl:glslFile];
    return data;
}

- (id) init
{
    if ((self = [super init]))
    {
        _pictures = [NSMutableArray array];
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
    // 根据配置，获取关键点传递给滤镜
    // 21点模式
    // 0:右边眉毛右
    // 1:右边眉毛中
    // 2:右边眉毛左
    
    // 3:左边眉毛右
    // 4:左边眉毛中
    // 5:左边眉毛左
    
    // 6:右边眼睛外眼角
    // 7:右边眼睛内眼角
    
    // 8:右边眼睛内眼角
    // 9:左边眼睛外眼角
    
    // 10:鼻翼右
    // 11:鼻子下
    // 12:鼻子左
    
    // 13:嘴唇上
    // 14:嘴中
    // 15:嘴唇下
    
    // 16:右眼中
    // 17:左眼中
    // 18:鼻尖
    // 19:嘴角右
    // 20:嘴角左
    
    NSMutableDictionary *face_points = [NSMutableDictionary dictionary];

    for (NSDictionary *dicPerson in arrPersons) {
        if ([dicPerson objectForKey:POINTS_KEY]) {
            NSArray *points = [dicPerson objectForKey:POINTS_KEY];
            // 21点
            NSArray *names = @[@"p_left",
                             @"p_right",
                             @"p_top",
                             @"p_bottom",
                             @"p_eyea",
                             @"p_eyeb",
                             @"p_nose",
                             @"p_faceleft",
                             @"p_faceright",
                             @"p_eyea_up",
                             @"p_eyea_down",
                             @"p_eyeb_up",
                             @"p_eyeb_down",
                             @"p_eyea_left",
                             @"p_eyea_right",
                             @"p_eyeb_left",
                             @"p_eyeb_right",
                               @"p_chin",
                               @"p_chin_left",
                               @"p_chin_right",
                               @"p_noseleg"];
#ifdef USE_FACE_TRACKER_106
            int pointsIndex[21] = {
                                    90,  // p_left
                                   84,  // p_right
                                   87,  // p_top
                                   93,  // p_bottom
                                   77,  // p_eyea
                                   74,  // p_eyeb
                                   46,  // p_nose
                                    5,  // p_faceleft
                                   27,  // p_faceright
                                   72,  // p_eyea_up
                                   73,  // p_eyea_down
                                   75,  // p_eyeb_up
                                   76,  // p_eyeb_down
                                   55,  // p_eyea_left
                                   52,  // p_eyea_right
                                   61,  // p_eyeb_left
                                    58,  // p_eyeb_right
                
                                    16, // p_chin
                                    19, // p_chin_left
                                    13, // p_chin_right
                                    43, // p_noseleg
            };
#else
            int pointsIndex[17] = {
                19,  // p_left
                20,  // p_right
                13,  // p_top
                15,  // p_bottom
                16,  // p_eyea
                17,  // p_eyeb
                18,  // p_nose
                10,  // p_faceleft
                12,  // p_faceright
                1,  // p_eyea_up
                16,  // p_eyea_down
                4,  // p_eyeb_up
                17,  // p_eyeb_down
                7,  // p_eyea_left
                6,  // p_eyea_right
                9,  // p_eyeb_left
                8  // p_eyeb_right
            };
#endif
            
            for (int i=0; i<[names count]; i++) {
                face_points[names[i]] = points[pointsIndex[i]];
            }
        }
        
        
    }
    
    [self setFacePoints:face_points];
}

- (void) setFacePoints:(NSDictionary*) facePoints
{
    [self.filter setFacePoints:facePoints];
}

- (void) setDetectValue:(CGFloat) detectValue
{
    [self.filter setDetectValue:detectValue];
}


@end
