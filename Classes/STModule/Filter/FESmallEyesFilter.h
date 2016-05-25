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

@interface FESmallEyesFilter : GPUImageNInputFilter

//小眼需要
- (void) setCenterValue:(CGPoint) centerValue;
- (void) setFaceLeftValue:(CGPoint) leftValue;
- (void) setFaceRightValue:(CGPoint) rightValue;
- (void) setMouthValue:(CGPoint[]) mouthValue lenth:(GLsizei)length;
- (void) setEyesValue:(CGPoint[]) eyesValue lenth:(GLsizei)length leftOrRight:(BOOL)iFlag;

//贴图需要
- (void) setCentersValue:(CGPoint[]) centersValue lenth:(GLsizei)lenth;
- (void) setPointLeftValue:(CGPoint) pointLeftValue;
- (void) setPointRightValue:(CGPoint) pointRightValue;
- (void) setRatiosValue:(GLfloat[]) ratios length:(GLsizei)length;
- (void) setHeightRatiosValue:(GLfloat[]) heightRatios length:(GLsizei)length;
- (void) setRollValue:(NSInteger) rollValue;
- (void) setFullscreensValue:(int[]) ifullscreen length:(GLsizei)length;
- (void) setAlignPointValue:(CGPoint[]) alignPointValue lenth:(GLsizei)length;
- (void) setTriggersValue:(int[]) iTrigger length:(GLsizei)length;
- (void) setTriggerValue:(int) iTrigger;
@end
