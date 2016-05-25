//
//  Utility.h
//  Perfect Chat
//
//  Created by jhzheng on 14-11-28.
//  Copyright (c) 2014年 arcsoft. All rights reserved.
//

#ifndef __UTILITY_H__
#define __UTILITY_H__

#include "asvloffscreen.h"

#define     AE_RET_SUCCESS                              0
#define     AE_RET_UNSUPPORT_PIXELS_FORMAT              -1
#define     AE_RET_PROCESS_FAILED                       -2
#define     AE_RET_MEMORY_ERROR                         -3
#define     AE_RET_TEMPLATE_LOAD_FAILED                 -4
#define     AE_RET_INTERNAL_ERROR                       -5
#define     AE_RET_UNKNOWN_ERROR                        -6

#define     AE_RET_TRIGGER_SUCCESS                      0
#define     AE_RET_TRIGGER_FAILED                       -100
#define     AE_RET_TRIGGER_FAILED_NO_TRIGGER            -102
#define     AE_RET_TRIGGER_FAILED_CONDITION             -103


#define AE_IMAGE_FORMAT_INVALID     0x0000
#define AE_IMAGE_FORMAT_NV12        0x0001 // for IOS Camera input
#define AE_IMAGE_FORMAT_NV21        0x0002 // for Android Camera input
#define AE_IMAGE_FORMAT_I420        0x0004
#define AE_IMAGE_FORMAT_A8R8G8B8    0X0008

extern MRESULT  ColorRGBA2FormatData(MByte* pDataSrc,MByte* pDataDst,MInt32 width,MInt32 height,MWord format);
//extern MRESULT  ColorFormatData2RGBA(MByte* pDataSrc,MByte* pDataDst,MInt32 width,MInt32 height,MWord format);
extern MInt32   mcvColorRGBA8888toNV12ByRegionu8_H(LPASVLOFFSCREEN srcImg,LPASVLOFFSCREEN dstImg,MUInt32 offsetX,MUInt32 offsetY,MByte* pMask);
extern MInt32   mcvColorNV12toRGBA8888ByRegionu8_H(LPASVLOFFSCREEN srcImg,LPASVLOFFSCREEN dstImg, MUInt32 offsetX,MUInt32 offsetY,MUInt8 alpha);
extern MInt32   mcvColorNV21toRGBA8888ByRegionu8_H(LPASVLOFFSCREEN srcImg,LPASVLOFFSCREEN dstImg, MUInt32 offsetX,MUInt32 offsetY,MUInt8 alpha);
extern MInt32   mcvColorRGBA8888toNV21ByRegionu8_H(LPASVLOFFSCREEN srcImg,LPASVLOFFSCREEN dstImg,MUInt32 offsetX,MUInt32 offsetY,MByte* pMask);
extern MInt32 mcvResizeRGBA8888Bilinear(MUInt16 *plTmpBuf,MInt32 buflength,
                                 MUInt8 *pSrc, MInt32 lSrcWidth, MInt32 lSrcHeight,
                                 MInt32 lSrcStride, MUInt8 *pDst,
                                 MInt32 lDstWidth, MInt32 lDstHeight, MInt32 lDstStride);

#ifdef __cplusplus
extern "C" {
#endif
    extern MRESULT  ColorFormatData2RGBA(MByte* pDataSrc,MByte* pDataDst,MInt32 width,MInt32 height,MWord format);
    extern int s_draw_pnt_NV12(MByte* pimg, MUInt32 width, MUInt32 height, MPOINT pnt);
    extern int s_draw_pnt_BGRA(MByte* pimg, MUInt32 width, MUInt32 height,MPOINT pnt,MByte r,MByte g,MByte b);
#ifdef __cplusplus
}
#endif

#endif