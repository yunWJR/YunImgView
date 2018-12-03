//
// Created by yun on 2017/6/29.
// Copyright (c) 2017 yun. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "YunVideoHelper.h"

@implementation YunVideoHelper

// 获取一个视频的第一帧图片
+ (UIImage *)getVideoCoverImgByPath:(NSString *)filepath {
    NSURL *url = [NSURL URLWithString:filepath];
    AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
    generate1.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 2);
    CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
    UIImage *one = [[UIImage alloc] initWithCGImage:oneRef];

    return one;
}

// 获取视频的时长
+ (NSInteger)getVideoTimeByPath:(NSString *)filepath {
    NSURL *videoUrl = [NSURL URLWithString:filepath];
    AVURLAsset *avUrl = [AVURLAsset assetWithURL:videoUrl];
    CMTime time = [avUrl duration];
    NSInteger seconds = ceil(time.value / time.timescale);
    return seconds;
}

@end