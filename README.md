iOS软件检查更新,每次启动检测Appstore是否有更新,每一次更新只提醒一次
# Version 1.0.2
- 无需填写AppStoreID即可查询
- 一句话简单整合版本更新
- 添加了https://github.com/whde/Alert 的Framework, 无需改动即可使用Alert弹出框提示
```objective-c
pod 'WhdeVersion', '~> 1.0.2'
```
## 使用:
- 将Version文件夹导入到项目中
- 导入头文件 
```objective-c
#import "VersionManage.h"
```
- 写入代码
```objective-c
[VersionManage checkVerSion];
```

#PS:
AlertView推荐使用https://github.com/whde/Alert
```objective-c
pod 'Alert', '~> 1.0.3'
```
   - 这个Alert兼容iOS7以上
   - 支持居左/居中/居右对齐
   - 同时支持设置行间距
   - 使用方式和UIAlertView一样
   - Alert同时还支持Block形式
   - 支持横竖屏切换
<p><p>
   
![效果图](https://raw.githubusercontent.com/whde/Version/master/Version/Simulator%20Screen%20Shot%202016年3月15日%20上午11.09.25.png)

