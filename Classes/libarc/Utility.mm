//
//  Utility.mm
//  Perfect Chat
//
//  Created by jhzheng on 14-11-28.
//  Copyright (c) 2014年 arcsoft. All rights reserved.
//

#include "Utility.h"
#include "merror.h"
#include <math.h>

MRESULT ColorRGBA2FormatData(MByte* pDataSrc,MByte* pDataDst,MInt32 width,MInt32 height,MWord format)
{
    if(pDataDst == MNull || pDataSrc == MNull)
        return AE_RET_MEMORY_ERROR;
    
    MInt32 plWidth = width;
    MInt32 plHeight = height;
    
    ASVLOFFSCREEN srcImg = {0};
    if(format == AE_IMAGE_FORMAT_NV12
       || format == AE_IMAGE_FORMAT_NV21
       )
    {
        srcImg.i32Width = plWidth;
        srcImg.i32Height = plHeight;
        srcImg.u32PixelArrayFormat = (format == AE_IMAGE_FORMAT_NV12) ? ASVL_PAF_NV12 : ASVL_PAF_NV21;
        srcImg.pi32Pitch[0] = plWidth;
        srcImg.pi32Pitch[1] = plWidth / 2 * 2;
        srcImg.ppu8Plane[0] = pDataDst;
        srcImg.ppu8Plane[1] = srcImg.ppu8Plane[0] + srcImg.pi32Pitch[0] * plHeight;
    }
    else
    {
        return AE_RET_UNSUPPORT_PIXELS_FORMAT;
    }
    
    ASVLOFFSCREEN rgbaImageData = {0};
    rgbaImageData.ppu8Plane[0] = pDataSrc;
    rgbaImageData.i32Height = height;
    rgbaImageData.i32Width = width;
    rgbaImageData.u32PixelArrayFormat = ASVL_PAF_RGB32_A8R8G8B8;
    rgbaImageData.pi32Pitch[0] = width*4;
    
    MRESULT ret = MERR_UNKNOWN;
    if(format == AE_IMAGE_FORMAT_NV12)
    {
        ret = mcvColorRGBA8888toNV12ByRegionu8_H(&rgbaImageData,&srcImg, 0,0,MNull);
    }
    else if(format == AE_IMAGE_FORMAT_NV21)
    {
        ret = mcvColorRGBA8888toNV21ByRegionu8_H(&rgbaImageData,&srcImg, 0,0,MNull);
    }
    
    return ret;
}

MRESULT ColorFormatData2RGBA(MByte* pDataSrc,MByte* pDataDst,MInt32 width,MInt32 height,MWord format)
{
    if(pDataDst == MNull || pDataSrc == MNull)
        return AE_RET_MEMORY_ERROR;
    
    MInt32 plWidth = width;
    MInt32 plHeight = height;
    
    ASVLOFFSCREEN srcImg = {0};
    if(format == AE_IMAGE_FORMAT_NV12
       || format == AE_IMAGE_FORMAT_NV21
       )
    {
        srcImg.i32Width = plWidth;
        srcImg.i32Height = plHeight;
        srcImg.u32PixelArrayFormat = (format == AE_IMAGE_FORMAT_NV12) ? ASVL_PAF_NV12 : ASVL_PAF_NV21;
        srcImg.pi32Pitch[0] = plWidth;
        srcImg.pi32Pitch[1] = plWidth / 2 * 2;
        srcImg.ppu8Plane[0] = pDataSrc;
        srcImg.ppu8Plane[1] = srcImg.ppu8Plane[0] + srcImg.pi32Pitch[0] * plHeight;
    }
    else
    {
        return AE_RET_UNSUPPORT_PIXELS_FORMAT;
    }
    
    ASVLOFFSCREEN rgbaImageData = {0};
    rgbaImageData.ppu8Plane[0] = pDataDst;
    rgbaImageData.i32Height = height;
    rgbaImageData.i32Width = width;
    rgbaImageData.u32PixelArrayFormat = ASVL_PAF_RGB32_A8R8G8B8;
    rgbaImageData.pi32Pitch[0] = width*4;
    
    MRESULT ret = MERR_UNKNOWN;
    {
        if(format == AE_IMAGE_FORMAT_NV12)
        {
            ret = mcvColorNV12toRGBA8888ByRegionu8_H(&srcImg,&rgbaImageData, 0,0,255);
        }
        else if(format == AE_IMAGE_FORMAT_NV21)
        {
            ret = mcvColorNV21toRGBA8888ByRegionu8_H(&srcImg,&rgbaImageData, 0,0,255);
        }
    }
    return ret;
}

