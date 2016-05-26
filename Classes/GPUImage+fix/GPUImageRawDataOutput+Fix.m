//
//  GPUImageRawDataOutput+Fix.m
//  VideoBlendTest
//
//  Created by iviktor on 15/10/21.
//  Copyright © 2015年 iviktor. All rights reserved.
//

#import "GPUImageRawDataOutput+Fix.h"
#import <objc/runtime.h>

@implementation GPUImageRawDataOutput (Fix)

static char kIsEndProcessingKey;
static char kTargetKey;

- (void)setIsEndProcessing:(BOOL) isEndProcessing
{
    objc_setAssociatedObject(self, &kIsEndProcessingKey, [NSNumber numberWithBool:isEndProcessing], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isEndProcessing
{
    return [objc_getAssociatedObject(self, &kIsEndProcessingKey) boolValue];
}

- (void)setTarget:(id<GPUImageInput>) target
{
    objc_setAssociatedObject(self, &kTargetKey, target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<GPUImageInput>)target
{
    return objc_getAssociatedObject(self, &kTargetKey);
}

static char kLastFrameTime;
//static char kLastTextureIndex;

- (void) setLastFrameTime:(CMTime)frameTime
{
    NSValue *value = [NSValue valueWithBytes:&frameTime objCType:@encode(CMTime)];
    objc_setAssociatedObject(self, &kLastFrameTime, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CMTime) lastFrameTime
{
    NSValue *value = objc_getAssociatedObject(self, &kLastFrameTime);
    
    if (value == nil)
        return kCMTimeInvalid;
    
    CMTime frameTime;
    [value getValue:&frameTime];
    return frameTime;
}
/*
- (void) setLastTextureIndex:(NSInteger) textureIndex
{
    objc_setAssociatedObject(self, &kLastTextureIndex, [NSNumber numberWithInteger:textureIndex], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger) lastTextureIndex
{
    return [objc_getAssociatedObject(self, &kLastTextureIndex) integerValue];
}*/


+ (void)load {

    method_exchangeImplementations(class_getInstanceMethod(self, @selector(endProcessing)),
                                   class_getInstanceMethod(self, @selector(swizzle_endProcessing)));
    
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(newFrameReadyAtTime:atIndex:)),
                                   class_getInstanceMethod(self, @selector(swizzle_newFrameReadyAtTime:atIndex:)));
}

- (void)swizzle_endProcessing;
{
    if (!self.isEndProcessing)
    {
        self.isEndProcessing = YES;
        
        [self.target endProcessing];
    }
}

- (void)swizzle_newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex
{
    self.lastFrameTime = frameTime;
    //self.lastTextureIndex = textureIndex;
    
    [self swizzle_newFrameReadyAtTime:frameTime atIndex:textureIndex];
}


@end
