//
//  ViewController.m
//  LyRequestManager
//
//  Created by 张杰 on 2017/3/21.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "ViewController.h"
#import "LyRequestDataTask.h"
#import "LyRequestDataTaskGroup.h"
#import "LyRequestManager.h"
#import "JNKeychain.h"
#import "MBProgressHUD+Ly.h"

@interface ViewController ()

@property(nonatomic,strong)LyRequestDataTask *task;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"修改版本2");
    
    [self someRequest];
    
//    [self.task post:@"/sign/index/get-image" heard:@{@"token" : @"8.1495265010.62328.0c6ea000dae4ed012cc2d4fcc1359a69"} success:^(id requestData) {
//        
//    } failure:^(NSError *error) {
//        
//    }];
    
}

//多个网络请求
- (void)someRequest
{
    LyURLRequesTaskGroup *task1 = [[LyURLRequesTaskGroup alloc] initWithUrlString:@"/index.php/Api/Circle/getLabel" method:LyHttpNetWorkTaskMethodPost heard:nil parameter:@{@"uid" : @"1"}];
    
    LyUploadFile *file = [[LyUploadFile alloc] initWithUploadKey:@"img" fileName:@"img.png" fileType:LyUploadFileTypePng fileData:[UIImage imageNamed:@"apply_bottom_course"]];
    LyURLRequesTaskGroup *task2 = [[LyURLRequesTaskGroup alloc] initWithUrlString:@"/index.php/api/Auth/uploadImg" method:LyHttpNetWorkTaskMethodPost heard:nil parameter:@{@"uid" : @"1"} uploadFile:@[file]];
    
    LyURLRequesTaskGroup *task3 = [[LyURLRequesTaskGroup alloc] initWithUrlString:@"/index.php/Api/Circle/index" method:LyHttpNetWorkTaskMethodPost heard:nil parameter:@{@"uid" : @"1" , @"p" : @"1"}];
    
    LyRequestDataTaskGroup *group = [[LyRequestDataTaskGroup alloc] initWithURLRequest:@[task1,task2,task3]];
    
//    [group ly_syncFinishWithsuccess:^(NSArray<id> *requestArray) {
//        
//        NSLog(@"%@", requestArray);
//        
//    } failure:^(NSArray<NSError *> *errorArray) {
//        NSLog(@"%@", errorArray);
//    }];

    [group ly_asyncFinishWithsuccess:^(NSDictionary<NSString *,id> *requestDict) {
        
        id a = requestDict[task1.urlString];
        
        NSLog(@"---%@",a);
        
    } failure:^(NSDictionary<NSString *,NSError *> *errorDict) {
        
    }];
}

- (LyRequestDataTask *)task
{
    if (!_task) {
        _task = [LyRequestDataTask shareTask];
    }
    return _task;
}

@end
