//
//  exp_recog.c
//  sample_face_track
//
//  Created by user on 16/3/28.
//  Copyright © 2016年 DeepID. All rights reserved.
//

#include "exp_recog.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>

#define KEYPOINT_NB 101

#define MIN2(a, b) (a) < (b) ? (a) : (b)
#define MIN3(a, b, c) (MIN2(a, b) < (c)) ? (MIN2(a, b)) : (c)
#define MIN4(a, b, c, d) (MIN3(a, b, c) < (d)) ? (MIN3(a, b, c)) : (d)
#define MIN5(a, b, c, d, e) (MIN4(a, b, c, d) < (e)) ? (MIN4(a, b, c, d)) : (e)
#define MIN6(a, b, c, d, e, f) (MIN5(a, b, c, d, e) < (f)) ? (MIN5(a, b, c, d, e)) : (f)


#define MAX2(a, b) (a) > (b) ? (a) : (b)
#define MAX3(a, b, c) (MAX2(a, b) > (c)) ? (MAX2(a, b)) : (c)
#define MAX4(a, b, c, d) (MAX3(a, b, c) > (d)) ? (MAX3(a, b, c)) : (d)
#define MAX5(a, b, c, d, e) (MAX4(a, b, c, d) > (e)) ? (MAX4(a, b, c, d)) : (e)
#define MAX6(a, b, c, d, e, f) (MAX5(a, b, c, d, e) > (f) ? (MAX5(a, b, c, d, e)) : (f)


int transform_2d(const float* src_x, const float* src_y, int n, float theta, float delta_x, float delta_y, float* dst_x, float* dst_y) {
    int i = 0;
    float* centered_x = (float*)malloc(n * sizeof(float));
    float* centered_y = (float*)malloc(n * sizeof(float));
    for(i = 0; i < n; i++) {
        centered_x[i] = src_x[i] - delta_x;
        centered_y[i] = src_y[i] - delta_y;
    }
    for(i = 0; i < n; i++){
        dst_x[i] = centered_x[i] * cos(theta) - centered_y[i] * sin(theta);
        dst_y[i] = centered_y[i] * cos(theta) + sin(theta) * centered_x[i];
    }
    free(centered_x);
    free(centered_y);
    return 0;
}

int reverse_transform_2d(const float* src_x, const float* src_y, int n, float theta, float delta_x, float delta_y, float* dst_x, float* dst_y) {
    int i = 0;
    for(i = 0; i < n; i++){
        dst_x[i] = src_x[i] * cos(theta) - src_y[i] * sin(theta);
        dst_y[i] = src_y[i] * cos(theta) + sin(theta) * src_x[i];
    }
    for(i = 0; i < n; i++) {
        dst_x[i] = dst_x[i] - delta_x;
        dst_y[i] = dst_y[i] - delta_y;
    }
    return 0;
}

#ifdef _SENSE_TIME_


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

#define OTHER_KPTS_NB 25

