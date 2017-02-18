//
//  LyHttpNetWork.m
//  028
//
//  Created by bona on 16/10/19.
//  Copyright © 2016年 bona. All rights reserved.
//

#import "LyHttpNetWork.h"
#import "AFNetworking.h"
#import <CommonCrypto/CommonDigest.h>
#import "LyNetWorkTaskError.h"
#import "MBProgressHUD+Ly.h"

@interface LyHttpNetWork ()

@property(nonatomic,strong)AFHTTPSessionManager *manager;
@property(nonatomic,strong)NSMutableArray<NSURLSessionTask *> *array_task;

@end

@implementation LyHttpNetWork

+ (instancetype)sharkNetWorkWithNetSetting:(LyNetSetting *)netSetting
{
    static LyHttpNetWork *manage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manage = [[self alloc] initWithNetSetting:netSetting];
    });
    return manage;
}

+ (instancetype)sharkNetWork
{
    LyNetSetting *netSetting = [[LyNetSetting alloc] init];
    netSetting.isCtrlHub = NO;
    netSetting.cachePolicy = LyCacheNormal;
    netSetting.isEncrypt = NO;
    netSetting.baseUrl = nil;
    
    return [LyHttpNetWork sharkNetWorkWithNetSetting:netSetting];
}

- (instancetype)initWithNetSetting:(LyNetSetting *)netSetting
{
    if (self = [super init])
    {
        self.netSetting = netSetting;
        
        self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:netSetting.baseUrl]];
        
        /**设置请求超时时间*/
        
        self.manager.requestSerializer.timeoutInterval = 3;
        
        /**设置相应的缓存策略*/
        /*
         NSURLRequestReloadIgnoringLocalCacheData = 1, URL应该加载源端数据，不使用本地缓存数据
         　　NSURLRequestReloadIgnoringLocalAndRemoteCacheData =4, 本地缓存数据、代理和其他中介都要忽视他们的缓存，直接加载源数据
         　　NSURLRequestReloadIgnoringCacheData = NSURLRequestReloadIgnoringLocalCacheData, 两个的设置相同
         　　NSURLRequestReturnCacheDataElseLoad = 2, 指定已存的缓存数据应该用来响应请求，不管它的生命时长和过期时间。如果在缓存中没有已存数据来响应请求的话，数据从源端加载。
         　　NSURLRequestReturnCacheDataDontLoad = 3, 指定已存的缓存数据用来满足请求，不管生命时长和过期时间。如果在缓存中没有已存数据来响应URL加载请求的话，不去尝试从源段加载数据，此时认为加载请求失败。这个常量指定了一个类似于离线模式的行为
         　　NSURLRequestReloadRevalidatingCacheData = 5 指定如果已存的缓存数据被提供它的源段确认为有效则允许使用缓存数据响应请求，否则从源段加载数据
         */
        self.manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        
        /**分别设置请求以及相应的序列化器*/
        self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        AFJSONResponseSerializer * response = [AFJSONResponseSerializer serializer];
        
        response.removesKeysWithNullValues = YES;
        
        self.manager.responseSerializer = response;
        
        /**复杂的参数类型 需要使用json传值-设置请求内容的类型*/
        
        //        [self.manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        /**设置接受的类型*/
        //接收类型不一致请替换一致text/html或别的
        self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                                  @"text/html",
                                                                  @"image/jpeg",
                                                                  @"image/png",
                                                                  @"application/octet-stream",
                                                                  @"text/json",
                                                                  @"text/javascript",
                                                                  nil];
    }
    return self;
}

- (void)get:(NSString *)url parameters:(NSDictionary *)parameters success:(void (^)(id resquestData))success failure:(void (^)(NSError *error))failure
{
    [self get:url token:nil parameters:parameters success:success failure:failure];
}

- (void)get:(NSString *)url token:(NSString *)token success:(void (^)(id resquestData))success failure:(void (^)(NSError *error))failure
{
    [self get:url token:token parameters:nil success:success failure:failure];
}

- (void)get:(NSString *)url token:(NSString *)token parameters:(NSDictionary *)parameters success:(void (^)(id resquestData))success failure:(void (^)(NSError *error))failure
{
    //设置http请求头
    if (![self isBlankString:token])
    {
        [self.manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    }
    
    id param = parameters;
    if (param == nil) {
        param = @"";
    }
    
    [self.manager GET:url parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure([self formatError:error]);
        }
    }];
}

