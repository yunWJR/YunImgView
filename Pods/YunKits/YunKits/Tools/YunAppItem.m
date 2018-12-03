//
// Created by yun on 2017/4/25.
// Copyright (c) 2017 yun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YunAppItem.h"
#import "YunSystemMediaHelper.h"
#import "SDImageCache.h"
#import "sys/utsname.h"
#import "YunConfig.h"
#import "YunValueVerifier.h"
#import "YunGlobalDefine.h"

@implementation YunAppItem {
}

+ (UIWindow *)appWindow {
    return [[UIApplication sharedApplication].delegate window];
}

+ (UIWindow *)getCurWindow {
    UIWindow *win = nil;

    //[UIApplication sharedApplication].keyWindow;
    for (id item in [UIApplication sharedApplication].windows) {
        if ([item class] == [UIWindow class]) {
            if (!((UIWindow *) item).hidden) {
                win = item;
                break;
            }
        }
    }
    return win;
}

+ (void)stopIdle {
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

+ (BOOL)canOpenSystemSetting {
    return UIApplicationOpenSettingsURLString != NULL;
}

+ (void)gotoSettingView {
    if (self.canOpenSystemSetting) {
        [YunSystemMediaHelper openURL:UIApplicationOpenSettingsURLString];
    }
}

+ (void)hideKb {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

+ (CGFloat)getCacheSize {
    NSUInteger imageCacheSize = [[SDImageCache sharedImageCache] getSize];
    //获取自定义缓存大小
    //用枚举器遍历 一个文件夹的内容
    //1.获取 文件夹枚举器
    NSString *myCachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:myCachePath];
    __block NSUInteger count = 0;
    //2.遍历
    for (NSString *fileName in enumerator) {
        NSString *path = [myCachePath stringByAppendingPathComponent:fileName];
        NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        count += fileDict.fileSize;//自定义所有缓存大小
    }
    // 得到是字节  转化为M
    CGFloat totalSize = ((CGFloat) imageCacheSize + count) / 1024 / 1024;
    return totalSize;
}

- (void)clearCache {
    //删除两部分
    //1.删除 sd 图片缓存
    //先清除内存中的图片缓存
    [[SDImageCache sharedImageCache] clearMemory];
    //清除磁盘的缓存
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    //2.删除自己缓存
    NSString *myCachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    [[NSFileManager defaultManager] removeItemAtPath:myCachePath error:nil];
}

+ (NSString *)getDeviceInfo {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine
                                            encoding:NSASCIIStringEncoding];

    //------------------------------Samulitor-----------------------
    if ([platform isEqualToString:@"i386"] ||
        [platform isEqualToString:@"x86_64"]) {
        return @"iPhone Simulator";
    }

    //------------------------------iPhone---------------------------
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"] ||
        [platform isEqualToString:@"iPhone3,2"] ||
        [platform isEqualToString:@"iPhone3,3"]) {
        return @"iPhone 4";
    }
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"] ||
        [platform isEqualToString:@"iPhone5,2"]) {
        return @"iPhone 5";
    }
    if ([platform isEqualToString:@"iPhone5,3"] ||
        [platform isEqualToString:@"iPhone5,4"]) {
        return @"iPhone 5c";
    }
    if ([platform isEqualToString:@"iPhone6,1"] ||
        [platform isEqualToString:@"iPhone6,2"]) {
        return @"iPhone 5s";
    }
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"] ||
        [platform isEqualToString:@"iPhone9,3"]) {
        return @"iPhone 7";
    }
    if ([platform isEqualToString:@"iPhone9,2"] ||
        [platform isEqualToString:@"iPhone9,4"]) {
        return @"iPhone 7 Plus";
    }
    if ([platform isEqualToString:@"iPhone10,1"] ||
        [platform isEqualToString:@"iPhone10,4"]) {
        return @"iPhone 8";
    }
    if ([platform isEqualToString:@"iPhone10,2"] ||
        [platform isEqualToString:@"iPhone10,5"]) {
        return @"iPhone 8 Plus";
    }
    if ([platform isEqualToString:@"iPhone10,3"] ||
        [platform isEqualToString:@"iPhone10,6"]) {
        return @"iPhone X";
    }
    if ([platform isEqualToString:@"iPhone11,8"]) return @"iPhone XR";
    if ([platform isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
    if ([platform isEqualToString:@"iPhone11,4"] ||
        [platform isEqualToString:@"iPhone11,6"]) {
        return @"iPhone XS Max";
    }

    //------------------------------iPad--------------------------
    if ([platform isEqualToString:@"iPad1,1"]) return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"] ||
        [platform isEqualToString:@"iPad2,2"] ||
        [platform isEqualToString:@"iPad2,3"] ||
        [platform isEqualToString:@"iPad2,4"]) {
        return @"iPad 2";
    }
    if ([platform isEqualToString:@"iPad3,1"] ||
        [platform isEqualToString:@"iPad3,2"] ||
        [platform isEqualToString:@"iPad3,3"]) {
        return @"iPad 3";
    }
    if ([platform isEqualToString:@"iPad3,4"] ||
        [platform isEqualToString:@"iPad3,5"] ||
        [platform isEqualToString:@"iPad3,6"]) {
        return @"iPad 4";
    }
    if ([platform isEqualToString:@"iPad4,1"] ||
        [platform isEqualToString:@"iPad4,2"] ||
        [platform isEqualToString:@"iPad4,3"]) {
        return @"iPad Air";
    }
    if ([platform isEqualToString:@"iPad5,3"] ||
        [platform isEqualToString:@"iPad5,4"]) {
        return @"iPad Air 2";
    }
    if ([platform isEqualToString:@"iPad6,3"] ||
        [platform isEqualToString:@"iPad6,4"]) {
        return @"iPad Pro 9.7-inch";
    }
    if ([platform isEqualToString:@"iPad6,7"] ||
        [platform isEqualToString:@"iPad6,8"]) {
        return @"iPad Pro 12.9-inch";
    }
    if ([platform isEqualToString:@"iPad6,11"] ||
        [platform isEqualToString:@"iPad6,12"]) {
        return @"iPad 5";
    }
    if ([platform isEqualToString:@"iPad7,1"] ||
        [platform isEqualToString:@"iPad7,2"]) {
        return @"iPad Pro 12.9-inch 2";
    }
    if ([platform isEqualToString:@"iPad7,3"] ||
        [platform isEqualToString:@"iPad7,4"]) {
        return @"iPad Pro 10.5-inch";
    }

    //------------------------------iPad Mini-----------------------
    if ([platform isEqualToString:@"iPad2,5"] ||
        [platform isEqualToString:@"iPad2,6"] ||
        [platform isEqualToString:@"iPad2,7"]) {
        return @"iPad mini";
    }
    if ([platform isEqualToString:@"iPad4,4"] ||
        [platform isEqualToString:@"iPad4,5"] ||
        [platform isEqualToString:@"iPad4,6"]) {
        return @"iPad mini 2";
    }
    if ([platform isEqualToString:@"iPad4,7"] ||
        [platform isEqualToString:@"iPad4,8"] ||
        [platform isEqualToString:@"iPad4,9"]) {
        return @"iPad mini 3";
    }
    if ([platform isEqualToString:@"iPad5,1"] ||
        [platform isEqualToString:@"iPad5,2"]) {
        return @"iPad mini 4";
    }

    //------------------------------iTouch------------------------
    if ([platform isEqualToString:@"iPod1,1"]) return @"iTouch";
    if ([platform isEqualToString:@"iPod2,1"]) return @"iTouch2";
    if ([platform isEqualToString:@"iPod3,1"]) return @"iTouch3";
    if ([platform isEqualToString:@"iPod4,1"]) return @"iTouch4";
    if ([platform isEqualToString:@"iPod5,1"]) return @"iTouch5";
    if ([platform isEqualToString:@"iPod7,1"]) return @"iTouch6";

    return platform;
}

