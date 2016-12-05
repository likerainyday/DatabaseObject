# DatabaseObject

An easier way to use fmdb

如何使用：

1、项目导入lib文件夹，引入libsqlite3.tbd。

2、lib里面默认包含sqlCipher。sqlCipher是用于对sqlite文件设置密码，密码在kDatabasePassword宏定义修改。如果使用sqlCipher，需要在target->Build Settings->Other C Flags添加： -DSQLITE_HAS_CODEC、 -DSQLITE_THREADSAFE、 -DSQLCIPHER_CRYPTO_CC、 -DSQLITE_TEMP_STORE=2。

3、对于需要数据库操作的数据，继承DatabaseObject基类。

使用示例：

1、集成DatabaseObject类自动在数据库中创建表

![QQ20161205-1@2x](/Users/yitong/Desktop/QQ20161205-1@2x.png)

2、增 ![QQ20161205-2@2x](/Users/yitong/Desktop/QQ20161205-2@2x.png)

3、查、删![QQ20161205-3@2x](/Users/yitong/Desktop/QQ20161205-3@2x.png)

4、更新 ![QQ20161205-4@2x](/Users/yitong/Desktop/QQ20161205-4@2x.png)