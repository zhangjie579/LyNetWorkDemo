//
//  LyHttpNetWorkTaskGroup.h
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/18.
//  Copyright © 2017年 张杰. All rights reserved.
//  多任务的网络请求

#import <Foundation/Foundation.h>
#import "LyURLRequestManager.h"
#import "LyUploadFile.h"
#import "LyNetworkConfig.h"
#import "LyNetSetting.h"

@class LyURLRequesTaskGroup;

@interface LyHttpNetWorkTaskGroup : NSObject

//创建请求,默认设置
- (instancetype)initWithURLRequest:(NSArray<LyURLRequesTaskGroup *> *)requestArray;

//创建请求,自定义设置
- (instancetype)initWithURLRequest:(NSArray<LyURLRequesTaskGroup *> *)requestArray netSetting:(LyNetSetting *)netSetting;

//完成请求后的回调，请求是顺序执行的,注意：回调不是在主线程上，so刷新UI要自己写在主线程上
- (void)finishRequestWithsuccess:(void (^)(NSArray<id > *resquestArray))success failure:(void (^)(NSArray<NSError *> *errorArray))failure;

@end

#pragma mark - LyURLRequesTaskGroup,初始化请求参数
@interface LyURLRequesTaskGroup : NSObject

@property(nonatomic,copy  ,readonly)NSString                        *urlString;//请求地址URL
@property(nonatomic,assign,readonly)LyHttpNetWorkTaskMethod         method;//请求方式
@property(nonatomic,copy  ,readonly)NSDictionary                    *heard;//请求头
@property(nonatomic,copy  ,readonly)NSDictionary                    *parameter;//请求内容
@property(nonatomic,strong,readonly)LyUploadFile                    *uploadFile;//上传文件

//创建post/get请求
- (instancetype)initWithUrlString:(NSString *)urlString method:(LyHttpNetWorkTaskMethod)method heard:(NSDictionary *)heard parameter:(NSDictionary *)parameter;

//创建上传请求,上传请求用的是post
- (instancetype)initWithUrlString:(NSString *)urlString method:(LyHttpNetWorkTaskMethod)method heard:(NSDictionary *)heard parameter:(NSDictionary *)parameter uploadFile:(LyUploadFile *)uploadFile;

@end
