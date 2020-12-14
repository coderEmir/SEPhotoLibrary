//
//  UIScrollView+Extension.m
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/12/11.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import "UIScrollView+Extension.h"

#import <objc/runtime.h>

@implementation UIScrollView (Extension)

- (NSString *)viewName
{
    return objc_getAssociatedObject(self, @"viewName");
}

- (void)setViewName:(NSString *)viewName {
    objc_setAssociatedObject(self, @"viewName", viewName, OBJC_ASSOCIATION_COPY);
}

@end
