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
#define AppStore_ID @"915233927"
@interface VersionManage : NSObject 
typedef void (^CallBackBlock)();
/**
 *   showAlert 设置中主动触发版本更新，
 *  @param callBackBlock 检查完毕后可能需要做的处理
 */
- (void)checkVerSionWithCallBack:(CallBackBlock)callBackBlock;
@end