int get_other_kpts(const float * kpts_x, const float* kpts_y, int n, float* target_kpts_x, float* target_kpts_y, int max_result_nb, float* xy_angle, float* xyz_angle, char* log, int max_log_size){
    
    if(kpts_x == NULL || kpts_y == NULL || target_kpts_x == NULL || target_kpts_y == NULL || n != KEYPOINT_NB || log == NULL) {
        return -1;
    }
    *xy_angle = 0.0f;
    *xyz_angle = 0.0f;
    
    float face_center_x, face_center_y;
    face_center_x = kpts_x[46];
    face_center_y = kpts_y[46];
    
    float* face_center_kpts_x = (float*)malloc(n * sizeof(float));
    float* face_center_kpts_y = (float*)malloc(n * sizeof(float));
    float slope = ((kpts_y[52] - kpts_y[55]) + (kpts_y[58] - kpts_y[61])) / ((kpts_x[52] - kpts_x[55]) + (kpts_x[58] - kpts_x[61]));
    
    transform_2d(kpts_x, kpts_y, n, atan(slope), face_center_x, face_center_y, face_center_kpts_x, face_center_kpts_y);
    
    float* face_center_dst_kpts_x = (float*)malloc(OTHER_KPTS_NB * sizeof(float));
    float* face_center_dst_kpts_y = (float*)malloc(OTHER_KPTS_NB * sizeof(float));
    
    float left_eye_width = face_center_kpts_x[58] - face_center_kpts_x[61];
    float right_eye_width = face_center_kpts_x[52] - face_center_kpts_y[55];
    float eye_width = (left_eye_width + right_eye_width)/2;
    
    float alpha_x = 0.5;
    //float alpha_y = 0.5;
    
    
    face_center_dst_kpts_x[0] = face_center_kpts_x[42];
    face_center_dst_kpts_y[0] = face_center_kpts_y[42];
    
    face_center_dst_kpts_x[1] = face_center_kpts_x[42] - alpha_x * eye_width;
    face_center_dst_kpts_y[1] = face_center_kpts_y[42];
    
    face_center_dst_kpts_x[2] = face_center_kpts_x[42];
    face_center_dst_kpts_y[2] = face_center_kpts_y[42]- alpha_x * eye_width;
    
    face_center_dst_kpts_x[3] = face_center_kpts_x[42] + alpha_x * eye_width;
    face_center_dst_kpts_y[3] = face_center_kpts_y[42]- eye_width;
    
    face_center_dst_kpts_x[4] = face_center_kpts_x[33] - alpha_x * eye_width;
    face_center_dst_kpts_y[4] = face_center_kpts_y[33]- eye_width;
    
    face_center_dst_kpts_x[5] = face_center_kpts_x[33];
    face_center_dst_kpts_y[5] = face_center_kpts_y[33]- alpha_x * eye_width;
    
    face_center_dst_kpts_x[6] = face_center_kpts_x[33]- alpha_x * eye_width;
    face_center_dst_kpts_y[6] = face_center_kpts_y[33];
    
    
    face_center_dst_kpts_x[7] = face_center_kpts_x[43];
    face_center_dst_kpts_y[7] = face_center_kpts_y[43]-  eye_width;
    
    face_center_dst_kpts_x[8] = (face_center_kpts_x[61] + face_center_kpts_x[90]) / 2.0;
    face_center_dst_kpts_y[8] = (face_center_kpts_y[61] + face_center_kpts_y[90]) / 2.0;
    
    face_center_dst_kpts_x[9] = (face_center_kpts_x[84] + face_center_kpts_x[52]) / 2.0;
    face_center_dst_kpts_y[9] = (face_center_kpts_y[84] + face_center_kpts_y[52]) / 2.0;
    
    face_center_dst_kpts_x[12] = face_center_kpts_x[16];
    face_center_dst_kpts_y[12] = face_center_kpts_y[16] + (face_center_kpts_y[16] - face_center_kpts_y[93]) / 3.0;
    
    face_center_dst_kpts_x[10] = face_center_kpts_x[20];
    face_center_dst_kpts_y[10] = face_center_dst_kpts_y[12];
    
    face_center_dst_kpts_x[11] = face_center_kpts_x[18];
    face_center_dst_kpts_y[11] = face_center_dst_kpts_y[12];
    
    face_center_dst_kpts_x[13] = face_center_kpts_x[14];
    face_center_dst_kpts_y[13] = face_center_dst_kpts_y[12];
    
    face_center_dst_kpts_x[14] = face_center_kpts_x[12];
    face_center_dst_kpts_y[14] = face_center_dst_kpts_y[12];
    
    float head_width = face_center_kpts_x[52] - face_center_kpts_x[61];
    
    
    face_center_dst_kpts_x[15] = face_center_kpts_x[61] - head_width;
    face_center_dst_kpts_y[15] = face_center_dst_kpts_y[12] + (face_center_kpts_y[16] - face_center_kpts_y[93]) / 3.0;
    
    face_center_dst_kpts_x[16] = face_center_kpts_x[61] - head_width * 0.8;
    face_center_dst_kpts_y[16] = face_center_dst_kpts_y[12]+ (face_center_kpts_y[16] - face_center_kpts_y[93]) / 3.0;
    
    face_center_dst_kpts_x[17] = face_center_kpts_x[61] - head_width * 0.5;
    face_center_dst_kpts_y[17] = face_center_dst_kpts_y[12]+ (face_center_kpts_y[16] - face_center_kpts_y[93]) / 3.0;
    
    face_center_dst_kpts_x[18] = face_center_kpts_x[61] - head_width * 0.2;
    face_center_dst_kpts_y[18] = face_center_dst_kpts_y[12]+ (face_center_kpts_y[16] - face_center_kpts_y[93]) / 3.0;
    
    face_center_dst_kpts_x[19] = face_center_kpts_x[61];
    face_center_dst_kpts_y[19] = face_center_dst_kpts_y[12]+ (face_center_kpts_y[16] - face_center_kpts_y[93]) / 3.0;
    
    
    
    face_center_dst_kpts_x[20] = face_center_kpts_x[52] + head_width;
    face_center_dst_kpts_y[20] = face_center_dst_kpts_y[12]+ (face_center_kpts_y[16] - face_center_kpts_y[93]) / 3.0;
    
    face_center_dst_kpts_x[21] = face_center_kpts_x[52] + head_width * 0.8;
    face_center_dst_kpts_y[21] = face_center_dst_kpts_y[12]+ (face_center_kpts_y[16] - face_center_kpts_y[93]) / 3.0;
    
    
    face_center_dst_kpts_x[22] = face_center_kpts_x[52] + head_width * 0.5;
    face_center_dst_kpts_y[22] = face_center_dst_kpts_y[12]+ (face_center_kpts_y[16] - face_center_kpts_y[93]) / 3.0;
    
    face_center_dst_kpts_x[23] = face_center_kpts_x[52] + head_width * 0.2;
    face_center_dst_kpts_y[23] = face_center_dst_kpts_y[12]+ (face_center_kpts_y[16] - face_center_kpts_y[93]) / 3.0;
    
    face_center_dst_kpts_x[24] = face_center_kpts_x[52];
    face_center_dst_kpts_y[24] = face_center_dst_kpts_y[12]+ (face_center_kpts_y[16] - face_center_kpts_y[93]) / 3.0;
    
    *xy_angle = atan(slope);
    
    reverse_transform_2d(face_center_dst_kpts_x, face_center_dst_kpts_y, OTHER_KPTS_NB, 0 - atan(slope),  0 - face_center_x, 0 - face_center_y, target_kpts_x, target_kpts_y);
    
    
    free(face_center_kpts_x);
    free(face_center_kpts_y);
    free(face_center_dst_kpts_x);
    free(face_center_dst_kpts_y);
    
    snprintf(log, max_log_size, "slope:%f\n", slope);
    
    return 0;
}



