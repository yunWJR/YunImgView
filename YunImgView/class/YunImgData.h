//
// Created by 王健 on 16/5/14.
// Copyright (c) 2016 成都晟堃科技有限责任公司. All rights reserved.
//

#import "YunImgDef.h"
#import <Mantle/Mantle.h>
#import "UIKit/UIKit.h"

@interface YunImgData : MTLModel <MTLJSONSerializing, NSCopying>

@property (nonatomic, assign) YunImgType type;

@property (nonatomic, strong) id data;

+ (instancetype)itemWithType:(YunImgType)type data:(id)data;

+ (instancetype)itemWithImg:(UIImage *)img;

+ (instancetype)itemWithUrlStr:(NSString *)url;

+ (NSArray<YunImgData *> *)imgListByURLStrList:(NSArray<NSString *> *)urlList;

- (void)setImgInView:(UIImageView *)imgView phImg:(UIImage *)phImg isZoom:(BOOL)isZoom;

- (BOOL)isSame:(YunImgData *)img;

@end