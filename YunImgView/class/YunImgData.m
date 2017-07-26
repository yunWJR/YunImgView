//
// Created by 王健 on 16/5/14.
// Copyright (c) 2016 成都晟堃科技有限责任公司. All rights reserved.
//

#import "YunImgData.h"
#import "YunQnHelper.h"
#import "UIImageView+WebCache.h"

@implementation YunImgData

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *mapping = [[NSDictionary mtl_identityPropertyMapWithModel:self] mutableCopy];
    return mapping;
}

- (id)copyWithZone:(NSZone *)zone {
    YunImgData *copy = [[YunImgData allocWithZone:zone] init];

    copy.data = [self.data copy];

    copy.type = self.type;

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

- (void)setImgInView:(UIImageView *)imgView phImg:(UIImage *)phImg isZoom:(BOOL)isZoom {
    switch (_type) {
        case YunImgImage:
            [imgView setImage:_data];
            break;
        case YunImgURLStr: {
            NSURL *imgUrl = isZoom ?
                            [[YunQnHelper instance] zoomURL:_data] :
                            [[YunQnHelper instance] norURL:_data];

            [imgView sd_setImageWithURL:imgUrl placeholderImage:phImg];
        }
            break;
        default:
            NSLog(@"ImageSrcUnknown");
            break;
    }
}

- (BOOL)isSame:(YunImgData *)img {
    if (self.type == img.type) {
        if ([self.data isEqual:img.data]) {return YES;} //todo
    }

    return NO;
}

@end