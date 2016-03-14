//
//  VerSionManage.m
//  eCarry
//
//  Created by main on 14-8-22.
//  Copyright (c) 2014年 whde. All rights reserved.
//

#import "VersionManage.h"
#import <StoreKit/StoreKit.h>
#define IS_VAILABLE_IOS8  ([[[UIDevice currentDevice] systemVersion] intValue] >= 8)
NSString * const VSERSION = @"Version";
NSString * const VSERSIONMANAGER = @"VersionManager";
@interface VersionManage()<SKStoreProductViewControllerDelegate, UIAlertViewDelegate>{
    CallBackBlock callBackBlock_;
    NSString *url_;
    NSMutableDictionary *versionManagerDic;
}
/**
 *  应用内打开Appstore
 */
- (void)openAppWithIdentifier;
@end
@implementation VersionManage
/**
 *   showAlert 设置中主动触发版本更新，
 *  @param showAlert     YES-需要提示“已经是最新”
 *  @param callBackBlock 检查完毕后可能需要做的处理
 */
- (void)checkVerSionWithCallBack:(CallBackBlock)callBackBlock {
    callBackBlock_ = [callBackBlock copy];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:VSERSIONMANAGER];
        versionManagerDic = [NSMutableDictionary dictionaryWithCapacity:0];
        if (dic) {
            [versionManagerDic addEntriesFromDictionary:dic];
        }
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appPackageName = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        NSString *firstLaunchKey = [NSString stringWithFormat:@"VersionManage_%@" , appPackageName];
        NSString *str = [versionManagerDic objectForKey:firstLaunchKey];
        if (![str boolValue]) {
            /*这个版本是第一次*/
            /*清除上一版本存储的信息*/
            /*第一次是NO*/
            /*第二次是YES*/
            [versionManagerDic removeAllObjects];
            [versionManagerDic setValue:@"YES" forKey:firstLaunchKey];
            [[NSUserDefaults standardUserDefaults] setValue:versionManagerDic forKey:VSERSIONMANAGER];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",AppStore_ID]];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    callBackBlock_();
                });
            } else {
                NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
                NSString *currentVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                NSArray *infoArray = [dic objectForKey:@"results"];
                if ([infoArray isKindOfClass:[NSArray class]] && [infoArray count]>0) {
                    NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
                    NSString *appstoreVersion = [releaseInfo objectForKey:@"version"];
                    url_ = [releaseInfo objectForKey:@"trackViewUrl"];
                    if ([[versionManagerDic valueForKey:VSERSION] isEqual:appstoreVersion]) {
                        /*记录下来的和appstoreVersion相比, 相同的表示已经检查过的版本,不需要在去提示*/
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
                            [versionManagerDic setObject:appstoreVersion forKey:VSERSION];
                            [[NSUserDefaults standardUserDefaults] setValue:versionManagerDic forKey:VSERSIONMANAGER];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (IS_VAILABLE_IOS8) {
                                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"有新版本更新" message:[NSString stringWithFormat:@"更新内容:\n%@", releaseInfo[@"releaseNotes"]] preferredStyle:UIAlertControllerStyleAlert];
                                    [alert addAction:[UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                        /*关闭*/
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            callBackBlock_();
                                        });
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
                                    return;
                                }
                            });
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
        storeProductVC.delegate = self;
        NSDictionary *dict = [NSDictionary dictionaryWithObject:AppStore_ID forKey:SKStoreProductParameterITunesItemIdentifier];
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
#pragma mark - SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            callBackBlock_();
        });
    }];
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        /*关闭*/
        dispatch_async(dispatch_get_main_queue(), ^{
            callBackBlock_();
        });
    } else {
        /*更新*/
        [self openAppWithIdentifier];
    }
}
#endif
@end
