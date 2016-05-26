//
//  FEFaceDetect.m
//  FaceEffectDemo
//
//  Created by Viktor Pih on 16/3/26.
//  Copyright © 2016年 Viktor Pih. All rights reserved.
//

#import "FEFaceDetect.h"
#import "common.h"
//#include "arcsoft_faceoutline.h"
#import "arcsoft_spotlight.h"
#import "exp_recog.h"

#define LANDMARK_RADIUS 4
#define LANDMARK_COLOR 160

static int s_draw_pnt_NV12(uint8_t* plane0,uint8_t* plane1, int width, int height, int posx,int posy)
{
    MUInt32 pitch0 = width;
    MUInt32 pitch1 = width;
    
    for (int i = -LANDMARK_RADIUS; i < LANDMARK_RADIUS + 1; i++)
    {
        int endj = floor(sqrt(LANDMARK_RADIUS * LANDMARK_RADIUS - i * i));
        for (int j = -endj ; j < endj + 1; j++)
        {
            int newx = posx + j;
            int newy = posy + i;
            if (newx < 1 || newx > width - 2 || newy < 1 || newy > height - 2)
                continue;
            MUInt8 * pdata = plane0 + pitch0 * newy + newx;
            if (LANDMARK_COLOR == 1)
                *pdata = 144;
            else
                *pdata = 81;
            newx = (newx - newx%2)/2;
            newy = (newy - newy%2)/2;
            
            pdata = plane1 + pitch1 * newy + newx * 2;
            if (LANDMARK_COLOR == 1)
            {
                *pdata++ = 34;
                *pdata = 53;
            }
            else
            {
                *pdata++ = 90;
                *pdata = 240;
            }
        }
    }
    return 0;
}

@interface FEFaceDetect()
{
    MHandle m_hEngine;
}

//@property (nonatomic) cv_handle_t hTracker;

@end

@implementation FEFaceDetect

- (void)dealloc
{
    if(m_hEngine != MNull)
    {
        ASL_Uninitialize(m_hEngine);
        ASL_DestroyEngine(m_hEngine);
        m_hEngine = MNull;
    }

}

- (id) init
{
    if ((self = [super init]))
    {
        self.realtimeDetectFace = YES;
        m_hEngine = ASL_CreateEngine();
        if(m_hEngine != MNull)
        {
            MRESULT hRet = ASL_Initialize(m_hEngine,
                                          [[[NSBundle mainBundle] pathForResource:@"track_data" ofType:@"dat"] UTF8String],
                                          ASL_MAX_FACE_NUM,
                                          MNull,MNull);
            if(hRet == MOK)
            {
                ASL_SetProcessModel(m_hEngine,ASL_PROCESS_MODEL_FACEOUTLINE|ASL_PROCESS_MODEL_FACEBEAUTY);
                ASL_SetFaceSkinSoftenLevel(m_hEngine,50);
                ASL_SetFaceBrightLevel(m_hEngine,50);
            }
        }
    }
    return self;
}

