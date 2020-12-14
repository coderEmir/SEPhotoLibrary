//
//  UIImage+Extension.h
//  HouPu
//
//  Created by seeEmil on 2020/11/10.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)


/**
 颜色转化为图片

 @param color 入参 颜色
 @return image
 */
+ (UIImage *)imageWithColor:(UIColor *)color;


/**
 等比例缩放图片 方法

 @param image 要缩放的 image
 @param scaleSize 缩放比例
 @return  缩放后的image
 */
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;

/**
 裁剪 图片

 @return image
 */
- (UIImage *)beginClip;



@end
