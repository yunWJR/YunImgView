//
// Created by yun on 16/12/29.
// Copyright (c) 2016 成都晟堃科技有限责任公司. All rights reserved.
//

#import "YunImgCVC.h"
#import "YunImgData.h"
#import <Masonry/Masonry.h>
#import "YunUIImageViewFactory.h"

@implementation YunImgCVC {
    UIView *_addView;
    UIImageView *_imgView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }

    return self;
}

#pragma mark - handles

#pragma mark - public functions

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

- (void)setImgItem:(YunImgData *)imgData {
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

    [imgData setImgInView:_imgView phImg:nil isZoom:NO];
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