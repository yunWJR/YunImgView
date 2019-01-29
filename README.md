# YunImgView


封装的 iOS 图片列表控件，用 Objective-C 编写

- Platform:  iOS 9.0 and later

## 需要的基本库

- YunBaseApp

- YunKits

- YunImageBrowser

- Mantle

- TZImagePickerController

- YunPmsHelper


## 主要功能

该库主要包括两部分：1）YunImgView 图片列表库。2）YunSelectImgHelper 图片视频选择库。

## 1. YunImgView 

使用示例

```
    YunImgListView *imgListView = [YunImgListView new];
    imgListView.delegate = self;

    // 参数设定，具体参数参见YunImgListView
    imgListView.hasAddBtn = YES; // 是否显示添加新图片按钮，如果为 YES，最后一格为添加新图片按钮。
    imgListView.maxCount = 12; // 最多图片数，默认9
    imgListView.rowNum = 4; // 每行显示图片数量，默认3

    [self.view addSubview:imgListView];

    [imgListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
        make.height.equalTo(@200);
        make.width.equalTo(self.view);
    }];
    
    // 设置显示的图片
    [imgListView resetImgByImgUrlList:@[@"url",@"url"]];
```


## 2. YunSelectImgHelper

### 1） 实现代理

以下两种代理任意实现一种。

```
    // 全局选择图片代理
    YunImgViewConfig.instance.delegate = self;

    // 实例选择图片代理
    YunSelectImgHelper *selectImgHelper = [YunSelectImgHelper new];
    selectImgHelper.delegate = self;
```

### 2）参数设置

图片或视频选择的参数可以在 全局**YunImgViewConfig.instance**设置，或者对应实例单独设置。

具体可配参数见**YunImgViewConfig** 或 **YunSelectImgHelper**。

### 3）选择图片

```
    NSInteger curCount = 0; // 已选择了图片数量，与maxCount对应。
    [selectImgHelper selectItem:curCount];
```

## 安装

Use the cocoaPods

> `pod 'YunImgView'`


