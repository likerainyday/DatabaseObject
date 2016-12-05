//
//  DatabaseManager.m
//  DatabaseObject
//
//  Created by wangyong on 2016/11/21.
//  Copyright © 2016年 wyong.developer. All rights reserved.
//

#import "DatabaseManager.h"
#import "DatabaseObject.h"
#import <objc/runtime.h>

@implementation DatabaseManager

+(DatabaseManager *)manager{

    static DatabaseManager *manager =nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager =[[DatabaseManager alloc]init];
        [manager updateDatabaseFromPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]];
    });
    
    return manager;
}

+(void)changeDatabaseFromPath:(NSString *)fullPath{
    
    [[DatabaseManager manager] updateDatabaseFromPath:fullPath];
}

+(void)changeDatabaseFromDirectory:(NSString *)directoryPath fileName:(NSString *)fileName{

    NSString *fullPath =[directoryPath stringByAppendingPathComponent:fileName];
    [[DatabaseManager manager] updateDatabaseFromPath:fullPath];
}

-(void)updateDatabaseFromPath:(NSString *)fullPath{

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
            if (class_getSuperclass(classes[i])==NSClassFromString(@"DatabaseObject")) {
                id object =classes[i];
                [object performSelector:@selector(createTable) withObject:nil];
            }
        }
        free(classes);
    }
}

@end
