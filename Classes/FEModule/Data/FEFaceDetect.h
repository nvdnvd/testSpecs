//
//  FEFaceDetect.h
//  FaceEffectDemo
//
//  Created by Viktor Pih on 16/3/26.
//  Copyright © 2016年 Viktor Pih. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage+Fix.h"
//#import "cv_face.h"

// 使用106点检测，禁用的同时需要替换库文件
//#define USE_FACE_TRACKER_106

/// cv pixel format definition
typedef enum {
    FS_PIX_FMT_GRAY8,	///< Y    1        8bpp ( 单通道8bit灰度像素 )
    FS_PIX_FMT_YUV420P,	///< YUV  4:2:0   12bpp ( 3通道, 一个亮度通道, 另两个为U分量和V分量通道, 所有通道都是连续的 )
    FS_PIX_FMT_NV12,	///< YUV  4:2:0   12bpp ( 2通道, 一个通道是连续的亮度通道, 另一通道为UV分量交错 )
    FS_PIX_FMT_NV21,	///< YUV  4:2:0   12bpp ( 2通道, 一个通道是连续的亮度通道, 另一通道为VU分量交错 )
    FS_PIX_FMT_BGRA8888,	///< BGRA 8:8:8:8 32bpp ( 4通道32bit BGRA 像素 )
    FS_PIX_FMT_BGR888	///< BGR  8:8:8   24bpp ( 3通道24bit BGR 像素 )
}fs_pixel_format;


/// @brief  人脸朝向
typedef enum {
    FS_FACE_UP = 0,		///< 人脸向上，即人脸朝向正常
    FS_FACE_LEFT = 1,	///< 人脸向左，即人脸被逆时针旋转了90度
    FS_FACE_DOWN = 2,	///< 人脸向下，即人脸被逆时针旋转了180度
    FS_FACE_RIGHT = 3	///< 人脸向右，即人脸被逆时针旋转了270度
} fs_face_orientation;

@interface FEFaceDetect : NSObject <GPUImageVideoCameraDelegate>

// 回调，返回检测到的点，没有则返回空数组
@property (nonatomic,copy) void(^callbackBlock)(NSArray *arrPersons);

@property (nonatomic,copy) void(^callbackBlock2)(NSArray *arrPersons);

// 实时检测人脸，不开启会有拖拽感。开启的话，4s卡顿比较严重。default = YES
@property (nonatomic) BOOL realtimeDetectFace;

// 用来检测设备方向之类
@property (nonatomic, weak) AVCaptureSession *captureSession;

// 判断输入视频的尺寸
@property(nonatomic, copy) NSString *sessionPreset;

// 提供外部处理的接口，手动检测照片之类，同样callbackBlock回调
- (void) processWithData:(uint8_t *) data1
                   data2:(uint8_t *) data2
                   width:(int) width
                  height:(int) height
                  format:(fs_pixel_format) format
                  stride:(int) stride
             orientation:(fs_face_orientation) orientation
             boundsWidth:(int) boundsWidth
            boundsHeight:(int) boundsHeight
                  mirror:(BOOL) mirror;

@end
