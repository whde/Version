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

