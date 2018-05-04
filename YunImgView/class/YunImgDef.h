//
// Created by yun on 2017/5/12.
// Copyright (c) 2017 skkj. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    YunImgSelUnknown               =0,
    YunImgSelByCamera              =1, //
    YunImgSelByPhotoAlbum          =2, //
    YunImgSelByCameraAndPhotoAlbum =3 //
} YunSelectImgType;

typedef enum : NSInteger {
    YunImgUnknown = 0,
    YunImgImage   = 1, // image对象
    YunImgURLStr  = 2, // url 地址
    YunImgSrcName = 3, // image名称
    YunImgImgData = 4  // image data
} YunImgType;
