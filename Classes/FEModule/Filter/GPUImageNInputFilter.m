//
//  GPUImageNInputFilter.m
//  FaceEffectDemo
//
//  Created by Viktor Pih on 16/3/31.
//  Copyright © 2016年 Viktor Pih. All rights reserved.
//

#import "GPUImageNInputFilter.h"

#define FILTER_PROPERTY __pro
#define FILTER_PROPERTIES_FOR(index, cmd) for (int i=index; i<[_filterProperties count]; i++){FilterProperty *__pro=_filterProperties[i];cmd;};
#define FILTER_PROPERTIES_FOR_SPACE(index, space, cmd) for (int i=index; i<[_filterProperties count]-space; i++){FilterProperty *__pro=_filterProperties[i];cmd;};

#define FILTER_PROPERTIES_FOR_REVERSE(index, cmd) for (int i=(int)[_filterProperties count]-1; i>=index; i--){FilterProperty *__pro=_filterProperties[i];cmd;};

@interface FilterProperty : NSObject
{
    NSInteger _index;
}

@property GPUImageFramebuffer *inputFramebuffer;

@property GLint filterTextureCoordinateAttribute;
@property GLint filterInputTextureUniform;
@property GPUImageRotationMode inputRotation;

@property CMTime frameTime;

@property BOOL hasSetPrevTexture, hasReceivedFrame, frameWasVideo;

@property BOOL frameCheckDisabled;

+ (FilterProperty*) propertyWithIndex:(NSInteger) index;
- (id) initWithIndex:(NSInteger) index;

- (NSString*) inputTextureCoordinateName;
- (NSString*) inputImageTextureName;

- (void) setupWithProgram:(GLProgram*) program;


@end

@implementation FilterProperty

+ (FilterProperty*) propertyWithIndex:(NSInteger) index
{
    return [[FilterProperty alloc] initWithIndex:index];
}

- (id) initWithIndex:(NSInteger) index
{
    if ((self = [self init]))
    {
        _index = index;
    }
    return self;
}

- (NSString*) inputTextureCoordinateName
{
    NSString *name = @"inputTextureCoordinate";
    
    if (_index > 0)
    {
        name = [NSString stringWithFormat:@"%@%ld", name, _index+1];
    }
    return name;
}

- (NSString*) inputImageTextureName
{
    NSString *name = @"inputImageTexture";
    
    if (_index > 0)
    {
        name = [NSString stringWithFormat:@"%@%ld", name, _index+1];
    }
    return name;
}

- (void) setupWithProgram:(GLProgram*) program
{
    [GPUImageContext useImageProcessingContext];
    
    self.filterTextureCoordinateAttribute = [program attributeIndex:self.inputTextureCoordinateName];
    
    self.filterInputTextureUniform = [program uniformIndex:self.inputImageTextureName]; // This does assume a name of "inputImageTexture2" for second input texture in the fragment shader
    glEnableVertexAttribArray(self.filterTextureCoordinateAttribute);
}

@end

@interface GPUImageNInputFilter()
{
    NSArray<FilterProperty*>* _filterProperties;
    
    //CMTime firstFrameTime;
    //BOOL hasReceivedFirstFrame, firstFrameWasVideo;
    //BOOL firstFrameCheckDisabled;
}

- (NSString*) vertexShaderStringForInputNumber:(NSInteger) inputNumber extend:(NSString*) extend;

@end

@implementation GPUImageNInputFilter

- (NSString*) vertexShaderStringForInputNumber:(NSInteger) inputNumber extend:(NSString*) extend
{
    NSString *formatStr = @"attribute vec4 position;\n\
    attribute vec4 inputTextureCoordinate;\n\
    varying vec2 textureCoordinate;\n\
    %@\
    void main()\n\
    {\n\
    gl_Position = position;\n\
    textureCoordinate = inputTextureCoordinate.xy;\n\
    %@\
    %@\
    }";
    
    NSString *textureCoordinateHeader = @"";
    NSString *textureCoordinateBody = @"";
    
    for (int i=0; i<inputNumber-1; i++) {
        
        NSInteger index = i + 2;
        NSString *header = [NSString stringWithFormat:
                            @"attribute vec4 inputTextureCoordinate%d;\n\
                            varying vec2 textureCoordinate%d;\n", index, index];
        
        textureCoordinateHeader = [NSString stringWithFormat:@"%@%@", textureCoordinateHeader, header];
        
        
        NSString *body = [NSString stringWithFormat:@"textureCoordinate%d = inputTextureCoordinate%d.xy;\n", index, index];
        textureCoordinateBody = [NSString stringWithFormat:@"%@%@", textureCoordinateBody, body];
        
    }
    
    
    NSString *resultStr = [NSString stringWithFormat:formatStr, textureCoordinateHeader, textureCoordinateBody, extend];
    
    return resultStr;
}

