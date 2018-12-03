//
// Created by yun on 2017/6/29.
// Copyright (c) 2017 yun. All rights reserved.
//

#import "YunKeyBoardHelper.h"

@implementation YunKeyBoardHelper {
}

+ (instancetype)instance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

+ (instancetype)kbHelper:(id)target {
    YunKeyBoardHelper *hp = [YunKeyBoardHelper new];
    hp.delegate = target;
    hp.globleDelegate = YunKeyBoardHelper.instance.globleDelegate;

    return hp;
}

#pragma mark - UIKeyboard Notification

- (void)addKbNtf {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardFrameChanged:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];

    if (_delegate && [_delegate respondsToSelector:@selector(didAddKbNtf)]) {
        [_delegate didAddKbNtf];
    }

    if (_globleDelegate && [_globleDelegate respondsToSelector:@selector(didAddKbNtf)]) {
        [_globleDelegate didAddKbNtf];
    }
}

- (void)removeKbNtf {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];

    if (_delegate && [_delegate respondsToSelector:@selector(didRemoveKbNtf)]) {
        [_delegate didRemoveKbNtf];
    }

    if (_globleDelegate && [_globleDelegate respondsToSelector:@selector(didRemoveKbNtf)]) {
        [_globleDelegate didRemoveKbNtf];
    }
}

- (void)keyboardWillShow:(NSNotification *)noti {
    if (_delegate && [_delegate respondsToSelector:@selector(kbWillShow:antDur:)]) {
        // 获得键盘尺寸
        NSDictionary *info = [noti userInfo];
        NSValue *frameValue = info[UIKeyboardFrameEndUserInfoKey];
        CGSize kbSize = [frameValue CGRectValue].size;

        // 获取键盘弹出动画时间
        NSValue *aniDuaVal = noti.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval aniDur;
        [aniDuaVal getValue:&aniDur];

        [_delegate kbWillShow:kbSize antDur:aniDur];
    }
}

- (void)keyboardWillHide:(NSNotification *)noti {
    if (_delegate && [_delegate respondsToSelector:@selector(kbWillHide:)]) {
        // 获取键盘弹出动画时间
        NSValue *aniDuaVal = noti.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval aniDur;
        [aniDuaVal getValue:&aniDur];

        [_delegate kbWillHide:aniDur];
    }
}

- (void)keyboardDidShow:(NSNotification *)noti {
    _kbIsOn = YES;
}

- (void)keyboardDidHide:(NSNotification *)noti {
    _kbIsOn = NO;
}

- (void)keyboardFrameChanged:(NSNotification *)noti {
    if (_delegate && [_delegate respondsToSelector:@selector(kbFrameChanged:)]) {
        // 获得键盘尺寸
        NSDictionary *info = [noti userInfo];
        NSValue *frameValue = info[UIKeyboardFrameEndUserInfoKey];
        CGSize kbSize = [frameValue CGRectValue].size;

        // 获取键盘弹出动画时间
        NSValue *aniDuaVal = noti.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval aniDur;
        [aniDuaVal getValue:&aniDur];

        [_delegate kbFrameChanged:kbSize];
    }
}

@end