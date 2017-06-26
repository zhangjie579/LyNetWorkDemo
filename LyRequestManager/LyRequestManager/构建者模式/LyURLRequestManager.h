//
//  LyURLRequestManager.h
//  LyRequestManager
//
//  Created by 张杰 on 2017/6/21.
//  Copyright © 2017年 张杰. All rights reserved.
//  请求参数

#import <Foundation/Foundation.h>

@interface LyURLRequestManager : NSObject

@property(nonatomic,strong,readonly)NSString             *urlString;
@property(nonatomic,strong,readonly)NSString             *methods;//post,get....
@property(nonatomic,strong,readonly)NSDictionary         *hearders;//请求头
@property(nonatomic,strong,readonly)NSDictionary         *params;//请求参数
//@property(nonatomic,strong,readonly)NSArray

+ (instancetype)shareManager;

- (LyURLRequestManager *(^)(NSString *url))url;
- (LyURLRequestManager *(^)(NSString *method))method;
- (LyURLRequestManager *(^)(NSDictionary *hearder))hearder;
- (LyURLRequestManager *(^)(NSDictionary *param))param;

@end

//@interface LyURLRequestFile : NSObject
//
//@end
