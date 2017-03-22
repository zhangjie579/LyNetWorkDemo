//
//  LyRequestDataTaskGroup.m
//  LyRequestManager
//
//  Created by 张杰 on 2017/3/22.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LyRequestDataTaskGroup.h"
#import <UIKit/UIKit.h>
#import "LyNetSetting.h"
#import "MBProgressHUD+Ly.h"
#import "LyRequestManager.h"

@interface LyRequestDataTaskGroup ()

@property(nonatomic,strong)NSMutableArray<LyURLRequesTaskGroup *> *arrayRequest;
@property(nonatomic,strong)LyNetSetting         *config;
@property(nonatomic,strong)LyRequestManager     *manager;

@end

@implementation LyRequestDataTaskGroup

//创建请求,默认设置
- (instancetype)initWithURLRequest:(NSArray<LyURLRequesTaskGroup *> *)requestArray
{
    if (self = [super init]) {
        [self.arrayRequest addObjectsFromArray:requestArray];
    }
    return self;
}

- (LyNetSetting *)config
{
    if (!_config) {
        NSString *baseUrl = nil;
#ifdef DEBUG //处于开发测试阶段
        baseUrl = @"http://182.254.228.211:9000";
#else //处于发布正式阶段
        baseUrl = @"http://www.xiaoban.mobi";
#endif
        _config = [[LyNetSetting alloc] initWithCtrlHub:NO isCache:NO timeInterval:10 cachePolicy:LyCacheNormal isEncrypt:NO requestType:LyRequestSerializerTypeHTTP responseType:LyResponseSerializerTypeJSON baseUrl:baseUrl];
    }
    return _config;
}

- (void)ly_finishRequestWithsuccess:(void (^)(NSArray<id > *requestArray))success failure:(void (^)(NSArray<NSError *> *errorArray))failure
{
    if (self.config.isCtrlHub) {
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSMutableArray *requestArray = [[NSMutableArray alloc] init];
    NSMutableArray *errorArray = [[NSMutableArray alloc] init];
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        
        for (NSInteger i = 0; i < self.arrayRequest.count; i++)
        {
            LyURLRequesTaskGroup *request = self.arrayRequest[i];
            
#warning 注意: @[nil],这样写是错误的
            NSArray *array = nil;
            if (request.uploadFile != nil) {
                array = request.uploadFile;
            }
            
            [self.manager dataWithMethod:request.method urlString:request.urlString header:request.heard parameters:request.parameter uploadFile:array config:self.config success:^(id responseData) {
                
                dispatch_semaphore_signal(sem);
                [requestArray addObject:responseData];
                
            } failure:^(NSError *error) {
                
                dispatch_semaphore_signal(sem);
                [errorArray addObject:error];
                
            }];
            
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
            
            //最后一个
            if (i == self.arrayRequest.count - 1)
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                });
                //隐藏弹框
                if (self.config.isCtrlHub) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
                    });
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        success(requestArray);
                    }
                    
                    if (failure) {
                        failure(errorArray);
                    }
                });
            }
        }
    });
}

- (NSMutableArray<LyURLRequesTaskGroup *> *)arrayRequest
{
    if (!_arrayRequest) {
        _arrayRequest = [[NSMutableArray alloc] init];
    }
    return _arrayRequest;
}

- (LyRequestManager *)manager
{
    if (!_manager) {
        _manager = [LyRequestManager shareManager];
    }
    return _manager;
}

@end

#pragma mark - LyURLRequesTaskGroup,初始化请求参数
@interface LyURLRequesTaskGroup ()

@property(nonatomic,copy  )NSString                        *urlString;//请求地址URL
@property(nonatomic,assign)LyHttpNetWorkTaskMethod         method;//请求方式
@property(nonatomic,copy  )NSDictionary                    *heard;//请求头
@property(nonatomic,copy  )NSDictionary                    *parameter;//请求内容
@property(nonatomic,strong)NSArray<LyUploadFile *>         *uploadFile;//上传文件

@end

@implementation LyURLRequesTaskGroup

- (instancetype)initWithUrlString:(NSString *)urlString method:(LyHttpNetWorkTaskMethod)method heard:(NSDictionary *)heard
{
    return [self initWithUrlString:urlString method:method heard:heard parameter:nil uploadFile:nil];
}

- (instancetype)initWithUrlString:(NSString *)urlString method:(LyHttpNetWorkTaskMethod)method parameter:(NSDictionary *)parameter
{
    return [self initWithUrlString:urlString method:method heard:nil parameter:parameter uploadFile:nil];
}

- (instancetype)initWithUrlString:(NSString *)urlString method:(LyHttpNetWorkTaskMethod)method heard:(NSDictionary *)heard parameter:(NSDictionary *)parameter
{
    return [self initWithUrlString:urlString method:method heard:heard parameter:parameter uploadFile:nil];
}

- (instancetype)initWithUrlString:(NSString *)urlString method:(LyHttpNetWorkTaskMethod)method heard:(NSDictionary *)heard uploadFile:(NSArray<LyUploadFile *> *)uploadFile
{
    return [self initWithUrlString:urlString method:method heard:heard parameter:nil uploadFile:uploadFile];
}

- (instancetype)initWithUrlString:(NSString *)urlString method:(LyHttpNetWorkTaskMethod)method parameter:(NSDictionary *)parameter uploadFile:(NSArray<LyUploadFile *> *)uploadFile
{
    return [self initWithUrlString:urlString method:method heard:nil parameter:parameter uploadFile:uploadFile];
}

- (instancetype)initWithUrlString:(NSString *)urlString method:(LyHttpNetWorkTaskMethod)method heard:(NSDictionary *)heard parameter:(NSDictionary *)parameter uploadFile:(NSArray<LyUploadFile *> *)uploadFile
{
    if (self = [super init]) {
        self.urlString = urlString;
        self.method = method;
        self.parameter = parameter;
        self.heard = heard;
        self.uploadFile = uploadFile;
    }
    return self;
}

@end
