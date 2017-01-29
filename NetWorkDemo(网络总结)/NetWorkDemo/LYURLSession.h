//
//  LYURLSession.h
//  NetWorkDemo
//
//  Created by 张杰 on 2017/1/21.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LYURLSession : NSObject

+ (instancetype)shareTool;

#pragma mark - post请求

/**
 post请求(有请求头Header)

 @param url 请求地址url
 @param token 请求头token
 @param keyString 请求参数 : @"vid=1&p=1"
 @param success 成功返回
 @param failure 失败返回
 */
- (void)post:(NSString *)url token:(NSString *)token keyString:(NSString *)keyString success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure;

/**
 post请求
 
 @param url 请求地址url
 @param keyString 请求参数 : @"vid=1&p=1"
 @param success 成功返回
 @param failure 失败返回
 */
- (void)post:(NSString *)url keyString:(NSString *)keyString success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure;

#pragma mark - get请求

/**
 get请求(有请求头Header)
 
 @param url 请求地址url
 @param token 请求头token
 @param keyString 请求参数 : @"vid=1&p=1"
 @param success 成功返回
 @param failure 失败返回
 */
- (void)get:(NSString *)url token:(NSString *)token keyString:(NSString *)keyString success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure;

/**
 get请求
 
 @param url 请求地址url
 @param keyString 请求参数 : @"vid=1&p=1"
 @param success 成功返回
 @param failure 失败返回
 */
- (void)get:(NSString *)url keyString:(NSString *)keyString success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure;

/**
 上传图片

 @param url 请求地址url
 @param imageName 图片name
 @param key 请求的参数
 @param value 请求的值
 @param uploadKey 图片对应的key
 @param success 成功返回
 @param failure 失败返回
 */
- (void)upLoad:(NSString *)url imageName:(NSString *)imageName key:(NSString *)key value:(NSString *)value uploadKey:(NSString *)uploadKey success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure;

@end
