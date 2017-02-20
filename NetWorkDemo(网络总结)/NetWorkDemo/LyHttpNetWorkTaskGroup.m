//
//  LyHttpNetWorkTaskGroup.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/18.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LyHttpNetWorkTaskGroup.h"
#import "LyHttpNetWorkTask.h"
#import <UIKit/UIKit.h>
#import "MBProgressHUD+Ly.h"

@interface LyHttpNetWorkTaskGroup ()

@property(nonatomic,strong)NSMutableArray<LyURLRequesTaskGroup *> *array_uRLRequest;
@property(nonatomic,strong)LyNetSetting         *settingNet;

@end

@implementation LyHttpNetWorkTaskGroup

//创建请求,默认设置
- (instancetype)initWithURLRequest:(NSArray<LyURLRequesTaskGroup *> *)requestArray
{
    //默认的网络设置
    LyNetSetting *settingNet = [[LyNetSetting alloc] init];
    settingNet.isCtrlHub = NO;
    settingNet.isCache = NO;
    settingNet.cacheValidTimeInterval = 0;
    settingNet.cachePolicy = LyCacheNormal;
    settingNet.isEncrypt = NO;
    settingNet.baseUrl = nil;
    
    return [self initWithURLRequest:requestArray netSetting:settingNet];
}

//创建请求,自定义设置
- (instancetype)initWithURLRequest:(NSArray<LyURLRequesTaskGroup *> *)requestArray netSetting:(LyNetSetting *)netSetting
{
    if (self = [super init]) {
        [self.array_uRLRequest addObjectsFromArray:requestArray];
        self.settingNet = netSetting;
    }
    return self;
}

- (void)finishRequestWithsuccess:(void (^)(NSArray<id > *resquestArray))success failure:(void (^)(NSArray<NSError *> *errorArray))failure
{
    LyHttpNetWorkTask *manager = [LyHttpNetWorkTask sharkNetWork];
    
    NSMutableArray *requestArray = [[NSMutableArray alloc] init];
    NSMutableArray *errorArray = [[NSMutableArray alloc] init];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    
    if (self.settingNet.isCtrlHub) {
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    }
    
    dispatch_async(queue, ^{
        
        for (NSInteger i = 0 ; i < self.array_uRLRequest.count; i++)
        {
            LyURLRequesTaskGroup *uRLRequest = self.array_uRLRequest[i];
            
            if (uRLRequest.uploadFile != nil)//上传文件
            {
                
                [manager uploadWithUrlString:[self urlFormatWithUrl:uRLRequest.urlString] header:uRLRequest.heard parameters:uRLRequest.parameter imageArray:@[uRLRequest.uploadFile] success:^(id responseData) {
                    dispatch_semaphore_signal(semaphore);
                    [requestArray addObject:responseData];
                    NSLog(@"success%ld",i);
                } failure:^(NSError *error) {
                    dispatch_semaphore_signal(semaphore);
                    [errorArray addObject:error];
                } progress:^(float progress) {
                    
                }];
            }
            else if (uRLRequest.method == LyHttpNetWorkTaskMethodGet)
            {
                [manager get:[self urlFormatWithUrl:uRLRequest.urlString] heard:uRLRequest.heard parameters:uRLRequest.parameter success:^(id requestData) {
                    
                    dispatch_semaphore_signal(semaphore);
                    [requestArray addObject:requestData];
                    NSLog(@"success%ld",i);
                    
                } failure:^(NSError *error) {
                    
                    dispatch_semaphore_signal(semaphore);
                    [errorArray addObject:error];
                    
                }];
            }
            else if (uRLRequest.method == LyHttpNetWorkTaskMethodPost)
            {
                [manager post:[self urlFormatWithUrl:uRLRequest.urlString] heard:uRLRequest.heard parameters:uRLRequest.parameter success:^(id requestData) {
                    
                    dispatch_semaphore_signal(semaphore);
                    [requestArray addObject:requestData];
                    NSLog(@"success%ld",i);
                    
                } failure:^(NSError *error) {
                    
                    dispatch_semaphore_signal(semaphore);
                    [errorArray addObject:error];
                    
                }];
            }
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            if (i == self.array_uRLRequest.count - 1)
            {
                //隐藏弹框
                if (self.settingNet.isCtrlHub) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
                    });
                }
                
                if (success) {
                    success(requestArray);
                }
                
                if (failure) {
                    failure(errorArray);
                }
            }
        }
    });
}

//拼接url
- (NSString *)urlFormatWithUrl:(NSString *)urlString
{
    if (![self isBlankString:self.settingNet.baseUrl])
    {
        return [NSString stringWithFormat:@"%@%@",self.settingNet.baseUrl,urlString];
    }
    else
        return urlString;
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

- (NSMutableArray *)array_uRLRequest
{
    if (!_array_uRLRequest) {
        _array_uRLRequest = [[NSMutableArray alloc] init];
    }
    return _array_uRLRequest;
}

@end

#pragma mark - LyURLRequesTaskGroup,初始化请求参数
@interface LyURLRequesTaskGroup ()

@property(nonatomic,copy  )NSString                        *urlString;//请求地址URL
@property(nonatomic,assign)LyHttpNetWorkTaskMethod         method;//请求方式
@property(nonatomic,copy  )NSDictionary                    *heard;//请求头
@property(nonatomic,copy  )NSDictionary                    *parameter;//请求内容
@property(nonatomic,strong)LyUploadFile                    *uploadFile;//上传文件

@end

@implementation LyURLRequesTaskGroup

- (instancetype)initWithUrlString:(NSString *)urlString method:(LyHttpNetWorkTaskMethod)method heard:(NSDictionary *)heard parameter:(NSDictionary *)parameter
{
    return [self initWithUrlString:urlString method:method heard:heard parameter:parameter uploadFile:nil];
}

- (instancetype)initWithUrlString:(NSString *)urlString method:(LyHttpNetWorkTaskMethod)method heard:(NSDictionary *)heard parameter:(NSDictionary *)parameter uploadFile:(LyUploadFile *)uploadFile
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

