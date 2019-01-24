//
// Created by yun on 2017/5/12.
// Copyright (c) 2017 skkj. All rights reserved.
//

#import <YunKits/YunGlobalDefine.h>
#import <CoreServices/CoreServices.h>
#import "YunImgData.h"
#import <YunKits/YunValueHelper.h>
#import <YunKits/NSError+YunAdd.h>
#import "YunSelectImgHelper.h"
#import "TZImagePickerController.h"
#import "YunPmsHlp.h"
#import "YunImgViewConfig.h"
#import "UIImage+YunAdd.h"
#import "YunValueVerifier.h"

@interface YunSelectImgHelper () <UIImagePickerControllerDelegate, TZImagePickerControllerDelegate, UINavigationControllerDelegate> {
    // 最近一次选择的类型
    YunSelectImgType _lastSelType;

    UIImagePickerController *_imgPk;
}

@end

@implementation YunSelectImgHelper {
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 默认参数
        self.disAmt = YES;
        self.imgLength = YunImgViewConfig.instance.maxImgLength;
        self.imgBoundary = YunImgViewConfig.instance.maxImgBoundary;
        self.videoLength = YunImgViewConfig.instance.videoLength;
        self.videoMaxDuration = YunImgViewConfig.instance.videoMaxDuration;
        self.videoQuality = YunImgViewConfig.instance.videoQuality;
    }

    return self;
}

// 兼容旧方法
- (void)selectImg:(NSInteger)curCount {
    [self selectItem:curCount];
}

