//
//  Created by 王健 on 16/6/2.
//  Copyright © 2016年 成都晟堃科技有限责任公司. All rights reserved.
//

#import "YunImgDef.h"
#import <UIKit/UIKit.h>

@class MWPhotoBrowser;

@protocol YunImgListViewDelegate <NSObject>

@optional

- (void)viewSizeChanged;

- (void)didShowImg;

- (void)selectImgByType:(void (^)(YunSelectImgType type))cmp
__deprecated_msg("已过期, 请使用- (void)selectItemByType:(YunSelectImgType)type cmp:(void (^)(YunSelectImgType type))cmp");

- (void)selectItemByType:(YunSelectImgType)type cmp:(void (^)(YunSelectImgType type))cmp;

- (BOOL)shouldShowImg:(NSInteger)index;

- (void)initWithMWPhotoBrowser:(MWPhotoBrowser *)browser;

@end

@class YunImgData;

@interface YunImgListView : UIView

@property (nonatomic, weak) id <YunImgListViewDelegate> delegate;

// 默认：3
@property (nonatomic, assign) NSInteger rowNum;

// 默认：9
@property (nonatomic, assign) NSInteger maxCount;

// 布局
@property (nonatomic, assign) CGFloat sideOff;
@property (nonatomic, assign) CGFloat interval;
@property (nonatomic, assign) CGSize cellSize;

// 照相的时候，保存照片，默认：NO
@property (nonatomic, assign) BOOL shouldStoreImg;

// 不是编辑状态，也可以删除照片，默认：NO
@property (nonatomic, assign) BOOL forceDel;

// 可以选择视频
@property (nonatomic, assign) BOOL selVideo;

// 是否显示新增按钮，默认：YES
@property (nonatomic, assign) BOOL hasAddBtn;

// 自定义新增按钮
@property (nonatomic, strong) UIView *cstAddView;

// 视频 coverView
@property (nonatomic, strong) UIImage *videoCoverImg;

// 添加图片时，是否压缩，默认：NO
@property (nonatomic, assign) BOOL isCompression;

// 各单元格显示图压缩片，默认：YES。（建议YES）
@property (nonatomic, assign) BOOL isZoom;

// 是否只能用相机，默认：YunImgSelByCameraAndPhotoAlbum
@property (nonatomic, assign) YunSelectImgType selType;

// 设定单元格背景色
@property (nonatomic, strong) UIColor *itemBgColor;

- (instancetype)initWithRowNum:(NSInteger)rowNum;

// get

- (NSMutableArray<YunImgData *> *)curImgList;

- (BOOL)isSameImgs:(NSArray<YunImgData *> *)imgList;

- (CGFloat)curHeight;

// add

- (void)addImgByImg:(UIImage *)image;

- (void)addImgByInfoList:(NSArray<YunImgData *> *)imgList;

- (void)addImgByUrlTypeImg:(NSArray *)urlList;

- (void)addImgByUrlStrList:(NSArray *)urlList;

- (void)addImgDataByUrlStr:(NSString *)url;

// reset

- (void)resetImgByImgList:(NSArray<YunImgData *> *)imgList;

- (void)resetImgByImgUrlList:(NSArray *)imgList;

- (void)removeAllImg;

// select

- (void)selectImg:(void (^)(BOOL changed))cmp;

// other

- (void)reloadImgData;

- (void)setViewWidth:(CGFloat)width refresh:(BOOL)refresh;

- (void)updateViewWidth:(CGFloat)width andEidt:(BOOL)isEdit;

- (void)setEdit:(BOOL)isEdit;

@end