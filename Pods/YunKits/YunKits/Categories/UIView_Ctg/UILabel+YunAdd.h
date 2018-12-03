///
///  UILabel+YunAdd.h
///
/// Created by yun on 16/5/8.
/// Copyright (c) 2017 yun. All rights reserved.
///

#import <UIKit/UIKit.h>

@interface UILabel (YunAdd)

/// 计算
+ (CGFloat)calHeightByWidth:(CGFloat)width text:(NSString *)text font:(UIFont *)font;

+ (CGFloat)calOneLineHeight:(UIFont *)font;

+ (CGFloat)calWidthWithText:(NSString *)text font:(UIFont *)font;

+ (CGFloat)calWidthWithTextAt:(NSAttributedString *)at;

/// 获取当前
- (CGFloat)getTextHeightByWidth:(CGFloat)width;

- (CGFloat)getOneLineHeight;

- (CGFloat)getOneLineHeightWithoutOffV;

- (CGFloat)getTextWidth;

- (CGFloat)getTitleWidthOff;

- (CGFloat)getWidthByWordCount:(NSInteger)count;

- (CGFloat)getOneWordWidth;

/// 设置文字行间距
- (void)setText:(NSString *)text lineInner:(CGFloat)inner;

@end
