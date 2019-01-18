//
//  Created by 王健 on 16/6/2.
//  Copyright © 2016年 成都晟堃科技有限责任公司. All rights reserved.
//

#import "YunImgListView.h"
#import "YunImgCVC.h"
#import "Masonry.h"
#import "MWPhotoBrowser.h"
#import "YunImgData.h"
#import "UIView+YunAdd.h"
#import "YunSizeHelper.h"
#import "YunSelectImgHelper.h"
#import "YunValueVerifier.h"
#import "YunValueHelper.h"
#import "YunUILabelFactory.h"
#import "YunGlobalDefine.h"
#import "UIColor+YunAdd.h"
#import "YunImgViewConfig.h"
#import "NSError+YunAdd.h"
#import "YunAlertViewHelper.h"

@interface YunImgListView () <UICollectionViewDataSource, UICollectionViewDelegate,
        UICollectionViewDelegateFlowLayout, MWPhotoBrowserDelegate,
        YunSelectImgDelegate, UIAlertViewDelegate> {
    UICollectionView *_ctnCV;

    NSMutableArray<YunImgData *> *_imgDataList;
    CGFloat _viewWidth;

    MWPhotoBrowser *_imgBrowser;

    BOOL _isEdit;

    void (^_didCmp)(BOOL changed);

    YunSelectImgHelper *_selHelper;

    CGFloat _lastWidth;

    BOOL _hasAddObserver;
}

@end

@implementation YunImgListView

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
    _viewWidth = YunSizeHelper.screenWidth;
    _imgDataList = [NSMutableArray new];
    _isEdit = YES;
    _hasAddBtn = YES;
    _isZoom = YES;
    _selType = YunImgSelByCameraAndPhotoAlbum;

    _rowNum = rowNum;
    _maxCount = 9;

    _selHelper = [YunSelectImgHelper new];
    _selHelper.delegate = self;

    _selVideo = NO;

    self.backgroundColor = [UIColor clearColor];

    [self setDefaultLayout:rowNum];

    UICollectionViewFlowLayout *fl = [UICollectionViewFlowLayout new];
    [fl setScrollDirection:UICollectionViewScrollDirectionVertical];

    _ctnCV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, _viewWidth, 0) collectionViewLayout:fl];
    _ctnCV.delegate = self;
    _ctnCV.dataSource = self;
    _ctnCV.backgroundColor = [UIColor clearColor];
    [_ctnCV registerClass:YunImgCVC.class forCellWithReuseIdentifier:c_YunImgCellId_ImgItem];
    [_ctnCV registerClass:YunImgCVC.class forCellWithReuseIdentifier:c_YunImgCellId_AddItem];
    _ctnCV.showsVerticalScrollIndicator = NO;

    [self addSubview:_ctnCV];

    [_ctnCV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.left.equalTo(@0);
        make.size.equalTo(self);
    }];

    [self initObserver];
}

- (void)initObserver {
    if (!_hasAddObserver) {
        [self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];
        _hasAddObserver = YES;
    }
}

- (void)dealloc {
    if (_hasAddObserver) {
        [self removeObserver:self forKeyPath:@"bounds"];

        _hasAddObserver = NO;
    }
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.item + indexPath.section * _rowNum;

    if (index == _imgDataList.count) { // 最后一个cell 新增
        YunImgCVC *cell = [collectionView dequeueReusableCellWithReuseIdentifier:c_YunImgCellId_AddItem
                                                                    forIndexPath:indexPath];
        if (!cell) {
            cell = [YunImgCVC new];
        }

        [cell setAddItem:self.getAddItemView];
        if (_itemBgColor) {
            cell.backgroundColor = _itemBgColor;
        }

        return cell;
    }

    YunImgCVC *cell = [collectionView dequeueReusableCellWithReuseIdentifier:c_YunImgCellId_ImgItem
                                                                forIndexPath:indexPath];
    if (!cell) {
        cell = [YunImgCVC new];
    }

    [cell setImgItem:_imgDataList[index] isZoom:_isZoom];
    if (_itemBgColor) {
        cell.backgroundColor = _itemBgColor;
    }

    [cell setCoverImg:_imgDataList[index].isVideoItem ? _videoCoverImg : nil];

    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _cellSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(_interval * 0.5f, _sideOff, _interval * 0.5f, _sideOff);
}

