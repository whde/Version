//
//  VersionManage.h
//  eCarry
//
//  Created by main on 14-8-22.
//  Copyright (c) 2014年 whde. All rights reserved.
//

/*
 VersionManager = {
 ----Version=3.0.4,
 ----VersionManage_3.0.4
 }
 数据存储在NSUserDefaults中,key为VersionManager;
 Version为记录已经检查过的Appstore版本号;作用是:当前版本未升级,Appstore升级了很多版本,保证每一个版本都能提示
 VersionManage_3.0.4为VersionManager+当前App版本号,作用是:能够在第一次清除以前版本的记录的数据,避免重复提示
 */


#import <Foundation/Foundation.h>
@interface VersionManager : NSObject
+ (void)checkVerSion;
@end
