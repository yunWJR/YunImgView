//
//  Created by 王健 on 16/6/2.
//  Copyright © 2016年 成都晟堃科技有限责任公司. All rights reserved.
//

#import "ImgEditListView.h"
#import "Masonry.h"
#import "MWPhotoBrowser.h"
#import "YunImgData.h"
#import "UIView+YunAdd.h"
#import "ImageEditCVC.h"
#import "YunSizeHelper.h"
#import "PpmAlertHelper.h"
#import "YunSelectImgHelper.h"
#import "YunValueVerifier.h"
#import "PpmLogHelper.h"
#import "YunValueHelper.h"
#import "YunUILabelFactory.h"
#import "PpmIconFontDefine.h"
#import "PpmTheme.h"
#import "PpmThemeHeader.h"

@interface ImgEditListView () <UICollectionViewDataSource, UICollectionViewDelegate,
        UICollectionViewDelegateFlowLayout, MWPhotoBrowserDelegate, YunSelectImgDelegate> {
    UICollectionView *_ctnCV;

    NSMutableArray<YunImgData *> *_imgInfoList;
    CGFloat _viewWidth;

    MWPhotoBrowser *_imgBrowser;

    BOOL _isEdit;

    void (^_didCmp)(BOOL);

    YunSelectImgHelper *_selHelper;

    UIView *_addView;

    CGFloat _lastWidth;
}

@end

@implementation ImgEditListView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initSubView:3];
    }

    return self;
}

- (instancetype)initWithRowNum:(NSInteger)rowNum {
    self = [super init];
    if (self) {
        [self initSubView:rowNum];
    }

    return self;
}

- (void)initSubView:(NSInteger)rowNum {
    [self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];

    _viewWidth = YunSizeHelper.screenWith;
    _imgInfoList = [NSMutableArray new];
    _isEdit = YES;
    _hasAddBtn = YES;

    _selHelper = [YunSelectImgHelper new];
    _selHelper.delegate = self;

    self.backgroundColor = [UIColor clearColor];

    [self setDefaultLayout:rowNum];

    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];

    _ctnCV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, _viewWidth, 0) collectionViewLayout:flowLayout];
    _ctnCV.delegate = self;
    _ctnCV.dataSource = self;
    _ctnCV.backgroundColor = [UIColor clearColor];
    [_ctnCV registerClass:[ImageEditCVC class] forCellWithReuseIdentifier:ImageEditCellId_ImgItem];
    [_ctnCV registerClass:[ImageEditCVC class] forCellWithReuseIdentifier:ImageEditCellId_AddItem];
    _ctnCV.showsVerticalScrollIndicator = NO;

    [self addSubview:_ctnCV];

    [_ctnCV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.left.equalTo(@0);
        make.size.equalTo(self);
    }];

    // other
    _addView = [self createAddView];
}

- (UIView *)createAddView {
    UIView *view = [UIView new];
    [view setViewRadius:0 width:PpmTheme.lineHeight color:PpmTheme.colorBsDkL_A4];

    UILabel *icon = [YunUILabelFactory labelWithIcon:IconFontAdd
                                            fontSize:[PpmTheme screenSize:20] textColor:PpmTheme.colorBsDkL_A4];
    [view addSubview:icon];

    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.centerY.equalTo(view);
        make.width.equalTo(view);
        make.height.equalTo(view);
    }];

    return view;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"bounds"];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == ([self sectionCount] - 1)) {
        return ([self countCellNum] - _rowNum * section);
    }
    else {
        return _rowNum;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self sectionCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.item + indexPath.section * _rowNum;

    if (index == _imgInfoList.count) { // 最后一个cell 新增
        ImageEditCVC *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ImageEditCellId_AddItem forIndexPath:indexPath];
        if (!cell) {
            cell = [ImageEditCVC new];
        }

        [cell setAddItem:_addView];

        return cell;
    }

    ImageEditCVC *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ImageEditCellId_ImgItem forIndexPath:indexPath];
    if (!cell) {
        cell = [ImageEditCVC new];
    }

    [cell setImgItem:_imgInfoList[index]];

    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _cellSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(_interval * 0.5f, _sideOffset, _interval * 0.5f, _sideOffset);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_didShowImg) {
        _didShowImg();
    }

    NSInteger index = indexPath.item + indexPath.section * _rowNum;
    if (index == _imgInfoList.count) { // 最后一个cell 新增
        [self selectAvr];
        return;
    }

    [self showImageAtIndex:index];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - private functions

- (void)selectAvr:(void (^)(BOOL))cmp {
    _didCmp = cmp;

    // todo
    _selHelper.superVC = [self superVC];
    _selHelper.isCameraOnly = _isCameraOnly;
    _selHelper.maxCount = _maxCount;

    [_selHelper selectImg:_imgInfoList.count];
}

