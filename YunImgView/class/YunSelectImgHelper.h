//
// Created by yun on 2017/5/12.
// Copyright (c) 2017 skkj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YunImgDef.h"

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

@property (nonatomic) NSInteger maxCount;

@property (nonatomic, assign) BOOL isCompression;

- (void)selectImg:(NSInteger)curCount;

- (void)notiCmp:(BOOL)hasImg imgs:(NSArray<UIImage *> *)imgs;

@end