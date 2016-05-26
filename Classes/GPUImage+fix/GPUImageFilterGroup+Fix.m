//
//  GPUImageFilterGroup+Fix.m
//  VideoBlendTest
//
//  Created by iviktor on 15/10/22.
//  Copyright © 2015年 iviktor. All rights reserved.
//

#import "GPUImageFilterGroup+Fix.h"
#import <objc/runtime.h>

@implementation GPUImageFilterGroup (Fix)

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

@end
