//
//  LyRequestManager.h
//  LyRequestManager
//
//  Created by 张杰 on 2017/3/21.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LyUploadFile.h"
#import "LyNetSetting.h"

@interface LyRequestManager : NSObject

//自定义网络请求配置
+ (instancetype)shareManagerWithConfig:(LyNetSetting *)config;

//默认网络请求配置,1.请求数据类型为http,2.返回数据类型为json,3.网络超时时间为30s
+ (instancetype)shareManager;

/**
 *  网络请求
 *
 *  @param urlString  urlString地址
 *  @param header     请求头
 *  @param parameters 请求参数
 *  @param uploadFile LyUploadFile数组,没有传nil
 *  @param success    成功时返回的数据
 *  @param failure    失败返回的数据
 */
- (void)dataWithMethod:(LyHttpNetWorkTaskMethod)method urlString:(NSString *)urlString header:(NSDictionary *)header parameters:(NSDictionary *)parameters uploadFile:(NSArray<LyUploadFile *> *)uploadFile success:(void(^)(id responseData))success failure:(void (^)(NSError *error))failure;

/**
 *  网络请求
 *
 *  @param urlString  urlString地址
 *  @param header     请求头
 *  @param parameters 请求参数
 *  @param uploadFile LyUploadFile数组,没有传nil
 *  @param success    成功时返回的数据
 *  @param failure    失败返回的数据
 *  @param progress   上传进程
 */
- (void)dataWithMethod:(LyHttpNetWorkTaskMethod)method urlString:(NSString *)urlString header:(NSDictionary *)header parameters:(NSDictionary *)parameters uploadFile:(NSArray<LyUploadFile *> *)uploadFile success:(void(^)(id responseData))success failure:(void (^)(NSError *error))failure progress:(void(^)(float progress))progress;

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