/*眨眼*/
int blink_eye_detection(const float * kpts_x, const float* kpts_y, int n, int* result, char* log, int max_log_size){
    if(result == NULL || n != KEYPOINT_NB || log == NULL) {
        return -1;
    }
    *result = 0;
    
    float face_center_x, face_center_y;
    face_center_x = kpts_x[46];
    face_center_y = kpts_y[46];
    
    float* face_center_kpts_x = (float*)malloc(n * sizeof(float));
    float* face_center_kpts_y = (float*)malloc(n * sizeof(float));
    float slope = ((kpts_y[52] - kpts_y[55]) + (kpts_y[58] - kpts_y[61])) / ((kpts_x[52] - kpts_x[55]) + (kpts_x[58] - kpts_x[61]));
    
    transform_2d(kpts_x, kpts_y, n, atan(slope), face_center_x, face_center_y, face_center_kpts_x, face_center_kpts_y);
    
    
    
    /*
     left eye: [58, 61]
     right eye: [52,57]
     */
    float left_eye_height = fabsf(face_center_kpts_y[76] - face_center_kpts_y[75]);
    float right_eye_height = fabsf(face_center_kpts_y[73] - face_center_kpts_y[72]);
    
    float left_eye_width = fabsf(face_center_kpts_x[58] - face_center_kpts_x[61]);
    float right_eye_width = fabsf(face_center_kpts_x[52] - face_center_kpts_x[55]);
    
    float left_ratio =left_eye_height / left_eye_width * 10.0;
    float right_ratio = right_eye_height / right_eye_width * 10.0;
    
    if(left_ratio < 2.8){
        *result += 1;
    }
    if(right_ratio < 2.8){
        *result += 2;
    }
    
    snprintf(log, max_log_size, "left_ratio:%f\nright_ratio:%f\nresult:%d\n", left_ratio,right_ratio, *result);
    
    
    free(face_center_kpts_x);
    free(face_center_kpts_y);
    return 0;
}

