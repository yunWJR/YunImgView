//
// Created by yun on 2017/5/12.
// Copyright (c) 2017 skkj. All rights reserved.
//

#import <YunKits/YunGlobalDefine.h>
#import "YunSelectImgHelper.h"
#import "TZImagePickerController.h"
#import "YunPmsHlp.h"
#import "YunImgViewConfig.h"
#import "UIImage+YunAdd.h"

@interface YunSelectImgHelper () <UIImagePickerControllerDelegate,
        TZImagePickerControllerDelegate, UINavigationControllerDelegate> {
}

@end

@implementation YunSelectImgHelper {
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.disAmt = YES;
        self.imgLength = YunImgViewConfig.instance.maxImgLength;
        self.imgBoundary = YunImgViewConfig.instance.maxImgBoundary;
    }

    return self;
}

- (void)selectImg:(NSInteger)curCount {
    _curCount = curCount;

    if (_selType == YunImgSelByCameraAndPhotoAlbum) {
        if (_delegate && [_delegate respondsToSelector:@selector(selectImgByType:)]) {
            [_delegate selectImgByType:^(YunSelectImgType type) {
                _selType = type;
                [self selectImgByType:_selType];
            }];
        }
    }
    else {
        [self selectImgByType:_selType];
    }
}

- (void)selectImgByType:(YunSelectImgType)type {
    if (type == YunImgSelByCamera) {
        [self selByCamera];
    }
    else if (type == YunImgSelByPhotoAlbum) {
        [self selByAlbum];
    }
}

- (void)selByCamera {
    WEAK_SELF
    [[YunPmsHlp instance] showCameraPmsWithTitle:@"是否允许使用相机？"
                                         message:@"是否允许使用相机？"
                                         denyBtn:@"取消"
                                        grantBtn:@"允许"
                                      cmpHandler:^(BOOL hasPms, YunDgRst userDr, YunDgRst sysDr) {
                                          if (hasPms) {
                                              [[YunPmsHlp instance] showPhotoPmsWithTitle:@"是否允许使用相册？"
                                                                                  message:@"是否允许使用相册？"
                                                                                  denyBtn:@"取消"
                                                                                 grantBtn:@"允许"
                                                                               cmpHandler:^(BOOL hasPmsAb,
                                                                                            YunDgRst userDrAb,
                                                                                            YunDgRst sysDrAb) {
                                                                                   if (hasPmsAb) {
                                                                                       [weakSelf openCamera];
                                                                                   }
                                                                                   else {
                                                                                       [weakSelf notiCmp:NO
                                                                                                    imgs:nil]; // todo 情况还应考虑
                                                                                   }
                                                                               }];
                                          }
                                          else {
                                              [weakSelf notiCmp:NO imgs:nil]; // todo 情况还应考虑
                                          }
                                      }];
}

- (void)openCamera {
    UIImagePickerController *imgPk = [[UIImagePickerController alloc] init];
    imgPk.delegate = self;

    imgPk.allowsEditing = _editImg;
    imgPk.sourceType = UIImagePickerControllerSourceTypeCamera;

    [self.superVC presentViewController:imgPk animated:YES completion:nil];
}

- (void)openPhotoLib {
    UIImagePickerController *imgPk = [[UIImagePickerController alloc] init];
    imgPk.delegate = self;

    imgPk.allowsEditing = _editImg;
    imgPk.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self.superVC presentViewController:imgPk animated:YES completion:nil];
}

- (void)selByAlbum {
    if (self.maxCount == 1) {
        [self openPhotoLib];
        return;
    }

    TZImagePickerController *imgPk =
            [[TZImagePickerController alloc] initWithMaxImagesCount:(_maxCount - _curCount)
                                                           delegate:self];
    imgPk.allowPickingImage = YES;
    imgPk.allowPickingVideo = NO;
    imgPk.isSelectOriginalPhoto = NO;
    imgPk.autoDismiss = NO;

    //imgPk.navigationBar.barTintColor = PpmTheme.colorHl;
    // imgPk.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imgPk.oKButtonTitleColorNormal = [UIColor greenColor];

    imgPk.sortAscendingByModificationDate = YES;

    imgPk.allowTakePicture = NO; // 在内部显示拍照按钮

    imgPk.imagePickerControllerDidCancelHandle = ^() {
        [self notiCmp:NO imgs:nil];
    };

    [self.superVC presentViewController:imgPk animated:YES completion:nil];
}

- (void)notiCmp:(BOOL)hasImg imgs:(NSArray *)imgs {
    if (_delegate && [_delegate respondsToSelector:@selector(didCmp:imgs:selType:)]) {
        [_delegate didCmp:hasImg imgs:imgs selType:_selType];
    }
}

#pragma mark - TZImagePickerControllerDelegate

- (void)imagePickerController:(TZImagePickerController *)picker
       didFinishPickingPhotos:(NSArray<UIImage *> *)photos
                 sourceAssets:(NSArray *)assets
        isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    NSMutableArray *imgList = [NSMutableArray new];
    for (int i = 0; i < photos.count; ++i) {
        UIImage *img = photos[i];
        if (_isCompression) {
            NSData *imgData = [img resizeToData:self.imgBoundary
                                         andCmp:self.imgLength];
            [imgList addObject:imgData];
        }
        else {
            [imgList addObject:img];
        }
    }

    [picker dismissViewControllerAnimated:_disAmt completion:nil];

    [self notiCmp:YES imgs:imgList];
}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    [picker dismissViewControllerAnimated:_disAmt completion:nil];

    [self notiCmp:NO imgs:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    UIImage *img = info[UIImagePickerControllerOriginalImage];
    if (img == nil) {
        img = info[UIImagePickerControllerEditedImage]; // 编辑后的
    }

    if (img == nil) {
        [self notiCmp:NO imgs:nil];
        return;
    }

    [picker dismissViewControllerAnimated:_disAmt completion:nil];

    NSArray *imgList = nil;
    if (_isCompression) {
        NSData *imgData = [img resizeToData:self.imgBoundary
                                     andCmp:self.imgLength];
        imgList = @[imgData];
    }
    else {
        imgList = @[img];
    }

    [self notiCmp:YES imgs:imgList];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:_disAmt completion:^{
    }];

    [self notiCmp:NO imgs:nil];
}

@end