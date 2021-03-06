//
//  LyHttpNetWork.h
//  028
//
//  Created by bona on 16/10/19.
//  Copyright © 2016年 bona. All rights reserved.
//
typedef enum {
    LyHttpNetWorkTypeGet,
    LyHttpNetWorkTypePost
}LyHttpNetWorkType;

#import <Foundation/Foundation.h>
#import "LyNetSetting.h"

@interface LyHttpNetWork : NSObject

+ (instancetype)sharkNetWork;
+ (instancetype)sharkNetWorkWithNetSetting:(LyNetSetting *)netSetting;

@property(nonatomic,strong)LyNetSetting *netSetting;


/**
 *  发送请求
 *
 *  @param type       post，get
 *  @param parameters 请求参数
 *  @param urlString  请求地址
 *  @param success    成功时返回的数据
 *  @param failure    失败返回的数据
 */
- (void)getType:(LyHttpNetWorkType )type parameters:(NSDictionary *)parameters urlString:(NSString *)urlString success:(void (^)(id resquestData))success failure:(void (^)(NSError *error))failure;

/**
 get请求(有请求头heard，请求body)

 @param url 地址
 @param token 请求头heard
 @param parameters 请求body
 @param success 成功返回
 @param failure 失败返回
 */
- (void)get:(NSString *)url token:(NSString *)token parameters:(NSDictionary *)parameters success:(void (^)(id resquestData))success failure:(void (^)(NSError *error))failure;

/**
 get请求(有请求body)
 
 @param url 地址
 @param parameters 请求body
 @param success 成功返回
 @param failure 失败返回
 */
- (void)get:(NSString *)url parameters:(NSDictionary *)parameters success:(void (^)(id resquestData))success failure:(void (^)(NSError *error))failure;

/**
 get请求(有请求头heard)
 
 @param url 地址
 @param token 请求头heard
 @param success 成功返回
 @param failure 失败返回
 */
- (void)get:(NSString *)url token:(NSString *)token success:(void (^)(id resquestData))success failure:(void (^)(NSError *error))failure;

/**
 post请求(有请求头heard，请求body)
 
 @param url 地址
 @param token 请求头heard
 @param parameters 请求body
 @param success 成功返回
 @param failure 失败返回
 */
- (void)post:(NSString *)url token:(NSString *)token parameters:(NSDictionary *)parameters success:(void (^)(id resquestData))success failure:(void (^)(NSError *error))failure;

/**
 post请求(请求body)
 
 @param url 地址
 @param parameters 请求body
 @param success 成功返回
 @param failure 失败返回
 */
- (void)post:(NSString *)url parameters:(NSDictionary *)parameters success:(void (^)(id resquestData))success failure:(void (^)(NSError *error))failure;

/**
 post请求(有请求头heard)
 
 @param url 地址
 @param token 请求头heard
 @param success 成功返回
 @param failure 失败返回
 */
- (void)post:(NSString *)url token:(NSString *)token success:(void (^)(id resquestData))success failure:(void (^)(NSError *error))failure;


/**
 *  上传图片
 *
 *  @param urlString  urlString地址
 *  @param parameters 请求参数
 *  @param imageArray 图片数组
 *  @param success    成功时返回的数据
 *  @param failure    失败返回的数据
 *  @param progress   上传进程
 */
- (void)uploadWithUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters imageArray:(NSArray *)imageArray success:(void(^)(id responseData))success failure:(void (^)(NSError *error))failure progress:(void(^)(float progress))progress;

#pragma mark - 取消请求
//取消全部请求
- (void)cancelAllRequest;

/**
 *  取消指定的url请求
 *
 *  @param requestType 该请求的请求类型
 *  @param string      该请求的完整url
 */
- (void)cancelHttpRequestWithRequestType:(NSString *)requestType requestUrlString:(NSString *)string;

@end
