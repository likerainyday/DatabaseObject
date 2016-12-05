//
//  SystemAnnouncement.h
//  DatabaseObject
//
//  Created by wangyong on 2016/12/5.
//  Copyright © 2016年 wyong.developer. All rights reserved.
//

#import "DatabaseObject.h"
/**
 系统公告
 */
@interface SystemAnnouncement : DatabaseObject

/**
 公告id
 */
@property(nonatomic,copy) NSString *code;

/**
 标题
 */
@property(nonatomic,copy) NSString *title;

/**
 内容
 */
@property(nonatomic,copy) NSString *content;

/**
 时间戳
 */
@property(nonatomic,copy) NSString *timestamp;

/**
 是否已读
 */
@property(nonatomic,assign) BOOL didRead;

@end
