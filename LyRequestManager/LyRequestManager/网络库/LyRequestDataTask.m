//
//  LyRequestDataTask.m
//  LyRequestManager
//
//  Created by 张杰 on 2017/3/21.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LyRequestDataTask.h"
#import "LyRequestManager.h"
#import "MBProgressHUD+Ly.h"

@interface LyRequestDataTask ()

@property(nonatomic,strong)LyRequestManager *manager;
@property(nonatomic,strong)LyNetSetting     *config;

@end

@implementation LyRequestDataTask

+ (instancetype)shareTask
{
    static LyRequestDataTask *task = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        task = [[self alloc] init];
    });
    return task;
}

- (LyRequestManager *)manager
{
    if (!_manager) {
        _manager = [[LyRequestManager alloc] init];
    }
    return _manager;
}

- (LyNetSetting *)config
{
    if (!_config) {
        NSString *baseUrl = nil;
        #ifdef DEBUG //处于开发测试阶段
                baseUrl = @"http://182.254.228.211:9000";
        #else //处于发布正式阶段
                baseUrl = @"http://www.xiaoban.mobi";
        #endif
        _config = [[LyNetSetting alloc] initWithCtrlHub:YES isCache:NO timeInterval:10 cachePolicy:LyCacheNormal isEncrypt:NO requestType:LyRequestSerializerTypeJSON responseType:LyResponseSerializerTypeJSON baseUrl:baseUrl];
    }
    return _config;
}

/**
 get请求(有请求body)
 
 @param url 地址
 @param parameters 请求body
 @param success 成功返回
 @param failure 失败返回
 */
- (void)get:(NSString *)url parameters:(NSDictionary *)parameters success:(void (^)(id requestData))success failure:(void (^)(NSError *error))failure
{
    [self get:url heard:nil parameters:parameters success:success failure:false];
}

/**
 get请求(有请求头heard)
 
 @param url 地址
 @param heard 请求头heard
 @param success 成功返回
 @param failure 失败返回
 */
- (void)get:(NSString *)url heard:(NSDictionary *)heard success:(void (^)(id requestData))success failure:(void (^)(NSError *error))failure
{
    [self get:url heard:heard parameters:nil success:success failure:false];
}

/**
 get请求(有请求头heard，请求body)
 
 @param url 地址
 @param heard 请求头heard
 @param parameters 请求body
 @param success 成功返回
 @param failure 失败返回
 */
- (void)get:(NSString *)url heard:(NSDictionary *)heard parameters:(NSDictionary *)parameters success:(void (^)(id requestData))success failure:(void (^)(NSError *error))failure
{
    [self dataWithMethod:LyHttpNetWorkTaskMethodGet urlString:url header:heard parameters:parameters uploadFile:nil success:success failure:failure progress:nil];
}

/**
 post请求(有请求头heard，请求body)
 
 @param url 地址
 @param heard 请求头heard
 @param parameters 请求body
 @param success 成功返回
 @param failure 失败返回
 */
- (void)post:(NSString *)url heard:(NSDictionary *)heard parameters:(NSDictionary *)parameters success:(void (^)(id requestData))success failure:(void (^)(NSError *error))failure
{
    [self dataWithMethod:LyHttpNetWorkTaskMethodPost urlString:url header:heard parameters:parameters uploadFile:nil success:success failure:failure progress:nil];
}

/**
 post请求(请求body)
 
 @param url 地址
 @param parameters 请求body
 @param success 成功返回
 @param failure 失败返回
 */
- (void)post:(NSString *)url parameters:(NSDictionary *)parameters success:(void (^)(id requestData))success failure:(void (^)(NSError *error))failure
{
    [self dataWithMethod:LyHttpNetWorkTaskMethodPost urlString:url header:nil parameters:parameters uploadFile:nil success:success failure:failure progress:nil];
}

/**
 post请求(有请求头heard)
 
 @param url 地址
 @param heard 请求头heard
 @param success 成功返回
 @param failure 失败返回
 */
- (void)post:(NSString *)url heard:(NSDictionary *)heard success:(void (^)(id requestData))success failure:(void (^)(NSError *error))failure
{
    [self dataWithMethod:LyHttpNetWorkTaskMethodPost urlString:url header:heard parameters:nil uploadFile:nil success:success failure:failure progress:nil];
}


/**
 *  上传图片
 *
 *  @param urlString  urlString地址
 *  @param header     请求头
 *  @param parameters 请求参数
 *  @param uploadFile 文件数组
 *  @param success    成功时返回的数据
 *  @param failure    失败返回的数据
 *  @param progress   上传进程
 */
- (void)uploadWithUrlString:(NSString *)urlString header:(NSDictionary *)header parameters:(NSDictionary *)parameters uploadFile:(NSArray<LyUploadFile *> *)uploadFile success:(void(^)(id responseData))success failure:(void (^)(NSError *error))failure progress:(void(^)(float progress))progress
{
    [self dataWithMethod:LyHttpNetWorkTaskMethodPost urlString:urlString header:header parameters:parameters uploadFile:@[uploadFile] success:success failure:failure progress:progress];
}