+ (UIViewController *)getRootViewController {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    NSAssert(window, @"The window is empty");
    return window.rootViewController;
}

+ (UIViewController *)getCurrentViewController {
    UIViewController *curVc = [self getRootViewController];
    NSInteger findTimes = 0;
    while (findTimes < 9999) { // 查询9999次，避免死循环
        if (curVc.presentedViewController) {
            curVc = curVc.presentedViewController;
        }
        else if ([curVc isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (UINavigationController *) curVc;
            curVc = [navigationController.childViewControllers lastObject];
        }
        else if ([curVc isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabBarController = (UITabBarController *) curVc;
            curVc = tabBarController.selectedViewController;
        }
        else {
            NSUInteger childVcCount = curVc.childViewControllers.count;
            if (childVcCount > 0) {
                curVc = curVc.childViewControllers.lastObject;

                return curVc;
            }
            else {
                return curVc;
            }
        }

        findTimes++;
    }

    return nil;
}

+ (UIViewController *)getVisibleVcFrom:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self getVisibleVcFrom:[((UINavigationController *) vc) visibleViewController]];
    }
    else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self getVisibleVcFrom:[((UITabBarController *) vc) selectedViewController]];
    }
    else {
        if (vc.presentedViewController) {
            return [self getVisibleVcFrom:vc.presentedViewController];
        }
        else {
            return vc;
        }
    }
}

+ (BOOL)gotoAppStoreComment {
    if ([YunValueVerifier isInvalidStr:YunConfig.instance.appId]) {
        return NO;
    }

    NSString *urlStr =
            FORMAT(@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@&pageNumber=0&sortOrdering=2&mt=8",
                   YunConfig.instance.appId);

    [YunSystemMediaHelper openURL:urlStr];

    return YES;
}

+ (BOOL)gotoAppStore {
    if ([YunValueVerifier isInvalidStr:YunConfig.instance.appId]) {
        return NO;
    }

    NSString *urlStr = FORMAT(@"itms-apps://itunes.apple.com/app/id%@", YunConfig.instance.appId);

    [YunSystemMediaHelper openURL:urlStr];

    return YES;
}

+ (NSString *)appStoreUrl {
    if ([YunValueVerifier isInvalidStr:YunConfig.instance.appId]) {
        return @"";
    }

    NSString *urlStr = FORMAT(@"itms-apps://itunes.apple.com/app/id%@", YunConfig.instance.appId);

    return urlStr;
}

@end