MInt32 mcvColorNV12toRGBA8888ByRegionu8_H(LPASVLOFFSCREEN srcImg,LPASVLOFFSCREEN dstImg, MUInt32 offsetX,MUInt32 offsetY,MUInt8 alpha)
{
    int y00,y01,y10,y11,u,v,r,g,b;
    int i,j,dstW,dstH;
    int rdif,gdif,bdif;
    MByte *ypt,*uvpt,*dst0,*dst1;
    
    
    if(srcImg == MNull || dstImg == MNull )
    {
        return MERR_UNKNOWN;
    }
    
    if(srcImg->u32PixelArrayFormat != ASVL_PAF_NV12 || dstImg->u32PixelArrayFormat != ASVL_PAF_RGB32_A8R8G8B8)
    {
        return MERR_UNKNOWN;
    }
    
    if(offsetX + dstImg->i32Width > srcImg->i32Width || offsetY + dstImg->i32Height > srcImg->i32Height)
    {
        return MERR_UNKNOWN;
    }
    
    dstH = dstImg->i32Height;
    dstW = dstImg->i32Width;
    
    offsetX = (offsetX>>1<<1);
    offsetY = (offsetY>>1<<1);
    
    
    for(i = 0;i <= dstH - 2; i+= 2)
    {
        dst0  = dstImg->ppu8Plane[0] + i * dstImg->pi32Pitch[0];
        dst1  = dst0 + dstImg->pi32Pitch[0];
        
        ypt  = srcImg->ppu8Plane[0] + (i+offsetY) * srcImg->pi32Pitch[0] +offsetX ;
        uvpt = srcImg->ppu8Plane[1] + ((i+offsetY) >> 1) * srcImg->pi32Pitch[1] + offsetX;
        
        for(j=0;j <= dstW - 2;j+= 2)
        {
            y10 = *(ypt +  srcImg->pi32Pitch[0]);
            y00 = *ypt++;
            y11 = *(ypt +  srcImg->pi32Pitch[0]);
            y01 = *ypt++;
            
            //update uv every 2 pixels
            u = *(uvpt++) - 128;
            v = *(uvpt++) - 128;
            
            y00 = y00<<15;
            y01 = y01<<15;
            y10 = y10<<15;
            y11 = y11<<15;
            
            rdif = ((v * 45941));
            gdif = ((u * 11277)) +((v * 23401));
            bdif = ((u * 58065));
            
            //y00
            r = (y00 + rdif)>>15;
            g = (y00 - gdif)>>15;
            b = (y00 + bdif)>>15;
            
            *(dst0++) = (b < 0 ? 0 : (b > 255 ? 255 : b));
            *(dst0++) = (g < 0 ? 0 : (g > 255 ? 255 : g));
            *(dst0++) = (r < 0 ? 0 : (r > 255 ? 255 : r));
            *(dst0++) = alpha;
            
            //y01
            r = (y01 + rdif)>>15;
            g = (y01 - gdif)>>15;
            b = (y01 + bdif)>>15;
            
            *(dst0++) = (b < 0 ? 0 : (b > 255 ? 255 : b));
            *(dst0++) = (g < 0 ? 0 : (g > 255 ? 255 : g));
            *(dst0++) = (r < 0 ? 0 : (r > 255 ? 255 : r));
            *(dst0++) = alpha;
            
            //y10
            r = (y10 + rdif)>>15;
            g = (y10 - gdif)>>15;
            b = (y10 + bdif)>>15;
            
            *(dst1++) = (b < 0 ? 0 : (b > 255 ? 255 : b));
            *(dst1++) = (g < 0 ? 0 : (g > 255 ? 255 : g));
            *(dst1++) = (r < 0 ? 0 : (r > 255 ? 255 : r));
            *(dst1++) = alpha;
            
            //y11
            r = (y11 + rdif)>>15;
            g = (y11 - gdif)>>15;
            b = (y11 + bdif)>>15;
            
            *(dst1++) = (b < 0 ? 0 : (b > 255 ? 255 : b));
            *(dst1++) = (g < 0 ? 0 : (g > 255 ? 255 : g));
            *(dst1++) = (r < 0 ? 0 : (r > 255 ? 255 : r));
            *(dst1++) = alpha;
        }
        
    }
    return MOK;
}