- (void)selectItem:(NSInteger)curCount {
    _curCount = curCount;

    if (!self.isValidCurCount) {
        return;
    }

    if (_selType == YunImgAndVideoSelByAny) {
        [self setAllByAny];
        return;
    }

    if (_selType == YunImgSelByCameraAndPhotoAlbum ||
        _selType == YunVideoSelByCameraAndPhotoAlbum ||
        _selType == YunImgAndVideoSelByCameraAndPhotoAlbum) {

        // 兼容旧方法
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

- (BOOL)isValidCurCount {
    if (_maxCount > 0) {
        BOOL isValid = _maxCount > _curCount;

        if (!isValid) {
            [self notiCmpError:FORMAT(@"最多选择%@项", [YunValueHelper intStr:_maxCount])];
        }

        return isValid;
    }

    return YES;
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
    else {
        [self notiCmpError:FORMAT(@"未知的选择类型")];
    }
}

- (void)selByCamera:(BOOL)isVideo {
    // todo 权限检查
    WEAK_SELF
    [[YunPmsHlp instance] showCameraPmsWithTitle:@"说明"
                                         message:FORMAT(YunImgViewConfig.instance.imgPsmMsg, @"相机拍摄")
                                         denyBtn:@"取消"
                                        grantBtn:@"请求允许"
                                      cmpHandler:^(BOOL hasPms, YunDgRst userDr, YunDgRst sysDr) {
                                          if (hasPms) {
                                              [[YunPmsHlp instance] showPhotoPmsWithTitle:@"说明"
                                                                                  message:FORMAT(YunImgViewConfig.instance
                                                                                                                 .imgPsmMsg,
                                                                                                 @"相册选取")
                                                                                  denyBtn:@"取消"
                                                                                 grantBtn:@"请求允许"
                                                                               cmpHandler:^(BOOL hasPmsAb,
                                                                                            YunDgRst userDrAb,
                                                                                            YunDgRst sysDrAb) {
                                                                                   if (hasPmsAb) {
                                                                                       [weakSelf openCamera:isVideo];
                                                                                   }
                                                                                   else {
                                                                                       [self notiCmpError:FORMAT(@"无相册权限")];
                                                                                   }
                                                                               }];
                                          }
                                          else {
                                              [self notiCmpError:FORMAT(@"无相机权限")];
                                          }
                                      }];
}

- (void)setAllByAny {
    TZImagePickerController *imgPk =
            [[TZImagePickerController alloc] initWithMaxImagesCount:(_maxCount - _curCount)
                                                           delegate:self];
    imgPk.allowPickingImage = YES;
    imgPk.allowPickingVideo = YES;
    imgPk.isSelectOriginalPhoto = YES;
    imgPk.autoDismiss = NO;

    //imgPk.navigationBar.barTintColor = [[YunAppTheme instance] commonColorHl];

    imgPk.sortAscendingByModificationDate = YES;

    imgPk.allowTakePicture = YES; // 在内部显示拍照按钮
    imgPk.allowTakeVideo = YES; // 在内部显示拍照按钮
    imgPk.uiImagePickerControllerSettingBlock = ^(UIImagePickerController *imagePickerController) {
        imagePickerController.videoQuality = _videoQuality;
    };

    if (_videoMaxDuration > 0) {
        imgPk.videoMaximumDuration = _videoMaxDuration;
    }

    imgPk.imagePickerControllerDidCancelHandle = ^() {
        [self notiCmpItems:nil];
    };

    [self.superVC presentViewController:imgPk animated:YES completion:nil];
}

- (void)openCamera:(BOOL)isVideo {
    _imgPk = [[UIImagePickerController alloc] init];
    _imgPk.delegate = self;
    _imgPk.sourceType = UIImagePickerControllerSourceTypeCamera;

    if (isVideo) {
        _imgPk.mediaTypes = @[(NSString *) kUTTypeMovie];    // 设置为视频模式 kUTTypeVideo - 不带声音  kUTTypeMovie-带声音
        _imgPk.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;  // 设置摄像头模式为录制视频
        _imgPk.videoQuality = _videoQuality;   // 设置视频质量

        if (self.videoMaxDuration > 0) {
            _imgPk.videoMaximumDuration = self.videoMaxDuration;
        }
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
        if (self.videoMaxDuration > 0) {
            _imgPk.videoMaximumDuration = self.videoMaxDuration;
        }
    }
    else {
        _imgPk.allowsEditing = _editImg;
    }

    [self.superVC presentViewController:_imgPk animated:YES completion:nil];
}

- (void)selByAlbum:(BOOL)isVideo {
    // 选择一张图片时，直接打开系统相册
    if (self.maxCount == 1 && _lastSelType == YunImgSelByPhotoAlbum) {
        [self openPhotoLib:isVideo];
        return;
    }

    // 多选
    TZImagePickerController *imgPk =
            [[TZImagePickerController alloc] initWithMaxImagesCount:(_maxCount - _curCount)
                                                           delegate:self];
    imgPk.allowPickingImage = !isVideo;
    imgPk.allowPickingVideo = isVideo;
    imgPk.isSelectOriginalPhoto = YES;
    imgPk.autoDismiss = NO;

    //imgPk.navigationBar.barTintColor = PpmTheme.colorHl;
    // imgPk.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imgPk.oKButtonTitleColorNormal = [UIColor greenColor];

    imgPk.sortAscendingByModificationDate = YES;

    imgPk.allowTakePicture = NO; // 在内部显示拍照按钮

    imgPk.imagePickerControllerDidCancelHandle = ^() {
        [self notiCmpItems:nil];
    };

    [self.superVC presentViewController:imgPk animated:YES completion:nil];
}

- (void)notiCmpError:(NSString *)error {
    [self notiErrorMsg:error items:nil];
}

- (void)notiCmpItems:(NSArray *)items {
    [self notiErrorMsg:nil items:items];
}

- (void)notiErrorMsg:(NSString *)errMsg items:(NSArray *)items {
    NSError *err = nil;
    if (errMsg) {
        err = [NSError errorWithCustomMsg:errMsg];
    }

    // 兼容旧方法
    if (_delegate && [_delegate respondsToSelector:@selector(didCmp:imgs:selType:)]) {
        [_delegate didCmp:YES imgs:items selType:_lastSelType];
    }
    else if (YunImgViewConfig.instance.delegate &&
             [YunImgViewConfig.instance.delegate respondsToSelector:@selector(didCmp:imgs:selType:)]) {
        [YunImgViewConfig.instance.delegate didCmp:YES imgs:items selType:_lastSelType];
    }
    else if (_delegate && [_delegate respondsToSelector:@selector(didCmpWithItems:error:selType:)]) {
        [_delegate didCmpWithItems:items
                             error:err
                           selType:_lastSelType];
    }
    else if (YunImgViewConfig.instance.delegate &&
             [YunImgViewConfig.instance.delegate respondsToSelector:@selector(didCmpWithItems:error:selType:)]) {
        [YunImgViewConfig.instance.delegate didCmpWithItems:items
                                                      error:err
                                                    selType:_lastSelType];
    }

    // 拍摄的照片，需要存储到相册
    if (_shouldStoreImg && _lastSelType == YunImgSelByCamera && items.count == 1) {
        UIImage *image = [UIImage imgWithObj:items[0]];

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

    [self notiCmpItems:imgList];
}

- (void)imagePickerController:(TZImagePickerController *)picker
        didFinishPickingVideo:(UIImage *)coverImage
                 sourceAssets:(PHAsset *)asset {
    // 选择的限制时长和大小
    [self getVideoPathFromPHAsset:asset rst:^(NSString *filePath) {
        [picker dismissViewControllerAnimated:_disAmt completion:nil];

        if ([YunValueVerifier isValidStr:filePath]) {
            if (_videoMaxDuration >= 0) {
                AVURLAsset *aAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
                CMTime time = [aAsset duration];
                int seconds = (int) ceil(time.value / time.timescale);

                if (seconds <= _videoMaxDuration) {
                    if (_videoLength > 0) {
                        NSData *data = [NSData dataWithContentsOfFile:filePath];
                        if (data.length > _videoLength * 1000) {
                            [self notiCmpError:FORMAT(@"视频文件过大（应不大于%@ kb）", [YunValueHelper intStr:_videoLength])];

                            return;
                        }
                    }
                }
                else {
                    [self notiCmpError:FORMAT(@"视频文件时间过长（应不长于%@s）", [YunValueHelper intStr:_videoMaxDuration])];

                    return;
                }
            }

            YunImgData *videoItem = [YunImgData itemWithType:YunImgVideoPHAsset data:asset];
            videoItem.thumbData = [YunImgData itemWithType:YunImgImage data:coverImage];

            [self notiCmpItems:@[videoItem]];
        }
        else {
            [self notiCmpError:@"获取视频文件失败"];
        }
    }];
}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    [picker dismissViewControllerAnimated:_disAmt completion:nil];

    [self notiCmpItems:nil];
}

- (void)getVideoPathFromPHAsset:(PHAsset *)asset rst:(void (^)(NSString *filePath))rst {
    NSArray *assetResources = [PHAssetResource assetResourcesForAsset:asset];
    PHAssetResource *resource;

    for (PHAssetResource *assetRes in assetResources) {
        if (assetRes.type == PHAssetResourceTypePairedVideo ||
            assetRes.type == PHAssetResourceTypeVideo) {
            resource = assetRes;
        }
    }

    if (resource == nil || [YunValueVerifier isInvalidStr:resource.originalFilename]) {
        rst(nil);
        return;
    }

    NSString *fileName = resource.originalFilename;

    if (asset.mediaType == PHAssetMediaTypeVideo || asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;

        NSString *tmpFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:tmpFilePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:tmpFilePath error:nil]; // 先删除临时文件
        }

        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource
                                                                    toFile:[NSURL fileURLWithPath:tmpFilePath]
                                                                   options:nil
                                                         completionHandler:^(NSError *_Nullable error) {
                                                             // 有些 error 不为 nil，而 userInfo 为nil
                                                             if (error == nil) {
                                                                 rst(tmpFilePath);
                                                             }
                                                             else if (error.userInfo.allValues.count == 0) {
                                                                 if ([[NSFileManager defaultManager]
                                                                                     fileExistsAtPath:tmpFilePath]) {
                                                                     rst(tmpFilePath);
                                                                 }
                                                                 else {
                                                                     rst(nil);
                                                                 }
                                                             }
                                                             else {
                                                                 rst(nil);
                                                             }
                                                         }];
    }
    else {
        rst(nil);
    }
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
            [self notiCmpError:@"获取图片失败"];
            [picker dismissViewControllerAnimated:_disAmt completion:nil];
            return;
        }

        NSArray *imgList = nil;
        if (_isCompression) {
            NSData *imgData = [img resizeToData:self.imgBoundary
                                         andCmp:self.imgLength];
            imgList = @[imgData];
        }
        else {
            imgList = @[img];
        }

        [self notiCmpItems:imgList];
        [picker dismissViewControllerAnimated:_disAmt completion:nil];
    }
    else if ([type isEqualToString:(NSString *) kUTTypeMovie]) { // 视频
        // 保存视频
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
    [picker dismissViewControllerAnimated:_disAmt completion:nil];

    [self notiCmpItems:nil];
}

