//
// Created by yun on 2017/5/12.
// Copyright (c) 2017 skkj. All rights reserved.
//

#import "YunImgDef.h"
#import <UIKit/UIKit.h>

@protocol YunSelectImgDelegate <NSObject>

@optional
- (void)selectImgByType:(void (^)(YunSelectImgType type))cmp;

@required
- (void)didCmp:(BOOL)cmp imgs:(NSArray<UIImage *> *)imgs selType:(YunSelectImgType)selType;

@end

@interface YunSelectImgHelper : NSObject

@property (nonatomic, weak) id <YunSelectImgDelegate> delegate;

@property (nonatomic, assign) YunSelectImgType selType;

@property (nonatomic, weak) UIViewController *superVC;

@property (nonatomic, assign) NSInteger curCount;

@property (nonatomic, assign) NSInteger maxCount;

// 是否压缩图片-NO
@property (nonatomic, assign) BOOL isCompression;

// 压缩大小-300 kb
@property (nonatomic, assign) NSInteger compressSize;

// 消失动画-YES
@property (nonatomic, assign) BOOL disAmt;

- (void)selectImg:(NSInteger)curCount;

@end