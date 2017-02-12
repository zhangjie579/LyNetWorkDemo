//
//  LYURLSession.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/1/21.
//  Copyright © 2017年 张杰. All rights reserved.
//
#define boundary @"uploadBoundary"

#import "LYURLSession.h"

@implementation LYURLSession

+ (instancetype)shareTool
{
    static LYURLSession *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[self alloc] init];
        }
    });
    return manager;
}

/**
 post请求(有请求头heard)
 
 @param url 请求地址url
 @param token 请求头token
 @param success 成功返回
 @param failure 失败返回
 */
- (void)post:(NSString *)url token:(NSString *)token success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure
{
    [self post:url token:token parameters:nil success:success failure:failure];
}

/**
 post请求
 
 @param url 请求地址url
 @param parameters 请求参数 字典
 @param success 成功返回
 @param failure 失败返回
 */
- (void)post:(NSString *)url parameters:(NSDictionary *)parameters success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure
{
    [self post:url token:nil parameters:parameters success:success failure:failure];
}

/**
 post请求(有请求头Header)
 
 @param url 请求地址url
 @param token 请求头token
 @param parameters 请求参数 : 字典
 @param success 成功返回
 @param failure 失败返回
 */
- (void)post:(NSString *)url token:(NSString *)token parameters:(NSDictionary *)parameters success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure
{
    NSMutableURLRequest *request = [self requestWithUrl:url method:@"POST" token:token parameters:parameters];
    
    //发送请求
//    NSURLSessionConfiguration *configurat = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSessionConfiguration *configurat = [self creatURLSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configurat];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error)
        {
            failure(error);
        }
        else
        {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            success(dict);
        }
        
    }];
    
    //发送请求
    [task resume];
}

/**
 设置NSURLSessionConfiguration

 @return NSURLSessionConfiguration
 */
- (NSURLSessionConfiguration *)creatURLSessionConfiguration
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    /*
     HTTPAdditionalHeaders           HTTP 请求头，告诉服务器有关客户端的附加信息，这对于跨会话共享信息，
     如内容类型，语言，用户代理，身份认证，是很有用的。
     
     Accept                      告诉服务器客户端可接收的数据类型，如：@"application/json" 。
     Accept-Language             告诉服务器客户端使用的语言类型，如：@"en" 。
     Authorization               验证身份信息，如：authString 。
     User-Agent                  告诉服务器客户端类型，如：@"iPhone AppleWebKit" 。
     range                       用于断点续传，如：bytes=10- 。
     */
    
    // 设置同时连接到一台服务器的最大连接数
    configuration.HTTPMaximumConnectionsPerHost = 4;
    
    // 设置授权信息，WebDav 的身份验证
    NSString *username = @"admin";
    NSString *password = @"adminpasswd";
    
    NSString *userPasswordString = [NSString stringWithFormat:@"%@:%@", username, password];
    NSData   *userPasswordData = [userPasswordString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64EncodedCredential = [userPasswordData base64EncodedStringWithOptions:0];
    NSString *authString = [NSString stringWithFormat:@"Basic: %@", base64EncodedCredential];
    
    // 设置客户端类型
    NSString *userAgentString = @"iPhone AppleWebKit";
    
    configuration.HTTPAdditionalHeaders = @{@"Accept": @"application/json",
                                            @"Accept-Language": @"en",
                                            @"Authorization": authString,
                                            @"User-Agent": userAgentString};
    
    
    //网络类型
    configuration.networkServiceType = NSURLNetworkServiceTypeDefault;
    
    //允许蜂窝访问
    configuration.allowsCellularAccess = YES;
    
    //超时时长,报文之间的时间
    configuration.timeoutIntervalForRequest = 30;
    
    //整个资源请求时长，实际上提供了整体超时的特性，这应该只用于后台传输，而不是用户实际上可能想要等待的任何东西
    configuration.timeoutIntervalForResource = 30;
    
    return configuration;
}

