//
// Created by yun on 2017/11/28.
// Copyright (c) 2017 skkj. All rights reserved.
//

#import "YunImgViewConfig.h"

@interface YunImgViewConfig () {
}

@end

@implementation YunImgViewConfig

+ (YunImgViewConfig *)instance {
    static YunImgViewConfig *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _maxImgLength = 300;
        _maxImgBoundary = 1280;

        _videoLength = -1;
        _videoMaxDuration = 10;
        _videoQuality = UIImagePickerControllerQualityTypeHigh;

        _imgPsmMsg = @"我们将使用%@图片，以添加记录";
    }

    return self;
}

@end