//
//  GPUImageRawDataInput+Fix.m
//  VideoBlendTest
//
//  Created by iviktor on 15/10/22.
//  Copyright © 2015年 iviktor. All rights reserved.
//

#import "GPUImageRawDataInput+Fix.h"

@implementation GPUImageRawDataInput (Fix)

- (void)processDataAtTime:(CMTime)frameTime
{
    if (dispatch_semaphore_wait(dataUpdateSemaphore, DISPATCH_TIME_NOW) != 0)
    {
        return;
    }
    
    runAsynchronouslyOnVideoProcessingQueue(^{
        
        CGSize pixelSizeOfImage = [self outputImageSize];
        
        for (id<GPUImageInput> currentTarget in targets)
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            
            [currentTarget setInputSize:pixelSizeOfImage atIndex:textureIndexOfTarget];
            [currentTarget setInputFramebuffer:outputFramebuffer atIndex:textureIndexOfTarget];
            [currentTarget newFrameReadyAtTime:frameTime atIndex:textureIndexOfTarget];
        }
        
        dispatch_semaphore_signal(dataUpdateSemaphore);
    });
}

@end
