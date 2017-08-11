//
// Created by yun on 2017/5/12.
// Copyright (c) 2017 skkj. All rights reserved.
//

#import "YunSelectImgHelper.h"
#import "TZImagePickerController.h"
#import "UIImage+YunAdd.h"
#import "YunPmsHlp.h"

#define img_size 150

@interface YunSelectImgHelper () <UIImagePickerControllerDelegate,
        TZImagePickerControllerDelegate, UINavigationControllerDelegate> {
}

@end

@implementation YunSelectImgHelper {
}

- (void)selectImg:(NSInteger)curCount {
    _curCount = curCount;

    YunSelectImgType type = YunImgSelUnknown;
    if (_selType == YunImgSelByCameraAndPhotoAlbum) {
        if (_delegate && [_delegate respondsToSelector:@selector(selectImgByType)]) {
            type = [_delegate selectImgByType];
        }
    }
    else {
        type = _selType;
    }

    if (type == YunImgSelByCamera) {
        [self selByCamera];

        return;
    }

    if (type == YunImgSelByPhotoAlbum) {
        [self selByAlbum];

        return;
    }
}

- (void)selByCamera {
    [[YunPmsHlp instance]
                showCameraPmsWithTitle:@"是否允许使用相机？"
                               message:@"是否允许使用相机？"
                               denyBtn:@"取消"
                              grantBtn:@"允许"
                            cmpHandler:^(BOOL hasPms, YunDgRst userDr, YunDgRst sysDr) {
                                if (hasPms) {
                                    [[YunPmsHlp instance]
                                                showPhotoPmsWithTitle:@"是否允许使用相册？"
                                                              message:@"是否允许使用相册？"
                                                              denyBtn:@"取消"
                                                             grantBtn:@"允许"
                                                           cmpHandler:^(BOOL hasPmsAb,
                                                                        YunDgRst userDrAb,
                                                                        YunDgRst sysDrAb) {
                                                               if (hasPmsAb) {
                                                                   UIImagePickerController
                                                                           *imagePicker =
                                                                           [[UIImagePickerController alloc] init];
                                                                   imagePicker.delegate = self;

                                                                   imagePicker.allowsEditing = NO;

                                                                   imagePicker.sourceType =
                                                                           UIImagePickerControllerSourceTypeCamera;

                                                                   [[self superVC]
                                                                          presentViewController:imagePicker
                                                                                       animated:YES
                                                                                     completion:nil];
                                                               }
                                                               else {
                                                                   [self notiCmp:NO imgs:nil]; // todo 情况还应考虑

                                                                   return;
                                                               }
                                                           }];
                                }
                                else {
                                    [self notiCmp:NO imgs:nil]; // todo 情况还应考虑

                                    return;
                                }
                            }];
}

- (void)selByAlbum {
    TZImagePickerController *imagePickerVc =
            [[TZImagePickerController alloc] initWithMaxImagesCount:(_maxCount - _curCount) delegate:self];
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.isSelectOriginalPhoto = NO;

    //imagePickerVc.navigationBar.barTintColor = PpmTheme.colorHl;
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];

    imagePickerVc.sortAscendingByModificationDate = YES;

    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮

    imagePickerVc.imagePickerControllerDidCancelHandle = ^() {
        [self notiCmp:NO imgs:nil];
    };

    [[self superVC] presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)notiCmp:(BOOL)hasImg imgs:(NSArray<UIImage *> *)imgs {
    if (_delegate && [_delegate respondsToSelector:@selector(didCmp:imgs:selType:)]) {
        [_delegate didCmp:hasImg imgs:imgs selType:_selType];
    }
}

#pragma mark - TZImagePickerControllerDelegate

- (void)imagePickerController:(TZImagePickerController *)picker
       didFinishPickingPhotos:(NSArray<UIImage *> *)photos
                 sourceAssets:(NSArray *)assets
        isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    NSMutableArray *newPhotos = [NSMutableArray new];
    for (int i = 0; i < photos.count; ++i) {
        [newPhotos addObject:_isCompression ? [photos[i] resizeWithSize:img_size] : photos[i]];
    }

    [self notiCmp:YES imgs:newPhotos];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image == nil) {
        [self notiCmp:NO imgs:nil];
        return;
    }

    [picker dismissViewControllerAnimated:YES completion:nil];

    UIImage *newImg = _isCompression ? [image resizeWithSize:img_size] : image;
    [self notiCmp:YES imgs:@[newImg]];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{

    }];

    [self notiCmp:NO imgs:nil];
}

@end