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
// imgs 压缩时，返回DSData、不压缩时，返回 UIImage
- (void)didCmp:(BOOL)cmp imgs:(NSArray *)imgs selType:(YunSelectImgType)selType;

@end

@interface YunSelectImgHelper : NSObject

@property (nonatomic, weak) id <YunSelectImgDelegate> delegate;

@property (nonatomic, assign) YunSelectImgType selType;

@property (nonatomic, weak) UIViewController *superVC;

@property (nonatomic, assign) NSInteger curCount;

@property (nonatomic, assign) NSInteger maxCount;

@property (nonatomic, assign) BOOL editImg;

// 是否压缩图片-NO
@property (nonatomic, assign) BOOL isCompression;

// 最大大小 默认：300kb
@property (nonatomic, assign) NSInteger imgLength;

// 最大尺寸边 默认：1280
@property (nonatomic, assign) CGFloat imgBoundary;

// 消失动画-YES
@property (nonatomic, assign) BOOL disAmt;

- (void)selectImg:(NSInteger)curCount;

@end