- (void)notiCmp:(BOOL)changed {
    if (_didCmp) {
        _didCmp(changed);

        _didCmp = nil;
    }
}

- (void)selectAvr {
    [self selectAvr:nil];
}

- (void)addImage:(UIImage *)tempImage {
    [self addImageByImage:tempImage];
}

- (void)setDefaultLayout:(NSInteger)rowNum {
    _rowNum = rowNum;

    _maxCount = 6;
    _sideOffset = 10;
    _interval = 10;

    [self setCellSize];
}

- (void)setCellSize {
    CGFloat cellWidth = (_viewWidth - _sideOffset * 2 - _interval * (_rowNum - 1)) / _rowNum;
    _cellSize = CGSizeMake(cellWidth, cellWidth);
}

- (NSInteger)sectionCount {
    NSInteger num = 0;
    NSInteger count = [self countCellNum];

    if (count > 0 && _rowNum != 0) {
        num = count / _rowNum;
        if ((count % _rowNum) != 0) {
            num++;
        }
    }

    return num;
}

- (NSInteger)countCellNum {
    NSInteger count = _imgInfoList.count;
    if (_isEdit && _imgInfoList.count < _maxCount && _hasAddBtn) {
        count++;
    }

    return count;
}

#pragma mark - public functions

- (void)resetImagesByImageInfoList:(NSArray<YunImgData *> *)imgList {
    [self removeAllImage];
    [self addImagesByImageInfoList:imgList];
}

- (void)addImageByImage:(UIImage *)image {
    if (_imgInfoList.count >= _maxCount) {
        [self showImageOutOfCount];
        return;
    }

    YunImgData *imgInfo = [YunImgData new];
    imgInfo.type = YunImgImage;
    imgInfo.data = image;

    [_imgInfoList addObject:imgInfo];

    [self reloadImgData];
}

- (void)addImagesByImageInfoList:(NSArray<YunImgData *> *)imgList {
    if (imgList == nil) {
        return;
    }

    if ((_imgInfoList.count + imgList.count) > _maxCount) {
        [self showImageOutOfCount];

        return;
    }

    for (int i = 0; i < imgList.count; ++i) {
        if ([imgList[i] isKindOfClass:YunImgData.class]) {
            [_imgInfoList addObject:imgList[i]];
        }
        else if ([imgList[i] isKindOfClass:NSString.class]) {
            [_imgInfoList addObject:[YunImgData itemWithType:YunImgURLStr data:imgList[i]]];
        }
    }

    //[_ctnCV reloadData];
    [self reloadImgData];
}

// url -> ImageData
- (void)addImagesByURLTypeInfo:(NSArray *)url {
    if (url == nil) {
        return;
    }

    if ((_imgInfoList.count + url.count) > _maxCount) {
        [self showImageOutOfCount];

        return;
    }

    for (int i = 0; i < url.count; ++i) {
        id img = url[i];
        if ([img isKindOfClass:[YunImgData class]]) {
            [_imgInfoList addObject:img];
        }
        else if ([img isKindOfClass:[NSString class]]) {
            [self addImgDataByURLStr:img];
        }
        else if ([img isKindOfClass:[NSMutableString class]]) {
            NSString *imgStr = img;
            [self addImgDataByURLStr:imgStr];
        }
    }

    [self reloadImgData];
}

- (void)addImageByURLStrs:(NSArray *)url {
    if (url == nil) {
        return;
    }

    if ((_imgInfoList.count + url.count) > _maxCount) {
        [self showImageOutOfCount];

        return;
    }

    for (int i = 0; i < url.count; ++i) {
        YunImgData *imgInfo = [YunImgData new];
        imgInfo.type = YunImgURLStr;
        imgInfo.data = url[i];

        [_imgInfoList addObject:imgInfo];
    }

    [self reloadImgData];
}

- (void)addImgDataByURLStr:(NSString *)url {
    if (_imgInfoList.count >= _maxCount) {
        [self showImageOutOfCount];

        return;
    }

    YunImgData *imgInfo = [YunImgData new];
    imgInfo.type = YunImgURLStr;
    imgInfo.data = url;

    [_imgInfoList addObject:imgInfo];

//    [_imageCV reloadData];
//    [self updateViewConstraints];
}

- (void)removeAllImage {
    [_imgInfoList removeAllObjects];

    [self reloadImgData];
}

- (void)reloadImgData {
    [self setViewWidth:self.width refresh:NO];

    [self updateViewConstraints];

    [_ctnCV reloadData];
}

- (void)updateViewConstraints {
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@([self currentHeight]));
    }];

    //[self layoutIfNeeded];

    if (_imgListViewChanged) {
        _imgListViewChanged();
    }
}

- (NSMutableArray<YunImgData *> *)currentImageList {
    return _imgInfoList;
}