/*抬眉头*/
int enlarged_eye_detection(const float * kpts_x, const float* kpts_y, int n, int* result, char* log, int max_log_size){
    if(result == NULL || n != KEYPOINT_NB || log == NULL) {
        return -1;
    }
    
    *result = 0;
    float face_center_x, face_center_y;
    face_center_x = kpts_x[46];
    face_center_y = kpts_y[46];
    
    float* face_center_kpts_x = (float*)malloc(n * sizeof(float));
    float* face_center_kpts_y = (float*)malloc(n * sizeof(float));
    float slope = ((kpts_y[52] - kpts_y[55]) + (kpts_y[58] - kpts_y[61])) / ((kpts_x[52] - kpts_x[55]) + (kpts_x[58] - kpts_x[61]));
    
    transform_2d(kpts_x, kpts_y, n, atan(slope), face_center_x, face_center_y, face_center_kpts_x, face_center_kpts_y);
    
    /*
     left eye brow: [38, 42] [68,71]
     right eye brow: [33, 37] [64, 67]
     */
    float left_brow_min_y = MIN5(face_center_kpts_y[38], face_center_kpts_y[39], face_center_kpts_y[40], face_center_kpts_y[4], face_center_kpts_y[42]);
    float right_brow_min_y = MIN5(face_center_kpts_y[33], face_center_kpts_y[34], face_center_kpts_y[35], face_center_kpts_y[36], face_center_kpts_y[37]);
    float brow_min_y = (left_brow_min_y+right_brow_min_y)/2;
    /*
     left eye: [58, 61]
     right eye: [52,57]
     */
    float left_eye_min_y = MIN4(face_center_kpts_y[58], face_center_kpts_y[59], face_center_kpts_y[60], face_center_kpts_y[61]);
    float right_eye_min_y = MIN4(face_center_kpts_y[52], face_center_kpts_y[53], face_center_kpts_y[54], face_center_kpts_y[55]);
    float eye_min_y = (left_eye_min_y + right_eye_min_y)/2;
    
    float left_eye_width = face_center_kpts_x[58] - face_center_kpts_x[61];
    float right_eye_width = face_center_kpts_x[52] - face_center_kpts_x[55];
    
    
    
    float eye_width = (left_eye_width + right_eye_width)/2;
    
    float brow_eye_dist = eye_min_y - brow_min_y;
    
    float ratio = fabs(brow_eye_dist / eye_width);
    
    if(ratio > 1.05){
        *result = 1;
    }
    
    snprintf(log, max_log_size, "brow_min_y:%f\neye_min_y:%f\neye_width:%f\nbrow_eye_dist:%f\nratio:%f\nresult:%d\n", brow_min_y,eye_min_y, eye_width, brow_eye_dist, ratio, *result);
    
    free(face_center_kpts_x);
    free(face_center_kpts_y);
    return 0;
}






int opened_mouse_detection(const float * kpts_x, const float* kpts_y, int n, int* result, char* log, int max_log_size) {
    if(result == NULL || n != KEYPOINT_NB || log == NULL) {
        return -1;
    }
    float face_center_x, face_center_y;
    face_center_x = kpts_x[46];
    face_center_y = kpts_y[46];
    
    float* face_center_kpts_x = (float*)malloc(n * sizeof(float));
    float* face_center_kpts_y = (float*)malloc(n * sizeof(float));
    float slope = ((kpts_y[52] - kpts_y[55]) + (kpts_y[58] - kpts_y[61])) / ((kpts_x[52] - kpts_x[55]) + (kpts_x[58] - kpts_x[61]));
    
    transform_2d(kpts_x, kpts_y, n, atan(slope), face_center_x, face_center_y, face_center_kpts_x, face_center_kpts_y);
    /*
     mouse: [84, 95]
     */
    float min_mouse_y = MIN3(face_center_kpts_y[86], face_center_kpts_y[87], face_center_kpts_y[88]);
    float max_mouse_y = MAX3(face_center_kpts_y[92], face_center_kpts_y[93], face_center_kpts_y[94]);
    float mouse_dist_y = fabs(max_mouse_y - min_mouse_y);
    float mouse_dist_x = face_center_kpts_x[84] - face_center_kpts_x[90];
    
    float mouse_nose_dist_y = fabs(face_center_kpts_y[87] - face_center_kpts_y[49]);
    
    float mouse_ratio = fabs(mouse_dist_y / mouse_dist_x);
    
    if(mouse_ratio > 0.6f && mouse_dist_y > 1.0 * mouse_nose_dist_y){
        *result = 1;
    }
    
    snprintf(log, max_log_size, "mouse_dist_y:%f\nmouse_dist_x:%f\nratio:%fmouse_nose_dist_y:%f\n", mouse_dist_y,mouse_dist_x, mouse_ratio, mouse_nose_dist_y);
    
    free(face_center_kpts_x);
    free(face_center_kpts_y);
    return 0;
}


