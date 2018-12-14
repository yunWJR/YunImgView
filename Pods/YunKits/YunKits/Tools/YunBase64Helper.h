//
// Created by yun on 2018/7/23.
// Copyright (c) 2018 yun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YunBase64Helper : NSObject

+ (NSString *)getBase64FromFile:(NSString *)fileName ofType:(NSString *)type;

@end