- (CGFloat)               collectionView:(UICollectionView *)collectionView
                                  layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.item + indexPath.section * _rowNum;

    if (index < _imgDataList.count && _delegate && [_delegate respondsToSelector:@selector(shouldShowImg:)]) {
        BOOL should = [_delegate shouldShowImg:index];

        if (!should) {
            return;
        }
    }

    if (_delegate && [_delegate respondsToSelector:@selector(didShowImg)]) {
        [_delegate didShowImg];
    }

    if (index == _imgDataList.count) { // 最后一个cell 新增
        [self selectImg:nil];
        return;
    }

    [self showImageAtIndex:index];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - private functions

- (void)selectImg:(void (^)(BOOL))cmp {
    _didCmp = cmp;

    _selHelper.superVC = [self superVC];
    _selHelper.selType = _selType;
    _selHelper.maxCount = _maxCount;
    _selHelper.isCompression = _isCompression;
    _selHelper.shouldStoreImg = _shouldStoreImg;

    [_selHelper selectItem:_imgDataList.count];
}

- (void)notiCmp:(BOOL)changed {
    if (_didCmp) {
        _didCmp(changed);

        _didCmp = nil;
    }
}

- (void)addImage:(UIImage *)img {
    [self addImgByImg:img];
}

- (void)setDefaultLayout:(NSInteger)rowNum {
    _rowNum = rowNum;

    _maxCount = 6;
    _sideOff = 10;
    _interval = 10;

    [self setCellSize];
}

- (void)setCellSize {
    CGFloat cellWidth = (_viewWidth - _sideOff * 2 - _interval * (_rowNum - 1)) / _rowNum;
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
    NSInteger count = _imgDataList.count;
    if (_isEdit && _imgDataList.count < _maxCount && _hasAddBtn) {
        count++;
    }

    return count;
}

- (UIView *)getAddItemView {
    if (_cstAddView) {
        return _cstAddView;
    }

    UIView *view = [UIView new];
    [view setViewRadius:0 width:0.5f color:[UIColor hexColor:0xE6E6E6]];

    UILabel *icon = [YunUILabelFactory labelWithText:@"+"
                                                font:[UIFont boldSystemFontOfSize:30]
                                               color:UIColor.lightGrayColor
                                               align:NSTextAlignmentCenter lines:1 adjust:YES];

    [view addSubview:icon];

    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.centerY.equalTo(view);
        make.width.equalTo(view);
        make.height.equalTo(view);
    }];

    _cstAddView = view;

    return view;
}

#pragma mark - public functions

- (void)resetImgByImgList:(NSArray<YunImgData *> *)imgList {
    [self removeAllImg];

    [self addImgByInfoList:imgList];
}

- (void)resetImgByImgUrlList:(NSArray *)imgList {
    [self removeAllImg];

    [self addImgByUrlStrList:imgList];
}

- (void)addImgByImg:(UIImage *)image {
    if (image == nil) {
        return;
    }

    if (_imgDataList.count >= _maxCount) {
        [self showImageOutOfCount];
        return;
    }

    YunImgData *imgInfo = [YunImgData new];
    imgInfo.type = YunImgImage;
    imgInfo.data = image;

    [_imgDataList addObject:imgInfo];

    [self reloadImgData];
}

- (void)addImgByImgData:(NSData *)data {
    if (data == nil) {
        return;
    }

    if (_imgDataList.count >= _maxCount) {
        [self showImageOutOfCount];
        return;
    }

    YunImgData *imgInfo = [YunImgData new];
    imgInfo.type = YunImgImgData;
    imgInfo.data = data;

    [_imgDataList addObject:imgInfo];

    [self reloadImgData];
}

- (void)addImgByInfoList:(NSArray<YunImgData *> *)imgList {
    if (imgList == nil) {
        return;
    }

    if ((_imgDataList.count + imgList.count) > _maxCount) {
        [self showImageOutOfCount];

        return;
    }

    for (int i = 0; i < imgList.count; ++i) {
        if ([imgList[i] isKindOfClass:YunImgData.class]) {
            [_imgDataList addObject:imgList[i]];
        }
        else if ([imgList[i] isKindOfClass:NSString.class]) {
            [_imgDataList addObject:[YunImgData itemWithType:YunImgURLStr data:imgList[i]]];
        }
    }

    [self reloadImgData];
}

// url -> ImageData
- (void)addImgByUrlTypeImg:(NSArray *)urlList {
    if (urlList == nil) {
        return;
    }

    if ((_imgDataList.count + urlList.count) > _maxCount) {
        [self showImageOutOfCount];

        return;
    }

    for (int i = 0; i < urlList.count; ++i) {
        id item = urlList[i];
        if ([item isKindOfClass:[YunImgData class]]) {
            [_imgDataList addObject:item];
        }
        else if ([item isKindOfClass:[NSString class]]) {
            [self addImgDataByUrlStr:item];
        }
        else if ([item isKindOfClass:[NSMutableString class]]) {
            NSString *imgStr = item;
            [self addImgDataByUrlStr:imgStr];
        }
    }

    [self reloadImgData];
}

