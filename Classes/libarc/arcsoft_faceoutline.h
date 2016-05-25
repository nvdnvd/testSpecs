/*******************************************************************************
 Copyright(c) ArcSoft, All right reserved.
 
 This file is ArcSoft's property. It contains ArcSoft's trade secret, proprietary
 and confidential information.
 
 The information and code contained in this file is only for authorized ArcSoft
 employees to design, create, modify, or review.
 
 DO NOT DISTRIBUTE, DO NOT DUPLICATE OR TRANSMIT IN ANY FORM WITHOUT PROPER
 AUTHORIZATION.
 
 If you are not an intended recipient of this file, you must not copy,
 distribute, modify, or take any action in reliance on it.
 
 If you have received this file in error, please immediately notify ArcSoft and
 permanently delete the original and any copy of any file and any printout
 thereof.
 *******************************************************************************/

#ifndef     _ARCSOFT_FACEOUTLINE_H_
#define     _ARCSOFT_FACEOUTLINE_H_

#ifdef __cplusplus
extern "C" {
#endif
    
#include "amcomdef.h"
    
#define AFOT_IMAGE_FORMAT_YUYV      1
#define AFOT_IMAGE_FORMAT_NV21      2
#define AFOT_IMAGE_FORMAT_NV12      3
#define AFOT_IMAGE_FORMAT_BGRA32    4
#define AFOT_IMAGE_FORMAT_RGBA32    5
    
#define AFOT_RESULT_CODE_SUCCESS         0
#define AFOT_RESULT_CODE_FAILED          -1
#define AFOT_RESULT_CODE_UNSUPPORTFORMAT -2
#define AFOT_RESULT_CODE_IMAGEINFOERROR  -3
#define AFOT_RESULT_CODE_BUNDLEID_ERROR  -4   
        
typedef MPVoid  HANDLE_AFOT;
    
typedef struct
{
    MInt32 lCodebase;			// Codebase version number
    MInt32 lMajor;				// major version number
    MInt32 lMinor;				// minor version number
    MInt32 lBuild;				// Build version number, increasable only
    const MChar Version[80];		// version in string form
    const MChar BuildDate[40];	// latest build Date
    const MChar CopyRight[80];	// copyright
} AFOT_VERSION;
    
HANDLE_AFOT     AFOT_CreateEngine();
MVoid           AFOT_DestroyEngine(HANDLE_AFOT hHandle);
    
MRESULT         AFOT_InitialEngine(HANDLE_AFOT hHandle,const MChar* szTrackDataPath);
MRESULT         AFOT_UninitialEngine(HANDLE_AFOT hHandle);

MUInt32         AFOT_GetOutlinePointCount(HANDLE_AFOT hHandle);
    
MRESULT         AFOT_TrackFaceOutline(HANDLE_AFOT hHandle,
                                     MByte* pImageData,
                                     MUInt32 nImageWidth,MUInt32 nImageHeight,
                                     MUInt32 nImageFormat,
                                     MPOINT* pOutlinePoint,
                                     MRECT*  pFaceRect,
                                     MFloat* pFaceOrient
                                     );

const AFOT_VERSION* AFOT_GetVersion();
    
#ifdef __cplusplus
}

#endif

#endif

