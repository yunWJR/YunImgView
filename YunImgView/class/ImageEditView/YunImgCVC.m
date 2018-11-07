//
// Created by yun on 16/12/29.
// Copyright (c) 2016 成都晟堃科技有限责任公司. All rights reserved.
//

#import "YunImgCVC.h"
#import "YunImgData.h"
#import "YunUIImageViewFactory.h"
#import <Masonry/Masonry.h>

NSString *const c_YunImgCellId_ImgItem = @"YunImgCellId_ImgItem";
NSString *const c_YunImgCellId_AddItem = @"YunImgCellId_AddItem";

@implementation YunImgCVC {
    UIView *_addView;
    UIImageView *_imgView;
    UIImageView *_coverView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }

    return self;
}

#pragma mark - handles

#pragma mark - public functions

- (void)setCoverImg:(UIImage *)coverImg {
    if (coverImg == nil) {
        if (_coverView) {
            _coverView.hidden = YES;
        }
        return;
    }

    if (_coverView == nil) {
        _coverView = [YunUIImageViewFactory imgViewWithImgName:@"" mode:UIViewContentModeScaleAspectFill];

        [self addSubview:_coverView];

        [_coverView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self);
            make.size.equalTo(self);
        }];
    }

    _coverView.image = coverImg;

    [self bringSubviewToFront:_coverView];

    _coverView.hidden = NO;
}

- (void)setAddItem:(UIView *)addView {
    if (_addView == nil) {
        [self removeAllSubView];

        _addView = addView;

        [self addSubview:_addView];

        [_addView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self);
            make.size.equalTo(self);
        }];
    }
}

- (void)setImgItem:(YunImgData *)imgData isZoom:(BOOL)isZoom {
    if (_imgView == nil) {
        [self removeAllSubView];

        _imgView = [self itemView];

        [self addSubview:_imgView];

        [_imgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self);
            make.size.equalTo(self);
        }];
    }

    [imgData setImgInView:_imgView isZoom:isZoom];
}

- (void)removeAllSubView {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}

#pragma mark - private functions

- (UIImageView *)itemView {
    UIImageView *imgView = [YunUIImageViewFactory imgView];

    return imgView;
}

@end