/**
 格式化字典 -> (@"vid=1&p=1")
 
 @param dict 字典
 @return 请求体(@"vid=1&p=1")
 */
- (NSString *)formatWithDict:(NSDictionary *)dict
{
    if (dict == nil)
    {
        return @"";
    }
    else
    {
        NSMutableString *string = [[NSMutableString alloc] init];
        for (NSInteger i = 0; i < dict.allKeys.count; i++)
        {
            if (i == dict.allKeys.count -1)
            {
                [string appendString:[NSString stringWithFormat:@"%@=%@",dict.allKeys[i],dict.allValues[i]]];
            }
            else
            {
                [string appendString:[NSString stringWithFormat:@"%@=%@&",dict.allKeys[i],dict.allValues[i]]];
            }
            
        }
        return string;
    }
}

/**
 创建请求NSMutableURLRequest

 @param url 请求的地址
 @param method 请求的发送，POST/GET
 @param token 请求头，如果没有传nil
 @param parameters 请求参数字典 @"vid=1&p=1"
 @return NSMutableURLRequest
 */
- (NSMutableURLRequest *)requestWithUrl:(NSString *)url method:(NSString *)method token:(NSString *)token parameters:(NSDictionary *)parameters
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    //1.请求方式
    request.HTTPMethod = [method uppercaseString];
    
    //2.请求头Header
    if (![self isBlankString:token])
    {
        [request setValue:token forHTTPHeaderField:@"token"];
    }
    
    //3.body
    if (parameters != nil)
    {
        request.HTTPBody = [[self formatWithDict:parameters] dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    //超时
    request.timeoutInterval = 30;
    //网络状态
    request.networkServiceType = NSURLNetworkServiceTypeDefault;
    //批量请求
    request.HTTPShouldUsePipelining = YES;
    //处理Cookie
    request.HTTPShouldHandleCookies = YES;
    //缓存策略
    request.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    //允许使用数据流量
    request.allowsCellularAccess = YES;
    
//    //或者下面这种方式 添加所有请求头信息
//    request.allHTTPHeaderFields=@{@"Content-Encoding":@"gzip"};
    
    return request;
}

/**
 get请求(有请求头Header)
 
 @param url 请求地址url
 @param token 请求头token
 @param success 成功返回
 @param failure 失败返回
 */
- (void)get:(NSString *)url token:(NSString *)token success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure
{
    [self get:url token:token parameters:nil success:success failure:failure];
}

/**
 get请求
 
 @param url 请求地址url
 @param parameters 请求参数 : 字典
 @param success 成功返回
 @param failure 失败返回
 */
- (void)get:(NSString *)url parameters:(NSDictionary *)parameters success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure
{
    [self get:url token:nil parameters:parameters success:success failure:failure];
}

/**
 get请求(有请求头Header)
 
 @param url 请求地址url
 @param token 请求头token
 @param parameters 请求参数 : 字典
 @param success 成功返回
 @param failure 失败返回
 */
- (void)get:(NSString *)url token:(NSString *)token parameters:(NSDictionary *)parameters success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure
{
    NSMutableURLRequest *request = [self requestWithUrl:url method:@"GET" token:token parameters:parameters];
    
    //4.发送请求
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error)
        {
            failure(error);
        }
        else
        {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            success(dict);
        }
        
    }];
    
    //发送请求
    [task resume];
}

#pragma mark - 上传

/**
 上传图片
 
 @param url 请求地址url
 @param imageName 图片name
 @param key 请求的参数
 @param value 请求的值
 @param uploadKey 图片对应的key
 @param success 成功返回
 @param failure 失败返回
 */
- (void)upLoad:(NSString *)url imageName:(NSString *)imageName key:(NSString *)key value:(NSString *)value uploadKey:(NSString *)uploadKey success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure
{
    [self upLoad:url imageName:imageName key:key value:value token:nil uploadKey:uploadKey success:success failure:failure];
}

