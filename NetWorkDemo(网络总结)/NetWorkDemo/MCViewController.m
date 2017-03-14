//
//  MCViewController.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/3/13.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "MCViewController.h"
#import "AFNetworking.h"

@interface MCViewController ()<NSURLSessionDelegate>

@end

@implementation MCViewController
/*
 简单说来, 就是在客户端和服务器之间建立一个安全通道, 建立通道的机制就是公钥和私钥, 但是服务器如何将公钥传给客户端呢? 如何保证公钥在传输的过程中不会被拦截呢? 这就需要CA颁发数字证书了.
 
 数字证书你可以理解为一个被CA用私钥加密了服务器端公钥的密文
 当服务器拿到了这个密文之后就可以发送给客户端了, 即使被拦截,没有CA的公钥也是无法解开的
 
 1.服务器将公钥发送给客户端
 2.客户端用公钥给请求数据加密
 3.服务器用私钥给请求数据解密，再用私钥将返回数据加密，然后发送给客户端
 4.客户端用公钥解密
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)test1
{
    /* 我们以购买火车票的url地址为例 */
    NSURL *url = [NSURL URLWithString:@"https://kyfw.12306.cn/otn/"];
    
    /* 发送HTTPS请求是需要对网络会话设置代理的 */
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    
    //    [session dataTaskWithRequest:<#(nonnull NSURLRequest *)#> completionHandler:<#^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)completionHandler#>]
    
    [dataTask resume];
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    if (![challenge.protectionSpace.authenticationMethod isEqualToString:@"NSURLAuthenticationMethodServerTrust"]) {
        return;
    }
    NSURLCredential *credential = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    [session finishTasksAndInvalidate];
    session = nil;
}

- (void)afn {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    
    //因为接收到的是html数据, 需要用原始解析,而不是默认的JSON解析
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //因为12306网站采用的是自认证, 所以我们需要允许无效证书, 默认是NO
    manager.securityPolicy.allowInvalidCertificates = YES;
    //使域名有效,我们需要改成NO,默认是YES
    manager.securityPolicy.validatesDomainName = NO;
    
    
    [manager GET:@"https://kyfw.12306.cn/otn/" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            NSLog(@"请求失败:%@",error.localizedDescription);
        }
    }];
}

@end
