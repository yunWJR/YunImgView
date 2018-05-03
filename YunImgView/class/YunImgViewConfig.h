//
// Created by yun on 2017/11/28.
// Copyright (c) 2017 skkj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YunImgViewConfig : NSObject

// 默认300kb
@property (nonatomic, assign) NSInteger maxImgLength;

// 默认1280
@property (nonatomic, assign) CGFloat maxImgBoundary;

+ (YunImgViewConfig *)instance;

@end