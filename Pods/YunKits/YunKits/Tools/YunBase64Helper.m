//
// Created by yun on 2018/7/23.
// Copyright (c) 2018 yun. All rights reserved.
//

#import "YunBase64Helper.h"

@interface YunBase64Helper () {
}

@end

@implementation YunBase64Helper

+ (NSString *)getBase64FromFile:(NSString *)fileName ofType:(NSString *)type {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:type];

    // Create NSData object
    NSData *data = [NSData dataWithContentsOfFile:filePath];

    // Get NSString from NSData object in Base64
    NSString *base64Encoded = [data base64EncodedStringWithOptions:0];

    return base64Encoded;
}

@end