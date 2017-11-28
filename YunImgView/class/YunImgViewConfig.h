//
// Created by yun on 2017/11/28.
// Copyright (c) 2017 skkj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YunImgViewConfig : NSObject

// 默认300kb
@property (nonatomic, assign) NSInteger compressSize;

+ (YunImgViewConfig *)instance;

@end