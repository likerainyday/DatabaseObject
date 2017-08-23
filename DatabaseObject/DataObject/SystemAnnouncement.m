//
//  SystemAnnouncement.m
//  DatabaseObject
//
//  Created by wangyong on 2016/12/5.
//  Copyright © 2016年 wyong.developer. All rights reserved.
//

#import "SystemAnnouncement.h"

@implementation SystemAnnouncement

+(NSArray <NSString *>*)ignoredProperties{

    return @[@"didRead"];
}

+(NSDictionary *)changedProperties{
    
    return @{@"content":@"content1"};
}

@end
