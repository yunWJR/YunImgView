//
// Created by yun on 2016/11/24.
// Copyright (c) 2017 yun. All rights reserved.
//

#import "YunAppInfo.h"
#import "YunValueVerifier.h"

@implementation YunAppInfo {
}

#pragma mark - version

+ (NSString *)appVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)appVersionStr {
    return [[NSMutableString stringWithString:self.appVersion]
                             stringByReplacingOccurrencesOfString:@"."
                                                       withString:@""];
}

+ (NSArray<NSString *> *)versionArr:(NSString *)version {
    return [version componentsSeparatedByString:@"."];
}

+ (BOOL)shouldUpdate:(NSString *)serverVersion {
    NSArray<NSString *> *curA = [self versionArr:[self appVersion]];
    NSArray<NSString *> *srvA = [self versionArr:serverVersion];

    if (curA.count != srvA.count) {
        return NO;
    }

    for (int i = 0; i < curA.count; ++i) {
        if (![YunValueVerifier isPureInt:curA[i]] || ![YunValueVerifier isPureInt:srvA[i]]) {return NO;}

        NSInteger curV = [curA[i] integerValue];
        NSInteger serV = [srvA[i] integerValue];
        if (curV < serV) {
            return YES;
        }
        else if (curV == serV) {
            continue;
        }
        else {
            return NO;
        }
    }

    return NO;
}

+ (NSString *)bundleVersion {
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];

    return version;
}

#pragma mark - info

+ (NSString *)bundleIdentifier {
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];

    return version;
}

+ (NSString *)bundleDisplayName {
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];

    return version;
}

+ (NSString *)bundleName {
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];

    return version;
}

@end