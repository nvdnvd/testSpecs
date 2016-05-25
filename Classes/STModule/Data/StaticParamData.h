//
//  FEEffectData.h
//  FaceEffectDemo
//
//  Created by Viktor Pih on 16/3/29.
//  Copyright © 2016年 Viktor Pih. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FEPictureFilter.h"

@interface StaticParamData : NSObject
@property (nonatomic, readonly) FEPictureFilter *pictureFilter;
@property (nonatomic, strong) NSString *audioFileName;
@property (nonatomic, strong) NSString *tips;

//for debug
//@property (nonatomic, assign)NSInteger rollValue;
//@property (nonatomic, assign)CGFloat distanceValue;

+ (StaticParamData*) dataFromPath:(NSString*)paramsName glsl:(NSString *)glslName;
- (void) setupFromPath:(NSString*)paramsName glsl:(NSString *)glslName;

- (void) setArrPersons:(NSArray*) arrPersons;

- (void)updateFramePicture:(int)frameIndex;
- (void) removeFramePicture;
@end
