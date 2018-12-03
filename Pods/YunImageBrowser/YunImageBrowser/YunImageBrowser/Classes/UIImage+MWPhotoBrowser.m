//
//  UIImage+MWPhotoBrowser.m
//  Pods
//
//  Created by Michael Waterfall on 05/07/2015.
//
//

#import "UIImage+MWPhotoBrowser.h"

@implementation UIImage (MWPhotoBrowser)

+ (UIImage *)imageForResourcePath:(NSString *)path ofType:(NSString *)type inBundle:(NSBundle *)bundle {
    //NSString *tmp = [bundle pathForResource:path ofType:type];

    NSString *name = [self stringByReplacing:path
                                       regex:@"MWPhotoBrowser.bundle/"
                                     options:NSRegularExpressionAllowCommentsAndWhitespace
                                  withString:@""];

    bundle = [NSBundle mainBundle];
    NSString *resourcePath = [bundle resourcePath];
    NSString *filePath = [resourcePath stringByAppendingPathComponent:name];

    UIImage *img = [UIImage imageWithContentsOfFile:filePath];


    //UIImage *img = [UIImage imageWithContentsOfFile:[bundle pathForResource:path ofType:type]];

    return img;
}

+ (NSString *)stringByReplacing:(NSString *)org
                          regex:(NSString *)regex
                        options:(NSRegularExpressionOptions)options
                     withString:(NSString *)replacement; {
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:nil];
    if (!pattern) return org;
    return [pattern stringByReplacingMatchesInString:org
                                             options:0
                                               range:NSMakeRange(0, [org length])
                                        withTemplate:replacement];
}

+ (UIImage *)clearImageWithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return blank;
}

@end