- (void)addImgByUrlStrList:(NSArray *)urlList {
    if (urlList == nil) {
        return;
    }

    if ((_imgDataList.count + urlList.count) > _maxCount) {
        [self showImageOutOfCount];

        return;
    }

    for (int i = 0; i < urlList.count; ++i) {
        YunImgData *imgInfo = [YunImgData new];
        imgInfo.type = YunImgURLStr;
        imgInfo.data = urlList[i];

        [_imgDataList addObject:imgInfo];
    }

    [self reloadImgData];
}

- (void)addImgDataByUrlStr:(NSString *)url {
    if (_imgDataList.count >= _maxCount) {
        [self showImageOutOfCount];

        return;
    }

    YunImgData *imgInfo = [YunImgData new];
    imgInfo.type = YunImgURLStr;
    imgInfo.data = url;

    [_imgDataList addObject:imgInfo];
}

- (void)addVideoByVideoItem:(YunImgData *)videoItem {
    if (_imgDataList.count >= _maxCount) {
        [self showImageOutOfCount];

        return;
    }

    [_imgDataList addObject:videoItem];

    [self reloadImgData];
}

- (void)removeAllImg {
    [_imgDataList removeAllObjects];

    [self reloadImgData];
}

- (void)reloadImgData {
    [self setViewWidth:self.width refresh:NO];

    [self updateViewConstraints];

    [_ctnCV reloadData];
}

- (void)updateViewConstraints {
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@([self curHeight]));
    }];

    if (_delegate && [_delegate respondsToSelector:@selector(viewSizeChanged)]) {
        [_delegate viewSizeChanged];
    }
}

- (NSMutableArray<YunImgData *> *)curImgList {
    return _imgDataList;
}

- (BOOL)isSameImgs:(NSArray<YunImgData *> *)imgList {
    NSArray *curImgs = self.curImgList;

    if (curImgs.count != imgList.count) {return NO;}

    for (int i = 0; i < curImgs.count; ++i) {
        if (![curImgs[i] isSame:imgList[i]]) {return NO;}
    }

    return YES;
}

- (CGFloat)curHeight {
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
        make.height.equalTo(@([self curHeight]));
    }];

    [_ctnCV reloadData];

    //[self layoutIfNeeded];
}

#pragma mark - image browser

- (void)showImageAtIndex:(NSInteger)index {
    _imgBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];

    _imgBrowser.displayActionButton = NO;
    _imgBrowser.displayNavArrows = NO;
    _imgBrowser.displaySelectionButtons = NO;
    _imgBrowser.alwaysShowControls = NO;
    _imgBrowser.zoomPhotosToFill = YES;
    _imgBrowser.enableGrid = NO;
    _imgBrowser.startOnGrid = NO;
    _imgBrowser.enableSwipeToDismiss = NO;
    _imgBrowser.autoPlayOnAppear = YES;
    _imgBrowser.delegate = self;

    _imgBrowser.hideNagItemDone = YES;

    [_imgBrowser setCurrentPhotoIndex:index];

    UINavigationController *ng = [[UINavigationController alloc] initWithRootViewController:_imgBrowser];

    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                       target:self
                                                                       action:@selector(didPBBack)];

    _imgBrowser.navigationItem.leftBarButtonItem = leftItem;

    if (_isEdit || _forceDel) {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"删除"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(deleteImage:)];

        _imgBrowser.navigationItem.rightBarButtonItem = rightItem;
    }
    else {
        _imgBrowser.navigationItem.rightBarButtonItem = nil;
    }

    if (_delegate && [_delegate respondsToSelector:@selector(initWithMWPhotoBrowser:)]) {
        [_delegate initWithMWPhotoBrowser:_imgBrowser];
    }

    [[self superVC] presentViewController:ng animated:YES completion:^{
    }];
}

- (void)didPBBack {
    [_imgBrowser dismissViewControllerAnimated:YES completion:nil];
}

- (void)deleteImage:(id)deleteImage {
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提醒"
                                                 message:@"确认删除照片?"
                                                delegate:self
                                       cancelButtonTitle:@"取消"
                                       otherButtonTitles:@"确定", nil];
    [al show];
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

#pragma mark - UIAlertViewDelegate

