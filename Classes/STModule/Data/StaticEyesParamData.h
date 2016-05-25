//
//  FEEffectData.h
//  FaceEffectDemo
//
//  Created by Viktor Pih on 16/3/29.
//  Copyright © 2016年 Viktor Pih. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FESmallEyesFilter.h"

@interface StaticEyesParamData : NSObject
@property (nonatomic, readonly) FESmallEyesFilter *smallEyesFilter;
@property (nonatomic, strong) NSString *audioFileName;
@property (nonatomic, strong) NSString *tips;

+ (StaticEyesParamData*) dataFromPath:(NSString*)paramsName glsl:(NSString *)glslName;
- (void) setupFromPath:(NSString*)paramsName glsl:(NSString *)glslName;

- (void) setArrPersons:(NSArray*) arrPersons;

- (void) updateFramePicture:(int) index;
- (void) removeFramePicture;
@end