#pragma mark -
#pragma mark Initialization and teardown

- (id) initWithInputNumber:(NSInteger) inputNumber fragmentShaderFromString:(NSString *)fragmentShaderString
{
    return [self initWithInputNumber:inputNumber vertexShaderFromString:[self vertexShaderStringForInputNumber:inputNumber extend:@""] fragmentShaderFromString:fragmentShaderString];
}

- (id) initWithInputNumber:(NSInteger) inputNumber fragmentShaderFromString:(NSString *)fragmentShaderString extendVertexShaderFromString:(NSString*) extendVertexShaderString
{
    return [self initWithInputNumber:inputNumber vertexShaderFromString:[self vertexShaderStringForInputNumber:inputNumber extend:extendVertexShaderString] fragmentShaderFromString:fragmentShaderString];
}

- (id) initWithInputNumber:(NSInteger) inputNumber vertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString
{
    if ((self = [self initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:fragmentShaderString]))
    {
        // 初始化 filterProperties
        NSMutableArray *arr = [NSMutableArray array];
        for (int i=0; i<inputNumber; i++) {
            
            FilterProperty *pro = [FilterProperty propertyWithIndex:i];
            pro.inputRotation = kGPUImageNoRotation;
            pro.hasSetPrevTexture = NO;
            pro.hasReceivedFrame = NO;
            pro.frameWasVideo = NO;
            pro.frameCheckDisabled = NO;
            pro.frameTime = kCMTimeInvalid;
            [arr addObject:pro];
        }
        _filterProperties = arr;
        
        runSynchronouslyOnVideoProcessingQueue(^{
            // 从2开始
            FILTER_PROPERTIES_FOR(1, [FILTER_PROPERTY setupWithProgram:filterProgram]);
        });
    }
    return self;
}

- (void)initializeAttributes;
{
    [super initializeAttributes];
    
    // 从2开始
    FILTER_PROPERTIES_FOR(1, [filterProgram addAttribute:FILTER_PROPERTY.inputTextureCoordinateName])
}

- (void)disableFrameCheckAtIndex:(NSInteger) index
{
    _filterProperties[index].frameCheckDisabled = YES;
}

#pragma mark -
#pragma mark Rendering

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;
{
    if (self.preventRendering)
    {
        FILTER_PROPERTIES_FOR(1, [FILTER_PROPERTY.inputFramebuffer unlock])
        
        return;
    }
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }
    
    [self setUniformsForProgramAtIndex:0];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 0
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform, 2);
    
    
    // 1
//    glActiveTexture(GL_TEXTURE3);
//    glBindTexture(GL_TEXTURE_2D, [secondInputFramebuffer texture]);
//    glUniform1i(filterInputTextureUniform2, 3);
//    glVertexAttribPointer(filterSecondTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation2]);

    FILTER_PROPERTIES_FOR(
                          1,
                          glActiveTexture(GL_TEXTURE2+i);
                          glBindTexture(GL_TEXTURE_2D, [FILTER_PROPERTY.inputFramebuffer texture]);
                          glUniform1i(FILTER_PROPERTY.filterInputTextureUniform, 2+i);
                          glVertexAttribPointer(FILTER_PROPERTY.filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:FILTER_PROPERTY.inputRotation]);
    )
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [firstInputFramebuffer unlock];
    //[secondInputFramebuffer unlock];
    FILTER_PROPERTIES_FOR(
                          1,
                          [FILTER_PROPERTY.inputFramebuffer unlock];
    )
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

#pragma mark -
#pragma mark GPUImageInput

