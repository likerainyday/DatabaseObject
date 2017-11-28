//
//  NSArray+Description.m
//  DatabaseObject
//
//  Created by wangyong on 2017/8/23.
//  Copyright © 2017年 wyong.developer. All rights reserved.
//

#import "NSArray+Description.h"

@implementation NSArray (Description)

-(NSString *)descriptionWithLocale:(id)locale{
    
    NSMutableString *description = [[NSMutableString alloc]initWithString:@"["];

    for (id obj in self) {
        [description appendFormat:@"\n%@,",obj];
    }
    if ([description hasSuffix:@","]) {
        [description deleteCharactersInRange:NSMakeRange(description.length - 1, 1)];
    }
    [description appendString:@"]"];
    
    return description;
}

@end
