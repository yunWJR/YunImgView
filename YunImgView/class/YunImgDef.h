//
// Created by yun on 2017/5/12.
// Copyright (c) 2017 skkj. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    YunImgSelUnknown                       =0,
    YunImgSelByCamera                      =1, //
    YunImgSelByPhotoAlbum                  =2, //
    YunImgSelByCameraAndPhotoAlbum         =3, //
    YunVideoSelByCamera                    =4, //
    YunVideoSelByPhotoAlbum                =5, //
    YunVideoSelByCameraAndPhotoAlbum       =6, //
    YunImgAndVideoSelByCameraAndPhotoAlbum =7,  //
    YunImgAndVideoSelByAny                 =8,  //
} YunSelectImgType;

typedef enum : NSInteger {
    YunImgUnknown          = 0,
    YunImgImage            = 1, // image对象
    YunImgURLStr           = 2, // url 地址
    YunImgSrcName          = 3, // image名称
    YunImgImgData          = 4, // image data
    YunImgVideoURLStr      = 5, // url 地址
    YunImgVideoFilePath    = 6, // url 地址
    YunImgVideoPHAsset     = 7, // url 地址
} YunImgType;
