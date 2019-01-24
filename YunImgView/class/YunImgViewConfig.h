//
// Created by yun on 2017/11/28.
// Copyright (c) 2017 skkj. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YunSelectImgDelegate;

@interface YunImgViewConfig : NSObject

@property (nonatomic, weak) id <YunSelectImgDelegate> delegate;

// 默认300kb
@property (nonatomic, assign) NSInteger maxImgLength;

// 默认1280
@property (nonatomic, assign) CGFloat maxImgBoundary;

// 单位：kb 默认-1（无限制）
@property (nonatomic, assign) NSInteger videoLength;

// 默认10s
@property (nonatomic, assign) NSTimeInterval videoMaxDuration;

// 默认：UIImagePickerControllerQualityTypeHigh
@property (nonatomic, assign) UIImagePickerControllerQualityType videoQuality;

/// 相机相册请求权限文言
@property (nonatomic, copy) NSString *imgPsmMsg;

+ (YunImgViewConfig *)instance;

@end