//
//  FEEffectFilter.h
//  FaceEffectDemo
//
//  Created by Viktor Pih on 16/3/29.
//  Copyright © 2016年 Viktor Pih. All rights reserved.
//

#import "GPUImageNInputFilter.h"

// 应该扩展为支持N个纹理的滤镜

@interface FEEffectFilter : GPUImageNInputFilter

- (void) setFacePoints:(NSDictionary*) facePoints;
- (void) setDetectValue:(CGFloat) detectValue;

@end