//监听点击事件 代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([btnTitle isEqualToString:@"取消"]) {
    }
    else if ([btnTitle isEqualToString:@"确定"]) {
        [_imgDataList removeObjectAtIndex:_imgBrowser.currentIndex];

        if (_imgDataList.count == 0) {
            [self reloadImgData];
            [self didPBBack];
            return;
        }

        if (_imgBrowser.currentIndex > _imgDataList.count - 1) {
            [_imgBrowser setCurrentPhotoIndex:_imgBrowser.currentIndex - 1];
        }

        [self reloadImgData];

        [_imgBrowser reloadData];
    }
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    if (_imgDataList) {
        return _imgDataList.count;
    }

    return 0;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (_imgDataList) {
        if (_imgDataList.count > index) {
            return [self imageForIndex:index];
        }
    }

    return nil;
}

- (MWPhoto *)imageForIndex:(NSInteger)index {
    YunImgData *img = _imgDataList[index];
    if (img) {
        switch (img.type) {
            case YunImgImage:
                return [MWPhoto photoWithImage:img.data];
            case YunImgURLStr:
                return [MWPhoto photoWithURL:[NSURL URLWithString:img.data]];
            case YunImgImgData:
                return [MWPhoto photoWithImage:[UIImage imageWithData:img.data]];
            case YunImgSrcName:
                return [MWPhoto photoWithImage:[UIImage imageNamed:img.data]];
            case YunImgVideoURLStr: {
                return [self getMwVideo:img];
            }
            case YunImgVideoFilePath: {
                return [self getMwVideo:img];
            }
            case YunImgVideoPHAsset: {
                return [self getMwVideo:img];
            }
            default:
                break;
            case YunImgUnknown:
                break;

        }
    }

    return nil;
}

- (MWPhoto *)getMwVideo:(YunImgData *)img {
    MWPhoto *video;

    switch (img.thumbData.type) {
        case YunImgUnknown:
            break;
        case YunImgImage:
            video = [MWPhoto photoWithImage:img.thumbData.data];
            break;
        case YunImgURLStr:
            video = [MWPhoto photoWithURL:[NSURL URLWithString:img.thumbData.data]];
            break;
        case YunImgSrcName:
            video = [MWPhoto photoWithImage:[UIImage imageNamed:img.thumbData.data]];
            break;
        case YunImgImgData:
            video = [MWPhoto photoWithImage:[UIImage imageWithData:img.thumbData.data]];
            break;
        case YunImgVideoURLStr:
            break;
        case YunImgVideoFilePath:
            break;
        case YunImgVideoPHAsset:
            break;
    }

    if (video == nil) {
        video = [MWPhoto new];
        video.isVideo = YES;
    }

    if (img.type == YunImgVideoURLStr) {
        video.videoURL = [NSURL URLWithString:img.data];
    }
    else if (img.type == YunImgVideoFilePath) {
        video.videoURL = [NSURL fileURLWithPath:img.data];
    }
    else if (img.type == YunImgVideoPHAsset) {
        video = [MWPhoto photoWithAsset:img.data targetSize:[UIScreen mainScreen].bounds.size];
    }

    return video;
}

- (void)showImageOutOfCount {
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提醒"
                                                 message:FORMAT(@"最多添加%@张图片", [YunValueHelper intStr:_maxCount])
                                                delegate:self
                                       cancelButtonTitle:@"知道了"
                                       otherButtonTitles:nil];
    [al show];
}

- (UIViewController *)superVC {
    return [self superViewController];
}

#pragma mark - YunSelectImgDelegate

- (void)didCmpWithItems:(NSArray *)items error:(NSError *)error selType:(YunSelectImgType)selType {
    if (error) {
        [YunAlertViewHelper.instance showYes:error.getErrorMsg];

        return;
    }

    if (items == nil || items.count == 0) {return;}

    [self notiCmp:YES];

    for (int i = 0; i < items.count; ++i) {
        if (selType == YunVideoSelByCamera || selType == YunVideoSelByPhotoAlbum) {

            [self addVideoByVideoItem:items[i]];
            continue;
        }

        if ([items[i] isKindOfClass:UIImage.class]) {
            [self addImgByImg:items[i]];
        }
        else if ([items[i] isKindOfClass:NSData.class]) {
            [self addImgByImgData:items[i]];
        }
    }
}

- (void)selectItemByType:(YunSelectImgType)type cmp:(void (^)(YunSelectImgType type))cmp {
    if (_delegate && [_delegate respondsToSelector:@selector(selectItemByType:cmp:)]) {
        [_delegate selectItemByType:type cmp:cmp];
    }
    else if (YunImgViewConfig.instance.delegate &&
             [YunImgViewConfig.instance.delegate respondsToSelector:@selector(selectItemByType:cmp:)]) {
        [YunImgViewConfig.instance.delegate selectItemByType:type cmp:cmp];
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
        }
    }
}

@end