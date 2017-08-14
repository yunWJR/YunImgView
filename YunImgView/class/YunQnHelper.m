//
// Created by yun on 16/7/2.
// Copyright (c) 2016 成都晟堃科技有限责任公司. All rights reserved.
//

#import <YunKits/YunGlobalDefine.h>
#import "YunQnHelper.h"
#import "YunValueVerifier.h"
#import "NSURL+YunAdd.h"

@implementation YunQnHelper {
}

+ (YunQnHelper *)instance {
    static YunQnHelper *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _zoomPara = @"?imageView2/2/w/300/h/300/interlace/0/q/100";
    }

    return self;
}

- (NSURL *)zoomURL:(NSString *)url {
    if ([YunValueVerifier isValidStr:_zoomPara]) {
        return [NSURL urlWithStr:FORMAT(@"%@%@", url, _zoomPara)];
    }
    else {
        return [self norURL:url];
    }
}

- (NSURL *)norURL:(NSString *)url {
    return [NSURL urlWithStr:url];
}

@end