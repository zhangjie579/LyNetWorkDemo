//
//  LyRequestManager.m
//  LyRequestManager
//
//  Created by 张杰 on 2017/3/21.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LyRequestManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "AFNetworking.h"
#import "Reachability.h"
#import "MBProgressHUD+Ly.h"

///< SSL证书名称，仅支持cer格式。本 Demo 没有导入HTTPS证书，如果有需要请导入自己的，HTTPS 证书验证的代码是正确的
#define kCertificateName @"httpsServerAuth"

#ifdef DEBUG //处于开发测试阶段
///< 关闭https SSL 验证
#define kOpenHttpsAuth NO

#else //处于发布正式阶段

///< 开启https SSL 验证
#define kOpenHttpsAuth YES

#endif

@interface LyRequestManager ()

@property(nonatomic,strong)AFHTTPRequestSerializer *requestSerialize;
@property(nonatomic,assign)BOOL networkIsError;
@property(nonatomic,strong)AFHTTPSessionManager *manager;
@property(nonatomic,strong)NSMutableArray<NSURLSessionTask *> *loadingTaskArray;//正在进行的请求任务

@end
@implementation LyRequestManager

+ (instancetype)shareManager
{
    return [[self alloc] init];
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
        
        /**复杂的参数类型 需要使用json传值-设置请求内容的类型*/
        
        //        [self.manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
//        /**分别设置请求以及相应的序列化器*/
//        self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        if (kOpenHttpsAuth) {
            [self.manager setSecurityPolicy:[self customSecurityPolicy]];
        }
        
        self.networkIsError = NO;
    }
    return self;
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
 */
- (void)dataWithMethod:(LyHttpNetWorkTaskMethod)method urlString:(NSString *)urlString header:(NSDictionary *)header parameters:(NSDictionary *)parameters uploadFile:(NSArray<LyUploadFile *> *)uploadFile config:(LyNetSetting *)config success:(void(^)(id responseData))success failure:(void (^)(NSError *error))failure
{
    [self dataWithMethod:method urlString:urlString header:header parameters:parameters uploadFile:uploadFile config:config success:success failure:failure progress:nil];
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
- (void)dataWithMethod:(LyHttpNetWorkTaskMethod)method urlString:(NSString *)urlString header:(NSDictionary *)header parameters:(NSDictionary *)parameters uploadFile:(NSArray<LyUploadFile *> *)uploadFile config:(LyNetSetting *)config success:(void(^)(id responseData))success failure:(void (^)(NSError *error))failure progress:(void(^)(float progress))progress
{
    self.networkIsError = [[Reachability reachabilityWithHostName:@"www.baidu.com"] currentReachabilityStatus] == NotReachable ? YES : NO;
    if (self.networkIsError) {
        if (failure) {
            failure([self formatError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:nil]]);
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD showSuccess:LyNetworkErrorNotice toView:[UIApplication sharedApplication].keyWindow];
        });
        return;
    }
    
    //用于处理fileData为空的时候
    for (LyUploadFile *file in uploadFile) {
        if (file.fileData == nil) {
            if (failure) {
                failure([self formatError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorCancelled userInfo:nil]]);
            }
            return;
        }
    }
    
    NSMutableURLRequest *request = [self requestWithUrlPath:urlString method:method params:parameters contents:uploadFile header:header config:config];
    
    //设置响应方式
    [self responseWithConfig:config];
    
    NSURLSessionTask *task = nil;
    if (uploadFile != nil) {
        
        task = [self.manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
            
            if (progress) {
                progress(uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
            }
            
        } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            
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
    }
    else
    {
        task = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {

            [self.loadingTaskArray removeObject:task];
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
    }
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

#pragma mark - 创建请求
/**
 上传文件请求
 
 @param urlPath 完整url
 @param method 请求方式
 @param params 请求内容
 @param contents 文件内容
 @param header 请求头
 @return NSMutableURLRequest
 */
- (NSMutableURLRequest *)requestWithUrlPath:(NSString *)urlPath method:(LyHttpNetWorkTaskMethod)method params:(NSDictionary *)params contents:(NSArray<LyUploadFile *> *)contents header:(NSDictionary *)header config:(LyNetSetting *)config
{
    NSError *error;
    AFHTTPRequestSerializer *requestSerializer = [self requestSerializerWithConfig:config];
    
    NSString *meth = nil;
    switch (method) {
        case LyHttpNetWorkTaskMethodGet:
            meth = @"GET";
            break;
        case LyHttpNetWorkTaskMethodPost:
            meth = @"POST";
            break;
            
        default:
            break;
    }
    
//    NSString *url = nil;
    
    NSMutableURLRequest *request = nil;
    if (contents != nil)
    {
        request = [requestSerializer multipartFormRequestWithMethod:meth URLString:[NSString stringWithFormat:@"%@%@",config.baseUrl,urlPath] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            
            [contents enumerateObjectsUsingBlock:^(LyUploadFile * _Nonnull file, NSUInteger idx, BOOL * _Nonnull stop) {
                [formData appendPartWithFileData:file.fileData name:file.uploadKey fileName:file.fileName mimeType:file.fileType];
            }];
            
        } error:&error];
    }
    else
    {
        request = [requestSerializer requestWithMethod:meth URLString:[NSString stringWithFormat:@"%@%@",config.baseUrl,urlPath] parameters:params error:&error];
    }
    
    [header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        [request setValue:value forHTTPHeaderField:key];
    }];
    
    return request;
}

