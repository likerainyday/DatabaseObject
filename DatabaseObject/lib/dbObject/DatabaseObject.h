//
//  DatabaseObject.h
//  DatabaseObject
//
//  Created by wangyong on 2016/11/21.
//  Copyright © 2016年 wyong.developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseManager.h"

@interface DatabaseObject : NSObject

/**
 主键
 */
@property(nonatomic,assign) NSInteger pk;

/**
 字段数组
 */
@property(nonatomic,strong,readonly) NSMutableArray *fields;

/**
 字段对应的类型数组
 */
@property(nonatomic,strong,readonly) NSMutableArray *types;

/**
 表中忽略字段

 @return 忽略字段数组
 */
+(NSArray <NSString *>*)ignoredProperties;

#pragma mark -数据库操作

/**
 插入

 @return 是否插入成功
 */
-(BOOL)saveObject;

/**
 删除

 @return 是否删除成功
 */
-(BOOL)deleteObject;

/**
 修改

 @return 是否修改成功
 */
-(BOOL)updateObject;

/**
 插入/更新数据
 
 @return 是否成功
 */
-(BOOL)saveOrUpdateObject;

/**
 插入一组数据

 @param objects 对象数组
 @return 是否成功
 */
+(BOOL)saveObjects:(NSArray *)objects;

/**
 删除一组数据

 @param objects 对象数组
 @return 是否成功
 */
+(BOOL)deleteObjects:(NSArray *)objects;

/**
 条件删除

 @param format 条件
 @return 是否删除成功
 */
+ (BOOL)deleteObjectsWithFormat:(NSString *)format, ...;

/**
 更新一组数据

 @param objects 对象数组
 @return 是否更新成功
 */
+ (BOOL)updateObjects:(NSArray *)objects;

/**
 表中所有数据

 @return 一组数据
 */
+ (NSArray *)totalObjects;

/**
 通过主键查询

 @param pk 主键
 @return 对象数据
 */
+(instancetype)objectByPK:(NSInteger)pk;

/**
 根据条件查询到第一条数据

 @param format 条件
 @return 对象数据
 */
+(instancetype)firstObjectWithFormat:(NSString *)format, ...;

/**
 根据条件查询数据

 @param format 条件
 @return 一组数据
 */
+ (NSArray *)objectsWithFormat:(NSString *)format, ...;

/**
 建表

 @return 是否成功
 */
+(BOOL)createTable;

/**
 是否存在表
 
 @return 是否存在
 */
+(BOOL)isExistTable;

/**
 清空当前表所有数据

 @return 是否清除成功
 */
+(BOOL)clearTable;

@end