int forward_mouse_detection(const float * kpts_x, const float* kpts_y, int n, int* result, char* log, int max_log_size) {
    if(result == NULL || n != KEYPOINT_NB || log == NULL) {
        return -1;
    }
    *result = 0;
    float face_center_x, face_center_y;
    face_center_x = kpts_x[46];
    face_center_y = kpts_y[46];
    
    float* face_center_kpts_x = (float*)malloc(n * sizeof(float));
    float* face_center_kpts_y = (float*)malloc(n * sizeof(float));
    float slope = ((kpts_y[52] - kpts_y[55]) + (kpts_y[58] - kpts_y[61])) / ((kpts_x[52] - kpts_x[55]) + (kpts_x[58] - kpts_x[61]));
    
    transform_2d(kpts_x, kpts_y, n, atan(slope), face_center_x, face_center_y, face_center_kpts_x, face_center_kpts_y);
    /*
     mouse: [84, 95]
     */
    float min_mouse_y = MIN3(face_center_kpts_y[86], face_center_kpts_y[87], face_center_kpts_y[88]);
    float max_mouse_y = MAX3(face_center_kpts_y[92], face_center_kpts_y[93], face_center_kpts_y[94]);
    float mouse_dist_y = max_mouse_y - min_mouse_y;
    
    float mouse_dist_x = fabs(face_center_kpts_x[84] - face_center_kpts_x[90]);
    float nose_dist_x = fabs(face_center_kpts_x[82] - face_center_kpts_x[83]);
    
    float mouse_ratio = fabs(mouse_dist_y / mouse_dist_x);
    float mouse_nose_dist_y = fabs(face_center_kpts_y[87] - face_center_kpts_y[49]);

    if(mouse_ratio > 0.6 && mouse_dist_y < mouse_nose_dist_y) {
        *result = 1;

    }
    snprintf(log, max_log_size, "mouse_ratio:%f\nmouse_dist_x:%f\nmouse_dist_y:%f\nnose_dist_x:%fmouse_nose_dist_y:%f\n", mouse_ratio, mouse_dist_x,mouse_dist_y, nose_dist_x,mouse_nose_dist_y);
    
    free(face_center_kpts_x);
    free(face_center_kpts_y);
    return 0;
}



#else


/*眨眼*/
int blink_eye_detection(const float * kpts_x, const float* kpts_y, int n, int* result, char* log, int max_log_size){
    if(result == NULL || n != KEYPOINT_NB || log == NULL) {
        return -1;
    }
    *result = 0;
    
    float face_center_x, face_center_y;
    face_center_x = kpts_x[99];
    face_center_y = kpts_y[99];
    
    float* face_center_kpts_x = (float*)malloc(n * sizeof(float));
    float* face_center_kpts_y = (float*)malloc(n * sizeof(float));
    float slope = ((kpts_y[39] - kpts_y[45]) + (kpts_y[51] - kpts_y[57])) / ((kpts_x[39] - kpts_x[45]) + (kpts_x[51] - kpts_x[57]));
    
    transform_2d(kpts_x, kpts_y, n, atan(slope), face_center_x, face_center_y, face_center_kpts_x, face_center_kpts_y);
    
    
    
    /*
     left eye: [58, 61]
     right eye: [52,57]
     */
    float left_eye_height = fabsf(face_center_kpts_y[60] - face_center_kpts_y[54]);
    float right_eye_height = fabsf(face_center_kpts_y[42] - face_center_kpts_y[48]);
    
    float left_eye_width = fabsf(face_center_kpts_x[51] - face_center_kpts_x[57]);
    float right_eye_width = fabsf(face_center_kpts_x[39] - face_center_kpts_x[45]);
    
    float left_ratio =left_eye_height / left_eye_width * 10.0;
    float right_ratio = right_eye_height / right_eye_width * 10.0;
    
    if(left_ratio < 1.0){
        *result += 1;
    }
    if(right_ratio < 1.0){
        *result += 2;
    }
    
    snprintf(log, max_log_size, "left_ratio:%f\nright_ratio:%f\nresult:%d\n", left_ratio,right_ratio, *result);
    
    
    free(face_center_kpts_x);
    free(face_center_kpts_y);
    return 0;
}

