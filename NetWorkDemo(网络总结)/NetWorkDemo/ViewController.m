//
//  ViewController.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/1/20.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "ViewController.h"
#import "CourseAddCommentApi.h"
#import "MyUserInfoUploadImageApi.h"
#import "AFNetworking.h"
#import "YTKBatchRequest.h"
#import "LYURLSession.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self test3];
    
//    [[LYURLSession shareTool] postWithUrl:@"http://zzy.bolemayy.com/video/comment/list" vid:@"1"];
    
    LYURLSession *manager = [LYURLSession shareTool];
    
    [manager upLoad:@"http://182.254.228.211:9000/index.php/api/Auth/uploadImg" imageName:@"1-1-登录.png" key:@"uid" value:@"1" uploadKey:@"img" success:^(NSDictionary *dict) {
        
    } failure:^(NSError *error) {
        
    }];
    
//    [manager post:@"http://zzy.bolemayy.com/video/comment/list" token:@"8.1487468031.57312.ff50c51ed2651b99dad5c6a1175f00c5" keyString:@"vid=1&p=1" success:^(NSDictionary *dict) {
//        NSLog(@"success   %@",dict);
//    } failure:^(NSError *error) {
//        NSLog(@"error  %@",error);
//    }];
}

#pragma mark - 有heards的请求
- (void)test1
{
    CourseAddCommentApi *api = [[CourseAddCommentApi alloc] initWithVid:@"1" content:@"123"];
    [api startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        
        NSDictionary *dict = [self jsonStrToDictionary:request.responseString];
        
        if ([dict[@"status"] integerValue] == 0)
        {
            
        }
        
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        
    }];
}

#pragma mark - YTK上传文件
- (void)test2
{
    MyUserInfoUploadImageApi *api = [[MyUserInfoUploadImageApi alloc] initWithImage:[UIImage imageNamed:@"1-1-登录.png"] uid:@"1"];
    [api startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        
        NSDictionary *dict = [self jsonStrToDictionary:request.responseString];
        
        if ([dict[@"status"] integerValue] == 0)
        {
            
        }
        
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
#warning 不知道为什么它从这返回
        NSDictionary *dict = [self jsonStrToDictionary:request.responseString];
        NSLog(@"%@",dict);
        
    }];
}

#pragma mark - 上传文件
- (void)test3
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //接收类型不一致请替换一致text/html或别的
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                         @"text/html",
                                                         @"image/jpeg",
                                                         @"image/png",
                                                         @"application/octet-stream",
                                                         @"text/json",
                                                         nil];

    [manager POST:@"http://182.254.228.211:9000/index.php/api/Auth/uploadImg" parameters:@{@"uid" : @"1"} constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
        
        NSData *imageData =UIImageJPEGRepresentation([UIImage imageNamed:@"1-1-登录.png"] ,1);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat =@"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
        
        //上传的参数(上传图片，以文件流的格式)
        [formData appendPartWithFileData:imageData
                                    name:@"img"
                                fileName:fileName
                                mimeType:@"image/jpeg"];
        
    } progress:^(NSProgress *_Nonnull uploadProgress) {
        //打印下上传进度
    } success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
        //上传成功
        NSLog(@"success   %@",responseObject);
    } failure:^(NSURLSessionDataTask *_Nullable task, NSError * _Nonnull error) {
        //上传失败
        NSLog(@"error    %@",error);
    }];
}

#pragma mark - YTK处理多个请求
- (void)test4
{
    CourseAddCommentApi *api1 = [[CourseAddCommentApi alloc] initWithVid:@"1" content:@"123"];
    MyUserInfoUploadImageApi *api2 = [[MyUserInfoUploadImageApi alloc] initWithImage:[UIImage imageNamed:@"1-1-登录.png"] uid:@"1"];
    YTKBatchRequest *batchRequest = [[YTKBatchRequest alloc] initWithRequestArray:@[api1, api2]];
    [batchRequest startWithCompletionBlockWithSuccess:^(YTKBatchRequest *batchRequest) {
        NSLog(@"succeed");
        NSArray *requests = batchRequest.requestArray;
        CourseAddCommentApi *a = (CourseAddCommentApi *)requests[0];
        MyUserInfoUploadImageApi *b = (MyUserInfoUploadImageApi *)requests[1];
        
        
        // deal with requests result ...
    } failure:^(YTKBatchRequest *batchRequest) {
        NSLog(@"failed");
    }];
}


#pragma mark - json 转 dict
- (NSDictionary *)jsonStrToDictionary:(NSString *)str
{
    NSDictionary *resultDic = nil;
    if (![self isBlankString:str]) {
        NSString *requestTmp = [NSString stringWithString:str];
        NSData *resData = [[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        resultDic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
    }
    return resultDic;
}

//判断某字符串是否为空
- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}


@end
