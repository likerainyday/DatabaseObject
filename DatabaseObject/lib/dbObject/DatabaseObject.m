//
//  DatabaseObject.m
//  DatabaseObject
//
//  Created by wangyong on 2016/11/21.
//  Copyright © 2016年 wyong.developer. All rights reserved.
//

#import "DatabaseObject.h"

#if __has_include("FMDB.h")

#import <objc/runtime.h>

/*SQLite数据类型*/
//文本类型
#define kSQLiteText @"TEXT"
//整型
#define kSQLiteInteger @"INTEGER"
//浮点型
#define kSQLiteReal @"REAL"
//二进制类型
#define kSQLiteBlob @"BLOB"
//空值
#define kSQLiteNull @"NULL"

#define kSQLitePrimaryKey @"pk"

@implementation DatabaseObject

+ (void)initialize{
    if (self !=[DatabaseObject self]) {
        [self createTable];
    }
}

-(id)init{
    if (self=[super init]) {
        NSDictionary *dict =[self.class propertyDictionary];
        _fields =[[NSMutableArray alloc] initWithArray:[dict objectForKey:@"name"]];
        _types =[[NSMutableArray alloc] initWithArray:[dict objectForKey:@"type"]];
    }
    return self;
}

-(id)initWithResultSet:(FMResultSet *)resultSet{
    if (self=[self init]) {
        for (int i=0; i< _fields.count; i++) {
            NSString *name =[_fields objectAtIndex:i];
            NSString *type =[_types objectAtIndex:i];
            if ([kSQLiteText isEqualToString:type]) {
                [self setValue:[resultSet stringForColumn:name] forKey:name];
            }else if ([kSQLiteBlob isEqualToString:type]) {
                [self setValue:[resultSet dataForColumn:name] forKey:name];
            }else{
                [self setValue:[NSNumber numberWithLongLong:[resultSet longLongIntForColumn:name]] forKey:name];
            }
        }
    }
    return self;
}

-(NSString *)description{
    
    NSDictionary *dict =[self.class propertyDictionary];
    NSMutableArray *proNames =[dict objectForKey:@"name"];

    if (proNames.count>0) {
        NSString *result =@"";
        for (int i = 0; i < proNames.count; i++) {
            NSString *proName = [proNames objectAtIndex:i];
            id  proValue = [self valueForKey:proName];
            BOOL isLast =i==proNames.count-1;
            result = [result stringByAppendingFormat:@"\n\t%@ = %@%@",proName,proValue,isLast?@"\n":@""];
        }
        result =[NSString stringWithFormat:@"{%@}",result];
        return result;
    }
    return [super description];
}

+(NSArray <NSString *>*)ignoredProperties{
    return @[];
}

+(NSDictionary*)changedProperties{
    return @{};
}