/*抬眉头*/
int enlarged_eye_detection(const float * kpts_x, const float* kpts_y, int n, int* result, char* log, int max_log_size){
    if(result == NULL || n != KEYPOINT_NB || log == NULL) {
        return -1;
    }
    
    *result = 0;
    float face_center_x, face_center_y;
    face_center_x = kpts_x[99];
    face_center_y = kpts_y[99];
    
    float* face_center_kpts_x = (float*)malloc(n * sizeof(float));
    float* face_center_kpts_y = (float*)malloc(n * sizeof(float));
    float slope = ((kpts_y[39] - kpts_y[45]) + (kpts_y[51] - kpts_y[57])) / ((kpts_x[39] - kpts_x[45]) + (kpts_x[51] - kpts_x[57]));
    
    transform_2d(kpts_x, kpts_y, n, atan(slope), face_center_x, face_center_y, face_center_kpts_x, face_center_kpts_y);
    
    /*
     left eye brow: [38, 42] [68,71]
     right eye brow: [33, 37] [64, 67]
     */
    float left_brow_min_y = MIN5(face_center_kpts_y[29], face_center_kpts_y[30], face_center_kpts_y[31], face_center_kpts_y[32], face_center_kpts_y[33]);
    float right_brow_min_y = MIN5(face_center_kpts_y[20], face_center_kpts_y[21], face_center_kpts_y[22], face_center_kpts_y[23], face_center_kpts_y[24]);
    float brow_min_y = (left_brow_min_y+right_brow_min_y)/2;
    /*
     left eye: [58, 61]
     right eye: [52,57]
     */
    float left_eye_min_y = MIN4(face_center_kpts_y[52], face_center_kpts_y[53], face_center_kpts_y[54], face_center_kpts_y[55]);
    float right_eye_min_y = MIN4(face_center_kpts_y[40], face_center_kpts_y[41], face_center_kpts_y[42], face_center_kpts_y[43]);
    float eye_min_y = (left_eye_min_y + right_eye_min_y)/2;
    
    float left_eye_width = fabs(face_center_kpts_x[51] - face_center_kpts_x[57]);
    float right_eye_width = fabs(face_center_kpts_x[39] - face_center_kpts_x[45]);
    
     
    float eye_width = (left_eye_width + right_eye_width)/2;
    
    float brow_eye_dist = eye_min_y - brow_min_y;
    
    float ratio = fabs(brow_eye_dist / eye_width);
    
    if(ratio > 1.0f){
        *result = 1;
    }
    
    snprintf(log, max_log_size, "brow_min_y:%f\neye_min_y:%f\neye_width:%f\nbrow_eye_dist:%f\nratio:%f\nresult:%d\n", brow_min_y,eye_min_y, eye_width, brow_eye_dist, ratio, *result);
    
    free(face_center_kpts_x);
    free(face_center_kpts_y);
    return 0;
}






