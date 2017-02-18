//
//  LyHttpNetWorkTask.h
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/18.
//  Copyright © 2017年 张杰. All rights reserved.
//  最底层的请求封装

#import <Foundation/Foundation.h>
//#import "LyNetSetting.h"

@interface LyHttpNetWorkTask : NSObject

+ (instancetype)sharkNetWork;
//+ (instancetype)sharkNetWorkWithNetSetting:(LyNetSetting *)netSetting;
//
//@property(nonatomic,strong)LyNetSetting *netSetting;

/**
 get请求(有请求头heard，请求body)
 
 @param url 地址
 @param heard 请求头heard
 @param parameters 请求body
 @param success 成功返回
 @param failure 失败返回
 */
- (void)get:(NSString *)url heard:(NSDictionary *)heard parameters:(NSDictionary *)parameters success:(void (^)(id requestData))success failure:(void (^)(NSError *error))failure;

/**
 get请求(有请求body)
 
 @param url 地址
 @param parameters 请求body
 @param success 成功返回
 @param failure 失败返回
 */
- (void)get:(NSString *)url parameters:(NSDictionary *)parameters success:(void (^)(id requestData))success failure:(void (^)(NSError *error))failure;

/**
 get请求(有请求头heard)
 
 @param url 地址
 @param heard 请求头heard
 @param success 成功返回
 @param failure 失败返回
 */
- (void)get:(NSString *)url heard:(NSDictionary *)heard success:(void (^)(id requestData))success failure:(void (^)(NSError *error))failure;

/**
 post请求(有请求头heard，请求body)
 
 @param url 地址
 @param heard 请求头heard
 @param parameters 请求body
 @param success 成功返回
 @param failure 失败返回
 */
- (void)post:(NSString *)url heard:(NSDictionary *)heard parameters:(NSDictionary *)parameters success:(void (^)(id requestData))success failure:(void (^)(NSError *error))failure;

/**
 post请求(请求body)
 
 @param url 地址
 @param parameters 请求body
 @param success 成功返回
 @param failure 失败返回
 */
- (void)post:(NSString *)url parameters:(NSDictionary *)parameters success:(void (^)(id requestData))success failure:(void (^)(NSError *error))failure;

/**
 post请求(有请求头heard)
 
 @param url 地址
 @param heard 请求头heard
 @param success 成功返回
 @param failure 失败返回
 */
- (void)post:(NSString *)url heard:(NSDictionary *)heard success:(void (^)(id requestData))success failure:(void (^)(NSError *error))failure;


/**
 *  上传图片
 *
 *  @param urlString  urlString地址
 *  @param header     请求头
 *  @param parameters 请求参数
 *  @param imageArray 图片数组
 *  @param success    成功时返回的数据
 *  @param failure    失败返回的数据
 *  @param progress   上传进程
 */
- (void)uploadWithUrlString:(NSString *)urlString header:(NSDictionary *)header parameters:(NSDictionary *)parameters imageArray:(NSArray *)imageArray success:(void(^)(id responseData))success failure:(void (^)(NSError *error))failure progress:(void(^)(float progress))progress;

#pragma mark - 取消请求
//取消全部请求
- (void)cancelAllRequest;

/**
 *  取消指定的url请求
 *
 *  @param requestMethod 该请求的请求类型
 *  @param urlString     该请求的部分url
 */
- (void)cancelHttpRequestWithRequestMethod:(NSString *)requestMethod requestUrlString:(NSString *)urlString;

@end
