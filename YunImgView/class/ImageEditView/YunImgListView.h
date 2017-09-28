//
//  Created by 王健 on 16/6/2.
//  Copyright © 2016年 成都晟堃科技有限责任公司. All rights reserved.
//

#import "YunImgDef.h"
#import <UIKit/UIKit.h>

@protocol YunImgListViewDelegate <NSObject>

@optional
- (void)viewSizeChanged;

- (void)didShowImg;

- (void)selectImgByType:(void (^)(YunSelectImgType type))cmp;

@end

@class YunImgData;

@interface YunImgListView : UIView

@property (nonatomic, weak) id <YunImgListViewDelegate> delegate;

// 3
@property (nonatomic, assign) NSInteger rowNum;

// 9
@property (nonatomic, assign) NSInteger maxCount;

@property (nonatomic, assign) CGFloat sideOff;
@property (nonatomic, assign) CGFloat interval;
@property (nonatomic, assign) CGSize cellSize;

// NO
@property (nonatomic, assign) BOOL shouldStoreImg; // 是否存储照片

// NO
@property (nonatomic, assign) BOOL forceDel; // 没有编辑，也可以删除照片

@property (nonatomic, assign) BOOL hasAddBtn; // 是否默认有新增按钮

@property (nonatomic, assign) BOOL isCompression;

@property (nonatomic, assign) BOOL isZoom;

@property (nonatomic, assign) YunSelectImgType selType; // 是否只能用相机

@property (nonatomic, strong) UIColor *itemBgColor;

@property (nonatomic, strong) UIView *cstAddView;

- (instancetype)initWithRowNum:(NSInteger)rowNum;

- (void)selectImg:(void (^)(BOOL changed))cmp;

- (void)selectImg;

- (void)resetImgByImgList:(NSArray<YunImgData *> *)imgList;

- (void)resetImgByImgUrlList:(NSArray *)imgList;

- (void)addImgByImg:(UIImage *)image;

- (void)addImgByInfoList:(NSArray<YunImgData *> *)imgList;

- (void)addImgByUrlTypeImg:(NSArray *)urlList;

- (void)addImgByUrlStrList:(NSArray *)urlList;

- (void)addImgDataByUrlStr:(NSString *)url;

- (void)removeAllImg;

- (void)reloadImgData;

- (NSMutableArray<YunImgData *> *)curImgList;

- (BOOL)isSameImgs:(NSArray<YunImgData *> *)imgList;

- (CGFloat)curHeight;

- (void)setViewWidth:(CGFloat)width refresh:(BOOL)refresh;

- (void)updateViewWidth:(CGFloat)width andEidt:(BOOL)isEdit;

- (void)setEdit:(BOOL)isEdit;

@end