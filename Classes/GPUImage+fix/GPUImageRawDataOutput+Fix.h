//
//  GPUImageRawDataOutput+Fix.h
//  VideoBlendTest
//
//  Created by iviktor on 15/10/21.
//  Copyright © 2015年 iviktor. All rights reserved.
//

#import "GPUImage.h"

@interface GPUImageRawDataOutput (Fix)

@property (nonatomic, strong) id<GPUImageInput> target;
@property (nonatomic) CMTime lastFrameTime;

@end
