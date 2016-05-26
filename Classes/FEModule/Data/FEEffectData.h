//
//  FEEffectData.h
//  FaceEffectDemo
//
//  Created by Viktor Pih on 16/3/29.
//  Copyright © 2016年 Viktor Pih. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FEEffectFilter.h"

@interface FEEffectData : NSObject

@property (nonatomic, readonly) FEEffectFilter *filter;

+ (FEEffectData*) dataFromPath:(NSString*)paramsName glsl:(NSString *)glslName;
- (id) initWithPath:(NSString*)paramsName glsl:(NSString *)glslName;

// 更新关键点，默认是106点，解析后会调用setFacePoints
- (void) setArrPersons:(NSArray*) arrPersons;

// 手动设置关键点
- (void) setFacePoints:(NSDictionary*) facePoints;

- (void) setDetectValue:(CGFloat) detectValue;

@end
