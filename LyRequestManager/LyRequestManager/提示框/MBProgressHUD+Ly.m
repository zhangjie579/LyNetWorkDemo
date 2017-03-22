//
//  MBProgressHUD+Ly.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/18.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "MBProgressHUD+Ly.h"

@implementation MBProgressHUD (Ly)

#pragma mark 显示信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = text;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    [hud hide:YES afterDelay:0.7];
}

#pragma mark 显示错误信息
+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"error.png" view:view];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"success.png" view:view];
}

#pragma mark 显示一些信息
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    hud.dimBackground = YES;
    return hud;
}

+ (void)showSuccess:(NSString *)success
{
    [self showSuccess:success toView:nil];
}

+ (void)showError:(NSString *)error
{
    [self showError:error toView:nil];
}

+ (MBProgressHUD *)showMessage:(NSString *)message
{
    return [self showMessage:message toView:nil];
}

+ (void)hideHUDForView:(UIView *)view
{
    [self hideHUDForView:view animated:YES];
}

+ (void)hideHUD
{
    [self hideHUDForView:nil];
}


/**
 *  显示hud（图片+文字）
 *
 *  @param text 文字内容
 */
+ (void)showLoadingHUDWithText:(NSString *)text {
    
    [self showLoadingHUDWithText:text inView:nil];
}

+ (void)showLoadingHUDWithText:(NSString *)text inView:(UIView *)containerView {
    UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"启动图标"]];
    imgView.layer.cornerRadius = imgView.frame.size.width / 2;
    imgView.layer.masksToBounds = YES;
    
    UIView *customerView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, imgView.frame.size.width, imgView.frame.size.width)];
    [customerView addSubview:imgView];
    imgView.center = customerView.center;
    
    //外围背景Layer
    CAShapeLayer *borderLayer = [CAShapeLayer new];
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.strokeColor = [UIColor whiteColor].CGColor;
    borderLayer.lineWidth = 4.0f;
    borderLayer.bounds = imgView.bounds;
    borderLayer.position = CGPointMake(CGRectGetMidX(imgView.bounds), CGRectGetMidY(imgView.bounds));
    borderLayer.path = [UIBezierPath bezierPathWithArcCenter:borderLayer.position radius:(borderLayer.bounds.size.width - 2)/2 startAngle:0 endAngle:M_PI * 2 clockwise:YES].CGPath;
    
    [imgView.layer addSublayer:borderLayer];
    
    //滚动中得Layer
    CAShapeLayer *animationLayer = [CAShapeLayer new];
    animationLayer.strokeColor = [UIColor colorWithRed:206/255.0 green:37/255.0 blue:50/255.0 alpha:1.0].CGColor;
    animationLayer.lineWidth = borderLayer.lineWidth - 1;
    animationLayer.fillColor = [UIColor clearColor].CGColor;
    animationLayer.bounds = borderLayer.bounds;
    animationLayer.position = borderLayer.position;
    animationLayer.path = [UIBezierPath bezierPathWithArcCenter:borderLayer.position radius:(borderLayer.bounds.size.width)/2 startAngle:0 endAngle:M_PI_2*1 clockwise:YES].CGPath;
    
    //渐变色Layer
    CAGradientLayer *gradienLayer = [CAGradientLayer new];
    gradienLayer.bounds = borderLayer.bounds;
    gradienLayer.position = borderLayer.position;
    gradienLayer.colors = [self gradientColorArrayWithColor:[UIColor colorWithRed:206/255.0 green:37/255.0 blue:50/255.0 alpha:1.0]];
    gradienLayer.startPoint = CGPointMake(1, 1);
    gradienLayer.endPoint = CGPointMake(0, 0);
    [gradienLayer setMask:animationLayer];
    
    [imgView.layer addSublayer:gradienLayer];
    
    //动画
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    anim.keyPath = @"transform";
    NSValue *val1 = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0.0 * M_PI, 0, 0, 1)];
    NSValue *val2 = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0.5 * M_PI, 0, 0, 1)];
    NSValue *val3 = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(1.0 * M_PI, 0, 0, 1)];
    NSValue *val4 = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(1.5 * M_PI, 0, 0, 1)];
    NSValue *val5 = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(2.0 * M_PI, 0, 0, 1)];
    anim.values = @[val1, val2, val3, val4, val5];
    anim.duration = 1.0;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    anim.repeatCount = MAXFLOAT;
    anim.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [animationLayer addAnimation:anim forKey:@"ringLayerAnimation"];
    
    
    MBProgressHUD *hud = [self sharedHUD];
    [self appendToView:containerView];
    hud.customView = customerView;
    hud.opacity = 0.2;
    hud.mode = MBProgressHUDModeCustomView;
    hud.margin = 10.0f; //设置HUD和customerView的边距（默认是20）
    hud.yOffset = -20.0f; //设置HUD距离中心位置的y偏移（同理也可以设置xOffset）
    //    hud.userInteractionEnabled = NO; //userInteractionEnabled=NO时，不会遮挡containerView，view可以正常响应
    if (text.length > 0) {
        hud.labelText = text;
    }
    
    [hud show:YES];
}

#pragma mark - private method

+(MBProgressHUD *)sharedHUD{
    static MBProgressHUD* hud;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hud = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication].delegate window]];
        hud.removeFromSuperViewOnHide = YES;
    });
    return hud;
}

+ (void)appendToView:(UIView *)containerView
{
    if (containerView) {
        [containerView addSubview:[self sharedHUD]];
    }
    else {
        [[[UIApplication sharedApplication].delegate window] addSubview:[self sharedHUD]];
    }
}

+ (NSArray *)gradientColorArrayWithColor: (UIColor *)color{
    if (!color) {
        return nil;
    }
    return @[(id)[color colorWithAlphaComponent:0.0].CGColor, (id)[color colorWithAlphaComponent:0.1].CGColor, (id)[color colorWithAlphaComponent:0.2].CGColor, (id)[color colorWithAlphaComponent:0.3].CGColor, (id)[color colorWithAlphaComponent:0.6].CGColor, (id)[color colorWithAlphaComponent:0.8].CGColor, (id)[color colorWithAlphaComponent:1.0].CGColor, (id)[color colorWithAlphaComponent:1.0].CGColor, (id)[color colorWithAlphaComponent:1.0].CGColor];
}


@end