- (void) processWithData:(uint8_t *) data1
                   data2:(uint8_t *) data2
                   width:(int) width
                  height:(int) height
                  format:(fs_pixel_format) format
                  stride:(int) stride
             orientation:(fs_face_orientation) orientation
             boundsWidth:(int) boundsWidth
            boundsHeight:(int) boundsHeight
                mirror:(BOOL) mirror
{
    if(m_hEngine == MNull)
        return;
    
    uint8_t *baseAddress0 = data1;
    uint8_t *baseAddress1 = data2;
    ASVLOFFSCREEN OffScreenIn = {0};
    OffScreenIn.u32PixelArrayFormat = ASVL_PAF_NV12;
    OffScreenIn.i32Width = width;
    OffScreenIn.i32Height = height;
    OffScreenIn.pi32Pitch[0] = OffScreenIn.i32Width;
    OffScreenIn.pi32Pitch[1] = OffScreenIn.i32Width;
    OffScreenIn.ppu8Plane[0] = data1;
    OffScreenIn.ppu8Plane[1] = data1 + OffScreenIn.i32Width * OffScreenIn.i32Height;
    
    MInt32 nFaceCountInOut = ASL_MAX_FACE_NUM;
    MRECT rcFaceRectOut[ASL_MAX_FACE_NUM];
    MFloat faceOrientOut[ASL_MAX_FACE_NUM * 3];
    MUInt32 nPointCount = ASL_GetFaceOutlinePointCount();
    MPOINT *pOutlinePoint = malloc(sizeof(MPOINT)*nPointCount);
    
    memset(pOutlinePoint, 0, sizeof(MPOINT) * nPointCount);
    
    NSMutableArray *arrPersons = [NSMutableArray array] ;
    NSMutableArray *arrStrPoints = [NSMutableArray array] ;
    
    MRESULT iRet = ASL_Process(m_hEngine,
                               &OffScreenIn,
                               MNull,
                               &nFaceCountInOut,
                               pOutlinePoint,
                               rcFaceRectOut,
                               faceOrientOut
                               );
    if(iRet == MOK)
    {
#ifdef EXTEND_KEY
        float kpts_x[101];
        float kpts_y[101];
        int extend_key_count = 25;
        float target_kpts_x[25] = {0};
        float target_kpts_y[25] = {0};
        float xy_angle=0.0f;
        float xyz_angle=0.0f;
        int blinkEyeResult = 0;
        int enlargeEyeResult = 0;
        int openedMouseResult = 0;
        int forwardMouseResult = 0;
        
        //char log1[1024];
        char log2[1024];
        char log3[1024];
        char log4[1024];
        char log5[1024];
        
        NSMutableArray *extendArrayStrPoints = [NSMutableArray array] ;
#endif
        
        for(int i = 0; i < nPointCount; i ++)
        {
        if (mirror) {
            CGPoint point = CGPointMake(1.0-1.0*pOutlinePoint[i].x/kVideoWidth, 1.0-1.0*pOutlinePoint[i].y/kVideoHeight);
            [arrStrPoints addObject:NSStringFromCGPoint(point)] ;
        } else
        {
            CGPoint point = CGPointMake(1.0*pOutlinePoint[i].x/kVideoWidth, 1.0-1.0*pOutlinePoint[i].y/kVideoHeight);
            [arrStrPoints addObject:NSStringFromCGPoint(point)] ;
        }
            
#ifdef EXTEND_KEY
            kpts_x[i] = pOutlinePoint[i].x;
            kpts_y[i] = pOutlinePoint[i].y;
#endif
        }
        
#if 0
        // draw face outline point
        {
            for(int i=0;i<nPointCount;i++)
            {
                s_draw_pnt_NV12(baseAddress0,baseAddress1,(MUInt32)width,(MUInt32)height,pOutlinePoint[i].x,pOutlinePoint[i].y);
            }
        }
#endif
        
        float tmpRoll = 0;
        if(mirror)
        {
            tmpRoll = -faceOrientOut[0]-90;
        }
        else
        {
            tmpRoll = faceOrientOut[0]-180.0;
        }
        
        NSNumber *roll = [NSNumber numberWithFloat:tmpRoll];
        
        // To decide whether mirror the rect or not.
        NSMutableDictionary *dicPerson = [NSMutableDictionary dictionary] ;
        [dicPerson setObject:arrStrPoints forKey:POINTS_KEY];
        [dicPerson setObject:roll forKey:ROLL_KEY];
        
#ifdef EXTEND_KEY
        if(faceOrientOut[1]>-5.0&&(faceOrientOut[1]<5.0)&&(faceOrientOut[2]<10.0)&&(faceOrientOut[2]>-10.0))
        {
        blink_eye_detection(kpts_x, kpts_y, 101, &blinkEyeResult, log2, 1024);
        enlarged_eye_detection(kpts_x, kpts_y, 101, &enlargeEyeResult, log3, 1024);
        opened_mouse_detection(kpts_x, kpts_y, 101, &openedMouseResult, log4, 1024);
        forward_mouse_detection(kpts_x, kpts_y, 101, &forwardMouseResult, log5, 1024);
        
        for(int i = 0; i < extend_key_count; i ++) {
            CGPoint point = CGPointMake(target_kpts_x[i]/kVideoWidth,target_kpts_y[i]/kVideoHeight);
            [extendArrayStrPoints addObject:NSStringFromCGPoint(point)] ;
        }
        
        //NSLog(@"[blink,enlarge,open,forword]=[%d,%d,%d,%d]",blinkEyeResult,enlargeEyeResult,openedMouseResult,forwardMouseResult);
        //NSLog(@"log3=%s",log3);
        [dicPerson setObject:[NSNumber numberWithInt:blinkEyeResult] forKey:BLINK_EYE_KEY];
        [dicPerson setObject:[NSNumber numberWithInt:enlargeEyeResult] forKey:ENLARGE_EYE_KEY];
        [dicPerson setObject:[NSNumber numberWithInt:openedMouseResult] forKey:OPEN_MOUTH_KEY];
        [dicPerson setObject:[NSNumber numberWithInt:forwardMouseResult] forKey:FORWORD_MOUTH_KEY];
        [dicPerson setObject:extendArrayStrPoints forKey:EXTEND_POINT_KEY];
        }
#endif
        
        [arrPersons addObject:dicPerson] ;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.callbackBlock)
            {
                self.callbackBlock(arrPersons);
            }
        } ) ;
        
        if(self.callbackBlock2)
        {
            self.callbackBlock2(arrPersons);
        }
    }
    
    if(pOutlinePoint!=nil)
    {
        free(pOutlinePoint);
        pOutlinePoint = nil;
    }
}