+(NSDictionary *)propertyDictionary{

    NSMutableArray *nameArray =[[NSMutableArray alloc]initWithObjects:kSQLitePrimaryKey, nil];
    NSMutableArray *typeArray =[[NSMutableArray alloc]initWithObjects:[NSString stringWithFormat:@"%@ %@",kSQLiteInteger,@"primary key"], nil];
    NSArray *ignoredArray =[[self class] ignoredProperties];
    
    unsigned int outCount, i;
    objc_property_t *properties =class_copyPropertyList([self class], &outCount);
    
    for (i =0; i < outCount; i++) {
        objc_property_t property =properties[i];
        //获取属性名
        NSString *propertyName =[NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        if ([ignoredArray containsObject:propertyName]) {
            continue;
        }
        [nameArray addObject:propertyName];
        //获取属性类型等参数
        NSString *propertyType =[NSString stringWithCString: property_getAttributes(property) encoding:NSUTF8StringEncoding];
        if ([propertyType hasPrefix:@"T@\"NSString\""]) {
            //字符串
            [typeArray addObject:kSQLiteText];
        }else if ([propertyType hasPrefix:@"T@\"NSData\""]) {
            //数据流
            [typeArray addObject:kSQLiteBlob];
        }else if ([propertyType hasPrefix:@"Ti"]||[propertyType hasPrefix:@"TI"]||[propertyType hasPrefix:@"Ts"]||[propertyType hasPrefix:@"TS"]||[propertyType hasPrefix:@"TB"]||[propertyType hasPrefix:@"Tq"]||[propertyType hasPrefix:@"TQ"]) {
            //Integer
            [typeArray addObject:kSQLiteInteger];
        }else {
            //近似数据类型
            [typeArray addObject:kSQLiteReal];
        }
    }
    free(properties);
    return @{@"name":nameArray,@"type":typeArray};
}

-(NSMutableArray *)saveValuesAndKeyString:(NSString **)keyString valueString:(NSString **)valueString{
    
    NSString *tempKey =@"",*tempValue =@"";
    NSMutableArray *insertValues =[NSMutableArray  array];
    
    for (NSString *propertyName in self.fields) {
        if ([propertyName isEqualToString:kSQLitePrimaryKey]) {
            continue;
        }
        NSString *itemString =[NSString stringWithFormat:@"%@,",propertyName];
        tempKey =[tempKey stringByAppendingString:itemString];
        tempValue =[tempValue stringByAppendingString:@"?,"];
        id value =[self valueForKey:propertyName]?:@"";
        [insertValues addObject:value];
    }
    if ([tempKey hasSuffix:@","])
        *keyString =[tempKey substringToIndex:tempKey.length-1];
    if ([tempValue hasSuffix:@","])
        *valueString =[tempValue substringToIndex:tempValue.length-1];
    
    return insertValues;
}

-(NSMutableArray *)updateValuesAndKeyString:(NSString **)keyString{
    
    NSString *tempString =@"";
    NSMutableArray *updateValues =[NSMutableArray  array];
    
    for (NSString *propertyName in self.fields) {
        if ([propertyName isEqualToString:kSQLitePrimaryKey]) {
            continue;
        }
        NSString *itemString =[NSString stringWithFormat:@" %@=?,",propertyName];
        tempString =[tempString stringByAppendingString:itemString];
        id value =[self valueForKey:propertyName]?:@"";
        [updateValues addObject:value];
    }
    if ([tempString hasSuffix:@","])
        *keyString =[tempString substringToIndex:tempString.length-1];
    
    return updateValues;
}

#pragma mark -数据库操作

- (BOOL)saveObject{
    
    __block BOOL success =NO;
    NSString *tableName =NSStringFromClass(self.class);
    NSString *keyString,*valueString;
    NSMutableArray *saveValues =[self saveValuesAndKeyString:&keyString valueString:&valueString];
    
    [[DatabaseManager manager].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql =[NSString stringWithFormat:@"insert into %@(%@) values (%@);", tableName, keyString, valueString];
        success =[db executeUpdate:sql withArgumentsInArray:saveValues];
        self.pk =success?[NSNumber numberWithLongLong:db.lastInsertRowId].intValue:0;
    }];
    return success;
}

-(BOOL)deleteObject{

    if (!self.pk || self.pk <=0) {
        return NO;
    }
    __block BOOL success =NO;
    NSString *tableName =NSStringFromClass(self.class);

    [[DatabaseManager manager].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql =[NSString stringWithFormat:@"delete from %@ where %@ =?",tableName,kSQLitePrimaryKey];
        success =[db executeUpdate:sql withArgumentsInArray:@[[self valueForKey:kSQLitePrimaryKey]]];
    }];
    return success;
}

-(BOOL)updateObject{
    
    if (!self.pk || self.pk <=0) {
        return NO;
    }
    
    __block BOOL success =NO;
    NSString *tableName =NSStringFromClass(self.class);
    NSString *keyString;
    NSMutableArray *updateValues =[self updateValuesAndKeyString:&keyString];
    
    [[DatabaseManager manager].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql =[NSString stringWithFormat:@"update %@ set %@ where %@ =?;", tableName, keyString, kSQLitePrimaryKey];
        [updateValues addObject:[self valueForKey:kSQLitePrimaryKey]];
        success =[db executeUpdate:sql withArgumentsInArray:updateValues];
    }];
    return success;
}

-(BOOL)saveOrUpdateObject{
    
    return (self.pk <=0)?[self saveObject]:[self updateObject];
}

+(BOOL)saveObjects:(NSArray *)objects{

    for (id dataObject in objects) {
        if (![dataObject isKindOfClass:[DatabaseObject class]]) {
            return NO;
        }
    }
    __block BOOL success =YES;
    NSString *tableName =NSStringFromClass(self.class);
    //事务模式操作
    [[DatabaseManager manager].dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (DatabaseObject *object in objects) {
            NSString *keyString,*valueString;
            NSMutableArray *saveValues =[object saveValuesAndKeyString:&keyString valueString:&valueString];
            NSString *sql =[NSString stringWithFormat:@"insert into %@(%@) values (%@);", tableName, keyString, valueString];
            BOOL flag =[db executeUpdate:sql withArgumentsInArray:saveValues];
            object.pk =flag?[NSNumber numberWithLongLong:db.lastInsertRowId].intValue:0;
            if (!flag) {
                success =NO;
                *rollback =YES;
                return;
            }
        }
    }];
    return success;
}

