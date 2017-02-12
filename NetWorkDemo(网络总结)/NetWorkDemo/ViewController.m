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
#import "LyJsonTool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self test3];
    
//    [[LYURLSession shareTool] postWithUrl:@"http://zzy.bolemayy.com/video/comment/list" vid:@"1"];
    
    LYURLSession *manager = [LYURLSession shareTool];
    
//    [manager upLoad:@"http://182.254.228.211:9000/index.php/api/Auth/uploadImg" imageName:@"1-1-登录.png" key:@"uid" value:@"1" uploadKey:@"img" success:^(NSDictionary *dict) {
//        
//    } failure:^(NSError *error) {
//        
//    }];
    
    [manager post:@"http://182.254.228.211:9000/index.php/api/worker/index" parameters:@{@"uid" : @"1"} success:^(NSDictionary *dict) {
        NSLog(@"success1   %@",dict);
    } failure:^(NSError *error) {
        NSLog(@"error  %@",error);
    }];
    
    [manager post:@"http://zzy.bolemayy.com/video/index/index" token:@"8.1489200645.43477.6133d147eb35145b305a96e22e7a30da" parameters:@{@"p" : @"1"} success:^(NSDictionary *dict) {
        NSLog(@"success2   %@",dict);
    } failure:^(NSError *error) {
        NSLog(@"error  %@",error);
    }];
    
//    [manager upLoad:@"http://zzy.bolemayy.com/user/index/upload-img" imageName:@"1-1-登录.png" token:@"8.1489395432.79340.6c1836767b617e15cb1263f1e40b3b66" uploadKey:@"img" success:^(NSDictionary *dict) {
//        NSLog(@"success   %@",dict);
//    } failure:^(NSError *error) {
//        NSLog(@"error  %@",error);
//    }];
}

- (void)async
{
    //    dispatch_async(dispatch_queue_create("123", DISPATCH_QUEUE_SERIAL), ^{
    //
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //
    //        });
    //
    //    });
    //
    //    dispatch_async(dispatch_queue_create("qqq", DISPATCH_QUEUE_CONCURRENT), ^{
    //
    //    });
    
    //    [NSRunLoop currentRunLoop] addTimer:<#(nonnull NSTimer *)#> forMode:NSDefaultRunLoopMode
}

//dict与json互转
- (void)changeToDictOrJson
{
    NSMutableDictionary *dict  = [[NSMutableDictionary alloc]init];
    [dict setValue:@"谢飞" forKey:@"name"];
    [dict setValue:@"1070430532@qq.com" forKey:@"email"];
    [dict setValue:@"ios工程师" forKey:@"profession"];
    
    //    NSArray *array = @[@"谢飞" , @"1070430532@qq.com" , @"ios工程师"];
    
    NSString *json =[LyJsonTool jsonWithObject:dict];
    
    NSLog(@"json    %@",json);
    
    NSDictionary *dic = [LyJsonTool dictWithJson:json];
    NSLog(@"dic    %@",dic[@"name"]);
}

#pragma mark - 有heards的请求
- (void)test1
{
    CourseAddCommentApi *api = [[CourseAddCommentApi alloc] initWithVid:@"1" content:@"123"];
    [api startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        
        NSDictionary *dict = [LyJsonTool dictWithJson:request.responseString];
        
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
        
        NSDictionary *dict = [LyJsonTool dictWithJson:request.responseString];
        
        if ([dict[@"status"] integerValue] == 0)
        {
            
        }
        
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
#warning 不知道为什么它从这返回
        NSDictionary *dict = [LyJsonTool dictWithJson:request.responseString];
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


@end
