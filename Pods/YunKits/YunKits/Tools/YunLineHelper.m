//
// Created by yun on 2018/11/22.
// Copyright (c) 2018 yun. All rights reserved.
//

#import "YunLineHelper.h"

@interface YunLineHelper () {
}

@end

@implementation YunLineHelper

/**
 *  通过 CAShapeLayer 方式绘制虚线
 *
 *  param lineView:       需要绘制成虚线的view
 *  param lineLength:     虚线的宽度
 *  param lineSpacing:    虚线的间距
 *  param lineColor:      虚线的颜色
 *  param lineDirection   虚线的方向  YES 为水平方向， NO 为垂直方向
 **/
+ (void)drawLineOfDashByCAShapeLayer:(UIView *)lineView
                          lineLength:(int)lineLength
                         lineSpacing:(int)lineSpacing
                           lineColor:(UIColor *)lineColor
                       lineDirection:(BOOL)isHorizontal {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];

    [shapeLayer setBounds:lineView.bounds];

    if (isHorizontal) {
        [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2,
                                            CGRectGetHeight(lineView.frame))];

    }
    else {
        [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2,
                                            CGRectGetHeight(lineView.frame) / 2)];
    }

    [shapeLayer setFillColor:[UIColor clearColor].CGColor];

    [shapeLayer setStrokeColor:lineColor.CGColor];

    //  设置虚线宽度
    if (isHorizontal) {
        [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
    }
    else {
        [shapeLayer setLineWidth:CGRectGetWidth(lineView.frame)];
    }

    [shapeLayer setLineJoin:kCALineJoinRound];

    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:@[
            @(lineLength),
            @(lineSpacing)
    ]];

    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);

    if (isHorizontal) {
        CGPathAddLineToPoint(path, NULL, CGRectGetWidth(lineView.frame), 0);
    }
    else {
        CGPathAddLineToPoint(path, NULL, 0, CGRectGetHeight(lineView.frame));
    }

    [shapeLayer setPath:path];

    CGPathRelease(path);

    //  把绘制好的虚线添加上来
    [lineView.layer addSublayer:shapeLayer];
}

@end