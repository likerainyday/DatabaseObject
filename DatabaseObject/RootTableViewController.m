//
//  RootTableViewController.m
//  DatabaseObject
//
//  Created by wangyong on 2016/12/5.
//  Copyright © 2016年 wyong.developer. All rights reserved.
//

#import "RootTableViewController.h"
#import "SystemAnnouncement.h"
#import "NSArray+Description.h"

@interface RootTableViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) NSArray *arrayOfData;

@end

@implementation RootTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title =@"DatabaseObject";
    self.arrayOfData =@[
                        @"数据库文件路径",
                        @"所有数据",
                        @"批量新增数据",
                        @"删除数据",
                        @"更新数据",
                        @"清空数据"
                        ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -UITableViewDataSource&&UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.arrayOfData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier =@"RootTableViewCellId";
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell ==nil) {
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor =[UIColor whiteColor];
    }
    NSString *title =self.arrayOfData[indexPath.row];
    cell.textLabel.text =title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case 0:
        {
            NSString *dbPath =[DatabaseManager manager].dbPath;
            NSLog(@"当前数据库路径：%@",dbPath);
        }
            break;
        case 1:
        {
            NSArray *cache =[SystemAnnouncement totalObjects];
            NSLog(@"%@表中所有数据：%@",NSStringFromClass(SystemAnnouncement.class),cache);
        }
            break;
        case 2:
        {
            NSArray *items =[self simulateData];
            BOOL success =[SystemAnnouncement saveObjects:items];
            NSLog(@"批量插入：%@",success?@"成功":@"失败");
        }
            break;
        case 3:
        {
            SystemAnnouncement *lastestItem =[[SystemAnnouncement objectsWithFormat:@"order by timestamp desc"] firstObject];
            if (lastestItem) {
                BOOL success =[lastestItem deleteObject];
                NSLog(@"删除code=%@数据：%@",lastestItem.code,success?@"成功":@"失败");
            }
        }
            break;
        case 4:
        {
            SystemAnnouncement *item =[SystemAnnouncement firstObjectWithFormat:@"where code ='%@'",@"sa_0"];
            if (item) {
                item.code =@"sa_2016";
                BOOL success =[item updateObject];
                NSLog(@"更新code=%@数据：%@",@"sa_0",success?@"成功":@"失败");
            }
        }
            break;
        case 5:
        {
            BOOL success =[SystemAnnouncement clearTable];
            NSLog(@"清空%@数据：%@",NSStringFromClass(SystemAnnouncement.class),success?@"成功":@"失败");
        }
            break;
        default:
            break;
    }
}

-(NSArray <SystemAnnouncement *>*)simulateData{
    
    SystemAnnouncement *item1 =[[SystemAnnouncement alloc]init];
    item1.code = @"sa_0";
    item1.title =@"标题1";
    item1.content =@"iOS快速创建常用UI，使代码更加整洁并且提高开发效率";
    item1.timestamp =@"1470264120";
    
    SystemAnnouncement *item2 =[[SystemAnnouncement alloc]init];
    item2.code = @"sa_1";
    item2.title =@"标题2";
    item2.content =@"让不懂编程的人爱上iPhone开发系列教程";
    item2.timestamp =@"1479785400";
    
    SystemAnnouncement *item3 =[[SystemAnnouncement alloc]init];
    item3.code = @"sa_2";
    item3.title =@"标题3";
    item3.content =@"如何设计APP唤起落地页，促进用户增长？";
    item3.timestamp =@"1473208380";
    
    return @[item1,item2,item3];
}

@end
