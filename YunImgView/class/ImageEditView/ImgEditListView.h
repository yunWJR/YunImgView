//
//  Created by 王健 on 16/6/2.
//  Copyright © 2016年 成都晟堃科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YunImgData;

@interface ImgEditListView : UIView

@property (nonatomic, copy) void (^imgListViewChanged)();

@property (nonatomic, copy) void (^didShowImg)();

@property (nonatomic, assign) NSInteger maxCount;
@property (nonatomic, assign) NSInteger rowNum;
@property (nonatomic, assign) CGFloat sideOffset;
@property (nonatomic, assign) CGFloat interval;
@property (nonatomic, assign) CGSize cellSize;

@property (nonatomic, assign) BOOL shouldStoreImg; // 是否存储照片
@property (nonatomic, assign) BOOL forceDel; // 没有编辑，也可以删除照片

@property (nonatomic, assign) BOOL hasAddBtn; // 是否默认有新增按钮

@property (nonatomic, assign) BOOL isCameraOnly; // 是否只能用相机

- (instancetype)initWithRowNum:(NSInteger)rowNum;

- (void)selectAvr:(void (^)(BOOL))cmp;

- (void)selectAvr;

- (void)resetImagesByImageInfoList:(NSArray<YunImgData *> *)imgList;

- (void)addImageByImage:(UIImage *)image;

- (void)addImagesByImageInfoList:(NSArray<YunImgData *> *)imgList;

- (void)addImagesByURLTypeInfo:(NSArray *)url;

- (void)addImageByURLStrs:(NSArray *)url;

- (void)addImgDataByURLStr:(NSString *)url;

- (void)removeAllImage;

- (void)reloadImgData;

- (NSMutableArray<YunImgData *> *)currentImageList;

- (BOOL)isSameImgs:(NSArray<YunImgData *> *)imgs;

- (CGFloat)currentHeight;

- (void)setViewWidth:(CGFloat)width refresh:(BOOL)refresh;

- (void)updateViewWidth:(CGFloat)width andEidt:(BOOL)isEdit;

- (void)setEdit:(BOOL)isEdit;

@end