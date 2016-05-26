//
//  GPUImage+Fix.m
//  VideoBlendTest
//
//  Created by iviktor on 15/7/15.
//  Copyright (c) 2015年 iviktor. All rights reserved.
//

#import "GPUImage+Fix.h"
#import "GPUImage.h"
#import <objc/runtime.h>

//@implementation GPUImageFramebuffer (Custom)
//
//static char kReferenceCountKey;
//
//- (void)setReferenceCount:(NSInteger)referenceCount
//{
//    objc_setAssociatedObject(self, &kReferenceCountKey, [NSNumber numberWithInteger:referenceCount], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (NSInteger)referenceCount
//{
//    return [objc_getAssociatedObject(self, &kReferenceCountKey) integerValue];
//}
//
//+ (void)load {
//    
//    method_exchangeImplementations(class_getInstanceMethod(self, @selector(lock)),
//                                   class_getInstanceMethod(self, @selector(swizzle_lock)));
//    method_exchangeImplementations(class_getInstanceMethod(self, @selector(unlock)),
//                                   class_getInstanceMethod(self, @selector(swizzle_unlock)));
//}
//
//- (void)swizzle_lock;
//{
//    [self swizzle_lock];
//    [self setReferenceCount:[self referenceCount]+1];
//}
//
//- (void)swizzle_unlock;
//{
//    [self swizzle_unlock];
//    [self setReferenceCount:[self referenceCount]-1];
//}
//
//@end
//
//
//@interface GPUImageMovie(Private)
//
//- (void)convertYUVToRGBOutput;
//
//@end
//
//@implementation GPUImageMovie (Custom)
//
//+ (void)load {
//    
//    method_exchangeImplementations(class_getInstanceMethod(self, @selector(convertYUVToRGBOutput)),
//                                   class_getInstanceMethod(self, @selector(swizzle_convertYUVToRGBOutput)));
//}
//
//- (void)swizzle_convertYUVToRGBOutput;
//{
//    if (outputFramebuffer != nil && [outputFramebuffer referenceCount] != 0)
//    {
//        //NSLog(@"This framebuffer didn't unlock and set nil yet!");
//        [outputFramebuffer unlock];
//    }
//    return [self swizzle_convertYUVToRGBOutput];
//}
//
//@end

//@implementation GPUImageRawDataOutput(Private)
//
//static char kRawBytesKey;
//
//- (void)setRawBytes:(GLbyte*)rawBytes
//{
//    NSMutableData
//    objc_setAssociatedObject(self, &kRawBytesKey, [NSNumber numberWithInt:(int*)rawBytes], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (NSInteger)referenceCount
//{
//    return [objc_getAssociatedObject(self, &kReferenceCountKey) integerValue];
//}
//
//+ (void)load {
//
//    method_exchangeImplementations(class_getInstanceMethod(self, @selector(lock)),
//                                   class_getInstanceMethod(self, @selector(swizzle_lock)));
//    method_exchangeImplementations(class_getInstanceMethod(self, @selector(unlock)),
//                                   class_getInstanceMethod(self, @selector(swizzle_unlock)));
//}
//
//
//+ (void)load {
//    
//    method_exchangeImplementations(class_getInstanceMethod(self, @selector(rawBytesForImage)),
//                                   class_getInstanceMethod(self, @selector(swizzle_rawBytesForImage)));
//}
//
//- (GLubyte *)swizzle_rawBytesForImage;
//{
//    //if ( (_rawBytesForImage == NULL) && (![GPUImageContext supportsFastTextureUpload]) )
//    if ( _rawBytesForImage == NULL )
//    {
//        _rawBytesForImage = (GLubyte *) calloc(imageSize.width * imageSize.height * 4, sizeof(GLubyte));
//        hasReadFromTheCurrentFrame = NO;
//    }
//    
//    if (hasReadFromTheCurrentFrame)
//    {
//        return _rawBytesForImage;
//    }
//    else
//    {
//        runSynchronouslyOnVideoProcessingQueue(^{
//            // Note: the fast texture caches speed up 640x480 frame reads from 9.6 ms to 3.1 ms on iPhone 4S
//            
//            [GPUImageContext useImageProcessingContext];
//            [self renderAtInternalSize];
//            
//            /*
//             if ([GPUImageContext supportsFastTextureUpload])
//             {
//             glFinish();
//             _rawBytesForImage = [outputFramebuffer byteBuffer];
//             }
//             else*/
//            {
//                //glReadPixels(0, 0, imageSize.width, imageSize.height, GL_RGBA, GL_UNSIGNED_BYTE, _rawBytesForImage);
//                glReadPixels(0, 0, imageSize.width, imageSize.height, GL_BGRA, GL_UNSIGNED_BYTE, _rawBytesForImage);
//                
//                // GL_EXT_read_format_bgra
//                //            glReadPixels(0, 0, imageSize.width, imageSize.height, GL_BGRA_EXT, GL_UNSIGNED_BYTE, _rawBytesForImage);
//            }
//            
//            hasReadFromTheCurrentFrame = YES;
//            
//        });
//        
//        return _rawBytesForImage;
//    }
//}
//
//@end
//
