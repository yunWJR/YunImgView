//
// Created by yun on 16/12/29.
// Copyright (c) 2016 成都晟堃科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YunImgData;

#define ImageEditCellId_ImgItem @"ImageEditCellId_ImgItem"
#define ImageEditCellId_AddItem @"ImageEditCellId_AddItem"

@interface ImageEditCVC : UICollectionViewCell

- (void)setAddItem:(UIView *)addView;

- (void)setImgItem:(YunImgData *)imgData;

@end