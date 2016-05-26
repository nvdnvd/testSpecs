//
//  GPUImageFilter+Fix.h
//  LTBRender
//
//  Created by iviktor on 15/8/24.
//  Copyright (c) 2015年 Viktor Pih. All rights reserved.
//

#import "GPUImage.h"

@interface GPUImageFilter (Fix)
- (void)setIntArray:(int *)arrayValue length:(GLsizei)arrayLength forUniform:(GLint)uniform program:(GLProgram *)shaderProgram;
- (void)setPointArray:(float[])pointValue length:(GLsizei)arrayLength forUniform:(GLint)uniform program:(GLProgram *)shaderProgram;
@end
