//
//  LyRequestSerializer.m
//  LyRequestManager
//
//  Created by 张杰 on 2017/6/21.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LyRequestSerializer.h"
#import "AFNetworking.h"

typedef enum {
    LyNetWorkRequestHTTP,
    LyNetWorkRequestJSON
}LyNetWorkRequest;//请求方式

typedef enum {
    LyNetWorkResponseJson,
    LyNetWorkResponseHTTP
}LyNetWorkResponse;//响应方式

@interface LyRequestSerializer ()

//基础配置
@property(nonatomic,assign,readonly)LyNetWorkRequest     requestType;//请求方式
@property(nonatomic,assign,readonly)LyNetWorkResponse    responseType;//响应方式
@property(nonatomic,assign,readonly)NSTimeInterval       timeoutInterval;//超时时间
@property(nonatomic,assign,readonly)NSString             *baseUrl;

@property(nonatomic,strong)AFHTTPSessionManager    *manager;

@end

@implementation LyRequestSerializer

- (LyNetWorkRequest)requestType
{
    return LyNetWorkRequestHTTP;
}

- (LyNetWorkResponse)responseType
{
    return LyNetWorkResponseJson;
}

- (NSTimeInterval)timeoutInterval
{
    return 20;
}

- (NSString *)baseUrl
{
    return @"http://182.254.228.211:9000";
}

- (void)request:(LyURLRequestManager *)urlRequest success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure
{
    [[self.manager dataTaskWithRequest:[self requestConfiger:urlRequest] completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            failure(error);
        }
        else {
            success(responseObject);
        }
    }] resume];
}

#pragma mark - 创建请求

- (NSMutableURLRequest *)requestConfiger:(LyURLRequestManager *)urlRequest
{
    NSError *error;
    
    NSMutableURLRequest *request = nil;
    
    request = [self.manager.requestSerializer requestWithMethod:[urlRequest.methods uppercaseString] URLString:[NSString stringWithFormat:@"%@%@",self.baseUrl,urlRequest.urlString] parameters:urlRequest.params error:&error];
    //    if (contents != nil)
    //    {
    //        request = [self.serializerManager.manager.requestSerializer multipartFormRequestWithMethod:[self.method uppercaseString] URLString:[NSString stringWithFormat:@"%@%@",self.serializerManager.baseUrl,self.url] parameters:self.param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    //
    //            [contents enumerateObjectsUsingBlock:^(LyUploadFile * _Nonnull file, NSUInteger idx, BOOL * _Nonnull stop) {
    //                [formData appendPartWithFileData:file.fileData name:file.uploadKey fileName:file.fileName mimeType:file.fileType];
    //            }];
    //
    //        } error:&error];
    //    }
    //    else
    //    {
    //        request = [self.manager.requestSerializer requestWithMethod:[self.method uppercaseString] URLString:[NSString stringWithFormat:@"%@%@",self.config.baseUrl,urlPath] parameters:params error:&error];
    //    }
    
    if (urlRequest.hearders != nil && urlRequest.hearders.allKeys.count != 0) {
        [urlRequest.hearders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
            [request setValue:value forHTTPHeaderField:key];
        }];
    }
    
    return request;
}

#pragma mark - 配置网络配置
//设置响应的方式
- (void)responseWithConfig
{
    switch (self.responseType) {
        case LyNetWorkResponseHTTP:
            self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        case LyNetWorkResponseJson:
        {
            AFJSONResponseSerializer * response = [AFJSONResponseSerializer serializer];
            
            //            response.removesKeysWithNullValues = YES;
            
            self.manager.responseSerializer = response;
            
            /**设置接受的类型*/
            //接收类型不一致请替换一致text/html或别的
            self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                                      @"application/json",
                                                                      @"text/html",
                                                                      @"image/jpeg",
                                                                      @"image/png",
                                                                      @"application/octet-stream",
                                                                      @"text/json",
                                                                      @"text/javascript",
                                                                      @"text/plain",
                                                                      @"multipart/form-data",
                                                                      nil];
        }
            break;
            
        default:
            break;
    }
}

//设置请求配置
- (AFHTTPRequestSerializer *)requestSerializer
{
    AFHTTPRequestSerializer *requestSerializer = nil;
    switch (self.requestType) {
        case LyNetWorkRequestHTTP: {
            requestSerializer = [AFHTTPRequestSerializer serializer];
        } break;
        case LyNetWorkRequestJSON: {
            requestSerializer = [AFJSONRequestSerializer serializer];
        } break;
    }
    
    //    requestSerializer.timeoutInterval = config.cacheValidTimeInterval;
    
    self.manager.requestSerializer = requestSerializer;
    
    [self.manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    self.manager.requestSerializer.timeoutInterval = self.timeoutInterval;//设置请求超时时间
    [self.manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    return requestSerializer;
}

static LyRequestSerializer *_produce = nil;
+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_produce == nil) {
            _produce = [[self alloc] init];
        };
    });
    return _produce;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    if (!_produce) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (_produce == nil) {
                _produce = [super allocWithZone:zone];
            };
        });
    }
    return _produce;
}

#pragma mark - get

- (AFHTTPSessionManager *)manager
{
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
        //1.设置请求配置
        _manager.requestSerializer = [self requestSerializer];
        
        //2.设置响应配置
        [self responseWithConfig];
        
        /**设置相应的缓存策略*/
        _manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    }
    return _manager;
}
@end


