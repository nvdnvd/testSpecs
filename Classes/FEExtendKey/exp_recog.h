//
//  exp_recog.h
//  sample_face_track
//
//  Created by user on 16/3/28.
//  Copyright © 2016年 DeepID. All rights reserved.
//

#ifndef exp_recog_h
#define exp_recog_h


#define _ARC_SOFT_

/*
 计算额头点,脸蛋,脖子,肩膀上的关键点
 注意要检查坐标的合法范围，可能有不在屏幕上的风险
 target_kpts[0,1,2,3,4,5,6] 额头周边点
 target_kpts[7] 额头中间点
 target_kpts[8,9] 左右脸蛋
 target_kpts[10,11,12,13,14] 脖子上的点
 target_kpts[15,16,17,18,19] 左肩膀上的点
 target_kpts[20,21,22,23,24] 右肩膀上的点
 */
int get_other_kpts(const float * kpts_x, const float* kpts_y, int n, float* target_kpts_x, float* target_kpts_y, int max_result_nb, float* xy_angle, float* xyz_angle, char* log, int max_log_size);

/*眨眼*/
int blink_eye_detection(const float * kpts_x, const float* kpts_y, int n, int* result, char* log, int max_log_size);

/*抬眉头*/
int enlarged_eye_detection(const float * kpts_x, const float* kpts_y, int n, int* result, char* log, int max_log_size);

/*张嘴*/
int opened_mouse_detection(const float * kpts_x, const float* kpts_y, int n, int* result, char* log, int max_log_size);

/*嘟嘴*/
int forward_mouse_detection(const float * kpts_x, const float* kpts_y, int n, int* result, char* log, int max_log_size) ;


#endif /* exp_recog_h */