MInt32 mcvColorRGBA8888toNV12ByRegionu8_H(LPASVLOFFSCREEN srcImg,LPASVLOFFSCREEN dstImg,MUInt32 offsetX,MUInt32 offsetY,MByte* pMask)
{
    int y,u,v,r,g,b;
    int i,j;
    int width,height;
    MByte *ypt,*uvpt,*src;
    
    if(srcImg == MNull || dstImg == MNull )
    {
        return MERR_UNKNOWN;
    }
    
    if(srcImg->u32PixelArrayFormat != ASVL_PAF_RGB32_A8R8G8B8  || dstImg->u32PixelArrayFormat != ASVL_PAF_NV12)
    {
        return MERR_UNKNOWN;
    }
    
    if(offsetX + srcImg->i32Width > dstImg->i32Width || offsetY + srcImg->i32Height > dstImg->i32Height)
    {
        return MERR_UNKNOWN;
    }
    
    width = srcImg->i32Width;
    height = srcImg->i32Height;
    
    
    offsetX = (offsetX>>1<<1);
    offsetY = (offsetY>>1<<1);
    
    for(i=0;i<height;i++)
    {
        ypt  = dstImg->ppu8Plane[0] + (i+offsetY) * dstImg->pi32Pitch[0] +offsetX ;
        uvpt = dstImg->ppu8Plane[1] + ((i+offsetY) >> 1) * dstImg->pi32Pitch[1] + offsetX;
        src = srcImg->ppu8Plane[0] + i * srcImg->pi32Pitch[0];
        
        for(j=0;j<width;j++)
        {
            if(pMask && pMask[i * width +j] == 0)
            {
                ypt ++;
                src += 4;
                if( i%2 == 0 && j%2 == 0)
                {
                    uvpt++;
                    uvpt++;
                }
            }
            else
            {
                b = *src++;
                g = *src++;
                r = *src++;
                src++;
                
                y = (9798*r + 19235*g + 3736*b);
                if( i%2 == 0 && j%2 == 0)
                {
                    u = ((18492*((b<<7)-(y>>8)))>>22) + 128;
                    v = ((23372*((r<<7)-(y>>8)))>>22) + 128;
                    *(uvpt++) = (u < 0 ? 0 : (u > 255 ? 255 : u));
                    *(uvpt++) = (v < 0 ? 0 : (v > 255 ? 255 : v));
                }
                y =y>>15;
                *(ypt++) = (y < 0 ? 0 : (y > 255 ? 255 : y));
            }
        }
    }
    return MOK;
}

