//
// Created by yun on 16/7/2.
// Copyright (c) 2016 成都晟堃科技有限责任公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YunQnHelper : NSObject

@property (nonatomic, copy) NSString *zoomPara;

+ (YunQnHelper *)instance;

- (NSURL *)zoomURL:(NSString *)url;

- (NSURL *)norURL:(NSString *)url;

@end