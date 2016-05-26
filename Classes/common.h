//
//  common.h
//  Bigbang
//
//  Created by 王聪 on 11/25/15.
//  Copyright © 2015 王聪. All rights reserved.
//
#define EXTEND_KEY

//获取屏幕 宽度、高度
#define kScreenBounds ([UIScreen mainScreen].bounds)
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)

//录制尺寸
#define kMovieWidth         720
#define kMovieHeight        1280

//显示尺寸
#define kVideoWidth         720
#define kVideoHeight        1280

//关键点
#define POINTS_KEY              @"POINTS_KEY"
#define RECT_KEY                @"RECT_KEY"
#define ROLL_KEY                @"ROLL_KEY"
#define BLINK_EYE_KEY           @"BLINK_EYE_KEY"
#define ENLARGE_EYE_KEY         @"ENLARGE_EYE_KEY"
#define OPEN_MOUTH_KEY          @"OPEN_MOUTH_KEY"
#define FORWORD_MOUTH_KEY       @"FORWORD_MOUTH_KEY"
#define EXTEND_POINT_KEY        @"EXTEND_POINT_KEY"

//帧率
#define kRate               15