- (void)post:(NSString *)url parameters:(NSDictionary *)parameters success:(void (^)(id resquestData))success failure:(void (^)(NSError *error))failure
{
    [self post:url token:nil parameters:parameters success:success failure:failure];
}

- (void)post:(NSString *)url token:(NSString *)token success:(void (^)(id resquestData))success failure:(void (^)(NSError *error))failure
{
    [self post:url token:token parameters:nil success:success failure:failure];
}

- (void)post:(NSString *)url token:(NSString *)token parameters:(NSDictionary *)parameters success:(void (^)(id resquestData))success failure:(void (^)(NSError *error))failure
{
    //设置http请求头
    if (![self isBlankString:token])
    {
        [self.manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    }
    
    id param = parameters;
    if (param == nil) {
        param = @"";
    }
    
    if (self.netSetting.isCtrlHub)
    {
        [MBProgressHUD showHUDAddedTo:[self topViewController].view animated:YES];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURLSessionTask *task = [self.manager POST:url parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //不管请求成功失败，读要把请求从数组中移除
        [self.array_task removeObject:task];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        //隐藏提示框
        if (self.netSetting.isCtrlHub)
        {
            //            [MBProgressHUD hideHUDForView:[self topViewController].view animated:YES];
            [MBProgressHUD hideAllHUDsForView:[self topViewController].view animated:YES];
        }
        if (success) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //不管请求成功失败，读要把请求从数组中移除
        [self.array_task removeObject:task];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        //隐藏提示框
        if (self.netSetting.isCtrlHub)
        {
            //            [MBProgressHUD hideHUDForView:[self topViewController].view animated:YES];
            [MBProgressHUD hideAllHUDsForView:[self topViewController].view animated:YES];
        }
        if (failure) {
            failure([self formatError:error]);
        }
    }];
    
    [self.array_task addObject:task];
}

/**
 *  发送请求
 *
 *  @param type       post，get
 *  @param parameters 请求参数
 *  @param urlString  请求地址
 *  @param success    成功时返回的数据
 *  @param failure    失败返回的数据
 */
- (void)getType:(LyHttpNetWorkType )type parameters:(NSDictionary *)parameters urlString:(NSString *)urlString success:(void (^)(id resquestData))success failure:(void (^)(NSError *error))failure
{
    if (type == LyHttpNetWorkTypePost)
    {
        [self.manager POST:urlString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if (success) {
                success(responseObject);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failure) {
                failure([self formatError:error]);
            }
        }];
    }
    else
    {
        [self.manager GET:urlString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {

        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (success) {
                success(responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failure) {
                failure([self formatError:error]);
            }
        }];
    }
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
- (void)uploadWithUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters imageArray:(NSArray *)imageArray success:(void (^)(id))success failure:(void (^)(NSError *))failure progress:(void(^)(float progress))progress
{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    
//    /**设置接受的类型*/
//    //接收类型不一致请替换一致text/html或别的
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
//                                                         @"text/html",
//                                                         @"image/jpeg",
//                                                         @"image/png",
//                                                         @"application/octet-stream",
//                                                         @"text/json",
//                                                         @"text/javascript",
//                                                         nil];
    
    //设置http请求头
//    manager.requestSerializer.HTTPRequestHeaders
//    [manager.requestSerializer setValue:@"" forHTTPHeaderField:@"token"];
    
    [self.manager POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSInteger i = 0; i < imageArray.count; i++)
        {
            UIImage *image = imageArray[i];
            NSData *data = UIImagePNGRepresentation(image);
            //拼接data
            
            /**
             *  appendPartWithFileURL   //  指定上传的文件
             *  name                    //  指定在服务器中获取对应文件或文本时的key(对应服务器上传文件的key)
             *  fileName                //  指定上传文件的原始文件名
             *  mimeType                //  指定商家文件的MIME类型
             */
            
            [formData appendPartWithFileData:data name:[NSString stringWithFormat:@"picflie%ld",(long)i] fileName:@"image.png" mimeType:@"image/jpeg"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure([self formatError:error]);
        }
    }];
}

///**
// 拼接url
// 
// @param path 请求的url
// @param useHttps 是否为https
// @return url
// */
//- (NSString *)urlStringWithPath:(NSString *)path useHttps:(BOOL)useHttps {
//    
//    if ([path hasPrefix:@"http"])
//    {
//        return path;
//    }
//    else
//    {
//        
//        NSString *baseUrlString = @"";
//        if (![self isBlankString:self.baseUrl])
//        {
//            baseUrlString = self.baseUrl;
//        }
//        
//        if (useHttps && baseUrlString.length > 4)
//        {
//            
//            NSMutableString *mString = [NSMutableString stringWithString:baseUrlString];
//            [mString insertString:@"s" atIndex:4];
//            baseUrlString = [mString copy];
//        }
//        return [NSString stringWithFormat:@"%@%@", baseUrlString, path];
//    }
//}

#pragma mark -   取消指定的url请求/
/**
 *  取消指定的url请求
 *
 *  @param requestType 该请求的请求类型
 *  @param string      该请求的完整url
 */
- (void)cancelHttpRequestWithRequestType:(NSString *)requestType requestUrlString:(NSString *)string
{
    for (NSInteger i = 0; i < self.array_task.count; i++)
    {
        NSURLSessionTask *task = self.array_task[i];
        
        //请求方式
        requestType = [requestType uppercaseString];
        BOOL hasMatchRequestType = [requestType isEqualToString:[task currentRequest].HTTPMethod];
        
        //请求的url
//        if ([string containsString:@"http"] && ![self isBlankString:self.netSetting.baseUrl])
//        {
//            string = [string substringFromIndex:self.netSetting.baseUrl.length];
//        }
        NSError *error;
        NSString * urlToPeCanced = [[[self.manager.requestSerializer requestWithMethod:requestType URLString:string parameters:nil error:&error] URL] path];
        
        BOOL hasMatchRequestUrlString = [urlToPeCanced isEqualToString:[task currentRequest].URL.path];
        
        //两项都匹配的话  取消该请求
        if (hasMatchRequestType && hasMatchRequestUrlString) {
            
            [task cancel];
            
        }
    }
}

//取消全部请求
- (void)cancelAllRequest
{
    for (NSInteger i = 0; i < self.array_task.count; i++)
    {
        NSURLSessionTask *task = self.array_task[i];
        [task cancel];
    }
//    [self.manager.operationQueue cancelAllOperations];
    
}

#pragma mark - 检测网络连接
- (void)reach
{
    /**
     AFNetworkReachabilityStatusUnknown          = -1,  // 未知
     AFNetworkReachabilityStatusNotReachable     = 0,   // 无连接
     AFNetworkReachabilityStatusReachableViaWWAN = 1,   // 3G 花钱
     AFNetworkReachabilityStatusReachableViaWiFi = 2,   // 局域网络,不花钱
     */
    // 如果要检测网络状态的变化,必须用检测管理器的单例的startMonitoring
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    // 检测网络连接的单例,网络变化时的回调方法
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown: {// 未知
                
                break;
            }
            case AFNetworkReachabilityStatusNotReachable: {// 无连接
                
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN: {// 3G 花钱
                
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi: {// 局域网络,不花钱
                
                break;
            }
        }
    }];
}

#pragma mark - Utils
//判断错误的状态
- (NSError *)formatError:(NSError *)error {
    
    if (error != nil) {
        switch (error.code) {
            case NSURLErrorCancelled: {
                error = LyError(LyDefaultErrorNotice, LyNetworkTaskErrorCanceled);
            }   break;
                
            case NSURLErrorTimedOut: {
                error = LyError(LyTimeoutErrorNotice, LyNetworkTaskErrorTimeOut);
                break;
            }
                
            case NSURLErrorCannotFindHost:
            case NSURLErrorCannotConnectToHost:
            case NSURLErrorNotConnectedToInternet:{
                error = LyError(LyNetworkErrorNotice, LyNetworkTaskErrorCannotConnectedToInternet);
                break;
            }
            case NSURLErrorUnsupportedURL: {
                error = LyError(LyErrorUnsupportedURL, LyNetworkTaskErrorUnsupportedURL);
                break;
            }
            default: {
                error = LyError(LyNoDataErrorNotice, LyNetworkTaskErrorDefault);
            }   break;
        }
    }
    return error;
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

- (NSMutableArray<NSURLSessionTask *> *)array_task
{
    if (!_array_task) {
        _array_task = [[NSMutableArray alloc] init];
    }
    return _array_task;
}

@end
