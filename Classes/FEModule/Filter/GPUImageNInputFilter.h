//
//  GPUImageNInputFilter.h
//  FaceEffectDemo
//
//  Created by Viktor Pih on 16/3/31.
//  Copyright © 2016年 Viktor Pih. All rights reserved.
//

#import "GPUImage+Fix.h"



@interface GPUImageNInputFilter : GPUImageFilter
{
    
}

- (id) initWithInputNumber:(NSInteger) inputNumber fragmentShaderFromString:(NSString *)fragmentShaderString;
- (id) initWithInputNumber:(NSInteger) inputNumber fragmentShaderFromString:(NSString *)fragmentShaderString extendVertexShaderFromString:(NSString*) extendVertexShaderString;
- (id) initWithInputNumber:(NSInteger) inputNumber vertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString;

- (void)disableFrameCheckAtIndex:(NSInteger) index;

@end
