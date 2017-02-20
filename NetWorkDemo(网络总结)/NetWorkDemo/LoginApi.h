//
//  LoginApi.h
//  NetWorkDemo
//
//  Created by 张杰 on 2017/1/20.
//  Copyright © 2017年 张杰. All rights reserved.
//

//#import <YTKNetwork/YTKNetwork.h>
#import "YTKNetwork.h"

@interface LoginApi : YTKRequest

- (instancetype)initLoginWithPhone:(NSString*)cellphone password:(NSString*)password;

@end