- (NSInteger)nextAvailableTextureIndex;
{
//    if (hasSetFirstTexture)
//    {
//        return 1;
//    }
//    else
//    {
//        return 0;
//    }
    
    FILTER_PROPERTIES_FOR_REVERSE(1,
                          if (FILTER_PROPERTY.hasSetPrevTexture)
                          return i;
    )
    return 0;
}

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex;
{
    if (textureIndex == 0)
    {
        firstInputFramebuffer = newInputFramebuffer;
        [firstInputFramebuffer lock];
    }
    else
    {
        _filterProperties[textureIndex].inputFramebuffer = newInputFramebuffer;
        [_filterProperties[textureIndex].inputFramebuffer lock];
    }
    
    if (textureIndex < [_filterProperties count]-1)
        _filterProperties[textureIndex+1].hasSetPrevTexture = YES;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;
{
    if (textureIndex == 0)
    {
        [super setInputSize:newSize atIndex:textureIndex];
    }
    
    if (textureIndex < [_filterProperties count]-1)
    {
        if (CGSizeEqualToSize(newSize, CGSizeZero))
        {
            _filterProperties[textureIndex+1].hasSetPrevTexture = NO;
        }
    }
}

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;
{
    if (textureIndex == 0)
    {
        inputRotation = newInputRotation;
    }
    else
    {
        _filterProperties[textureIndex].inputRotation = newInputRotation;
    }
}

- (CGSize)rotatedSize:(CGSize)sizeToRotate forIndex:(NSInteger)textureIndex;
{
    CGSize rotatedSize = sizeToRotate;
    
    GPUImageRotationMode rotationToCheck;
    if (textureIndex == 0)
    {
        rotationToCheck = inputRotation;
    }
    else
    {
        rotationToCheck = _filterProperties[textureIndex].inputRotation;
    }
    
    if (GPUImageRotationSwapsWidthAndHeight(rotationToCheck))
    {
        rotatedSize.width = sizeToRotate.height;
        rotatedSize.height = sizeToRotate.width;
    }
    
    return rotatedSize;
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    // You can set up infinite update loops, so this helps to short circuit them
    
    BOOL over = YES;
    FILTER_PROPERTIES_FOR(0,
                          if (!FILTER_PROPERTY.hasReceivedFrame)
                          {
                              over = NO;
                              break;
                          }
    )
    if (over)
        return;
    
//    if (hasReceivedFirstFrame && hasReceivedSecondFrame)
//    {
//        return;
//    }
    
    BOOL updatedMovieFrameOppositeStillImage = NO;
    
    if (textureIndex == 0)
    {
//        hasReceivedFirstFrame = YES;
//        firstFrameTime = frameTime;
//        if (secondFrameCheckDisabled)
//        {
//            hasReceivedSecondFrame = YES;
//        }
        
        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            if CMTIME_IS_INDEFINITE(_filterProperties[1].frameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    else
    {
//        hasReceivedSecondFrame = YES;
//        secondFrameTime = frameTime;
//        if (firstFrameCheckDisabled)
//        {
//            hasReceivedFirstFrame = YES;
//        }
        
        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            if CMTIME_IS_INDEFINITE(_filterProperties[0].frameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    
    _filterProperties[textureIndex].hasReceivedFrame = YES;
    _filterProperties[textureIndex].frameTime = frameTime;
    
    for (int i=0; i<[_filterProperties count]; i++) {
        if (i != textureIndex)
        {
            if (_filterProperties[i].frameCheckDisabled)
            {
                _filterProperties[textureIndex].hasReceivedFrame = YES;
            }
        }
    }
    
    
    // || (hasReceivedFirstFrame && secondFrameCheckDisabled) || (hasReceivedSecondFrame && firstFrameCheckDisabled)
    //if ((hasReceivedFirstFrame && hasReceivedSecondFrame) || updatedMovieFrameOppositeStillImage)
    
    BOOL allReceived = YES;
    FILTER_PROPERTIES_FOR(0,
                          if (!FILTER_PROPERTY.hasReceivedFrame)
                          {
                              allReceived = NO;
                              break;
                          }
                          )
    
    if (allReceived || updatedMovieFrameOppositeStillImage)
    {
        static const GLfloat imageVertices[] = {
            -1.0f, -1.0f,
            1.0f, -1.0f,
            -1.0f,  1.0f,
            1.0f,  1.0f,
        };
        
        [self renderToTextureWithVertices:imageVertices textureCoordinates:[[self class] textureCoordinatesForRotation:inputRotation]];
        
        [self informTargetsAboutNewFrameAtTime:frameTime];
        
//        hasReceivedFirstFrame = NO;
//        hasReceivedSecondFrame = NO;
//        hasReceivedThirdFrame = NO;
//        hasReceivedFourthFrame = NO;
        FILTER_PROPERTIES_FOR(0,
                              FILTER_PROPERTY.hasReceivedFrame = NO;
        )
    }
}


@end
