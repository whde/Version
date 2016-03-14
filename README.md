# Version
iOS软件检查更新,每次启动检测Appstore是否有更新,每一次更新只提醒一次
#使用:
```objective-c
VersionManage *manager = [[VersionManage alloc] init];
    [manager checkVerSionWithCallBack:^{
}];
```