//设置响应的方式
- (void)responseWithConfig:(LyNetSetting *)config
{
    switch (config.responseType) {
        case LyResponseSerializerTypeHTTP:
            self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        case LyResponseSerializerTypeJSON:
        {
            AFJSONResponseSerializer * response = [AFJSONResponseSerializer serializer];
            
            response.removesKeysWithNullValues = YES;
            
            self.manager.responseSerializer = response;
            
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
            break;
        case LyResponseSerializerTypeXMLParser:
            self.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
            
        default:
            break;
    }
}

//设置请求配置
- (AFHTTPRequestSerializer *)requestSerializerWithConfig:(LyNetSetting *)config
{
    AFHTTPRequestSerializer *requestSerializer = nil;
    switch (config.requestType) {
        case LyRequestSerializerTypeHTTP: {
            requestSerializer = [AFHTTPRequestSerializer serializer];
        } break;
        case LyRequestSerializerTypeJSON: {
            requestSerializer = [AFJSONRequestSerializer serializer];
        } break;
    }
    
    requestSerializer.timeoutInterval = config.cacheValidTimeInterval;
    
    self.manager.requestSerializer = requestSerializer;
    
    return requestSerializer;
}

/**
 *  新增的方法，用来验证https证书
 *
 *  @return 证书模式的SecurityPolicy，AFSecurityPolicy有3种安全验证方式
 *          具体看头文件的枚举
 */
- (AFSecurityPolicy *)customSecurityPolicy {
    //先导入证书到项目
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:kCertificateName ofType:@"cer" inDirectory:@"HttpsServerAuth.bundle"];//证书的路径
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    
    //AFSSLPinningModeCertificate使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    
    //allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    //如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = YES;
    
    //validatesCertificateChain 是否验证整个证书链，默认为YES
    //设置为YES，会将服务器返回的Trust Object上的证书链与本地导入的证书进行对比，这就意味着，假如你的证书链是这样的：
    //GeoTrust Global CA
    //    Google Internet Authority G2
    //        *.google.com
    //那么，除了导入*.google.com之外，还需要导入证书链上所有的CA证书（GeoTrust Global CA, Google Internet Authority G2）；
    //如是自建证书的时候，可以设置为YES，增强安全性；假如是信任的CA所签发的证书，则建议关闭该验证，因为整个证书链一一比对是完全没有必要（请查看源代码）；
    //    securityPolicy.validatesCertificateChain = NO;
    
    NSSet *cerDataSet = [NSSet setWithArray:@[cerData]];
    securityPolicy.pinnedCertificates = cerDataSet;
    
    return securityPolicy;
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

#pragma mark -
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

#pragma mark - Getter

- (NSMutableArray<NSURLSessionTask *> *)loadingTaskArray
{
    if (!_loadingTaskArray) {
        _loadingTaskArray = [[NSMutableArray alloc] init];
    }
    return _loadingTaskArray;
}

@end
