//
//  LyURLRequestManager.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/18.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LyURLRequestManager.h"
#import "AFNetworking.h"
#import "LyUploadFile.h"

@interface LyURLRequestManager ()

@property (strong, nonatomic) AFHTTPRequestSerializer *requestSerialize;

@end

@implementation LyURLRequestManager

+ (instancetype)shareTool
{
    static LyURLRequestManager *tool = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        tool = [[self alloc] init];
    });
    return tool;
}

/**
 get/post请求

 @param urlPath 完整url
 @param method 请求方式
 @param params 请求内容
 @param header 请求头
 @return NSMutableURLRequest
 */
- (NSMutableURLRequest *)requestWithUrlPath:(NSString *)urlPath method:(NSString *)method params:(NSDictionary *)params header:(NSDictionary *)header
{
    NSError *error;
    //1.创建请求
    NSMutableURLRequest *request = [self.requestSerialize requestWithMethod:[method uppercaseString] URLString:urlPath parameters:params error:&error];

    //2.设置请求头
    [header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        [request setValue:value forHTTPHeaderField:key];
    }];
    return request;
}

/**
 上传文件请求

 @param urlPath 完整url
 @param method 请求方式
 @param params 请求内容
 @param contents 文件内容
 @param header 请求头
 @return NSMutableURLRequest
 */
- (NSMutableURLRequest *)uploadRequestUrlPath:(NSString *)urlPath method:(NSString *)method params:(NSDictionary *)params contents:(NSArray<LyUploadFile *> *)contents header:(NSDictionary *)header
{
    
    NSMutableURLRequest *request = [self.requestSerialize multipartFormRequestWithMethod:[method uppercaseString] URLString:urlPath parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [contents enumerateObjectsUsingBlock:^(LyUploadFile * _Nonnull file, NSUInteger idx, BOOL * _Nonnull stop) {
            [formData appendPartWithFileData:file.fileData name:file.uploadKey fileName:file.fileName mimeType:file.fileType];
        }];
        
    } error:nil];

    [header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        [request setValue:value forHTTPHeaderField:key];
    }];
    return request;
}

#pragma mark - Getter

- (AFHTTPRequestSerializer *)requestSerialize {
    if (!_requestSerialize) {
        _requestSerialize = [AFHTTPRequestSerializer serializer];
    }
    return _requestSerialize;
}

@end
