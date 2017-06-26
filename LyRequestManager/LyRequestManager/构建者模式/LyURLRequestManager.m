//
//  LyURLRequestManager.m
//  LyRequestManager
//
//  Created by 张杰 on 2017/6/21.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LyURLRequestManager.h"

@interface LyURLRequestManager ()

@property(nonatomic,strong)NSString             *urlString;
@property(nonatomic,strong)NSString             *methods;//post,get....
@property(nonatomic,strong)NSDictionary         *hearders;//请求头
@property(nonatomic,strong)NSDictionary         *params;//请求参数

@end

@implementation LyURLRequestManager

- (LyURLRequestManager *(^)(NSString *url))url
{
    return ^(NSString *url) {
        self.urlString = url;
        return self;
    };
}
- (LyURLRequestManager *(^)(NSString *method))method
{
    return ^(NSString *method) {
        self.methods = method;
        return self;
    };
}
- (LyURLRequestManager *(^)(NSDictionary *hearder))hearder
{
    return ^(NSDictionary *hearder) {
        self.hearders = hearder;
        return self;
    };
}
- (LyURLRequestManager *(^)(NSDictionary *param))param
{
    return ^(NSDictionary *param) {
        self.params = param;
        return self;
    };
}

+ (instancetype)shareManager
{
    return [[LyURLRequestManager alloc] init];
}

@end
