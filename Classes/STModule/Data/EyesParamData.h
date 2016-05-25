//
//  FEEffectData.h
//  FaceEffectDemo
//
//  Created by Viktor Pih on 16/3/29.
//  Copyright © 2016年 Viktor Pih. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FEEyesFilter.h"

@interface EyesParamData : NSObject
@property (nonatomic, readonly) FEEyesFilter *eyesFilter;
@property (nonatomic, strong) NSString *audioFileName;
- (id) init:(NSString *)glsl;
- (void) setArrPersons:(NSArray*) arrPersons;
//- (void) updateFramePicture:(int) index;
@end
