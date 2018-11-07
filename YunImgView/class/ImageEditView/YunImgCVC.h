//
// Created by yun on 16/12/29.
// Copyright (c) 2016 成都晟堃科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YunImgData;

extern NSString *const c_YunImgCellId_ImgItem;
extern NSString *const c_YunImgCellId_AddItem;

@interface YunImgCVC : UICollectionViewCell

- (void)setCoverImg:(UIImage *)coverImg;

- (void)setAddItem:(UIView *)addView;

- (void)setImgItem:(YunImgData *)imgData isZoom:(BOOL)isZoom;

@end