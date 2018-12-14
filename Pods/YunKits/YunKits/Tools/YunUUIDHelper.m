//
// Created by yun on 2018/4/11.
// Copyright (c) 2018 成都晟堃科技有限责任公司. All rights reserved.
//

#import "YunUUIDHelper.h"

@interface YunUUIDHelper () {
}

@end

@implementation YunUUIDHelper

+ (NSString *)uuid {
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);

    NSString *uuidStr = (NSString *) CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidRef));

    CFRelease(uuidRef);

    return uuidStr;
}

@end