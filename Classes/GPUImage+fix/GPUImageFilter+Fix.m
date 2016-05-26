//
//  GPUImageFilter+Fix.m
//  LTBRender
//
//  Created by iviktor on 15/8/24.
//  Copyright (c) 2015年 Viktor Pih. All rights reserved.
//

#import "GPUImageFilter+Fix.h"
#import <objc/runtime.h>

@implementation GPUImageFilter (Fix)

+ (void)load {
    
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(newFrameReadyAtTime:atIndex:)),
                                   class_getInstanceMethod(self, @selector(swizzle_newFrameReadyAtTime:atIndex:)));
}

// 修复滤镜重复使用导致的 endProcessing 无法回调的BUG
- (void)swizzle_newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex
{
    isEndProcessing = NO;
    
    [self swizzle_newFrameReadyAtTime:frameTime atIndex:textureIndex];
}

#if 1
- (void)setIntArray:(int *)arrayValue length:(GLsizei)arrayLength forUniform:(GLint)uniform program:(GLProgram *)shaderProgram
{
    // Make a copy of the data, so it doesn't get overwritten before async call executes
    NSData* arrayData = [NSData dataWithBytes:arrayValue length:arrayLength * sizeof(arrayValue[0])];
    
    runAsynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext setActiveShaderProgram:shaderProgram];
        
        [self setAndExecuteUniformStateCallbackAtIndex:uniform forProgram:shaderProgram toBlock:^{
            
            //glUniform1fv(uniform, arrayLength, [arrayData bytes]);
            glUniform1iv(uniform, arrayLength, [arrayData bytes]);
        }];
    });
}

- (void)setPointArray:(float[])pointValue length:(GLsizei)arrayLength forUniform:(GLint)uniform program:(GLProgram *)shaderProgram;
{
    NSData* arrayData = [NSData dataWithBytes:pointValue length:arrayLength * sizeof(pointValue[0])];
    
    runAsynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext setActiveShaderProgram:shaderProgram];
        [self setAndExecuteUniformStateCallbackAtIndex:uniform forProgram:shaderProgram toBlock:^{
            glUniform2fv(uniform, arrayLength/2, [arrayData bytes]);
        }];
    });
}
#endif
@end
