//
//  LyHttpNetWorkManager.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/18.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LyHttpNetWorkManager.h"
#import "LyHttpNetWorkTask.h"
#import "LyNetworkConfig.h"
#import <CommonCrypto/CommonDigest.h>
#import "MBProgressHUD+Ly.h"
#import "LyNetworkCacheManager.h"

@implementation LyHttpNetWorkManager

+ (instancetype)sharkManager
{
    static LyHttpNetWorkManager *tool = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        tool = [[self alloc] init];
    });
    return tool;
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
    [self get:url heard:nil parameters:parameters success:success failure:failure];
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
    [self get:url heard:heard parameters:nil success:success failure:failure];
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
    [self dataWithMethod:LyHttpNetWorkTaskMethodGet urlString:url heard:heard parameters:parameters success:success failure:failure];
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
    [self post:url heard:nil parameters:parameters success:success failure:failure];
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
    [self post:url heard:heard parameters:nil success:success failure:failure];
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
    [self dataWithMethod:LyHttpNetWorkTaskMethodPost urlString:url heard:heard parameters:parameters success:success failure:failure];
}

- (void)dataWithMethod:(LyHttpNetWorkTaskMethod)method urlString:(NSString *)urlString heard:(NSDictionary *)heard parameters:(NSDictionary *)parameters success:(void (^)(id resquestData))success failure:(void (^)(NSError *error))failure
{
    //0.处理urlString
    urlString = [self settingWithUrlString:urlString];
    
    //1.缓存
    NSString *cacheKey;
    
    NSMutableString *mString = [[NSMutableString alloc] initWithString:urlString];
    
    [heard enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [mString appendFormat:@"&%@=%@",key, obj];
    }];
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [mString appendFormat:@"&%@=%@",key, obj];
    }];
    
    //加密
    cacheKey = [self md5WithString:[mString copy]];
    
    //取出缓存
    LyNetworkCacheManager *cacheTool = [LyNetworkCacheManager sharedManager];
    
    if (self.settingNetWork != nil && self.settingNetWork.isCache)
    {
        LyNetworkCache *cache = [cacheTool objcetForKey:cacheKey];
        
        //判断缓存是否存在
        if (!cache.isValid)
        {
            [cacheTool removeObejectForKey:cacheKey];
        }
        else//存在
        {
            if (success) {
                success(cache.data);
            }
            return;
        }
        
    }

    //2.处理网络请求
    if (method == LyHttpNetWorkTaskMethodGet)//get
    {
        [[LyHttpNetWorkTask sharkNetWork] get:urlString heard:heard parameters:parameters success:^(id requestData) {
            
            if (self.settingNetWork != nil && self.settingNetWork.isCtrlHub)
            {
                [MBProgressHUD hideAllHUDsForView:[self topViewController].view animated:YES];
            }
            if (success) {
                success(requestData);
            }
            
            //缓存
            [self cacheDataWithKey:cacheKey requestData:requestData];
            
        } failure:^(NSError *error) {
            if (self.settingNetWork != nil && self.settingNetWork.isCtrlHub)
            {
                [MBProgressHUD hideAllHUDsForView:[self topViewController].view animated:YES];
            }
            if (error) {
                failure(error);
            }
        }];
    }
    else//post
    {
        [[LyHttpNetWorkTask sharkNetWork] post:urlString heard:heard parameters:parameters success:^(id requestData) {
            
            if (self.settingNetWork != nil && self.settingNetWork.isCtrlHub)
            {
                [MBProgressHUD hideAllHUDsForView:[self topViewController].view animated:YES];
            }
            if (success) {
                success(requestData);
            }
            
            //缓存
            [self cacheDataWithKey:cacheKey requestData:requestData];
            
        } failure:^(NSError *error) {
            if (self.settingNetWork != nil && self.settingNetWork.isCtrlHub)
            {
                [MBProgressHUD hideAllHUDsForView:[self topViewController].view animated:YES];
            }
            if (error) {
                failure(error);
            }
        }];
    }
}

/**
 缓存数据

 @param cacheKey 缓存的key
 @param requestData 数据
 */
- (void)cacheDataWithKey:(NSString *)cacheKey requestData:(id)requestData
{
    //缓存
    if (self.settingNetWork != nil && self.settingNetWork.isCache && self.settingNetWork.cacheValidTimeInterval > 0)
    {
        LyNetworkCache *cache = [LyNetworkCache cacheWithData:requestData validTimeInterval:self.settingNetWork.cacheValidTimeInterval];
        [[LyNetworkCacheManager sharedManager] setObjcet:cache forKey:cacheKey];
    }
}

