//
//  DataManager
//
//
//  Created by 王聪 on 1/12/16.
//  Copyright © 2016 王聪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

@interface DataManager : NSObject
{
}
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(DataManager)

@property (nonatomic, readonly)NSArray *typeList;
@property (nonatomic, readonly)NSArray *itemList;

- (NSArray*)itemFromDic:(NSInteger)index;
@end


