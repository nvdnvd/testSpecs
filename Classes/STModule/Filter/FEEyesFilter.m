//
//  FEEyesFilter.m
//  FaceEffectDemo
#import "FEEyesFilter.h"
#import "common.h"

@interface FEEyesFilter()
{
    //NSDictionary<NSString*,NSString*> *_facePoints;             // CGPoint
    //NSMutableDictionary<NSString*,NSValue*> *_finalFacePoints;  // CGPoint
    
    GLint _centerUniform;//旋转中心
    GLint _rollUniform;//旋转角度
    GLint _eyeAUniform;//
    GLint _eyeBUniform;//
    GLint _faceLeftUniform;//
    GLint _faceRightUniform;//
}

@end

@implementation FEEyesFilter
- (id) initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString
{
    if ((self = [super initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:fragmentShaderString]))
    {
        //_finalFacePoints = [NSMutableDictionary dictionary];
        

        _centerUniform = [filterProgram uniformIndex:@"p_face_center"];
        _rollUniform = [filterProgram uniformIndex:@"m_roll"];
        
        _eyeAUniform = [filterProgram uniformIndex:@"m_eyea"];
        _eyeBUniform = [filterProgram uniformIndex:@"m_eyeb"];
        _faceLeftUniform = [filterProgram uniformIndex:@"p_faceleft"];
        _faceRightUniform = [filterProgram uniformIndex:@"p_facerright"];
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


- (void) setRollValue:(NSInteger) rollValue
{
    //rollValue =  rollValue - 90.0;
    [self setFloat:rollValue forUniform:_rollUniform program:filterProgram];
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

@end
