//
//  FEEffectData.m
//  FaceEffectDemo
//
//  Created by Viktor Pih on 16/3/29.
//  Copyright © 2016年 Viktor Pih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EyesParamData.h"
#import "common.h"

#define ARRAY_LENTH 10

@interface EyesParamData()
{
}
@property (nonatomic, strong)FEEyesFilter *eyesFilter;
@end
@implementation EyesParamData
- (id) init:(NSString *)glsl
{
    if ((self = [super init]))
    {
        //self.eyesFilter = [FEEyesFilter new];
        NSURL *glslURL = [[NSBundle mainBundle] URLForResource:glsl withExtension:@""];
        NSData *data = [NSData dataWithContentsOfURL:glslURL];
        NSString *glslString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSString *tmp = [glslString1 stringByReplacingOccurrencesOfString:@"size_to_be_replaced" withString:@"1"];
        
        //NSLog(@"tmp=%@",tmp);
        //if(self.eyesFilter == nil)
        {
            //NSLog(@"glslString1=%@",glslString1);
            self.eyesFilter = [[FEEyesFilter alloc] initWithInputNumber:2 fragmentShaderFromString:glslString];
            GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"eyes_small_icon.png"]];
            // 加载图片
            [pic addTarget:self.eyesFilter atTextureLocation:1];
            [pic processImage];
        }
    }
    return self;
}

- (void) setArrPersons:(NSArray*) arrPersons
{
    //NSMutableDictionary *face_points = [NSMutableDictionary dictionary];
    NSInteger roll = 0;
    CGPoint centerPoint = CGPointZero;
    CGPoint leftFacePoint = CGPointZero;
    CGPoint rightFacePoint = CGPointZero;
    CGPoint eyesA[12];
    CGPoint eyesB[12];
    
    
    
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
        if ([dicPerson objectForKey:ROLL_KEY]) {
            roll = [[dicPerson objectForKey:ROLL_KEY] integerValue];
        }
    }
    
    [self.eyesFilter setCenterValue:centerPoint];
    [self.eyesFilter setRollValue:roll];
    [self.eyesFilter setFaceLeftValue:leftFacePoint];
    [self.eyesFilter setFaceRightValue:rightFacePoint];
    [self.eyesFilter setEyesValue:eyesA lenth:12 leftOrRight:YES];
    [self.eyesFilter setEyesValue:eyesB lenth:12 leftOrRight:NO];
}

@end