// 视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [_imgPk dismissViewControllerAnimated:_disAmt completion:nil];

    if (error) {
        [self notiCmpError:error.localizedDescription];
    }
    else {
        [self checkVideoDurWithSourcePath:videoPath];
    }
}

- (void)checkVideoDurWithSourcePath:(NSString *)videoPath {
    // 拍摄的只限制时长
    if (_videoMaxDuration >= 0) {
        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
        CMTime time = [asset duration];
        int seconds = (int) ceil(time.value / time.timescale);

        if (seconds > _videoMaxDuration) {
            [self notiCmpError:FORMAT(@"视频文件时间过长（应不长于%@s）", [YunValueHelper intStr:_videoMaxDuration])];

            return;
        }
    }

    YunImgData *videoItem = [YunImgData itemWithType:YunImgVideoFilePath data:videoPath];
    [self notiCmpItems:@[videoItem]];
}

#pragma mark - getItemData

+ (void)getItemData:(YunImgData *)item cmpFactor:(CGFloat)cmpFactor rst:(void (^)(NSData *data))rst {
    if (item.type == YunImgVideoPHAsset) {
        [self getVideoPathFromPHAsset:item.data rst:rst];

        return;
    }

    NSData *itemData = nil;

    if (item.type == YunImgImage) {
        itemData = UIImageJPEGRepresentation(item.data, cmpFactor);
    }
    else if (item.type == YunImgSrcName) {
        itemData = UIImageJPEGRepresentation([UIImage imageNamed:item.data], cmpFactor);
    }
    else if (item.type == YunImgImgData) {
        itemData = item.data;
    }
    else if (item.type == YunImgVideoFilePath) {
        NSURL *vdFile = [NSURL fileURLWithPath:item.data];
        itemData = [NSData dataWithContentsOfURL:vdFile];
    }

    rst(itemData);
}