#pragma mark - 上传文件

/**
 *  上传图片
 *
 *  @param urlString  urlString地址
 *  @param header     请求头
 *  @param imageArray 图片数组
 *  @param success    成功时返回的数据
 *  @param failure    失败返回的数据
 *  @param progress   上传进程
 */
- (void)uploadWithUrlString:(NSString *)urlString header:(NSDictionary *)header imageArray:(NSArray<LyUploadFile *> *)imageArray success:(void(^)(id responseData))success failure:(void (^)(NSError *error))failure progress:(void(^)(float progress))progress
{
    [self uploadWithUrlString:urlString header:header parameters:nil imageArray:imageArray success:success failure:failure progress:progress];
}

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
- (void)uploadWithUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters imageArray:(NSArray<LyUploadFile *> *)imageArray success:(void(^)(id responseData))success failure:(void (^)(NSError *error))failure progress:(void(^)(float progress))progress
{
    [self uploadWithUrlString:urlString header:nil parameters:parameters imageArray:imageArray success:success failure:failure progress:progress];
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
    [self uploadWithUrlString:urlString header:header parameters:nil imageArray:@[file] success:success failure:failure progress:progress];
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
    [self uploadWithUrlString:urlString header:header parameters:parameters imageArray:@[file] success:success failure:failure progress:progress];
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
    [self uploadWithUrlString:urlString header:nil parameters:parameters imageArray:@[file] success:success failure:failure progress:progress];
}


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
- (void)uploadWithUrlString:(NSString *)urlString header:(NSDictionary *)header parameters:(NSDictionary *)parameters imageArray:(NSArray<LyUploadFile *> *)imageArray success:(void(^)(id responseData))success failure:(void (^)(NSError *error))failure progress:(void(^)(float progress))progress
{
    urlString = [self settingWithUrlString:urlString];
    
    [[LyHttpNetWorkTask sharkNetWork] uploadWithUrlString:urlString header:header parameters:parameters imageArray:imageArray success:^(id responseData) {
        if (self.settingNetWork != nil && self.settingNetWork.isCtrlHub)
        {
            [MBProgressHUD hideAllHUDsForView:[self topViewController].view animated:YES];
        }
        if (success) {
            success(responseData);
        }
    } failure:^(NSError *error) {
        if (self.settingNetWork != nil && self.settingNetWork.isCtrlHub)
        {
            [MBProgressHUD hideAllHUDsForView:[self topViewController].view animated:YES];
        }
        if (error) {
            failure(error);
        }
    } progress:progress];
}

//对于网络设置的处理
- (NSString *)settingWithUrlString:(NSString *)urlString
{
    if (self.settingNetWork != nil)//有网络的设置
    {
        if (self.settingNetWork.isCtrlHub)
        {
            [MBProgressHUD showHUDAddedTo:[self topViewController].view animated:YES];
        }
        
        if (![self isBlankString:self.settingNetWork.baseUrl])
        {
            urlString = [NSString stringWithFormat:@"%@%@",self.settingNetWork.baseUrl,urlString];
        }
    }
    
    return urlString;
}

#pragma mark - 取消请求
//取消全部请求
- (void)cancelAllRequest
{
    [[LyHttpNetWorkTask sharkNetWork] cancelAllRequest];
}

/**
 *  取消指定的url请求
 *
 *  @param requestMethod 该请求的请求类型
 *  @param urlString     当设置了baseUrl，可以是全部url，也可以是部分url；如果没设置必须是部分url
 */
- (void)cancelHttpRequestWithRequestMethod:(NSString *)requestMethod requestUrlString:(NSString *)urlString
{
    if (self.settingNetWork != nil && [urlString containsString:@"http"] && ![self isBlankString:self.settingNetWork.baseUrl]) {
        urlString = [urlString substringFromIndex:self.settingNetWork.baseUrl.length];
    }
    
    [[LyHttpNetWorkTask sharkNetWork] cancelHttpRequestWithRequestMethod:requestMethod requestUrlString:urlString];
}

//加密
- (NSString *)md5WithString:(NSString *)string {
    const char *cStr = [string UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    //    CC_MD5( cStr, strlen(cStr), result );
    return [[[NSString alloc] initWithFormat:
             @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
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

//判断某字符串是否为空
- (BOOL) isBlankString:(NSString *)string
{
    if (string == nil || string == NULL)
    {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0)
    {
        return YES;
    }
    return NO;
}

@end
