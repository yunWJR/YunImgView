//
//  NSError+YunAdd.m
//
// Created by yun on 16/12/1.
// Copyright (c) 2017 yun. All rights reserved.
//

#import "NSError+YunAdd.h"

NSString *const yun_error_custom_msg_key = @"yun_error_custom_msg_key";

@implementation NSError (YunAdd)

+ (instancetype)errorWithCustomMsg:(NSString *)msg {
    return [self errorWithCustomMsg:msg andCode:-1 andDomain:nil];
}

+ (instancetype)errorWithCustomMsg:(NSString *)msg andCode:(NSInteger)code andDomain:(NSString *)domain {
    if (msg == nil) {msg = @"no_error_msg";}
    if (domain == nil) {domain = @"yun_error_custom";}

    return [[NSError alloc] initWithDomain:domain code:code userInfo:@{yun_error_custom_msg_key : msg}];
}

+ (instancetype)errorWithCustomMsg:(NSString *)msg andCode:(NSInteger)code {
    return [self errorWithCustomMsg:msg andCode:code andDomain:nil];
}

+ (instancetype)errorWithCustomCode:(NSInteger)code {
    return [self errorWithCustomMsg:nil andCode:code andDomain:nil];
}

- (NSString *)getErrorMsg {
    id customInfo = self.userInfo[yun_error_custom_msg_key];
    if (customInfo) {
        return customInfo;
    }

    return self.localizedDescription;
}

@end