//
// Created by yun on 2018/11/22.
// Copyright (c) 2018 yun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YunLineHelper : NSObject

+ (void)drawLineOfDashByCAShapeLayer:(UIView *)lineView
                          lineLength:(int)lineLength
                         lineSpacing:(int)lineSpacing
                           lineColor:(UIColor *)lineColor
                       lineDirection:(BOOL)isHorizontal;

@end