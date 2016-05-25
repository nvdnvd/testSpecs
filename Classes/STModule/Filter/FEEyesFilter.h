//
//  FEEyesFilter.h
//  FaceEffectDemo
//
//  Created by Viktor Pih on 16/3/29.
//  Copyright © 2016年 Viktor Pih. All rights reserved.
//

//#import "GPUImage+Fix.h"
#import "GPUImageNInputFilter.h"

// 应该扩展为支持N个纹理的滤镜

@interface FEEyesFilter : GPUImageNInputFilter

//- (void) setFacePoints:(NSDictionary*) facePoints;
- (void) setCenterValue:(CGPoint) centerValue;
- (void) setFaceLeftValue:(CGPoint) leftValue;
- (void) setFaceRightValue:(CGPoint) rightValue;
- (void) setRollValue:(NSInteger) rollValue;
- (void) setEyesValue:(CGPoint[]) eyesValue lenth:(GLsizei)length leftOrRight:(BOOL)iFlag;
@end
