# Version
iOS软件检查更新,每次启动检测Appstore是否有更新,每一次更新只提醒一次
## 使用:
- 将Version文件夹导入到项目中
- 导入头文件 
```objective-c
#import "VersionManage.h"
```
- 写入代码
```objective-c
VersionManage *manager = [[VersionManage alloc] init];
[manager checkVerSionWithCallBack:^{
}];
```

PS:AlertView推荐使用https://github.com/whde/Alert
   这个Alert兼容iOS7以上
   支持居左/居中/居右对齐
   同时支持设置行间距
   使用方式和UIAlertView一样
   Alert同时还支持Block形式