+(BOOL)deleteObjects:(NSArray *)objects{

    for (id dataObject in objects) {
        if (![dataObject isKindOfClass:[DatabaseObject class]]) {
            return NO;
        }
    }
    __block BOOL success =YES;
    NSString *tableName =NSStringFromClass(self.class);
    //事务模式操作
    [[DatabaseManager manager].dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (DatabaseObject *object in objects) {
            id primaryValue =[object valueForKey:kSQLitePrimaryKey];
            if (!primaryValue || primaryValue <=0) {
                return ;
            }
            NSString *sql =[NSString stringWithFormat:@"delete from %@ where %@ =?",tableName,kSQLitePrimaryKey];
            BOOL flag =[db executeUpdate:sql withArgumentsInArray:@[primaryValue]];
            if (!flag) {
                success =NO;
                *rollback =YES;
                return;
            }
        }
    }];
    return success;
}

+ (BOOL)deleteObjectsWithFormat:(NSString *)format, ...{

    va_list ap;
    va_start(ap, format);
    NSString *string =[[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:ap];
    va_end(ap);
    
    __block BOOL success =NO;
    NSString *tableName =NSStringFromClass(self.class);

    [[DatabaseManager manager].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql =[NSString stringWithFormat:@"delete from %@ %@ ",tableName,string];
        success =[db executeUpdate:sql];
    }];
    return success;
}

+ (BOOL)updateObjects:(NSArray *)objects{

    for (id dataObject in objects) {
        if (![dataObject isKindOfClass:[DatabaseObject class]]) {
            return NO;
        }
    }
    __block BOOL success =YES;
    NSString *tableName =NSStringFromClass(self.class);
    //事务模式操作
    [[DatabaseManager manager].dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (DatabaseObject *object in objects) {
            id primaryValue =[object valueForKey:kSQLitePrimaryKey];
            if (!primaryValue || primaryValue <=0) {
                success =NO;
                *rollback =YES;
                return;
            }
            NSString *keyString;
            NSMutableArray *updateValues =[object updateValuesAndKeyString:&keyString];
            NSString *sql =[NSString stringWithFormat:@"update %@ set %@ where %@ =?;", tableName, keyString, kSQLitePrimaryKey];
            [updateValues addObject:[object valueForKey:kSQLitePrimaryKey]];
            BOOL flag =[db executeUpdate:sql withArgumentsInArray:updateValues];
            if (!flag) {
                success =NO;
                *rollback =YES;
                return;
            }
        }
    }];
    return success;
}

+ (NSArray *)totalObjects{

    NSMutableArray *objects =[NSMutableArray new];
    
    [[DatabaseManager manager].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName =NSStringFromClass(self.class);
        NSString *sql =[NSString stringWithFormat:@"select * from %@",tableName];
        FMResultSet *resultSet =[db executeQuery:sql];
        while ([resultSet next]) {
            DatabaseObject *object =[[self.class alloc] initWithResultSet:resultSet];
            [objects addObject:object];
            FMDBRelease(object);
        }
    }];
    return [[NSArray alloc]initWithArray:objects];
}

+(instancetype)objectByPK:(NSInteger)pk{

    NSString *sql =[NSString stringWithFormat:@"where %@=%ld",kSQLitePrimaryKey,(long)pk];
    return [self firstObjectWithFormat:sql];
}

