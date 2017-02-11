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


/*
 
 //超时
 request.timeoutInterval = 30;
 //网络状态
 request.networkServiceType = NSURLNetworkServiceTypeDefault;
 //批量请求
 request.HTTPShouldUsePipelining = YES;
 //处理Cookie
 request.HTTPShouldHandleCookies = YES;
 //缓存策略
 request.cachePolicy = NSURLRequestUseProtocolCachePolicy;
 //允许使用数据流量
 request.allowsCellularAccess = YES;
 
*/


/*

NSJSONReadingMutableContainers：返回可变容器，NSMutableDictionary或NSMutableArray。

NSJSONReadingMutableLeaves：返回的JSON对象中字符串的值为NSMutableString，目前在iOS 7上测试不好用，应该是个bug，参见：
http://stackoverflow.com/questions/19345864/nsjsonreadingmutableleaves-option-is-not-working

NSJSONReadingAllowFragments：允许JSON字符串最外层既不是NSArray也不是NSDictionary，但必须是有效的JSON Fragment。例如使用这个选项可以解析 @“123” 这样的字符串。参见：

*/

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

#pragma mark - 上传图片

/**
 上传图片
 
 @param url 地址url
 @param imageName 图片name
 @param key 请求的参数
 @param value 请求的值
 @param token 请求头
 @param uploadKey 图片对应的key
 @param success 成功返回
 @param failure 失败返回
 */
- (void)upLoad:(NSString *)url imageName:(NSString *)imageName key:(NSString *)key value:(NSString *)value token:(NSString *)token uploadKey:(NSString *)uploadKey success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure;

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

/**
 上传图片
 
 @param url 请求地址url
 @param imageName 图片name
 @param uploadKey 图片对应的key
 @param success 成功返回
 @param failure 失败返回
 */
- (void)upLoad:(NSString *)url imageName:(NSString *)imageName token:(NSString *)token uploadKey:(NSString *)uploadKey success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure;

/**
 上传图片
 
 @param url 地址url
 @param image 图片
 @param key 请求的参数
 @param value 请求的值
 @param token 请求头
 @param uploadKey 图片对应的key
 @param success 成功返回
 @param failure 失败返回
 */
- (void)upLoad:(NSString *)url image:(UIImage *)image key:(NSString *)key value:(NSString *)value token:(NSString *)token uploadKey:(NSString *)uploadKey success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure;

/**
 上传图片
 
 @param url 地址url
 @param image 图片
 @param token 请求头
 @param uploadKey 图片对应的key
 @param success 成功返回
 @param failure 失败返回
 */
- (void)upLoad:(NSString *)url image:(UIImage *)image token:(NSString *)token uploadKey:(NSString *)uploadKey success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure;

/**
 上传图片
 
 @param url 地址url
 @param image 图片
 @param key 请求的参数
 @param value 请求的值
 @param uploadKey 图片对应的key
 @param success 成功返回
 @param failure 失败返回
 */
- (void)upLoad:(NSString *)url image:(UIImage *)image key:(NSString *)key value:(NSString *)value uploadKey:(NSString *)uploadKey success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure;

@end
