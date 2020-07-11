# DatabaseObject

An easier way to use fmdb

如何使用：(现已修改为pods工程)

1、项目导入lib文件夹，引入libsqlite3.tbd。

2、如果使用sqlcipher，target->Build Settings->Other C Flags添加 -DSQLITE_HAS_CODEC。

3、对于需要存储在数据库里的表，创建继承DatabaseObject的子类。

4、ignoredProperties数组是你所需要忽略的字段

5、changedProperties字典用于表字段变更配置

使用示例：

1、继承DatabaseObject的子类自动在数据库中创建表

```objective-c
@interface SystemAnnouncement : DatabaseObject
@end
```

2、增 

```objective-c
NSArray *items =[self simulateData];
BOOL success =[SystemAnnouncement saveObjects:items];
NSLog(@"批量插入：%@",success?@"成功":@"失败");
```
3、查、删

```objective-c
SystemAnnouncement *lastestItem =[[SystemAnnouncement objectsWithFormat:@"order by timestamp desc"] firstObject];        
if (lastestItem) {
    BOOL success =[lastestItem deleteObject];
    NSLog(@"删除code=%@数据：%@",lastestItem.code,success?@"成功":@"失败");
}
```
4、更新 

```objective-c
SystemAnnouncement *item =[SystemAnnouncement firstObjectWithFormat:@"where code ='%@'",@"sa_0"];
if (item) {
	item.code =@"sa_2016";
	BOOL success =[item updateObject];
	NSLog(@"更新code=%@数据：%@",@"sa_0",success?@"成功":@"失败");
}
```
