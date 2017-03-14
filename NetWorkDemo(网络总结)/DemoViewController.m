//
//  DemoViewController.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/24.
//  Copyright © 2017年 张杰. All rights reserved.
//  NSURLSession避免循环引用

#import "DemoViewController.h"
#import "LyURLSessionManager.h"
#import <objc/message.h>

@interface DemoViewController ()<NSURLSessionDelegate,NSURLSessionTaskDelegate>

@property(nonatomic,strong)NSURLSession *session;
@property(nonatomic,strong)NSMutableData *mutableData;

@end

/*
 由于NSURLSession中的delegate是retain，so会出现循环引用，因此用完读需要销毁
 retain的原因是:如果出了这个页面还继续下载等等的需求，so苹果才会如此设计
 */

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
//    [self lyURLSessionManager];
    
//    [NSTimer scheduledTimerWithTimeInterval:<#(NSTimeInterval)#> repeats:<#(BOOL)#> block:^(NSTimer * _Nonnull timer) {
//        
//    }]

}

- (void)dealloc
{
    NSLog(@"销毁了...");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
#warning 如果是[session dataTaskWithRequest:request]这样请求，不是通过block得到数据的，就不需要在这invalidateAndCancel
//    [self.session invalidateAndCancel];
//    self.session = nil;
}

- (void)test
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://182.254.228.211:9000/index.php/Api/Circle/getLabel"]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [@"uid=1" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:queue];
    //    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    //
    //        if (error)
    //        {
    //            NSLog(@"error  %@",error);
    //        }
    //        else
    //        {
    //            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    //            NSLog(@"success1  %@",dict);
    //        }
    //
    //    }];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task resume];
    NSURLSessionDataTask *task1 = [session dataTaskWithRequest:request];
    [task1 resume];
    self.session = session;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSData *data = nil;
    if (self.mutableData)
    {
        data = [self.mutableData copy];
        //每完成一次任务self.mutableData读需要重新赋值
        self.mutableData = nil;
    }
    
    if (error)
    {
        NSLog(@"error  %@",error);
    }
    else
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"success1  %@",dict);
    }
    [session finishTasksAndInvalidate];
    session = nil;
}

- (void)URLSession:(__unused NSURLSession *)session
          dataTask:(__unused NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    if(!self.mutableData){
        self.mutableData = [NSMutableData new];
    }
    [self.mutableData appendData:data];
}

#pragma mark - LyURLSessionManager使用
- (void)lyURLSessionManager
{
    LyURLSessionManager *manager = [LyURLSessionManager shareTool];
    NSString *token = @"8.1490585441.75941.2089ca7089f71050fdc1baf539978ce1";
    
    dispatch_semaphore_t semap = dispatch_semaphore_create(0);
    
    [manager post:@"http://182.254.228.211:9000/index.php/Api/ServiceContact/index" header:nil parameters:@{@"uid" : @"1"} success:^(NSDictionary *dict) {
        
        dispatch_semaphore_signal(semap);
        NSLog(@"success1  %@",dict);
        
    } failure:^(NSError *error) {
        dispatch_semaphore_signal(semap);
        NSLog(@"error1  %@",error);
    }];
    dispatch_semaphore_wait(semap, DISPATCH_TIME_FOREVER);
    
    [manager post:@"http://zzy.bolemayy.com/video/index/index" header:@{@"token" : token} parameters:@{@"p" : @"1"} success:^(NSDictionary *dict) {
        dispatch_semaphore_signal(semap);
        NSLog(@"success2  %@",dict);
    } failure:^(NSError *error) {
        dispatch_semaphore_signal(semap);
        NSLog(@"error2  %@",error);
    }];
    dispatch_semaphore_wait(semap, DISPATCH_TIME_FOREVER);
    
    [manager upLoad:@"http://182.254.228.211:9000/index.php/api/Auth/uploadImg" imageName:@"1-1-登录.png" header:nil parameters:@{@"uid" : @"1"} uploadKey:@"img" success:^(NSDictionary *dict) {
        NSLog(@"success4  %@",dict);
        dispatch_semaphore_signal(semap);
    } failure:^(NSError *error) {
        NSLog(@"error4  %@",error);
        dispatch_semaphore_signal(semap);
    }];
    dispatch_semaphore_wait(semap, DISPATCH_TIME_FOREVER);
    
    [manager upLoad:@"http://zzy.bolemayy.com/user/index/upload-img" image:[UIImage imageNamed:@"1-1-登录.png"] header:@{@"token" : token} uploadKey:@"img" success:^(NSDictionary *dict) {
        NSLog(@"success3  %@",dict);
        dispatch_semaphore_signal(semap);
    } failure:^(NSError *error) {
        NSLog(@"error3  %@",error);
        dispatch_semaphore_signal(semap);
    }];
    dispatch_semaphore_wait(semap, DISPATCH_TIME_FOREVER);
}

@end
