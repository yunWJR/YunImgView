//
// Created by yun on 2018/9/21.
// Copyright (c) 2018 yun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YunTypeDefine.h"

@interface YunTypeDefine () {
}

@end

@implementation YunTypeDefine

+ (BOOL)isIPhoneXAndOn {
    return IS_IPHONE_X || IS_IPHONE_Xr || IS_IPHONE_Xs || IS_IPHONE_Xs_Max;
}

@end