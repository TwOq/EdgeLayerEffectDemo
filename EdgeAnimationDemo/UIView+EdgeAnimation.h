//
//  UIView+EdgeAnimation.h
//  EdgeAnimationDemo
//
//  Created by lizq on 16/8/17.
//  Copyright © 2016年 zqLee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (EdgeAnimation)

//边缘涂成填充颜色  默认: GrayColor
@property (nonatomic, strong) UIColor *edgeFillColor;
//添加边缘效果
- (void)addEdgeEffect;


@end
