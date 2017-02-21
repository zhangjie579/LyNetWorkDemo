//
//  LyURLRequestManager.h
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/18.
//  Copyright © 2017年 张杰. All rights reserved.
//  创建NSMutableURLRequest

#import <Foundation/Foundation.h>
#import "LyUploadFile.h"

@interface LyURLRequestManager : NSObject

+ (instancetype)shareTool;

/**
 get/post请求
 
 @param urlPath 完整url
 @param method 请求方式
 @param params 请求内容
 @param header 请求头
 @return NSMutableURLRequest
 */
- (NSMutableURLRequest *)requestWithUrlPath:(NSString *)urlPath method:(NSString *)method params:(NSDictionary *)params header:(NSDictionary *)header;

/**
 上传文件请求
 
 @param urlPath 完整url
 @param method 请求方式
 @param params 请求内容
 @param contents 文件内容
 @param header 请求头
 @return NSMutableURLRequest
 */
- (NSMutableURLRequest *)uploadRequestUrlPath:(NSString *)urlPath method:(NSString *)method params:(NSDictionary *)params contents:(NSArray<LyUploadFile *> *)contents header:(NSDictionary *)header;

@end
