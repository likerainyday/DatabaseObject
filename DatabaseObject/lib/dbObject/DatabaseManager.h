//
//  DatabaseManager.h
//  DatabaseObject
//
//  Created by wangyong on 2016/11/21.
//  Copyright © 2016年 wyong.developer. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include("FMDB.h")

#import "FMDB.h"

//默认db文件名
#define kDefaultFileName @"cache.db"
//默认数据库秘钥
#define kDefaultSecretKey @"com.wyong.developer.dbObjC"

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
  更改数据库

 @param directoryPath 目录路径
 @param fileName 文件名
 */
+(void)changeDatabaseFromDirectory:(NSString *)directoryPath fileName:(NSString *)fileName;

/**
 更改数据库

 @param directoryPath 目录路径
 @param fileName 文件名
 @param secretKey 秘钥
 */
+(void)changeDatabaseFromDirectory:(NSString *)directoryPath fileName:(NSString *)fileName password:(NSString *)secretKey;

@end

#endif
