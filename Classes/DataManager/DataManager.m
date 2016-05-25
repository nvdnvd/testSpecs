//
//  MOAudioManager.m
//  Monodrama
//
//  Created by 王聪 on 1/12/16.
//  Copyright © 2016 王聪. All rights reserved.
//

#import "DataManager.h"
#import "Common.h"

#define KResourceList           @"ResourceList.txt"

@interface DataManager()
@property (nonatomic, strong) NSDictionary *paramsDic;
@end

@implementation DataManager
SYNTHESIZE_SINGLETON_FOR_CLASS(DataManager)

- (id)init
{
    self = [super init];
    if(self)
    {
        self.paramsDic = [self parsingParams];
        [self typeListFromDic];
    }
    return self;
}

//浏览
- (NSDictionary*) parsingParams
{
    NSError *error = nil;
    NSURL *paramsURL = [[NSBundle mainBundle] URLForResource:KResourceList withExtension:@""];
    //NSString* stringPath = [filePath absoluteString]; //this is correct
    //NSString *dir = [stringPath stringByDeletingLastPathComponent];
    //NSURL *paramsURL = [NSURL URLWithString:[dir stringByAppendingPathComponent:KResourceList]];
    
    NSData *data = [NSData dataWithContentsOfURL:paramsURL];
    id resultString = [NSJSONSerialization JSONObjectWithData:data
                                                      options:NSJSONReadingMutableLeaves
                                                        error:&error];
    if (error)
    {
        NSLog(@"Prasing Resource list Error:%@",error);
    }
    //NSLog(@"resultString=%@",resultString);
    
    return resultString;
}

- (NSInteger)typeListFromDic
{
    NSInteger typeCount = 0;
    if([self.paramsDic objectForKey:@"categories"] == nil)
    {
        return 0;
    }
    typeCount = [self.paramsDic[@"categories"] count];
    //NSLog(@"type count=%ld", (long)typeCount);
    NSArray *reslist = self.paramsDic[@"categories"];
    NSMutableArray *resType = [NSMutableArray new];
    for (int i = 0; i<typeCount; i++)
    {
        NSString *typeName = reslist[i][@"typeName"];
        [resType addObject:typeName];
    }
    _typeList = resType;
    return typeCount;
}

- (NSArray*)itemFromDic:(NSInteger)index
{
    if((_typeList.count == 0)||(index >= _typeList.count))
    {
        return nil;
    }
    NSArray *reslist = self.paramsDic[@"categories"];
    NSDictionary *itemDic = reslist[index];
    
    if([itemDic objectForKey:@"resList"]==nil)
    {
        return nil;
    }
    
    NSArray *itemResList = [NSArray arrayWithArray:[itemDic objectForKey:@"resList"]];
    
    return itemResList;
}

@end
