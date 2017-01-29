//
//  LoginApi.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/1/20.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LoginApi.h"

@implementation LoginApi

{
    NSString  *_cellphone;
    NSString  *_password;
}

-(instancetype)initLoginWithPhone:(NSString *)cellphone password:(NSString *)password
{
    if (self==[super init]) {
        _cellphone = cellphone;
        _password  = password;
    }
    return self;
}

- (NSString *)requestUrl {
    return @"/sign/index/login";
}

-(YTKRequestMethod)requestMethod
{
    return YTKRequestMethodPOST;
}

- (id)requestArgument {
    return @{ @"cellphone": _cellphone,
              @"password":_password
              };
}

@end
