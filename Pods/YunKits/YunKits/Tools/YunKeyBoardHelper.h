//
// Created by yun on 2017/6/29.
// Copyright (c) 2017 yun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YunKeyBoardDelegate <NSObject>

@optional

- (void)kbWillShow:(CGSize)size antDur:(double)antDur;

- (void)kbWillHide:(double)antDur;

- (void)kbFrameChanged:(CGSize)size;

- (void)didAddKbNtf;

- (void)didRemoveKbNtf;

@end

@protocol YunKeyBoardGlobleDelegate <NSObject>

@optional

- (void)didAddKbNtf;

- (void)didRemoveKbNtf;

@end

@interface YunKeyBoardHelper : NSObject

@property (nonatomic, weak) id <YunKeyBoardGlobleDelegate> globleDelegate;

@property (nonatomic, weak) id <YunKeyBoardDelegate> delegate;

@property (nonatomic, assign) BOOL kbIsOn;

+ (instancetype)kbHelper:(id)target;

+ (instancetype)instance;

- (void)addKbNtf;

- (void)removeKbNtf;

@end