#pragma mark -
#pragma mark - GPUImageVideoCameraDelegate

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    static BOOL detectFace = YES;
    
    if (detectFace)
    {
        // 如果想在人脸监测未完成时，实时监测人脸，不跳帧处理，则注释这句。但会增加内存拷贝次数
        detectFace = NO;
        CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        
        int iWidth  = (int)CVPixelBufferGetWidth(pixelBuffer);
        int iHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
        int stride = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
        //NSLog(@"stride=%d",stride);
        OSType formatType = CVPixelBufferGetPixelFormatType(pixelBuffer);
        fs_pixel_format format;
        uint8_t *baseAddress0;
        uint8_t *baseAddress1;
        
        switch (formatType) {
            case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange:
                format = FS_PIX_FMT_GRAY8; // CV_PIX_FMT_NV12
                baseAddress0 = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
                baseAddress1 = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
                break;
            case kCVPixelFormatType_32BGRA:
                format = FS_PIX_FMT_BGRA8888;
                baseAddress0 = CVPixelBufferGetBaseAddress(pixelBuffer);
                break;
            default:
                assert(!"不支持其他格式");
                break;
        }
        
        fs_face_orientation orientation = FS_FACE_LEFT;
        
        // 方向
        int iDeviceOrientation = [[UIDevice currentDevice]orientation];
        
        //     double t0 = CFAbsoluteTimeGetCurrent();
        
        //NSLog(@"%d",iDeviceOrientation);
        switch (iDeviceOrientation) {
            case UIDeviceOrientationPortrait://home键向下
            {
                orientation = FS_FACE_LEFT;
                break;
            }
            case UIDeviceOrientationPortraitUpsideDown://home键向上
            {
                orientation = FS_FACE_RIGHT;
                break;
            }
            case UIDeviceOrientationLandscapeLeft://home键向Right
            {
                orientation = FS_FACE_DOWN;
                break;
            }
            case UIDeviceOrientationLandscapeRight://home键向左
            {
                orientation = FS_FACE_UP;
                break;
            }
        };
        
        orientation = FS_FACE_UP;
        
        // 检查是否需要水平翻转
        BOOL mirror = NO;
        AVCaptureDevicePosition position = AVCaptureDevicePositionFront;
        for (id input in [self.captureSession inputs]) {
            if ([input isKindOfClass:[AVCaptureDeviceInput class]])
            {
                AVCaptureDeviceInput *deviceInput = input;
                if ([[deviceInput device] hasMediaType:AVMediaTypeVideo])
                {
                    position = [[deviceInput device] position];
                }
            }
        }
        
        if (position == AVCaptureDevicePositionFront) {
            mirror = YES;
        }
        
        // 计算尺寸
        int boundsWidth;
        int boundsHeight;
        if (self.sessionPreset == AVCaptureSessionPreset1280x720) {
            boundsWidth = 720;
            boundsHeight = 1280;
        } else if (self.sessionPreset == AVCaptureSessionPreset640x480) {
            boundsWidth = 480;
            boundsHeight = 640;
        } else if (self.sessionPreset == AVCaptureSessionPreset352x288) {
            boundsWidth = 288;
            boundsHeight = 352;
        } else {
            boundsWidth = 480;
            boundsHeight = 640;
        }
        
        if (self.realtimeDetectFace)
        {
            // 实时处理
            [self processWithData:baseAddress0 data2:baseAddress1 width:iWidth height:iHeight format:format stride:stride orientation:orientation boundsWidth:boundsWidth boundsHeight:boundsHeight mirror:mirror];
            
            detectFace = YES;
        }
        else
        {
            /*
            size_t dataSize = CVPixelBufferGetDataSize(pixelBuffer);
            
            static uint8_t *frameBuffer =NULL;
            if (frameBuffer == NULL) frameBuffer = (uint8_t*)malloc(dataSize);
            memcpy(frameBuffer, baseAddress, dataSize);
            
            // 异步处理人脸，防卡顿
            [_operationQueue cancelAllOperations];
            [_operationQueue addOperationWithBlock:^{
                
                //CFAbsoluteTime old_time = CFAbsoluteTimeGetCurrent();
                
                [self processWithData:frameBuffer width:iWidth height:iHeight format:format stride:stride orientation:orientation boundsWidth:boundsWidth boundsHeight:boundsHeight mirror:mirror];
                // 处理完成，开启对下一帧的获取
                detectFace = YES;
                
#ifdef DEBUG
                double time = CFAbsoluteTimeGetCurrent() - old_time;
                NSLog(@"用时 %f", time);
#endif
//
//                static float mFpsTime = 0;
//                static long mFpsCount = 0;
//                mFpsCount ++;
//                mFpsTime += time;
//                float fps = mFpsCount/mFpsTime;
//                
//                NSLog(@"count: %ld time: %f fps: %f", mFpsCount, mFpsTime, fps);
            }];
            
           */
        }
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    }
}

@end
