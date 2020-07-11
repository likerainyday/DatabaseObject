//
//  DatabaseManager.m
//  DatabaseObject
//
//  Created by wangyong on 2016/11/21.
//  Copyright © 2016年 wyong.developer. All rights reserved.
//

#import "DatabaseManager.h"

#if __has_include("FMDB.h")

#import "DatabaseObject.h"
#import <objc/runtime.h>

@implementation DatabaseManager

/**
 单例

 @return DatabaseManager
 */
+(DatabaseManager *)manager{
    static DatabaseManager *manager =nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *cachePath =[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        manager =[[DatabaseManager alloc]init];
        [manager updateDatabaseFromPath:cachePath password:kDefaultSecretKey];
    });
    return manager;
}

/**
 变更数据库

 @param directoryPath 目录路径
 @param fileName 文件名
 */
+(void)changeDatabaseFromDirectory:(NSString *)directoryPath fileName:(NSString *)fileName{
    NSString *fullPath =[directoryPath stringByAppendingPathComponent:fileName];
    [[DatabaseManager manager] updateDatabaseFromPath:fullPath password:nil];
}

/**
  变更数据库

 @param directoryPath 目录路径
 @param fileName 文件名
 @param secretKey 秘钥
 */
+(void)changeDatabaseFromDirectory:(NSString *)directoryPath fileName:(NSString *)fileName password:(NSString *)secretKey{
    NSString *fullPath =[directoryPath stringByAppendingPathComponent:fileName];
    [[DatabaseManager manager] updateDatabaseFromPath:fullPath password:secretKey];
}

/**
 更新数据库

 @param fullPath 路径
 @param secretKey 数据库路径
 */
-(void)updateDatabaseFromPath:(NSString *)fullPath password:(NSString *)secretKey{

    BOOL needUpdateObject =NO;
    if (_dbQueue) {
        _dbQueue =nil;
        needUpdateObject =YES;
    }
    NSFileManager *fm =[NSFileManager defaultManager];
    BOOL isDirectory,isExist;
    isExist =[fm fileExistsAtPath:fullPath isDirectory:&isDirectory];
    if (isDirectory) {
        if (!isExist)
            [fm createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
        fullPath =[fullPath stringByAppendingPathComponent:kDefaultFileName];
    }else{
        NSString *directoryPath =[fullPath stringByDeletingLastPathComponent];
        isExist =[fm fileExistsAtPath:directoryPath isDirectory:nil];
        if (!isExist)
            [fm createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    _dbQueue =[[FMDatabaseQueue alloc] initWithPath:fullPath];
    //设置加密数据库秘钥
    if ([secretKey isKindOfClass:NSString.class] &&secretKey.length>0) {
        [_dbQueue inDatabase:^(FMDatabase*db) {
            [db setKey:secretKey];
        }];
//        FMDatabase *db =[_dbQueue valueForKey:@"_db"];
//        if (db) {
//            [db setKey:secretKey];
//        }
    }
    _dbPath =fullPath;
    if (!needUpdateObject) {
        return;
    }
    int numClasses;
    Class *classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    
    if (numClasses > 0 ){
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; i++) {
            //读取工程内所有继承DatabaseObject的类
            if (class_getSuperclass(classes[i])==NSClassFromString(@"DatabaseObject")) {
                id object =classes[i];
                //更新表结构
                [object performSelector:@selector(createTable) withObject:nil];
            }
        }
        free(classes);
    }
}

@end

#endif