+ (void)getVideoPathFromPHAsset:(PHAsset *)asset rst:(void (^)(NSData *))rst {
    NSArray *assetResources = [PHAssetResource assetResourcesForAsset:asset];
    PHAssetResource *resource;

    for (PHAssetResource *assetRes in assetResources) {
        if (assetRes.type == PHAssetResourceTypePairedVideo ||
            assetRes.type == PHAssetResourceTypeVideo) {
            resource = assetRes;
        }
    }

    if (resource == nil) {
        rst(nil);
        return;
    }

    NSString *fileName = @"tempAssetVideo.mov";
    if (resource.originalFilename) {
        fileName = resource.originalFilename;
    }

    if (asset.mediaType == PHAssetMediaTypeVideo || asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;

        NSString *PATH_MOVIE_FILE = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE error:nil];
        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource
                                                                    toFile:[NSURL fileURLWithPath:PATH_MOVIE_FILE]
                                                                   options:nil
                                                         completionHandler:^(NSError *_Nullable error) {
                                                             if (error) {
                                                                 rst(nil);
                                                             }
                                                             else {
                                                                 rst([NSData dataWithContentsOfFile:PATH_MOVIE_FILE]);
                                                             }
                                                         }];
    }
    else {
        rst(nil);
    }
}

@end