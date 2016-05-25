//
//  FEEyesFilter.m
//  FaceEffectDemo
#import "FESmallEyesFilter.h"
#import "common.h"

@interface FESmallEyesFilter()
{
    GLint _centerUniform;//旋转中心
    GLint _mouthUniform;
    GLint _eyeAUniform;//
    GLint _eyeBUniform;//
    GLint _faceLeftUniform;//
    GLint _faceRightUniform;//
    
    GLint _centersUniform;//旋转中心
    GLint _rollUniform;//旋转角度
    GLint _ratioUniform;//
    GLint _heightRatioUniform;//
    GLint _pleftUniform;//
    GLint _prightUniform;//
    GLint _fullscreen;
    GLint _alignPointUniform;
    GLint _triggersUniform;
    GLint _triggerUniform;
}

@end

@implementation FESmallEyesFilter
- (id) initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString
{
    if ((self = [super initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:fragmentShaderString]))
    {
        _centerUniform = [filterProgram uniformIndex:@"p_face_center"];
        _mouthUniform = [filterProgram uniformIndex:@"m_mouth"];
        _eyeAUniform = [filterProgram uniformIndex:@"m_eyea"];
        _eyeBUniform = [filterProgram uniformIndex:@"m_eyeb"];
        _faceLeftUniform = [filterProgram uniformIndex:@"p_faceleft"];
        _faceRightUniform = [filterProgram uniformIndex:@"p_facerright"];
        
        _centersUniform = [filterProgram uniformIndex:@"p_center"];
        _rollUniform = [filterProgram uniformIndex:@"f_rotation"];
        _prightUniform = [filterProgram uniformIndex:@"p_right_bound"];
        _pleftUniform = [filterProgram uniformIndex:@"p_left_bound"];
        _ratioUniform = [filterProgram uniformIndex:@"f_ratio"];
        _heightRatioUniform = [filterProgram uniformIndex:@"f_height_ratio"];
        _fullscreen = [filterProgram uniformIndex:@"i_fullscreen"];
        _alignPointUniform = [filterProgram uniformIndex:@"p_align"];
        _triggersUniform = [filterProgram uniformIndex:@"i_trigger"];
        _triggerUniform = [filterProgram uniformIndex:@"i_detect"];
    }
    return self;
}

- (void) setCenterValue:(CGPoint) centerValue
{
    [self setPoint:[self transformPoint:centerValue] forUniform:_centerUniform program:filterProgram];
}

- (void) setFaceLeftValue:(CGPoint) leftValue
{
    [self setPoint:[self transformPoint:leftValue] forUniform:_faceLeftUniform program:filterProgram];
}

- (void) setFaceRightValue:(CGPoint) rightValue
{
    [self setPoint:[self transformPoint:rightValue] forUniform:_faceRightUniform program:filterProgram];
}

- (void) setMouthValue:(CGPoint[]) mouthValue lenth:(GLsizei)length
{
    float pointFloat[length*2];
    for (int i=0; i<length*2; i+=2) {
        CGPoint transformCenter = CGPointMake(mouthValue[i/2].x, mouthValue[i/2].y);
        CGPoint t = [self transformPoint:transformCenter];
        pointFloat[i] = t.x;
        pointFloat[i+1] = t.y;
    }
    [self setPointArray:pointFloat length:length*2 forUniform:_mouthUniform program:filterProgram];
}

- (void) setEyesValue:(CGPoint[]) eyesValue lenth:(GLsizei)length leftOrRight:(BOOL)iFlag
{
    float pointFloat[length*2];
    for (int i=0; i<length*2; i+=2) {
        CGPoint transformCenter = CGPointMake(eyesValue[i/2].x, eyesValue[i/2].y);
        CGPoint t = [self transformPoint:transformCenter];
        pointFloat[i] = t.x;
        pointFloat[i+1] = t.y;
    }
    GLint uniform = iFlag?_eyeAUniform:_eyeBUniform;
    [self setPointArray:pointFloat length:length*2 forUniform:uniform program:filterProgram];
}

- (CGPoint)transformPoint:(CGPoint) pointValue
{
    CGPoint pointTmp;
    pointTmp.x = 1.0 - pointValue.y;
    pointTmp.y = pointValue.x;
    
    return pointTmp;
    
}

- (void) setCentersValue:(CGPoint[]) centersValue lenth:(GLsizei)length
{
    //CGPoint pointArray[length];
    float pointFloat[length*2];
    for (int i=0; i<length*2; i+=2) {
        CGPoint transformCenter = CGPointMake(centersValue[i/2].x, centersValue[i/2].y);
        pointFloat[i] = transformCenter.x;
        pointFloat[i+1] = transformCenter.y;
        //NSLog(@"[%f,%f]",pointFloat[i],pointFloat[i+1]);
    }
    
    [self setPointArray:pointFloat length:length*2 forUniform:_centersUniform program:filterProgram];
}

- (void) setAlignPointValue:(CGPoint[]) alignPointValue lenth:(GLsizei)length
{
    //CGPoint pointArray[length];
    float pointFloat[length*2];
    for (int i=0; i<length*2-1; i+=2) {
        //  CGPoint transformCenter = CGPointMake(centersValue[i/2].x, centersValue[i/2].y);
        pointFloat[i] = alignPointValue[i/2].x;
        pointFloat[i+1] = alignPointValue[i/2].y;
        
        //NSLog(@"pf %d: %f, %f", i, pointFloat[i], pointFloat[i+1]);
    }
    
    [self setPointArray:pointFloat length:length*2 forUniform:_alignPointUniform program:filterProgram];
}


- (void) setPointLeftValue:(CGPoint) pointLeftValue
{
    CGPoint transformPointLeft = CGPointMake(pointLeftValue.x, pointLeftValue.y);
    [self setPoint:transformPointLeft forUniform:_pleftUniform program:filterProgram];
}

- (void) setPointRightValue:(CGPoint) pointRightValue
{
    CGPoint transformPointRight = CGPointMake(pointRightValue.x, pointRightValue.y);
    [self setPoint:transformPointRight forUniform:_prightUniform program:filterProgram];
}

- (void) setRatiosValue:(GLfloat[]) ratios length:(GLsizei)length
{
    [self setFloatArray:ratios length:length forUniform:_ratioUniform program:filterProgram];
}


- (void) setHeightRatiosValue:(GLfloat[]) heightRatios length:(GLsizei)length
{
    [self setFloatArray:heightRatios length:length forUniform:_heightRatioUniform program:filterProgram];
}

- (void) setRollValue:(NSInteger) rollValue
{
    CGFloat realRoll = (-M_PI/2.0) - rollValue/180.0*(M_PI);
    [self setFloat:realRoll forUniform:_rollUniform program:filterProgram];
}


- (void) setFullscreensValue:(int[]) ifullscreen length:(GLsizei)length
{
    [self setIntArray:ifullscreen length:length forUniform:_fullscreen program:filterProgram];
}

- (void) setTriggersValue:(int[]) iTriggers length:(GLsizei)length
{
    for (int i=0; i < length; i++) {
        //NSLog(@"%d -> iTrigger=%d",i, iTriggers[i]);
    }
    [self setIntArray:iTriggers length:length forUniform:_triggersUniform program:filterProgram];
}

- (void) setTriggerValue:(int) iTrigger
{
    //NSLog(@"iTrigger=%d",iTrigger);
    [self setInteger:iTrigger forUniform:_triggerUniform program:filterProgram];
}
@end
