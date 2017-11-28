//
// Created by 王健 on 16/5/14.
// Copyright (c) 2016 成都晟堃科技有限责任公司. All rights reserved.
//

#import "YunImgData.h"
#import "YunQnHelper.h"
#import "UIImageView+YunAdd.h"
#import "NSObject+YunAdd.h"

@implementation YunImgData

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
        default:
            NSLog(@"ImageSrcUnknown");
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

@end