+(instancetype)firstObjectWithFormat:(NSString *)format, ...{

    va_list ap;
    va_start(ap, format);
    NSString *sql =[[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:ap];
    va_end(ap);

    NSArray *results =[self.class queryObjectsWithString:sql];
    return (results&&results.count>=1)?[results firstObject]:nil;
}

+ (NSArray *)objectsWithFormat:(NSString *)format, ...{

    va_list ap;
    va_start(ap, format);
    NSString *sql =[[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:ap];
    va_end(ap);
    
    return [self.class queryObjectsWithString:sql];
}

+ (NSArray *)queryObjectsWithString:(NSString *)string{
    
    NSMutableArray *objects =[NSMutableArray new];
    NSString *tableName =NSStringFromClass(self.class);

    [[DatabaseManager manager].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql =[NSString stringWithFormat:@"select * from %@ %@",tableName,string];
        FMResultSet *resultSet =[db executeQuery:sql];
        while ([resultSet next]) {
            DatabaseObject *object =[[self.class alloc] initWithResultSet:resultSet];
            [objects addObject:object];
            FMDBRelease(object);
        }
    }];
    return [[NSArray alloc]initWithArray:objects];
}

+(BOOL)createTable{
    
    __block BOOL success =YES;
    
    [[DatabaseManager manager].dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *tableName =NSStringFromClass(self.class);
        NSString *fieldString =@"";
        NSDictionary *dict =[self.class propertyDictionary];
        NSArray *names =[dict objectForKey:@"name"];
        NSArray *types =[dict objectForKey:@"type"];
        for (NSInteger i=0; i<names.count; i++) {
            NSString *itemString =[NSString stringWithFormat:@"%@ %@,",names[i],types[i]];
            fieldString =[fieldString stringByAppendingString:itemString];
        }
        if ([fieldString hasSuffix:@","]) {
            fieldString =[fieldString substringToIndex:fieldString.length-1];
        }
        NSString *sql =[NSString stringWithFormat:@"create table if not exists %@(%@);",tableName,fieldString];
        if (![db executeUpdate:sql]) {
            success =NO;
            *rollback =YES;
            return;
        };
        //处理数据库表升级情况
        NSMutableArray *columns =[NSMutableArray array];
        FMResultSet *resultSet =[db getTableSchema:tableName];
        while ([resultSet next]) {
            NSString *column =[resultSet stringForColumn:@"name"];
            [columns addObject:column];
        }
        NSPredicate *changePredicate =[NSPredicate predicateWithFormat:@"not (self in %@)",names];
        NSArray *changedArray =[columns filteredArrayUsingPredicate:changePredicate];
        if (changedArray && changedArray.count>0) {
            //原表字段有减少或者字段变更
            //1、修改原表名
            NSString *renameSql =[NSString stringWithFormat:@"alter table '%@' rename to '%@-temporary';",tableName,tableName];
            if (![db executeUpdate:renameSql]) {
                success =NO;
                *rollback =YES;
                return ;
            }
            //2、创建新表
            NSString *createSql =[NSString stringWithFormat:@"create table if not exists %@(%@);",tableName,fieldString];
            if (![db executeUpdate:createSql]) {
                success =NO;
                *rollback =YES;
                return;
            };
            NSString *strItem1=@"",*strItem2 =@"";
            for (NSString *newItem in names) {
                NSString *changedProperty =[[self changedProperties] objectForKey:newItem];
                if (changedProperty && [columns containsObject:changedProperty]){
                    strItem1 =[strItem1 stringByAppendingString:[NSString stringWithFormat:@"%@,",newItem]];
                    strItem2 =[strItem2 stringByAppendingString:[NSString stringWithFormat:@"%@,",changedProperty]];
                }else  if ([columns containsObject:newItem]) {
                    strItem1 =[strItem1 stringByAppendingString:[NSString stringWithFormat:@"%@,",newItem]];
                    strItem2 =[strItem2 stringByAppendingString:[NSString stringWithFormat:@"%@,",newItem]];
                }
            }
            if (strItem1.length>1) {
                strItem1 =[strItem1 substringToIndex:strItem1.length-1];
                strItem2 =[strItem2 substringToIndex:strItem2.length-1];
            }
            //3、导入数据
            NSString *insertSql =[NSString stringWithFormat:@"insert into '%@'(%@) select %@ from '%@-temporary';",tableName,strItem1,strItem2,tableName];
            if (![db executeUpdate:insertSql]) {
                success =NO;
                *rollback =YES;
                return;
            };
            //4、删除临时表
            NSString *dropSql =[NSString stringWithFormat:@"drop table '%@-temporary';",tableName];
            if (![db executeUpdate:dropSql]) {
                success =NO;
                *rollback =YES;
                return;
            };
        }else{
            NSPredicate *filterPredicate =[NSPredicate predicateWithFormat:@"not (self in %@)",columns];
            NSArray *resultArray =[names filteredArrayUsingPredicate:filterPredicate];
            for (NSString *column in resultArray) {
                //原表的基础上新增了字段
                NSUInteger index =[names indexOfObject:column];
                NSString *proType =[[dict objectForKey:@"type"] objectAtIndex:index];
                NSString *fieldSql =[NSString stringWithFormat:@"%@ %@",column,proType];
                NSString *sql =[NSString stringWithFormat:@"alter table %@ add column %@ ",NSStringFromClass(self.class),fieldSql];
                if (![db executeUpdate:sql]) {
                    success =NO;
                    *rollback =YES;
                    return ;
                }
            }
        }
    }];
    return success;
}

+(BOOL)isExistTable{
    
    __block BOOL success =NO;
    NSString *tableName =NSStringFromClass(self.class);
    
    [[DatabaseManager manager].dbQueue inDatabase:^(FMDatabase *db) {
        success =[db tableExists:tableName];
    }];
    return success;
}

+(BOOL)clearTable{

    __block BOOL success =NO;
    NSString *tableName =NSStringFromClass(self.class);
    
    [[DatabaseManager manager].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql =[NSString stringWithFormat:@"delete from %@",tableName];
        success =[db executeUpdate:sql];
    }];
    return success;
}

@end

#endif