MInt32 mcvColorRGBA8888toNV21ByRegionu8_H(LPASVLOFFSCREEN srcImg,LPASVLOFFSCREEN dstImg,MUInt32 offsetX,MUInt32 offsetY,MByte* pMask)
{
    int y,u,v,r,g,b;
    int i,j;
    int width,height;
    MByte *ypt,*uvpt,*src;
    
    if(srcImg == MNull || dstImg == MNull )
    {
        return MERR_UNKNOWN;
    }
    
    if(srcImg->u32PixelArrayFormat != ASVL_PAF_RGB32_A8R8G8B8  || dstImg->u32PixelArrayFormat != ASVL_PAF_NV21)
    {
        return MERR_UNKNOWN;
    }
    
    if(offsetX + srcImg->i32Width > dstImg->i32Width || offsetY + srcImg->i32Height > dstImg->i32Height)
    {
        return MERR_UNKNOWN;
    }
    
    width = srcImg->i32Width;
    height = srcImg->i32Height;
    
    offsetX = (offsetX>>1<<1);
    offsetY = (offsetY>>1<<1);
    
    for(i=0;i<height;i++)
    {
        ypt  = dstImg->ppu8Plane[0] + (i+offsetY) * dstImg->pi32Pitch[0] +offsetX ;
        uvpt = dstImg->ppu8Plane[1] + ((i+offsetY) >> 1) * dstImg->pi32Pitch[1] + offsetX;
        src = srcImg->ppu8Plane[0] + i * srcImg->pi32Pitch[0];
        
        for(j=0;j<width;j++)
        {
            if(pMask && pMask[i * width +j] == 0)
            {
                ypt ++;
                src += 4;
                if( i%2 == 0 && j%2 == 0)
                {
                    uvpt++;
                    uvpt++;
                }
            }
            else
            {
                b = *src++;
                g = *src++;
                r = *src++;
                src++;
                
                y = (9798*r + 19235*g + 3736*b);
                if( i%2 == 0 && j%2 == 0)
                {
                    u = ((18492*((b<<7)-(y>>8)))>>22) + 128;
                    v = ((23372*((r<<7)-(y>>8)))>>22) + 128;
                    *(uvpt++) = (v < 0 ? 0 : (v > 255 ? 255 : v));
                    *(uvpt++) = (u < 0 ? 0 : (u > 255 ? 255 : u));
                }
                y =y>>15;
                *(ypt++) = (y < 0 ? 0 : (y > 255 ? 255 : y));
            }
        }
    }
    return MOK;
}

MInt32 mcvColorNV21toRGBA8888ByRegionu8_H(LPASVLOFFSCREEN srcImg,LPASVLOFFSCREEN dstImg, MUInt32 offsetX,MUInt32 offsetY,MUInt8 alpha)
{
    int y00,y01,y10,y11,u,v,r,g,b;
    int i,j,dstW,dstH;
    int rdif,gdif,bdif;
    MByte *ypt,*uvpt,*dst0,*dst1;
    
    if(srcImg == MNull || dstImg == MNull )
    {
        return MERR_UNKNOWN;
    }
    
    if(srcImg->u32PixelArrayFormat != ASVL_PAF_NV21|| dstImg->u32PixelArrayFormat != ASVL_PAF_RGB32_A8R8G8B8)
    {
        return MERR_UNKNOWN;
    }
    
    if(offsetX + dstImg->i32Width > srcImg->i32Width || offsetY + dstImg->i32Height > srcImg->i32Height)
    {
        return MERR_UNKNOWN;
    }
    
    dstH = dstImg->i32Height;
    dstW = dstImg->i32Width;
    
    offsetX = (offsetX>>1<<1);
    offsetY = (offsetY>>1<<1);
    
    for(i = 0;i <= dstH - 2; i+= 2)
    {
        dst0  = dstImg->ppu8Plane[0] + i * dstImg->pi32Pitch[0];
        dst1  = dst0 + dstImg->pi32Pitch[0];
        
        ypt  = srcImg->ppu8Plane[0] + (i+offsetY) * srcImg->pi32Pitch[0] +offsetX ;
        uvpt = srcImg->ppu8Plane[1] + ((i+offsetY) >> 1) * srcImg->pi32Pitch[1] + offsetX;
        
        for(j=0;j <= dstW - 2;j+= 2)
        {
            y10 = *(ypt +  srcImg->pi32Pitch[0]);
            y00 = *ypt++;
            y11 = *(ypt +  srcImg->pi32Pitch[0]);
            y01 = *ypt++;
            
            //update uv every 2 pixels
            v = *(uvpt++) - 128;
            u = *(uvpt++) - 128;
            
            y00 = y00<<15;
            y01 = y01<<15;
            y10 = y10<<15;
            y11 = y11<<15;
            
            rdif = ((v * 45941));
            gdif = ((u * 11277)) +((v * 23401));
            bdif = ((u * 58065));
            
            //y00
            r = (y00 + rdif)>>15;
            g = (y00 - gdif)>>15;
            b = (y00 + bdif)>>15;
            
            *(dst0++) = (b < 0 ? 0 : (b > 255 ? 255 : b));
            *(dst0++) = (g < 0 ? 0 : (g > 255 ? 255 : g));
            *(dst0++) = (r < 0 ? 0 : (r > 255 ? 255 : r));
            *(dst0++) = alpha;
            
            //y01
            r = (y01 + rdif)>>15;
            g = (y01 - gdif)>>15;
            b = (y01 + bdif)>>15;
            
            *(dst0++) = (b < 0 ? 0 : (b > 255 ? 255 : b));
            *(dst0++) = (g < 0 ? 0 : (g > 255 ? 255 : g));
            *(dst0++) = (r < 0 ? 0 : (r > 255 ? 255 : r));
            *(dst0++) = alpha;
            
            //y10
            r = (y10 + rdif)>>15;
            g = (y10 - gdif)>>15;
            b = (y10 + bdif)>>15;
            
            *(dst1++) = (b < 0 ? 0 : (b > 255 ? 255 : b));
            *(dst1++) = (g < 0 ? 0 : (g > 255 ? 255 : g));
            *(dst1++) = (r < 0 ? 0 : (r > 255 ? 255 : r));
            *(dst1++) = alpha;
            
            //y11
            r = (y11 + rdif)>>15;
            g = (y11 - gdif)>>15;
            b = (y11 + bdif)>>15;
            
            *(dst1++) = (b < 0 ? 0 : (b > 255 ? 255 : b));
            *(dst1++) = (g < 0 ? 0 : (g > 255 ? 255 : g));
            *(dst1++) = (r < 0 ? 0 : (r > 255 ? 255 : r));
            *(dst1++) = alpha;	
            
        }        
    }
    return MOK;
}

