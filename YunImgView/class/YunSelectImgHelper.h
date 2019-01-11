//
// Created by yun on 2017/5/12.
// Copyright (c) 2017 skkj. All rights reserved.
//

#import "YunImgDef.h"
#import <UIKit/UIKit.h>

@protocol YunSelectImgDelegate <NSObject>

@optional

- (void)selectImgByType:(void (^)(YunSelectImgType type))cmp
__deprecated_msg("已过期, 请使用- (void)selectItemByType:(YunSelectImgType)type cmp:(void (^)(YunSelectImgType type))cmp");

- (void)selectItemByType:(YunSelectImgType)type cmp:(void (^)(YunSelectImgType type))cmp;

@required

// 注意：imgs:压缩时，返回NSData、不压缩时，返回UIImage
- (void)didCmp:(BOOL)cmp imgs:(NSArray *)imgs selType:(YunSelectImgType)selType
__deprecated_msg(
        "已过期, 请使用- (void)didCmpWithItems:(NSArray *)items error:(NSError *)error selType:(YunSelectImgType)selType");

// 注意：imgs:压缩时，返回NSData、不压缩时，返回UIImage
- (void)didCmpWithItems:(NSArray *)items error:(NSError *)error selType:(YunSelectImgType)selType;

@end

@class YunImgData;

@interface YunSelectImgHelper : NSObject

@property (nonatomic, weak) UIViewController *superVC;

@property (nonatomic, weak) id <YunSelectImgDelegate> delegate;

@property (nonatomic, assign) YunSelectImgType selType;

// 消失动画-YES
@property (nonatomic, assign) BOOL disAmt;

// image param--------
@property (nonatomic, assign) NSInteger curCount;

@property (nonatomic, assign) NSInteger maxCount;

@property (nonatomic, assign) BOOL editImg;

// 照相的时候，保存照片，默认：NO
@property (nonatomic, assign) BOOL shouldStoreImg;

// 是否压缩图片-NO
@property (nonatomic, assign) BOOL isCompression;

// 最大大小 默认：300kb
@property (nonatomic, assign) NSInteger imgLength;

// 最大尺寸边 默认：1280
@property (nonatomic, assign) CGFloat imgBoundary;

// video param--------

// 视频最大时长：默认10s
@property (nonatomic, assign) NSTimeInterval videoMaxDuration;

// 视频最大大小：单位：kb 默认-1（无限制）
@property (nonatomic, assign) NSInteger videoLength;

// 视频录制质量：默认：UIImagePickerControllerQualityTypeHigh
@property (nonatomic, assign) UIImagePickerControllerQualityType videoQuality;

- (void)selectImg:(NSInteger)curCount
__deprecated_msg("已过期, 请使用- (void)selectItem:(NSInteger)curCount");

- (void)selectItem:(NSInteger)curCount;

+ (void)getItemData:(YunImgData *)item cmpFactor:(CGFloat)cmpFactor rst:(void (^)(NSData *data))rst;

@end