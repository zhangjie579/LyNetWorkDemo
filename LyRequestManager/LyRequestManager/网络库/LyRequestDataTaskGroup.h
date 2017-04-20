//
//  LyRequestDataTaskGroup.h
//  LyRequestManager
//
//  Created by 张杰 on 2017/3/22.
//  Copyright © 2017年 张杰. All rights reserved.
//  多个请求直接使用的类

#import <Foundation/Foundation.h>
#import "LyUploadFile.h"
#import "LyNetworkConfig.h"
@class LyURLRequesTaskGroup;

@interface LyRequestDataTaskGroup : NSObject

//创建请求,默认设置
- (instancetype)initWithURLRequest:(NSArray<LyURLRequesTaskGroup *> *)requesTask;

/**
 顺序请求
 
 @param success 成功的数据
 @param failure 失败的数据
 */
- (void)ly_syncFinishWithsuccess:(void (^)(NSArray<id > *requestArray))success failure:(void (^)(NSArray<NSError *> *errorArray))failure;

/**
 无序请求,字典的key为url,不过不包含baseUrl
 
 @param success 成功的数据
 @param failure 失败的数据
 */
- (void)ly_asyncFinishWithsuccess:(void (^)(NSDictionary<NSString * , id> *requestDict))success failure:(void (^)(NSDictionary<NSString * ,NSError *> *errorDict))failure;

@end

#pragma mark - LyURLRequesTaskGroup,初始化请求参数
@interface LyURLRequesTaskGroup : NSObject

@property(nonatomic,copy  ,readonly)NSString                        *urlString;//请求地址URL
@property(nonatomic,assign,readonly)LyHttpNetWorkTaskMethod         method;//请求方式
@property(nonatomic,copy  ,readonly)NSDictionary                    *heard;//请求头
@property(nonatomic,copy  ,readonly)NSDictionary                    *parameter;//请求内容
@property(nonatomic,strong,readonly)NSArray<LyUploadFile *>         *uploadFile;//上传文件

//创建post/get请求
- (instancetype)initWithUrlString:(NSString *)urlString method:(LyHttpNetWorkTaskMethod)method heard:(NSDictionary *)heard parameter:(NSDictionary *)parameter;

- (instancetype)initWithUrlString:(NSString *)urlString method:(LyHttpNetWorkTaskMethod)method heard:(NSDictionary *)heard;

- (instancetype)initWithUrlString:(NSString *)urlString method:(LyHttpNetWorkTaskMethod)method parameter:(NSDictionary *)parameter;

//创建上传请求,上传请求用的是post
- (instancetype)initWithUrlString:(NSString *)urlString method:(LyHttpNetWorkTaskMethod)method heard:(NSDictionary *)heard parameter:(NSDictionary *)parameter uploadFile:(NSArray<LyUploadFile *> *)uploadFile;

- (instancetype)initWithUrlString:(NSString *)urlString method:(LyHttpNetWorkTaskMethod)method heard:(NSDictionary *)heard uploadFile:(NSArray<LyUploadFile *> *)uploadFile;

- (instancetype)initWithUrlString:(NSString *)urlString method:(LyHttpNetWorkTaskMethod)method parameter:(NSDictionary *)parameter uploadFile:(NSArray<LyUploadFile *> *)uploadFile;

@end
