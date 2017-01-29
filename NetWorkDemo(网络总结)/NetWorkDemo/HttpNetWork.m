//
//  HttpNetWork.m
//  028
//
//  Created by bona on 16/10/19.
//  Copyright © 2016年 bona. All rights reserved.
//

#import "HttpNetWork.h"
#import "AFNetworking.h"

@interface HttpNetWork ()

@end

@implementation HttpNetWork

+ (instancetype)sharkNetWork
{
    static HttpNetWork *manage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manage = [[self alloc] init];
    });
    return manage;
}

- (instancetype)init
{
    if (self = [super init]) {
    
    }
    return self;
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
- (void)getType:(HttpNetWorkType )type parameters:(NSDictionary *)parameters urlString:(NSString *)urlString success:(void (^)(id resquestData))success failure:(void (^)(NSError *error))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //设置http请求头
    //    manager.requestSerializer.HTTPRequestHeaders
    //    [manager.requestSerializer setValue:@"" forHTTPHeaderField:@"token"];
    
    /**设置接受的类型*/
    //接收类型不一致请替换一致text/html或别的
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                         @"text/html",
                                                         @"image/jpeg",
                                                         @"image/png",
                                                         @"application/octet-stream",
                                                         @"text/json",
                                                         @"text/javascript",
                                                         nil];
    
    if (type == HttpNetWorkTypePost)
    {
        [manager POST:urlString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if (success) {
                success(responseObject);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failure) {
                failure(error);
            }
        }];
    }
    else
    {
        [manager GET:urlString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {

        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (success) {
                success(responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failure) {
                failure(error);
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
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    /**设置接受的类型*/
    //接收类型不一致请替换一致text/html或别的
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                         @"text/html",
                                                         @"image/jpeg",
                                                         @"image/png",
                                                         @"application/octet-stream",
                                                         @"text/json",
                                                         @"text/javascript",
                                                         nil];
    
    //设置http请求头
//    manager.requestSerializer.HTTPRequestHeaders
//    [manager.requestSerializer setValue:@"" forHTTPHeaderField:@"token"];
    
    [manager POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
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
            failure(error);
        }
    }];
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

@end