static MVoid s_mcvBilinearInterpolationLine(MUInt16 *pXTop1,MUInt16 *pXTop2,
                                            MUInt8 *pDst, MInt32 lDstWidth, MInt32 Ry1)
{
    MInt32 x,t0,t1,lSum;
    
    //lDstWidth = (lDstWidth >> 1) << 1;
    for(x = lDstWidth; x != 0; x--)
    {
        t0 = *pXTop1++;
        t1 = *pXTop2++;
        lSum = (t0 - t1)*Ry1 + (t1 << 8);
        *pDst++ = (MUInt8)(lSum >> 16);
    }
    
}

MInt32 mcvResizeRGBA8888Bilinear(MUInt16 *plTmpBuf,MInt32 buflength,
                                 MUInt8 *pSrc, MInt32 lSrcWidth, MInt32 lSrcHeight,
                                 MInt32 lSrcStride, MUInt8 *pDst,
                                 MInt32 lDstWidth, MInt32 lDstHeight, MInt32 lDstStride)
{
    MInt32 x,y;
#if 1
    MInt32 lZoomW = ((lSrcWidth<<16))/lDstWidth;
    MInt32 lZoomH = ((lSrcHeight<<16))/lDstHeight;
#else
    MInt32 lZoomW = ((lSrcWidth<<8) + (lDstWidth>>1))/lDstWidth;
    MInt32 lZoomH = ((lSrcHeight<<8) + (lDstHeight>>1))/lDstHeight;
#endif
    
    MInt32 lTop, lRealTop, lLeft, lRealLeft;
    MInt32 Rx1, Ry1;
    MUInt8 *pSrcTop = MNull;
    MUInt16 *pt;
    
    
    MInt32 lPreTop = 0,lTopInterval,t0,t1,d0,d1,d2,d3;
    MUInt16 *pXTop1;
    MUInt16 *pXTop2;
    
    if(plTmpBuf == MNull || pSrc == MNull || pDst == MNull)
    {
        return AE_RET_PROCESS_FAILED;
    }
    //2+ 2top*4channel
    if(buflength < sizeof(MUInt16)*(lDstWidth * 10))
    {
        return AE_RET_PROCESS_FAILED;
    }
    
    if(lSrcWidth<=2 || lSrcHeight<=2 || lDstHeight<=2 || lDstWidth<=2 )
    {
        return AE_RET_PROCESS_FAILED;
    }
    
    pXTop1 = plTmpBuf + (lDstWidth << 1);
    lDstWidth = (lDstWidth << 2) ;//+ lDstWidth;
    pXTop2 = pXTop1 + lDstWidth;
    
    pt = plTmpBuf;
    lRealLeft = 0;//�����疯��棰���ュ����茶�����濞�纰����纰����纰����娼�璋╄�抽�跺�ら��(璺����楹�璐�256��ら�茶�����娼�璐哥�������扮��)
    for (x = 0; x < lDstWidth;)
    {
#if 1
        // 		if (lRealLeft >= ((lSrcWidth-1)<<16))
        // 		{
        // 			lRealLeft = (lSrcWidth-2)<<16; // Don't overflow
        // 		}
        lLeft = lRealLeft>>16;//�����疯��棰���ュ����茶�����濞�纰����纰����纰����娼�璋╄�抽�跺�ら��纰�������娌¤�㈠�����椹磋矾��拌�扮��
        Rx1 = (((lLeft+1)<<16) - lRealLeft)>>8;
#else
        if (lRealLeft >= ((lSrcWidth-1)<<8))
        {
            lRealLeft = (lSrcWidth-2)<<8; // Don't overflow
        }
        lLeft = lRealLeft>>8;//�����疯��棰���ュ����茶�����濞�纰����纰����纰����娼�璋╄�抽�跺�ら��纰�������娌¤�㈠�����椹磋矾��拌�扮��
        Rx1 = ((lLeft+1)<<8) - lRealLeft;
#endif
        
        t0 = (lLeft << 2);//+ lLeft;//3channels
        t1 = Rx1;
        *pt++ = t0;
        *pt++ = t1;
        
        if((t0>>2)>=lSrcWidth-1)
        {
            //r
            d0 = pSrc[t0];
            d1 = 0;//pSrc[(t0 + 4)];
            d2 = pSrc[lSrcStride + t0];
            d3 = 0;//pSrc[lSrcStride + t0 + 3];
            pXTop1[x] = (d0 - d1)*t1 + (d1<<8);//x1<<8
            pXTop2[x++] = (d2 - d3)*t1 + (d3<<8);//x2<<8
            
            //g
            d0 = pSrc[t0 + 1];
            d1 = 0;//pSrc[(t0 + 1 + 4)];
            d2 = pSrc[lSrcStride + t0 + 1];
            d3 = 0;//pSrc[lSrcStride + t0 + 1 + 4];
            pXTop1[x] = (d0 - d1)*t1 + (d1<<8);//x1<<8
            pXTop2[x++] = (d2 - d3)*t1 + (d3<<8);//x2<<8
            
            //b
            d0 = pSrc[t0 + 2];
            d1 = 0;//pSrc[(t0 + 2 + 4)];
            d2 = pSrc[lSrcStride + t0 + 2 ];
            d3 = 0;//pSrc[lSrcStride + t0 + 2 + 4];
            pXTop1[x] = (d0 - d1)*t1 + (d1<<8);//x1<<8
            pXTop2[x++] = (d2 - d3)*t1 + (d3<<8);//x2<<8
            
            //a
            d0 = pSrc[t0 + 3];
            d1 = 0;//pSrc[(t0 + 3 + 4)];
            d2 = pSrc[lSrcStride + t0 + 3 ];
            d3 = 0;//pSrc[lSrcStride + t0 + 3 + 4];
            pXTop1[x] = (d0 - d1)*t1 + (d1<<8);//x1<<8
            pXTop2[x++] = (d2 - d3)*t1 + (d3<<8);//x2<<8
        }else
        {
            //r
            d0 = pSrc[t0];
            d1 = pSrc[(t0 + 4)];
            d2 = pSrc[lSrcStride + t0];
            d3 = pSrc[lSrcStride + t0 + 3];
            pXTop1[x] = (d0 - d1)*t1 + (d1<<8);//x1<<8
            pXTop2[x++] = (d2 - d3)*t1 + (d3<<8);//x2<<8
            
            //g
            d0 = pSrc[t0 + 1];
            d1 = pSrc[(t0 + 1 + 4)];
            d2 = pSrc[lSrcStride + t0 + 1];
            d3 = pSrc[lSrcStride + t0 + 1 + 4];
            pXTop1[x] = (d0 - d1)*t1 + (d1<<8);//x1<<8
            pXTop2[x++] = (d2 - d3)*t1 + (d3<<8);//x2<<8
            
            //b
            d0 = pSrc[t0 + 2];
            d1 = pSrc[(t0 + 2 + 4)];
            d2 = pSrc[lSrcStride + t0 + 2 ];
            d3 = pSrc[lSrcStride + t0 + 2 + 4];
            pXTop1[x] = (d0 - d1)*t1 + (d1<<8);//x1<<8
            pXTop2[x++] = (d2 - d3)*t1 + (d3<<8);//x2<<8
            
            //a
            d0 = pSrc[t0 + 3];
            d1 = pSrc[(t0 + 3 + 4)];
            d2 = pSrc[lSrcStride + t0 + 3 ];
            d3 = pSrc[lSrcStride + t0 + 3 + 4];
            pXTop1[x] = (d0 - d1)*t1 + (d1<<8);//x1<<8
            pXTop2[x++] = (d2 - d3)*t1 + (d3<<8);//x2<<8
        }
        
        lRealLeft += lZoomW;
    }
    lRealTop = 0;
    //pt = plTmpBuf;
    //lDstHeight should be even
    for (y = lDstHeight; y != 0; y--)
    {
        /*R */
        //first line
#if 1
        if (lRealTop >= ((lSrcHeight-1)<<16))
        {
            lRealTop = (lSrcHeight-2)<<16; // Don't overflow
        }
        lTop = lRealTop>>16;
        Ry1 = (((lTop+1)<<16) - lRealTop)>>8;
#else
        if (lRealTop >= ((lSrcHeight-1)<<8))
        {
            lRealTop = (lSrcHeight-2)<<8; // Don't overflow
        }
        lTop = lRealTop>>8;
        Ry1 = ((lTop+1)<<8) - lRealTop;
#endif
        
        //lTopInterval = lTop - lPreTop;
        {
            /*calc two new lines*/
            pt = plTmpBuf;
            pSrcTop = pSrc + lTop*lSrcStride;
            
            for (x = 0; x < lDstWidth;)
            {
                t0 = *pt++;
                t1 = *pt++;
                //printf("%d ",t0);
                
                if((t0>>2)>=lSrcWidth-1)
                {
                    
                    d0 = pSrcTop[t0];
                    d1 = 0;//pSrcTop[t0 + 4];
                    d2 = pSrcTop[lSrcStride + t0];
                    d3 = 0;//pSrcTop[lSrcStride + t0 + 4];
                    pXTop1[x] = (d0 - d1)*t1 + (d1<<8);//x1<<8
                    pXTop2[x++] = (d2 - d3)*t1 + (d3<<8);//x2<<8
                    //G
                    d0 = pSrcTop[t0 + 1];
                    d1 = 0;//pSrcTop[t0 + 1 + 4];
                    d2 = pSrcTop[lSrcStride + t0 + 1];
                    d3 = 0;//pSrcTop[lSrcStride + t0 + 1 + 4];
                    pXTop1[x] = (d0 - d1)*t1 + (d1<<8);//x1<<8
                    pXTop2[x++] = (d2 - d3)*t1 + (d3<<8);//x2<<8
                    //B
                    d0 = pSrcTop[t0 + 2];
                    d1 = 0;//pSrcTop[t0 + 2 + 4];
                    d2 = pSrcTop[lSrcStride + t0 + 2];
                    d3 = 0;//pSrcTop[lSrcStride + t0 + 2 + 4];
                    pXTop1[x] = (d0 - d1)*t1 + (d1<<8);//x1<<8
                    pXTop2[x++] = (d2 - d3)*t1 + (d3<<8);//x2<<8
                    //A
                    d0 = pSrcTop[t0 + 3];
                    d1 = 0;//pSrcTop[t0 + 3 + 4];
                    d2 = pSrcTop[lSrcStride + t0 + 3];
                    d3 = 0;//pSrcTop[lSrcStride + t0 + 3 + 4];
                    
                }else
                {
                    d0 = pSrcTop[t0];
                    d1 = pSrcTop[t0 + 4];
                    d2 = pSrcTop[lSrcStride + t0];
                    d3 = pSrcTop[lSrcStride + t0 + 4];
                    pXTop1[x] = (d0 - d1)*t1 + (d1<<8);//x1<<8
                    pXTop2[x++] = (d2 - d3)*t1 + (d3<<8);//x2<<8
                    //G
                    d0 = pSrcTop[t0 + 1];
                    d1 = pSrcTop[t0 + 1 + 4];
                    d2 = pSrcTop[lSrcStride + t0 + 1];
                    d3 = pSrcTop[lSrcStride + t0 + 1 + 4];
                    pXTop1[x] = (d0 - d1)*t1 + (d1<<8);//x1<<8
                    pXTop2[x++] = (d2 - d3)*t1 + (d3<<8);//x2<<8
                    //B
                    d0 = pSrcTop[t0 + 2];
                    d1 = pSrcTop[t0 + 2 + 4];
                    d2 = pSrcTop[lSrcStride + t0 + 2];
                    d3 = pSrcTop[lSrcStride + t0 + 2 + 4];
                    pXTop1[x] = (d0 - d1)*t1 + (d1<<8);//x1<<8
                    pXTop2[x++] = (d2 - d3)*t1 + (d3<<8);//x2<<8
                    //A
                    d0 = pSrcTop[t0 + 3];
                    d1 = pSrcTop[t0 + 3 + 4];
                    d2 = pSrcTop[lSrcStride + t0 + 3];
                    d3 = pSrcTop[lSrcStride + t0 + 3 + 4];
                }
                
                //R
                
                pXTop1[x] = (d0 - d1)*t1 + (d1<<8);//x1<<8
                pXTop2[x++] = (d2 - d3)*t1 + (d3<<8);//x2<<8
            }
            
        }/*others,use current line data.*/
        s_mcvBilinearInterpolationLine(pXTop1,pXTop2,pDst,lDstWidth,Ry1);
        pDst += lDstStride;
        lRealTop += lZoomH;
        lPreTop = lTop;
    }
    
    return AE_RET_SUCCESS;
}

