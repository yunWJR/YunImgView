//
// Created by yun on 16/12/29.
// Copyright (c) 2016 成都晟堃科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YunImgData;

#define YunImgCellId_ImgItem @"YunImgCellId_ImgItem"
#define YunImgCellId_AddItem @"YunImgCellId_AddItem"

@interface YunImgCVC : UICollectionViewCell

- (void)setAddItem:(UIView *)addView;

- (void)setImgItem:(YunImgData *)imgData;

@end