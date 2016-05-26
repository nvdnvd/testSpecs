//
//  FEEffectFilter.m
//  FaceEffectDemo
//
//  Created by Viktor Pih on 16/3/29.
//  Copyright © 2016年 Viktor Pih. All rights reserved.
//

#import "FEEffectFilter.h"

@interface FEEffectFilter()
{
    NSDictionary<NSString*,NSString*> *_facePoints;             // CGPoint
    NSMutableDictionary<NSString*,NSValue*> *_finalFacePoints;  // CGPoint
    
    GLint _timeUniform;
    GLint _detectUniform;
}

@end

@implementation FEEffectFilter

- (id) initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString
{
    if ((self = [super initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:fragmentShaderString]))
    {
        _finalFacePoints = [NSMutableDictionary dictionary];
        
        _timeUniform = [filterProgram uniformIndex:@"m_time"];
        _detectUniform = [filterProgram uniformIndex:@"m_detect"];
    }
    return self;
}

//- (id)init;
//{
//    NSString *extend = @"textureCoordinate.y = 1.0 - textureCoordinate.y;"; // 追加强制翻转的代码
//    return [self initWithInputNumber:5 fragmentShaderFromString:kFEEffectFragmentShaderString extendVertexShaderFromString:extend];
//}

- (void)setUniformsForProgramAtIndex:(NSUInteger)programIndex;
{
    [super setUniformsForProgramAtIndex:programIndex];
    
    for (NSString *key in _finalFacePoints) {
        
        CGPoint point = [(NSValue*)_finalFacePoints[key] CGPointValue];
        //NSLog(@"key: %@ value: %@", key, NSStringFromCGPoint(point));
        //[self setPoint:point forUniformName:key];
        
        
        // 注意：为了适应faceu的demo，将y翻转
        //point.y = 1.0-point.y;
        
        GLint uniformIndex = [filterProgram uniformIndex:key];
        
        //NSLog(@"%@-> %f, %f", key, point.x, point.y);
        glUniform2f(uniformIndex, point.x, point.y);
    }
    
    static CGFloat time = 0;
    time += 0.1;
    
    glUniform1f(_timeUniform, time);
}

- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    runSynchronouslyOnVideoProcessingQueue(^{
        
        [_finalFacePoints removeAllObjects];
        
        for (NSString *key in _facePoints) {
            
            CGPoint point = CGPointFromString(_facePoints[key]);
            //point.x /= filterFrameSize.width;
            //point.y /= filterFrameSize.height;
            
//            if ([key isEqualToString:@"p_eyea"])
//            NSLog(@"key: %@ value: %@", key, NSStringFromCGPoint(point));
            
            _finalFacePoints[key] = [NSValue valueWithCGPoint:point];
        }
        
        
    });
}



- (void) setFacePoints:(NSDictionary*) facePoints
{
    _facePoints = facePoints;
    [self setupFilterForSize:[self sizeOfFBO]];
    
    //NSLog(@"size: %f, %f", [self sizeOfFBO].width, [self sizeOfFBO].height);
}

- (void) setDetectValue:(CGFloat) detectValue
{
    //NSLog(@"m_detect:%f", detectValue);
    [self setFloat:detectValue forUniform:_detectUniform program:filterProgram];
}

@end