#define LANDMARK_RADIUS 4
#define LANDMARK_COLOR 160

int s_draw_pnt_NV12(MByte* pimg, MUInt32 width, MUInt32 height, MPOINT pnt)
{
    MByte* plane0 = pimg;
    MByte* plane1 = plane0 + width * height;
    MUInt32 pitch0 = width;
    MUInt32 pitch1 = width;
    
    for (int i = -LANDMARK_RADIUS; i < LANDMARK_RADIUS + 1; i++)
    {
        int endj = floor(sqrt(LANDMARK_RADIUS * LANDMARK_RADIUS - i * i));
        for (int j = -endj ; j < endj + 1; j++)
        {
            int newx = pnt.x + j;
            int newy = pnt.y + i;
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

int s_draw_pnt_BGRA(MByte* pimg, MUInt32 width, MUInt32 height,MPOINT pnt,MByte r,MByte g,MByte b)
{
    MByte* plane0 = pimg;
    MUInt32 pitch0 = width * 4;
    
    for (int i = -LANDMARK_RADIUS; i < LANDMARK_RADIUS + 1; i++) // x
    {
        int x = pnt.x + i;
        if(x < 0 || x >= width)
            continue;
        
        for (int j = -LANDMARK_RADIUS; j < LANDMARK_RADIUS + 1; j++) // y
        {
            int y = pnt.y + j;
            if(y < 0 || y >=height)
                continue;
            
            MUInt8* pData = plane0 + pitch0 * y + x * 4;
            *(pData++) = b; // b
            *(pData++) = g; // g
            *(pData++) = r;// r
            //            *(pData++) = 100; // a
        }
    }
    return 0;
}