- (BOOL)isSameImgs:(NSArray<YunImgData *> *)imgs {
    NSArray *curImgs = self.currentImageList;

    if (curImgs.count != imgs.count) {return NO;}

    for (int i = 0; i < curImgs.count; ++i) {
        if (![curImgs[i] isSame:imgs[i]]) {return NO;}
    }

    return YES;
}

- (CGFloat)currentHeight {
    return [self sectionCount] * (_cellSize.height + _interval) + 4;
}

- (void)setViewWidth:(CGFloat)width refresh:(BOOL)refresh {
    if (width <= 0) {return;}

    _viewWidth = width;

    [self setCellSize];

    if (refresh) {
        [self reloadImgData];
    }
}

- (void)setEdit:(BOOL)isEdit {
    _isEdit = isEdit;

    //[self reloadImgData];
}

- (void)updateViewWidth:(CGFloat)width andEidt:(BOOL)isEdit {
    _viewWidth = width;
    _isEdit = isEdit;

    [self setCellSize];

    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@([self currentHeight]));
    }];

    [_ctnCV reloadData];

    //[self layoutIfNeeded];
}

#pragma mark - image browser

- (void)showImageAtIndex:(NSInteger)index {
    _imgBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    if (_isEdit || _forceDel) {
        UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithTitle:@"删除"
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(deleteImage:)];
        saveBtn.tintColor = [UIColor whiteColor];
        [_imgBrowser.navigationItem setRightBarButtonItem:saveBtn];
    }

    _imgBrowser.displayActionButton = NO;
    _imgBrowser.displayNavArrows = YES;
    _imgBrowser.displaySelectionButtons = NO;
    _imgBrowser.alwaysShowControls = NO;
    _imgBrowser.zoomPhotosToFill = YES;
    _imgBrowser.enableGrid = NO;
    _imgBrowser.startOnGrid = NO;
    _imgBrowser.enableSwipeToDismiss = NO;
    _imgBrowser.autoPlayOnAppear = YES;
    _imgBrowser.delegate = self;
    [_imgBrowser setCurrentPhotoIndex:index];

    [[self superVC].navigationController pushViewController:_imgBrowser animated:YES];
}

- (void)deleteImage:(id)deleteImage {
    [[PpmAlertHelper instance] showDeleteAlert:@"确认删除照片?" result:^(BOOL delete) {
        if (delete) {
            [_imgInfoList removeObjectAtIndex:_imgBrowser.currentIndex];

            if (_imgInfoList.count == 0) {
                [self reloadImgData];
                [_imgBrowser.navigationController popViewControllerAnimated:YES];
                return;
            }

            if (_imgBrowser.currentIndex > _imgInfoList.count - 1) {
                [_imgBrowser setCurrentPhotoIndex:_imgBrowser.currentIndex - 1];
            }

            [self reloadImgData];

            [_imgBrowser reloadData];
        }
    }];
}

// 保存到相册
- (void)savedPhotosToAlbum:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *) self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    if (_imgInfoList) {
        return _imgInfoList.count;
    }

    return 0;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (_imgInfoList) {
        if (_imgInfoList.count > index) {
            return [self imageForIndex:index];
        }
    }

    return nil;
}

- (MWPhoto *)imageForIndex:(NSInteger)index {
    YunImgData *img = _imgInfoList[index];
    if (img) {
        switch (img.type) {
            case YunImgImage:
                return [MWPhoto photoWithImage:img.data];
                break;
            case YunImgURLStr:
                return [MWPhoto photoWithURL:[NSURL URLWithString:img.data]];
                break;
            default:
                NSLog(@"ImageSrcUnkonw");
                break;
        }
    }

    return nil;
}

- (void)showImageOutOfCount {
    [[PpmAlertHelper instance] showErrorMsg:
             [NSString stringWithFormat:@"最多添加%@张图片", [YunValueHelper intStr:_maxCount]]
                                      sView:[self superVC].view.window result:nil];
}

- (UIViewController *)superVC {
    return [self superViewController];
}

#pragma mark - PpmSelectImageDelegate

- (void)didCmp:(BOOL)cmp imgs:(NSArray<UIImage *> *)imgs selType:(YunSelectImgType)isCamera {
    [self notiCmp:cmp];

    if (imgs == nil || imgs.count == 0) {return;}

    for (int i = 0; i < imgs.count; ++i) {
        [self addImage:imgs[i]];

        if (_shouldStoreImg && isCamera) {
            [self savedPhotosToAlbum:imgs[i]];
        }
    }
}

#pragma mark - noti

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object change:(NSDictionary<NSString *, id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"bounds"]) {
        if (![YunValueVerifier isSameFloat:self.width value2:_lastWidth]) {
            _lastWidth = self.width;

            [self reloadImgData];

            [PpmLogHelper logMsg:@"img view bounds changed"];
        }
    }
}

@end