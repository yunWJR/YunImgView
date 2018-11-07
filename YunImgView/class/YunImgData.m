//
// Created by 王健 on 16/5/14.
// Copyright (c) 2016 成都晟堃科技有限责任公司. All rights reserved.
//

#import <YunKits/YunConfig.h>
#import <YunKits/UIImage+YunAdd.h>
#import "YunImgData.h"
#import "YunQnHelper.h"
#import "UIImageView+YunAdd.h"
#import "NSObject+YunAdd.h"
#import "YunSizeHelper.h"

@implementation YunImgData {
    UIImage *_zoomImg;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *mapping = [[NSDictionary mtl_identityPropertyMapWithModel:self] mutableCopy];
    return mapping;
}

- (id)copyWithZone:(NSZone *)zone {
    YunImgData *copy = self.yunDeepCopy;

    return copy;
}

+ (instancetype)itemWithType:(YunImgType)type data:(id)data {
    YunImgData *item = [YunImgData new];
    item.type = type;
    item.data = data;

    return item;
}

+ (instancetype)itemWithUrlStr:(NSString *)url {
    return [self itemWithType:YunImgURLStr data:url];
}

+ (instancetype)itemWithVideoUrlStr:(NSString *)videoUrl thumb:(NSString *)thumb {
    YunImgData *item = [self itemWithType:YunImgVideoURLStr data:videoUrl];
    item.thumbData = thumb;

    return item;
}

+ (instancetype)itemWithImg:(UIImage *)img {
    return [self itemWithType:YunImgImage data:img];
}

+ (NSArray<YunImgData *> *)imgListByURLStrList:(NSArray<NSString *> *)urlList {
    if (urlList == nil || urlList.count == 0) {
        return nil;
    }

    NSMutableArray *imgList = [NSMutableArray new];
    for (int i = 0; i < urlList.count; ++i) {
        YunImgData *info = [self itemWithUrlStr:urlList[i]];

        [imgList addObject:info];
    }

    return imgList;
}

- (void)setImgInView:(UIImageView *)imgView isZoom:(BOOL)isZoom {
    switch (_type) {
        case YunImgImage:
            [imgView setImage:_data];
            break;
        case YunImgURLStr: {
            NSURL *imgUrl = isZoom ?
                            [[YunQnHelper instance] zoomURL:_data] :
                            [[YunQnHelper instance] norURL:_data];

            [imgView setImgUrlStr:[imgUrl absoluteString]];
        }
            break;
        case YunImgImgData: {
            if (isZoom && _zoomImg && imgView.image == _zoomImg) { // 是缩略图
                return;
            }

            if (imgView.image == nil) {
                UIImage *phImg = [UIImage imageNamed:YunConfig.instance.imgViewHolderImgName];
                imgView.image = phImg;
            }

            imgView.image = [self getImg:isZoom data:_data];

            if (isZoom) {
                _zoomImg = imgView.image;
            }
        }
            break;
        case YunImgUnknown:
            //[YunLogHelper logMsg:@"ImageSrcUnknown"];
            break;
        case YunImgSrcName:
            imgView.image = [UIImage imageNamed:_data];
            break;
        case YunImgVideoURLStr:
            //[imgView setImgUrlStr:_thumbData]; // todo
            break;
        case YunImgVideoFilePath:
            //[imgView setImgUrlStr:_thumbData]; // todo
            break;
        case YunImgVideoPHAsset:
            break;
        default:
            break;
    }
}

- (BOOL)isSame:(YunImgData *)item {
    if (item == nil) {return NO;}

    if (self.type == item.type) {
        if (self.type == YunImgURLStr || self.type == YunImgSrcName) {
            return [self.data isEqualToString:item.data];
        }
        else {
            if ([self.data isKindOfClass:UIImage.class]) {
                NSData *imgD1 = UIImagePNGRepresentation(self.data);
                NSData *imgD2 = UIImagePNGRepresentation(item.data);

                return [imgD1 isEqual:imgD2];
            }

            if ([self.data isKindOfClass:NSData.class]) {
                return [self.data isEqual:item.data];
            }

            NSLog(@"unknown img data");
            return NO;
        }
    }

    return NO;
}

- (BOOL)isVideoItem {
    return _type >= YunImgVideoURLStr;
}

- (UIImage *)getImg:(BOOL)isZoom data:(id)data {
    UIImage *img0 = nil;

    if (isZoom) {
        UIImage *img = [UIImage imageWithData:data];

        NSData *imgD = UIImageJPEGRepresentation(img, 0.01);

        img0 = [UIImage imageWithData:imgD];

        img0 = [img0 resizeByMaxBd:YunSizeHelper.screenWidth * 0.5f];
    }
    else {
        img0 = [UIImage imageWithData:data];
    }

    return img0;
}

- (void)getZoomImg:(BOOL)isZoom data:(id)data rst:(void (^)(UIImage *img))rst {
    UIImage *img0 = nil;

    if (isZoom) {
        UIImage *img = [UIImage imageWithData:data];

        NSData *imgD = UIImageJPEGRepresentation(img, 0.01);

        img0 = [UIImage imageWithData:imgD];

        img0 = [img0 resizeByMaxBd:YunSizeHelper.screenWidth * 0.3f];
    }
    else {
        img0 = [UIImage imageWithData:data];
    }

    if (rst) {
        rst(img0);
    }
}

@end