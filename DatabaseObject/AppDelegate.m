//
//  AppDelegate.m
//  DatabaseObject
//
//  Created by wangyong on 2016/12/5.
//  Copyright © 2016年 wyong.developer. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

/*
 lib文件包含3个文件夹
 1、fmdb：优秀的三方数据库处理工具。需要引入libsqlite3.tbd
 2、sqlCipher：对sqlite文件的加密类。需要在target->Build Settings->Other C Flags添加：
 -DSQLITE_HAS_CODEC、
 -DSQLITE_THREADSAFE、
 -DSQLCIPHER_CRYPTO_CC、
 -DSQLITE_TEMP_STORE=2。
 FMDatabase.h中：#define kDatabasePassword @"wyong_sqlite_2016"用于设置数据库密码
 3、dbManager：基于fmdb对NSObject的二次封装，对于需要存储的数据类，直接继承DatabaseObject基类，直接使用类或者类的实例对象进行(批量)数据的增删改查。
 */

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
