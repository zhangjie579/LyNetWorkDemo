//
//  MyUserInfoUploadImageApi.h
//  NetWorkDemo
//
//  Created by 张杰 on 2017/1/20.
//  Copyright © 2017年 张杰. All rights reserved.
//

//#import <YTKNetwork/YTKNetwork.h>
#import "YTKNetwork.h"
#import <UIKit/UIKit.h>

@interface MyUserInfoUploadImageApi : YTKRequest

- (id)initWithImage:(UIImage *)image uid:(NSString *)uid;
//- (NSString *)responseImageId;

@end
