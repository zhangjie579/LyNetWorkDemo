//
//  LyURLSessionManager.h
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/25.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LyURLSessionManager : NSObject

#pragma mark - 配置
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

#pragma mark - 内存泄漏
/*
 注意事项:如果是自定义会话并指定了代理，会话会对代理进行强引用,在视图控制器销毁之前，需要取消网络会话，否则会造成内存泄漏
 
 - (void)viewDidDisappear:(BOOL)animated
 {
 [super viewDidDisappear:animated];
 
 [self.session invalidateAndCancel];
 self.session = nil;
 }
 */

#pragma mark - 解析
/*
 
 NSJSONReadingMutableContainers：返回可变容器，NSMutableDictionary或NSMutableArray。
 
 NSJSONReadingMutableLeaves：返回的JSON对象中字符串的值为NSMutableString，目前在iOS 7上测试不好用，应该是个bug，参见：
 http://stackoverflow.com/questions/19345864/nsjsonreadingmutableleaves-option-is-not-working
 
 NSJSONReadingAllowFragments：允许JSON字符串最外层既不是NSArray也不是NSDictionary，但必须是有效的JSON Fragment。例如使用这个选项可以解析 @“123” 这样的字符串。参见：
 */

+ (instancetype)shareTool;

//移除session,避免内存泄漏
- (void)removeSession;

#pragma mark - post请求

/**
 post请求(有请求头Header,请求体body)
 
 @param url 请求地址url
 @param header 请求头token
 @param parameters 请求参数 :
 @param success 成功返回
 @param failure 失败返回
 */
- (void)post:(NSString *)url header:(NSDictionary *)header parameters:(NSDictionary *)parameters success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure;

/**
 post请求(有请求头heard)
 
 @param url 请求地址url
 @param header 请求头token
 @param success 成功返回
 @param failure 失败返回
 */
- (void)post:(NSString *)url header:(NSDictionary *)header success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure;

/**
 post请求（请求体body）
 
 @param url 请求地址url
 @param parameters 请求参数 :
 @param success 成功返回
 @param failure 失败返回
 */
- (void)post:(NSString *)url parameters:(NSDictionary *)parameters success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure;

#pragma mark - get请求

/**
 get请求(有请求头Header，请求体)
 
 @param url 请求地址url
 @param header 请求头token
 @param parameters 请求参数 :
 @param success 成功返回
 @param failure 失败返回
 */
- (void)get:(NSString *)url header:(NSDictionary *)header parameters:(NSDictionary *)parameters success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure;

/**
 get请求(有请求头Header)
 
 @param url 请求地址url
 @param header 请求头token
 @param success 成功返回
 @param failure 失败返回
 */
- (void)get:(NSString *)url header:(NSDictionary *)header success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure;

/**
 get请求（请求体body）
 
 @param url 请求地址url
 @param parameters 请求参数 : 字典
 @param success 成功返回
 @param failure 失败返回
 */
- (void)get:(NSString *)url parameters:(NSDictionary *)parameters success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure;

#pragma mark - 上传图片
/**
 上传图片
 
 @param url 请求地址url
 @param imageName 图片name
 @param parameters 请求体
 @param uploadKey 图片对应的key
 @param success 成功返回
 @param failure 失败返回
 */
- (void)upLoad:(NSString *)url imageName:(NSString *)imageName parameters:(NSDictionary *)parameters uploadKey:(NSString *)uploadKey success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure;

/**
 上传图片
 
 @param url 请求地址url
 @param imageName 图片name
 @param uploadKey 图片对应的key
 @param success 成功返回
 @param failure 失败返回
 */
- (void)upLoad:(NSString *)url imageName:(NSString *)imageName header:(NSDictionary *)header uploadKey:(NSString *)uploadKey success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure;

/**
 上传图片
 
 @param url 地址url
 @param imageName 图片name
 @param parameters 请求体
 @param header 请求头
 @param uploadKey 图片对应的key
 @param success 成功返回
 @param failure 失败返回
 */
- (void)upLoad:(NSString *)url imageName:(NSString *)imageName header:(NSDictionary *)header parameters:(NSDictionary *)parameters uploadKey:(NSString *)uploadKey success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure;

/**
 上传图片
 
 @param url 地址url
 @param image 图片
 @param header 请求头
 @param uploadKey 图片对应的key
 @param success 成功返回
 @param failure 失败返回
 */
- (void)upLoad:(NSString *)url image:(UIImage *)image header:(NSDictionary *)header uploadKey:(NSString *)uploadKey success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure;

/**
 上传图片
 
 @param url 地址url
 @param image 图片
 @param parameters 请求体
 @param uploadKey 图片对应的key
 @param success 成功返回
 @param failure 失败返回
 */
- (void)upLoad:(NSString *)url image:(UIImage *)image parameters:(NSDictionary *)parameters uploadKey:(NSString *)uploadKey success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure;

/**
 上传图片
 
 @param url 地址url
 @param image 图片
 @param parameters 请求体
 @param header 请求头
 @param uploadKey 图片对应的key
 @param success 成功返回
 @param failure 失败返回
 */
- (void)upLoad:(NSString *)url image:(UIImage *)image header:(NSDictionary *)header parameters:(NSDictionary *)parameters uploadKey:(NSString *)uploadKey success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure;

@end
