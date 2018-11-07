//
// Created by yun on 2017/5/12.
// Copyright (c) 2017 skkj. All rights reserved.
//

#import <YunKits/YunGlobalDefine.h>
#import <CoreServices/CoreServices.h>
#import "YunImgData.h"
#import "YunSelectImgHelper.h"
#import "TZImagePickerController.h"
#import "YunPmsHlp.h"
#import "YunImgViewConfig.h"
#import "UIImage+YunAdd.h"

@interface YunSelectImgHelper () <UIImagePickerControllerDelegate,
        TZImagePickerControllerDelegate, UINavigationControllerDelegate> {
    YunSelectImgType _lastSelType;

    UIImagePickerController *_imgPk;
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

        self.videoMaxTime = 10;
    }

    return self;
}

- (void)selectImg:(NSInteger)curCount {
    _curCount = curCount;

    if (_selType == YunImgSelByCameraAndPhotoAlbum ||
        _selType == YunVideoSelByCameraAndPhotoAlbum ||
        _selType == YunImgAndVideoSelByCameraAndPhotoAlbum) {

        // todo 兼容旧方法
        if (_selType == YunImgSelByCameraAndPhotoAlbum) {
            if (_delegate && [_delegate respondsToSelector:@selector(selectImgByType:)]) {
                [_delegate selectImgByType:^(YunSelectImgType type) {
                    [self selectImgByType:type];
                }];

                return;
            }

            if (YunImgViewConfig.instance.delegate &&
                [YunImgViewConfig.instance.delegate respondsToSelector:@selector(selectImgByType:)]) {
                [YunImgViewConfig.instance.delegate selectImgByType:^(YunSelectImgType type) {
                    [self selectImgByType:type];
                }];

                return;
            }
        }

        if (_delegate && [_delegate respondsToSelector:@selector(selectItemByType:cmp:)]) {
            [_delegate selectItemByType:_selType cmp:^(YunSelectImgType type) {
                [self selectImgByType:type];
            }];
        }
        else if (YunImgViewConfig.instance.delegate &&
                 [YunImgViewConfig.instance.delegate respondsToSelector:@selector(selectItemByType:cmp:)]) {
            [YunImgViewConfig.instance.delegate selectItemByType:_selType cmp:^(YunSelectImgType type) {
                [self selectImgByType:type];
            }];
        }
    }
    else {
        [self selectImgByType:_selType];
    }
}

- (void)selectImgByType:(YunSelectImgType)type {
    _lastSelType = type;

    if (type == YunImgSelByCamera) {
        [self selByCamera:NO];
    }
    else if (type == YunImgSelByPhotoAlbum) {
        [self selByAlbum:NO];
    }
    else if (type == YunVideoSelByCamera) {
        [self selByCamera:YES];
    }
    else if (type == YunVideoSelByPhotoAlbum) {
        [self selByAlbum:YES];
    }
}