/**
 *  上传图片
 *
 *  @param urlString  urlString地址
 *  @param header     请求头
 *  @param uploadFile 文件数组
 *  @param success    成功时返回的数据
 *  @param failure    失败返回的数据
 *  @param progress   上传进程
 */
- (void)uploadWithUrlString:(NSString *)urlString header:(NSDictionary *)header uploadFile:(NSArray<LyUploadFile *> *)uploadFile success:(void(^)(id responseData))success failure:(void (^)(NSError *error))failure progress:(void(^)(float progress))progress
{
    [self dataWithMethod:LyHttpNetWorkTaskMethodPost urlString:urlString header:header parameters:nil uploadFile:@[uploadFile] success:success failure:failure progress:progress];
}

/**
 *  上传图片
 *
 *  @param urlString  urlString地址
 *  @param parameters 请求参数
 *  @param uploadFile 文件数组
 *  @param success    成功时返回的数据
 *  @param failure    失败返回的数据
 *  @param progress   上传进程
 */
- (void)uploadWithUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters uploadFile:(NSArray<LyUploadFile *> *)uploadFile success:(void(^)(id responseData))success failure:(void (^)(NSError *error))failure progress:(void(^)(float progress))progress
{
    [self dataWithMethod:LyHttpNetWorkTaskMethodPost urlString:urlString header:nil parameters:parameters uploadFile:@[uploadFile] success:success failure:failure progress:progress];
}

/**
 *  上传图片
 *
 *  @param urlString  urlString地址
 *  @param header     请求头
 *  @param file       文件
 *  @param success    成功时返回的数据
 *  @param failure    失败返回的数据
 *  @param progress   上传进程
 */
- (void)uploadWithUrlString:(NSString *)urlString header:(NSDictionary *)header file:(LyUploadFile *)file success:(void(^)(id responseData))success failure:(void (^)(NSError *error))failure progress:(void(^)(float progress))progress
{
    [self dataWithMethod:LyHttpNetWorkTaskMethodPost urlString:urlString header:header parameters:nil uploadFile:@[file] success:success failure:failure progress:progress];
}

/**
 *  上传图片
 *
 *  @param urlString  urlString地址
 *  @param header     请求头
 *  @param parameters 请求参数
 *  @param file       文件
 *  @param success    成功时返回的数据
 *  @param failure    失败返回的数据
 *  @param progress   上传进程
 */
- (void)uploadWithUrlString:(NSString *)urlString header:(NSDictionary *)header parameters:(NSDictionary *)parameters file:(LyUploadFile *)file success:(void(^)(id responseData))success failure:(void (^)(NSError *error))failure progress:(void(^)(float progress))progress
{
    [self dataWithMethod:LyHttpNetWorkTaskMethodPost urlString:urlString header:header parameters:parameters uploadFile:@[file] success:success failure:failure progress:progress];
}

/**
 *  上传图片
 *
 *  @param urlString  urlString地址
 *  @param parameters 请求参数
 *  @param file       文件
 *  @param success    成功时返回的数据
 *  @param failure    失败返回的数据
 *  @param progress   上传进程
 */
- (void)uploadWithUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters file:(LyUploadFile *)file success:(void(^)(id responseData))success failure:(void (^)(NSError *error))failure progress:(void(^)(float progress))progress
{
    [self dataWithMethod:LyHttpNetWorkTaskMethodPost urlString:urlString header:nil parameters:parameters uploadFile:@[file] success:success failure:failure progress:progress];
}

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
- (void)dataWithMethod:(LyHttpNetWorkTaskMethod)method urlString:(NSString *)urlString header:(NSDictionary *)header parameters:(NSDictionary *)parameters uploadFile:(NSArray<LyUploadFile *> *)uploadFile success:(void(^)(id responseData))success failure:(void (^)(NSError *error))failure progress:(void(^)(float progress))progress
{
    if (self.config.isCtrlHub) {
//        [MBProgressHUD showHUDAddedTo:[self topViewController].view animated:YES];
    }
    [self.manager dataWithMethod:method urlString:urlString header:header parameters:parameters uploadFile:uploadFile config:self.config success:^(id responseData) {
        if (self.config.isCtrlHub) {
            [MBProgressHUD hideHUDForView:[self topViewController].view animated:YES];
        }
        if (success) {
            success(responseData);
        }
    } failure:^(NSError *error) {
        if (self.config.isCtrlHub) {
//            [MBProgressHUD hideHUDForView:[self topViewController].view animated:YES];
        }
        if (failure) {
            failure(error);
        }
    } progress:nil];
}

- (UIViewController*)topViewController
{
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController
{
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    }
    else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    }
    else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    }
    else {
        return rootViewController;
    }
}

#pragma mark - 取消请求
//取消全部请求
- (void)cancelAllRequest
{
    [self.manager cancelAllRequest];
}

/**
 *  取消指定的url请求
 *
 *  @param requestMethod 该请求的请求类型
 *  @param urlString     当设置了baseUrl，可以是全部url，也可以是部分url；如果没设置必须是部分url
 */
- (void)cancelHttpRequestWithRequestMethod:(NSString *)requestMethod requestUrlString:(NSString *)urlString
{
    [self.manager cancelHttpRequestWithRequestMethod:requestMethod requestUrlString:urlString];
}

@end
