//
//  DatabaseManager.h
//  DatabaseObject
//
//  Created by wangyong on 2016/11/21.
//  Copyright © 2016年 wyong.developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

#define kDefaultFileName @"data.sqlite"

@interface DatabaseManager : NSObject

/**
 构造DatabaseManager单例

 @return DatabaseManager
 */
+(DatabaseManager *)manager;

/**
 数据库队列
 */
@property(nonatomic,retain,readonly) FMDatabaseQueue *dbQueue;

/**
 当前数据库路径
 */
@property(nonatomic,strong,readonly) NSString *dbPath;

/**
 更改数据库路径

 @param fullPath 全路径
 */
+(void)changeDatabaseFromPath:(NSString *)fullPath;

/**
  更改数据库路径

 @param directoryPath 目录路径
 @param fileName 文件名
 */
+(void)changeDatabaseFromDirectory:(NSString *)directoryPath fileName:(NSString *)fileName;

@end