int opened_mouse_detection(const float * kpts_x, const float* kpts_y, int n, int* result, char* log, int max_log_size) {
    if(result == NULL || n != KEYPOINT_NB || log == NULL) {
        return -1;
    }
    float face_center_x, face_center_y;
    face_center_x = kpts_x[99];
    face_center_y = kpts_y[99];
    
    float* face_center_kpts_x = (float*)malloc(n * sizeof(float));
    float* face_center_kpts_y = (float*)malloc(n * sizeof(float));
    float slope = ((kpts_y[39] - kpts_y[45]) + (kpts_y[51] - kpts_y[57])) / ((kpts_x[39] - kpts_x[45]) + (kpts_x[51] - kpts_x[57]));
    
    transform_2d(kpts_x, kpts_y, n, atan(slope), face_center_x, face_center_y, face_center_kpts_x, face_center_kpts_y);
    /*
     mouse: [84, 95]
     */
    float min_mouse_y = MIN3(face_center_kpts_y[88], face_center_kpts_y[89], face_center_kpts_y[90]);
    float max_mouse_y = MAX3(face_center_kpts_y[92], face_center_kpts_y[93], face_center_kpts_y[94]);
    float mouse_dist_y = fabs(max_mouse_y - min_mouse_y);
    float mouse_dist_x = fabs(face_center_kpts_x[81] - face_center_kpts_x[75]);
    
    //float mouse_nose_dist_y = fabs(face_center_kpts_y[87] - face_center_kpts_y[49]);
    
    float mouse_ratio = fabs(mouse_dist_y / mouse_dist_x);
    
    //if(mouse_ratio > 0.6f && mouse_dist_y > 1.0 * mouse_nose_dist_y){
    if(mouse_ratio > 0.2f){
        *result = 1;
    }
    
    snprintf(log, max_log_size, "mouse_dist_y:%f\nmouse_dist_x:%f\nratio:%f\nresult:%d\n", mouse_dist_y,mouse_dist_x, mouse_ratio,*result);
    
    free(face_center_kpts_x);
    free(face_center_kpts_y);
    return 0;
}


int forward_mouse_detection(const float * kpts_x, const float* kpts_y, int n, int* result, char* log, int max_log_size) {
    if(result == NULL || n != KEYPOINT_NB || log == NULL) {
        return -1;
    }
    float face_center_x, face_center_y;
    face_center_x = kpts_x[99];
    face_center_y = kpts_y[99];
    
    float* face_center_kpts_x = (float*)malloc(n * sizeof(float));
    float* face_center_kpts_y = (float*)malloc(n * sizeof(float));
    float slope = ((kpts_y[39] - kpts_y[45]) + (kpts_y[51] - kpts_y[57])) / ((kpts_x[39] - kpts_x[45]) + (kpts_x[51] - kpts_x[57]));
    
    transform_2d(kpts_x, kpts_y, n, atan(slope), face_center_x, face_center_y, face_center_kpts_x, face_center_kpts_y);
     /*
        mouse: [84, 95]
     */
    float max_mouse_y = MIN3(face_center_kpts_y[83], face_center_kpts_y[84], face_center_kpts_y[85]);
    float min_mouse_y = MAX3(face_center_kpts_y[77], face_center_kpts_y[78], face_center_kpts_y[79]);
    float mouse_dist_y = max_mouse_y - min_mouse_y;
    
    
    float mouse_lip_dist = fabs(face_center_kpts_y[89] - face_center_kpts_y[93]);
    float mouse_lip_height = fabs(face_center_kpts_y[78] - face_center_kpts_y[89]);
    
    float mouse_dist_x = fabs(face_center_kpts_x[81] - face_center_kpts_x[87]);
    float nose_dist_x = fabs(face_center_kpts_x[67] - face_center_kpts_x[70]);
    
    float mouse_ratio = fabs(mouse_dist_y / mouse_dist_x);
    float mouse_nose_dist_y = fabs(face_center_kpts_y[68] - face_center_kpts_y[78]);
    
    //if(mouse_ratio > 0.4 && mouse_dist_y < mouse_nose_dist_y && mouse_lip_dist > mouse_lip_height) {
        
        
    if(mouse_ratio > 0.45 && mouse_ratio < 0.9 && mouse_dist_y < 3 * mouse_nose_dist_y && mouse_lip_dist < 0.8 * mouse_lip_height) {
        *result = 1;
    }
    
    snprintf(log, max_log_size, "mouse_ratio:%f\nmouse_dist_y:%f\nmouse_nose_dist_y:%f\nmouse_lip_height:%f\nmouse_lip_dist:%f\nresult:%d\n", mouse_ratio,mouse_dist_y,mouse_nose_dist_y,mouse_lip_height, mouse_lip_dist, *result);
    
    free(face_center_kpts_x);
    free(face_center_kpts_y);
    return 0;
}


#endif







