/**
 上传图片
 
 @param url 请求地址url
 @param imageName 图片name
 @param uploadKey 图片对应的key
 @param success 成功返回
 @param failure 失败返回
 */
- (void)upLoad:(NSString *)url imageName:(NSString *)imageName token:(NSString *)token uploadKey:(NSString *)uploadKey success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure
{
    [self upLoad:url imageName:imageName key:nil value:nil token:token uploadKey:uploadKey success:success failure:failure];
}

/**
 上传图片

 @param url 地址url
 @param imageName 图片name
 @param key 请求的参数
 @param value 请求的值
 @param token 请求头
 @param uploadKey 图片对应的key
 @param success 成功返回
 @param failure 失败返回
 */
- (void)upLoad:(NSString *)url imageName:(NSString *)imageName key:(NSString *)key value:(NSString *)value token:(NSString *)token uploadKey:(NSString *)uploadKey success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    request.HTTPMethod = @"POST";
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];//这一行一定不能少，因为后面是转换成JSON发送的
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:20];
    
    if (![self isBlankString:token])
    {
        [request setValue:token forHTTPHeaderField:@"token"];
    }
    
    // 设置请求头
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; charset=utf-8; boundary=%@", boundary]
   forHTTPHeaderField:@"Content-Type"];
    
    // 设置请求文件参数,请求体
    //    NSData *formData = [self setBodyData:@"1-1-登录.png" key:@"uid" value:@"1" uploadKey:@"img"];
    NSData *formData = [self setBodyData:imageName key:key value:value uploadKey:uploadKey];
    
    NSURLSessionConfiguration *configurat = [self creatURLSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configurat];
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:formData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       
        if (error)
        {
            if (failure) {
                failure(error);
            }
        }
        else
        {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@"success  %@",dict);
            if (success) {
                success(dict);
            }
        }
        
    }];
    
    [task resume];
}

/**
 拼接请求体body

 @param imageName 图片name
 @param key 请求参数key
 @param value 请求参数key的值
 @param uploadKey 请求图片的key
 @return 请求体body
 */
