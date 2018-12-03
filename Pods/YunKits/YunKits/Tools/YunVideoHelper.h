//
// Created by yun on 2017/6/29.
// Copyright (c) 2017 yun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YunVideoHelper : NSObject {
}

/// 获取一个视频的第一帧图片
+ (UIImage *)getVideoCoverImgByPath:(NSString *)filepath;

/// 获取视频的时长
+ (NSInteger)getVideoTimeByPath:(NSString *)filepath;

@end