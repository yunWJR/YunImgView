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

@interface YunImgListView () <UICollectionViewDataSource, UICollectionViewDelegate,
        UICollectionViewDelegateFlowLayout, MWPhotoBrowserDelegate,
        YunSelectImgDelegate, UIAlertViewDelegate> {
    UICollectionView *_ctnCV;

    NSMutableArray<YunImgData *> *_imgDataList;
    CGFloat _viewWidth;

    MWPhotoBrowser *_imgBrowser;

    BOOL _isEdit;

    void (^_didCmp)(BOOL);

    YunSelectImgHelper *_selHelper;

    UIView *_addView;

    CGFloat _lastWidth;
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
    [self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];

    _viewWidth = YunSizeHelper.screenWidth;
    _imgDataList = [NSMutableArray new];
    _isEdit = YES;
    _hasAddBtn = YES;
    _isZoom = YES;

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
    [_ctnCV registerClass:[YunImgCVC class] forCellWithReuseIdentifier:YunImgCellId_ImgItem];
    [_ctnCV registerClass:[YunImgCVC class] forCellWithReuseIdentifier:YunImgCellId_AddItem];
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.item + indexPath.section * _rowNum;

    if (index == _imgDataList.count) { // 最后一个cell 新增
        YunImgCVC *cell = [collectionView dequeueReusableCellWithReuseIdentifier:YunImgCellId_AddItem
                                                                    forIndexPath:indexPath];
        if (!cell) {
            cell = [YunImgCVC new];
        }

        [cell setAddItem:_addView];
        cell.backgroundColor = _itemBgColor;

        return cell;
    }

    YunImgCVC *cell = [collectionView dequeueReusableCellWithReuseIdentifier:YunImgCellId_ImgItem
                                                                forIndexPath:indexPath];
    if (!cell) {
        cell = [YunImgCVC new];
    }

    [cell setImgItem:_imgDataList[index] isZoom:_isZoom];
    cell.backgroundColor = _itemBgColor;

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
    if (_delegate && [_delegate respondsToSelector:@selector(didShowImg)]) {
        [_delegate didShowImg];
    }

    NSInteger index = indexPath.item + indexPath.section * _rowNum;
    if (index == _imgDataList.count) { // 最后一个cell 新增
        [self selectImg];
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

    [_selHelper selectImg:_imgDataList.count];
}

- (void)notiCmp:(BOOL)changed {
    if (_didCmp) {
        _didCmp(changed);

        _didCmp = nil;
    }
}

- (void)selectImg {
    [self selectImg:nil];
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

- (UIView *)createAddView {
    UIView *view = [UIView new];
    [view setViewRadius:0 width:0.5f color:UIColor.lightGrayColor];

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

    return view;
}

#pragma mark - public functions

- (void)resetImgByImgList:(NSArray<YunImgData *> *)imgList {
    [self removeAllImg];
    [self addImgByInfoList:imgList];
}

- (void)resetImgByImgUrlList:(NSArray *)imgList {
    [self removeAllImg];

    [self addImgByUrlStrsList:imgList];
}

- (void)addImgByImg:(UIImage *)image {
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

    //[_ctnCV reloadData];
    [self reloadImgData];
}

// url -> ImageData
- (void)addImgByUrlTypeImg:(NSArray *)url {
    if (url == nil) {
        return;
    }

    if ((_imgDataList.count + url.count) > _maxCount) {
        [self showImageOutOfCount];

        return;
    }

    for (int i = 0; i < url.count; ++i) {
        id img = url[i];
        if ([img isKindOfClass:[YunImgData class]]) {
            [_imgDataList addObject:img];
        }
        else if ([img isKindOfClass:[NSString class]]) {
            [self addImgDataByUrlStr:img];
        }
        else if ([img isKindOfClass:[NSMutableString class]]) {
            NSString *imgStr = img;
            [self addImgDataByUrlStr:imgStr];
        }
    }

    [self reloadImgData];
}

- (void)addImgByUrlStrsList:(NSArray *)url {
    if (url == nil) {
        return;
    }

    if ((_imgDataList.count + url.count) > _maxCount) {
        [self showImageOutOfCount];

        return;
    }

    for (int i = 0; i < url.count; ++i) {
        YunImgData *imgInfo = [YunImgData new];
        imgInfo.type = YunImgURLStr;
        imgInfo.data = url[i];

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

//    [_imageCV reloadData];
//    [self updateViewConstraints];
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

    //[self layoutIfNeeded];

    if (_delegate && [_delegate respondsToSelector:@selector(viewSizeChanged)]) {
        [_delegate viewSizeChanged];
    }
}

- (NSMutableArray<YunImgData *> *)curImgList {
    return _imgDataList;
}

- (BOOL)isSameImgs:(NSArray<YunImgData *> *)imgs {
    NSArray *curImgs = self.curImgList;

    if (curImgs.count != imgs.count) {return NO;}

    for (int i = 0; i < curImgs.count; ++i) {
        if (![curImgs[i] isSame:imgs[i]]) {return NO;}
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
    //NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
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
            [_imgBrowser.navigationController popViewControllerAnimated:YES];
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

- (void)selectImgByType:(void (^)(YunSelectImgType type))cmp {
    if (_delegate && [_delegate respondsToSelector:@selector(selectImgByType:)]) {
        return [_delegate selectImgByType:cmp];
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