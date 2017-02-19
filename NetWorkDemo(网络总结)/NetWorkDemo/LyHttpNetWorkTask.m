//
//  LyHttpNetWorkTask.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/18.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LyHttpNetWorkTask.h"
#import "AFNetworking.h"
#import "LyURLRequestManager.h"
#import "LyNetWorkTaskError.h"
#import <CommonCrypto/CommonDigest.h>
#import "LyNetworkConfig.h"
#import "LyNetWorkReachTool.h"

@interface LyHttpNetWorkTask ()

@property(nonatomic,strong)AFHTTPSessionManager *manager;
@property(nonatomic,strong)NSMutableArray<NSURLSessionTask *> *loadingTaskArray;//正在进行的请求任务

@end

//static dispatch_semaphore_t lock;
@implementation LyHttpNetWorkTask

+ (instancetype)sharkNetWork
{
    static LyHttpNetWorkTask *tool = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
//        lock = dispatch_semaphore_create(1);
        tool = [[self alloc] init];
    });
    return tool;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.manager = [AFHTTPSessionManager manager];
        
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

- (void)dataWithMethod:(LyHttpNetWorkTaskMethod)method urlString:(NSString *)urlString heard:(NSDictionary *)heard parameters:(NSDictionary *)parameters success:(void (^)(id requestData))success failure:(void (^)(NSError *error))failure
{
//    //1.先判断网络是否可用
//    LyNetWorkReachTool *tool = [LyNetWorkReachTool sharedInstance];
//    if (!tool.isReachable) {
//        if (failure) {
//            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorCannotConnectToHost userInfo:nil];
//            failure([self formatError:error]);
//        }
//    }
    
    LyURLRequestManager *requestTool = [LyURLRequestManager shareTool];
    NSMutableURLRequest *request = nil;
    if (method == LyHttpNetWorkTaskMethodGet)
    {
        request = [requestTool requestWithUrlPath:urlString method:@"GET" params:parameters header:heard];
    }
    else if (method == LyHttpNetWorkTaskMethodPost)
    {
        request = [requestTool requestWithUrlPath:urlString method:@"POST" params:parameters header:heard];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLSessionTask *task = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
//        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
        [self.loadingTaskArray removeObject:task];
//        dispatch_semaphore_signal(lock);
        if (error)
        {
            if (failure) {
                failure([self formatError:error]);
            }
        }
        else
        {
            if (success) {
                success(responseObject);
            }
        }
        
    }];
    [self.loadingTaskArray addObject:task];
    [task resume];
}

/**
 *  上传图片
 *
 *  @param urlString  urlString地址
 *  @param header     请求头
 *  @param parameters 请求参数
 *  @param imageArray LyUploadFile数组
 *  @param success    成功时返回的数据
 *  @param failure    失败返回的数据
 *  @param progress   上传进程
 */
- (void)uploadWithUrlString:(NSString *)urlString header:(NSDictionary *)header parameters:(NSDictionary *)parameters imageArray:(NSArray<LyUploadFile *> *)imageArray success:(void(^)(id responseData))success failure:(void (^)(NSError *error))failure progress:(void(^)(float progress))progress
{
    NSMutableURLRequest *request = [[LyURLRequestManager shareTool] uploadRequestUrlPath:urlString method:@"POST" params:parameters contents:imageArray header:header];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLSessionDataTask *task = [self.manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        
        progress(uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
        [self.loadingTaskArray removeObject:task];
        if (error)
        {
            if (failure) {
                failure([self formatError:error]);
            }
        }
        else
        {
            success(responseObject);
        }
        
    }];
    [self.loadingTaskArray addObject:task];
    [task resume];
}

#pragma mark - 取消请求
//取消全部请求
- (void)cancelAllRequest
{
    for (NSInteger i = 0; i < self.loadingTaskArray.count; i++) {
        NSURLSessionTask *task = self.loadingTaskArray[i];
        [task cancel];
        [self.loadingTaskArray removeAllObjects];
    }
}

/**
 *  取消指定的url请求
 *
 *  @param requestMethod 该请求的请求类型
 *  @param urlString     该请求的部分url
 */
- (void)cancelHttpRequestWithRequestMethod:(NSString *)requestMethod requestUrlString:(NSString *)urlString
{
    for (NSInteger i = 0; i < self.loadingTaskArray.count; i++)
    {
        NSURLSessionTask *task = self.loadingTaskArray[i];
        //1.请求方式
        BOOL isMethod = [[requestMethod uppercaseString] isEqualToString:[task currentRequest].HTTPMethod];
        
        //2.请求url
        BOOL isUrl = [urlString isEqualToString:[task currentRequest].URL.path];
        
        if (isUrl && isMethod) {
            [task cancel];
            [self.loadingTaskArray removeObject:task];
        }
    }
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

- (NSMutableArray<NSURLSessionTask *> *)loadingTaskArray
{
    if (!_loadingTaskArray) {
        _loadingTaskArray = [[NSMutableArray alloc] init];
    }
    return _loadingTaskArray;
}

@end
