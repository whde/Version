//
//  VerSionManage.m
//  eCarry
//
//  Created by main on 14-8-22.
//  Copyright (c) 2014年 whde. All rights reserved.
//

#import "VersionManager.h"
#import <StoreKit/StoreKit.h>
#if  __has_include(<Alert.h>)
#import "Alert.h"
#endif
#define IS_VAILABLE_IOS8  ([[[UIDevice currentDevice] systemVersion] intValue] >= 8)
NSString * const VSERSION = @"Version";
NSString * const VSERSIONMANAGER = @"VersionManager";
static VersionManager *manager = nil;
@interface VersionManager()<SKStoreProductViewControllerDelegate, UIAlertViewDelegate>{
    NSString *url_;
    NSMutableDictionary *versionManagerDic;
    NSString *_appstore_ID;
}
/**
 *  应用内打开Appstore
 */
- (void)openAppWithIdentifier;
@end
@implementation VersionManager
+ (void)checkVerSion {
    if (manager) {
        [manager checkVerSion];
    } else {
        manager = [[VersionManager alloc] init];
        [manager checkVerSion];
    }
}

- (instancetype)init {
    if (manager) {
        return manager;
    } else {
        return self = [super init];
    }
}

/**
 *   checkVerSion 设置中主动触发版本更新，
 */
- (void)checkVerSion{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:VSERSIONMANAGER];
        self->versionManagerDic = [NSMutableDictionary dictionaryWithCapacity:0];
        if (dic) {
            [self->versionManagerDic addEntriesFromDictionary:dic];
        }
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appPackageName = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        NSString *firstLaunchKey = [NSString stringWithFormat:@"VersionManage_%@" , appPackageName];
        NSString *str = [self->versionManagerDic objectForKey:firstLaunchKey];
        if (![str boolValue]) {
            /*这个版本是第一次*/
            /*清除上一版本存储的信息*/
            /*第一次是NO*/
            /*第二次是YES*/
            [self->versionManagerDic removeAllObjects];
            [self->versionManagerDic setValue:@"YES" forKey:firstLaunchKey];
            [[NSUserDefaults standardUserDefaults] setValue:self->versionManagerDic forKey:VSERSIONMANAGER];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@",[infoDictionary objectForKey:@"CFBundleIdentifier"]]];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                manager = nil;
            } else {
                NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
                NSString *currentVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                NSArray *infoArray = [dic objectForKey:@"results"];
                if ([infoArray isKindOfClass:[NSArray class]] && [infoArray count]>0) {
                    NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
                    NSString *appstoreVersion = [releaseInfo objectForKey:@"version"];
                    self->url_ = [releaseInfo objectForKey:@"trackViewUrl"];
                    self->_appstore_ID = [NSString stringWithFormat:@"%@", [releaseInfo objectForKey:@"artistId"]];
                    if ([[self->versionManagerDic valueForKey:VSERSION] isEqual:appstoreVersion]) {
                        /*记录下来的和appstoreVersion相比, 相同的表示已经检查过的版本,不需要在去提示*/
                        manager = nil;
                        return ;
                    }
                    NSArray *appstoreVersionAry = [appstoreVersion componentsSeparatedByString:@"."];
                    NSInteger appstoreCount = [appstoreVersionAry count];
                    NSArray *currentVersionAry = [currentVersion componentsSeparatedByString:@"."];
                    NSInteger currentCount = [currentVersionAry count];
                    NSInteger count = currentCount>appstoreCount?appstoreCount:currentCount;
                    for (int i = 0; i<count; i++) {
                        if ([[appstoreVersionAry objectAtIndex:i] intValue]>[[currentVersionAry objectAtIndex:i] intValue]){
                            /*appstore版本有更新*/
                            /*记录下来版本号*/
                            [self->versionManagerDic setObject:appstoreVersion forKey:VSERSION];
                            [[NSUserDefaults standardUserDefaults] setValue:self->versionManagerDic forKey:VSERSIONMANAGER];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            dispatch_async(dispatch_get_main_queue(), ^{
#if __has_include(<Alert.h>)
                                // https://github.com/whde/Alert
                                Alert *alert = [[Alert alloc] initWithTitle:@"有新版本更新" message:[NSString stringWithFormat:@"更新内容:\n%@", releaseInfo[@"releaseNotes"]] delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:@"更新", nil];
                                [alert setContentAlignment:NSTextAlignmentLeft];
                                [alert setLineSpacing:5];
                                __weak __typeof__(self) weakSelf = self;
                                [alert setClickBlock:^(Alert *alertView, NSInteger buttonIndex) {
                                    if (buttonIndex == 0) {
                                        manager = nil;
                                    } else {
                                        /*更新*/
                                        [weakSelf openAppWithIdentifier];
                                    }
                                }];
                                [alert show];
#else
                                if (IS_VAILABLE_IOS8) {
                                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"有新版本更新" message:[NSString stringWithFormat:@"更新内容:\n%@", releaseInfo[@"releaseNotes"]] preferredStyle:UIAlertControllerStyleAlert];
                                    [alert addAction:[UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                        /*关闭*/
                                        manager = nil;
                                    }]];
                                    [alert addAction:[UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                        /*更新*/
                                        [self openAppWithIdentifier];
                                    }]];
                                    UIWindow *window = nil;
                                    id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
                                    if ([delegate respondsToSelector:@selector(window)]) {
                                        window = [delegate performSelector:@selector(window)];
                                    } else {
                                        window = [[UIApplication sharedApplication] keyWindow];
                                    }
                                    [window.rootViewController presentViewController:alert animated:YES completion:nil];
                                } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"有新版本更新" message:[NSString stringWithFormat:@"更新内容:\n%@", releaseInfo[@"releaseNotes"]] delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"更新", nil];
                                    [alert show];
#endif
                                }
#endif
                            });
                            return;
                        }else if ([[appstoreVersionAry objectAtIndex:i] intValue]<[[currentVersionAry objectAtIndex:i] intValue]){
                            /*本地版本号高于Appstore版本号,测试时候出现,不会提示出来*/
                            return;
                        }else{
                            continue;
                        }
                    }
                }
            }
        }];
        [dataTask resume];
    });
}

/**
 *  应用内打开Appstore
 */
- (void)openAppWithIdentifier{
    dispatch_async(dispatch_get_main_queue(), ^{
        SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
        NSDictionary *dict = [NSDictionary dictionaryWithObject:self->_appstore_ID forKey:SKStoreProductParameterITunesItemIdentifier];
        storeProductVC.delegate = self;
        [storeProductVC loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error) {
            if (result) {
                UIWindow *window = nil;
                id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
                if ([delegate respondsToSelector:@selector(window)]) {
                    window = [delegate performSelector:@selector(window)];
                } else {
                    window = [[UIApplication sharedApplication] keyWindow];
                }
                [window.rootViewController presentViewController:storeProductVC animated:YES completion:nil];
            }
        }];
    });
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
    manager = nil;
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        /*关闭*/
        manager = nil;
    } else {
        /*更新*/
        [self openAppWithIdentifier];
    }
}
#endif
@end
