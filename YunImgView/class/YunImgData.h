//
// Created by 王健 on 16/5/14.
// Copyright (c) 2016 成都晟堃科技有限责任公司. All rights reserved.
//

#import <Mantle/MTLModel.h>
#import <Mantle/Mantle.h>
#import "UIKit/UIKit.h"
#import "YunImgDef.h"

@interface YunImgData : MTLModel <MTLJSONSerializing, NSCopying>

@property (nonatomic, assign) YunImgType type;

@property (nonatomic, strong) id data;

@property (nonatomic, strong) YunImgData *thumbData;

+ (instancetype)itemWithType:(YunImgType)type data:(id)data;

+ (instancetype)itemWithImg:(UIImage *)img;

+ (instancetype)itemWithUrlStr:(NSString *)url;

+ (instancetype)itemWithVideoUrlStr:(NSString *)videoUrl thumb:(NSString *)thumb;

+ (NSArray<YunImgData *> *)imgListByURLStrList:(NSArray<NSString *> *)urlList;

- (void)setImgInView:(UIImageView *)imgView isZoom:(BOOL)isZoom;

- (BOOL)isSame:(YunImgData *)item;

- (BOOL)isVideoItem;

@end