- (void)selByCamera:(BOOL)isVideo {
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
                                                                                       [weakSelf openCamera:isVideo];
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

- (void)openCamera:(BOOL)isVideo {
    _imgPk = [[UIImagePickerController alloc] init];
    _imgPk.delegate = self;
    _imgPk.sourceType = UIImagePickerControllerSourceTypeCamera;

    if (isVideo) {
        _imgPk.mediaTypes = @[(NSString *) kUTTypeMovie];    // 设置为视频模式 kUTTypeVideo - 不带声音  kUTTypeMovie-带声音
        _imgPk.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;  // 设置摄像头模式为录制视频
        _imgPk.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;   // 设置视频质量
        _imgPk.videoMaximumDuration = self.videoMaxTime;
    }
    else {
        _imgPk.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto; //设置摄像头模式为拍照
        _imgPk.allowsEditing = _editImg;
    }

    [self.superVC presentViewController:_imgPk animated:YES completion:nil];
}

- (void)openPhotoLib:(BOOL)isVideo {
    _imgPk = [[UIImagePickerController alloc] init];
    _imgPk.delegate = self;
    _imgPk.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    if (isVideo) {
        //imgPk.mediaTypes = @[(NSString *) kUTTypeMovie];    // 设置为视频模式 kUTTypeVideo - 不带声音  kUTTypeMovie-带声音
        //imgPk.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;  // 设置摄像头模式为录制视频
        //imgPk.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;   // 设置视频质量
        _imgPk.videoMaximumDuration = self.videoMaxTime;
    }
    else {
        //imgPk.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto; //设置摄像头模式为拍照
        _imgPk.allowsEditing = _editImg;
    }

    [self.superVC presentViewController:_imgPk animated:YES completion:nil];
}

- (void)selByAlbum:(BOOL)isVideo {
    if (self.maxCount == 1 && _lastSelType == YunImgSelByPhotoAlbum) {
        [self openPhotoLib:isVideo];
        return;
    }

    TZImagePickerController *imgPk =
            [[TZImagePickerController alloc] initWithMaxImagesCount:(_maxCount - _curCount)
                                                           delegate:self];
    imgPk.allowPickingImage = YES;
    imgPk.allowPickingVideo = isVideo;
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
        [_delegate didCmp:hasImg imgs:imgs selType:_lastSelType];
    }
    else if (YunImgViewConfig.instance.delegate &&
             [YunImgViewConfig.instance.delegate respondsToSelector:@selector(didCmp:imgs:selType:)]) {
        [YunImgViewConfig.instance.delegate didCmp:hasImg imgs:imgs selType:_lastSelType];
    }

    if (_shouldStoreImg && _lastSelType == YunImgSelByCamera && imgs.count == 1) {
        UIImage *image = [UIImage imgWithObj:imgs[0]];

        if (image) {
            [self savedPhotosToAlbum:image];
        }
    }
}

// 保存到相册
- (void)savedPhotosToAlbum:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image,
                                   self,
                                   @selector(image:didFinishSavingWithError:contextInfo:),
                                   (__bridge void *) self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
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

- (void)imagePickerController:(TZImagePickerController *)picker
        didFinishPickingVideo:(UIImage *)coverImage
                 sourceAssets:(PHAsset *)asset {
    YunImgData *videoItem = [YunImgData itemWithType:YunImgVideoPHAsset data:asset];
    videoItem.thumbData = [YunImgData itemWithType:YunImgImage data:coverImage];

    [picker dismissViewControllerAnimated:_disAmt completion:nil];

    [self notiCmp:YES imgs:@[videoItem]];
}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    [picker dismissViewControllerAnimated:_disAmt completion:nil];

    [self notiCmp:NO imgs:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    NSString *type = info[UIImagePickerControllerMediaType];

    // 图片
    if ([type isEqualToString:(NSString *) kUTTypeImage]) {
        UIImage *img = nil;
        if (self.maxCount == 1 && self.editImg) {
            img = info[UIImagePickerControllerEditedImage]; // 编辑后的
        }
        else {
            img = info[UIImagePickerControllerOriginalImage]; // 原始图片
        }

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
    else if ([type isEqualToString:(NSString *) kUTTypeMovie]) { // 视频
        //视频保存后 播放视频
        NSURL *url = info[UIImagePickerControllerMediaURL];
        NSString *urlPath = [url path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlPath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(urlPath,
                                                self,
                                                @selector(video:didFinishSavingWithError:contextInfo:),
                                                nil);
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:_disAmt completion:^{
    }];

    [self notiCmp:NO imgs:nil];
}

//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [_imgPk dismissViewControllerAnimated:_disAmt completion:nil];
    if (error) {
        [self notiCmp:NO imgs:nil];
        //[YunLogHelper logMsg:FORMAT(@"保存视频过程中发生错误，错误信息:%@", error.localizedDescription)];
    }
    else {
        NSLog(@"视频保存成功.");

        [self checkVideoDurWithSourcePath:videoPath];
    }
}

- (void)checkVideoDurWithSourcePath:(NSString *)videoPath {
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
    CMTime time = [asset duration];
    int seconds = (int) ceil(time.value / time.timescale);

    if (seconds < _videoMaxTime) {
        // todo 判断视频长度
        YunImgData *videoItem = [YunImgData itemWithType:YunImgVideoFilePath data:videoPath];

        [self notiCmp:YES imgs:@[videoItem]];
    }
    else {
        [self notiCmp:NO imgs:nil];
    }
}

@end