//
//  Created by 王健 on 16/6/2.
//  Copyright © 2016年 成都晟堃科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YunImgDef.h"

@protocol YunImgListViewDelegate <NSObject>

- (void)viewSizeChanged;

- (void)didShowImg;

- (YunSelectImgType)selectImgByType;

@end

@class YunImgData;

@interface YunImgListView : UIView

@property (nonatomic, weak) id <YunImgListViewDelegate> delegate;

@property (nonatomic, assign) NSInteger maxCount;
@property (nonatomic, assign) NSInteger rowNum;
@property (nonatomic, assign) CGFloat sideOff;
@property (nonatomic, assign) CGFloat interval;
@property (nonatomic, assign) CGSize cellSize;

@property (nonatomic, assign) BOOL shouldStoreImg; // 是否存储照片
@property (nonatomic, assign) BOOL forceDel; // 没有编辑，也可以删除照片

@property (nonatomic, assign) BOOL hasAddBtn; // 是否默认有新增按钮

@property (nonatomic, assign) YunSelectImgType selType; // 是否只能用相机

- (instancetype)initWithRowNum:(NSInteger)rowNum;

- (void)selectImg:(void (^)(BOOL))cmp;

- (void)selectImg;

- (void)resetImgByImgList:(NSArray<YunImgData *> *)imgList;

- (void)resetImgByImgUrlList:(NSArray *)imgList;

- (void)addImgByImg:(UIImage *)image;

- (void)addImgByInfoList:(NSArray<YunImgData *> *)imgList;

- (void)addImgByUrlTypeImg:(NSArray *)url;

- (void)addImgByUrlStrsList:(NSArray *)url;

- (void)addImgDataByUrlStr:(NSString *)url;

- (void)removeAllImg;

- (void)reloadImgData;

- (NSMutableArray<YunImgData *> *)curImgList;

- (BOOL)isSameImgs:(NSArray<YunImgData *> *)imgs;

- (CGFloat)curHeight;

- (void)setViewWidth:(CGFloat)width refresh:(BOOL)refresh;

- (void)updateViewWidth:(CGFloat)width andEidt:(BOOL)isEdit;

- (void)setEdit:(BOOL)isEdit;

@end