- (NSData *)setBodyData:(NSString *)imageName key:(NSString *)key value:(NSString *)value uploadKey:(NSString *)uploadKey
{
    // 设置请求文件参数
    NSMutableData *formData = [NSMutableData data];
    
    //1.请求参数，有就设置，没有就不需要设置
    if (![self isBlankString:key] && ![self isBlankString:value])
    {
        // 参数,uid = 1
        [formData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [formData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n",key]
                              dataUsingEncoding:NSUTF8StringEncoding]];
        [formData appendData:[[NSString stringWithFormat:@"\r\n%@\r\n", value] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //2.文件,后台文件key为img
    [formData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [formData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", uploadKey, @"test2.png"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //3.上传文件的形式
    [formData appendData:[[NSString stringWithFormat:@"Content-Type: image/png\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [formData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [formData appendData:UIImageJPEGRepresentation([UIImage imageNamed:imageName], 0.7)];
    [formData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    //4.结束
    [formData appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return formData;
}

/**
 上传图片
 
 @param url 地址url
 @param image 图片
 @param key 请求的参数
 @param value 请求的值
 @param token 请求头
 @param uploadKey 图片对应的key
 @param success 成功返回
 @param failure 失败返回
 */
- (void)upLoad:(NSString *)url image:(UIImage *)image key:(NSString *)key value:(NSString *)value token:(NSString *)token uploadKey:(NSString *)uploadKey success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure
{
    //1.NSMutableURLRequest
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];//这一行一定不能少，因为后面是转换成JSON发送的
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:20];
    
    if (![self isBlankString:token])
    {
        [request setValue:token forHTTPHeaderField:@"token"];
    }
    
    // 设置请求头
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; charset=utf-8; boundary=%@", boundary]
   forHTTPHeaderField:@"Content-Type"];
    
    // 设置请求文件参数,请求体
    //    NSData *formData = [self setBodyWithImage:@"1-1-登录.png" key:@"uid" value:@"1" uploadKey:@"img"];
    NSData *formData = [self setBodyWithImage:image key:key value:value uploadKey:uploadKey];
    
    //2.NSURLSessionConfiguration
    NSURLSessionConfiguration *configuration = [self creatURLSessionConfiguration];
    
    //3.NSURLSession
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionUploadTask *task =[session uploadTaskWithRequest:request fromData:formData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error)
        {
            if (failure) {
                failure(error);
            }
        }
        else
        {
            if (success) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                success(dict);
            }
        }
        
    }];
    
    [task resume];
}

/**
 上传图片
 
 @param url 地址url
 @param image 图片
 @param token 请求头
 @param uploadKey 图片对应的key
 @param success 成功返回
 @param failure 失败返回
 */
- (void)upLoad:(NSString *)url image:(UIImage *)image token:(NSString *)token uploadKey:(NSString *)uploadKey success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure
{
    [self upLoad:url image:image key:nil value:nil token:token uploadKey:uploadKey success:success failure:failure];
}

/**
 上传图片
 
 @param url 地址url
 @param image 图片
 @param key 请求的参数
 @param value 请求的值
 @param uploadKey 图片对应的key
 @param success 成功返回
 @param failure 失败返回
 */
- (void)upLoad:(NSString *)url image:(UIImage *)image key:(NSString *)key value:(NSString *)value uploadKey:(NSString *)uploadKey success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSError *error))failure
{
    [self upLoad:url image:image key:key value:value token:nil uploadKey:uploadKey success:success failure:failure];
}

/**
 拼接请求体body
 
 @param image 图片
 @param key 请求参数key
 @param value 请求参数key的值
 @param uploadKey 请求图片的key
 @return 请求体body
 */
- (NSData *)setBodyWithImage:(UIImage *)image key:(NSString *)key value:(NSString *)value uploadKey:(NSString *)uploadKey
{
    // 设置请求文件参数
    NSMutableData *formData = [NSMutableData data];
    
    //1.请求参数，有就设置，没有就不需要设置
    if (![self isBlankString:key] && ![self isBlankString:value])
    {
        // 参数,uid = 1
        [formData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [formData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n",key]
                              dataUsingEncoding:NSUTF8StringEncoding]];
        [formData appendData:[[NSString stringWithFormat:@"\r\n%@\r\n", value] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //2.文件,后台文件key为img
    [formData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [formData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", uploadKey, @"test2.png"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //3.上传文件的形式
    [formData appendData:[[NSString stringWithFormat:@"Content-Type: image/png\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [formData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [formData appendData:UIImageJPEGRepresentation(image, 0.7)];
    [formData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    //4.结束
    [formData appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return formData;
}

#pragma mark - 下载

- (void)download:(NSString *)url token:(NSString *)token parameters:(NSDictionary *)parameters success:(void(^)(NSString *filePath))success failure:(void(^)(NSError *error))failure
{
    /*
     response.suggestedFilename是从相应中取出文件在服务器上存储路径的最后部分,如数据在服务器的url为http://www.daka.com/resources/image/icon.png, 那么其suggestedFilename就是icon.png.
     */
    
    NSMutableURLRequest *request = [self requestWithUrl:url method:@"POST" token:token parameters:parameters];
    
    NSURLSessionConfiguration *configuration = [self creatURLSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error)
        {
            if (failure) {
                failure(error);
            }
        }
        else
        {
            // location是沙盒中tmp文件夹下的一个临时url,文件下载后会存到这个位置,由于tmp中的文件随时可能被删除,所以我们需要自己需要把下载的文件挪到需要的地方
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
            // 剪切文件
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:path] error:nil];
            
            if (success) {
                success(path);
            }
        }
        
    }];
    
    [task resume];
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
