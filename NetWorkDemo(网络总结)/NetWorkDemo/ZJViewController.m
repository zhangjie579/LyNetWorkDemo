//
//  ZJViewController.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/18.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "ZJViewController.h"
#import "LyHttpNetWorkTask.h"
#import "LyHttpNetWorkManager.h"
#import "LyHttpNetWorkTaskGroup.h"
#import "LyCacheManager.h"
#import "Person.h"
#import "LyCacheSession.h"

@interface ZJViewController ()

@end

@implementation ZJViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"ZJViewController";
    
    [self cache];
//    [self abc];
    
//    NSDictionary *dict = @{@"1" : @{@"saoge" : @"弱鸡"}};
//    
//    NSString *str =  dict[@"1"][@"saoge"];
//    
//    NSLog(@"saoge = %@",str);
}

- (void)dealloc
{
    NSLog(@"销毁了");
}

- (void)abc
{
    LyCacheSession *session = [LyCacheSession defaultSession];
    
    [session creatTableWithClassName:@"StatusModel"];
}

- (void)cache
{
    LyCacheSession *session = [LyCacheSession defaultSession];
    
    Person *person = [[Person alloc] init];

    person.dict = @{@"1" : @{@"saoge" : @"弱鸡"}};
    person.name = @"zhangjie";
    person.key = 3.5;
    person.num = @0;
    person.count = 10;
    
//    id key = [person valueForKey:@"key"];
//    id count = [person valueForKey:@"count"];
//    NSNumber *num = [person valueForKey:@"num"];
//    NSString *name = [person valueForKey:@"name"];
//
//    NSLog(@"%@",name);
    
//    [session creatTableWithClassName:@"Person"];
    
//    [session insertWithModel:person className:@"Person"];
    
    
//    [session updateWithClassName:@"Person" dict:@{@"a" : @2 , @"age" : @"18"} dependDict:@{@"name" : @"zhangjie"}];
    
//    [session updateWithClassName:@"Person" model:person dependDict:nil];
    
    NSArray *array = [session selectAllClassName:@"Person"];
    
    NSLog(@"%@ ",array);
    
    
//    [session deleteWithDict:@{@"a" : @1 , @"age" : @"16"} className:@"Person"];
    
//    [session insertWithArrayModel:@[person , person] className:@"Person"];
}

//多个请求
- (void)demo3
{
    //1.创建上传的文件
    LyUploadFile *file = [[LyUploadFile alloc] initWithUploadKey:@"img" fileName:@"iphone" fileType:LyUploadFileTypeJpg fileData:[UIImage imageNamed:@"1-1-登录.png"]];
    
    //2.创建请求
//    LyURLRequesTaskGroup *request1 = [[LyURLRequesTaskGroup alloc] initWithUrlString:@"http://182.254.228.211:9000/index.php/api/Auth/uploadImg" method:LyHttpNetWorkTaskMethodPost heard:nil parameter:@{@"uid" : @"1"} uploadFile:file];
//    LyURLRequesTaskGroup *request2 = [[LyURLRequesTaskGroup alloc] initWithUrlString:@"http://182.254.228.211:9000//index.php/Api/Circle/messageList" method:LyHttpNetWorkTaskMethodPost heard:nil parameter:@{@"uid" : @"1" , @"p" : @"1"}];
//    LyURLRequesTaskGroup *request3 = [[LyURLRequesTaskGroup alloc] initWithUrlString:@"http://182.254.228.211:9000/index.php/Api/Circle/getLabel" method:LyHttpNetWorkTaskMethodPost heard:nil parameter:@{@"uid" : @"1"}];
    
    LyURLRequesTaskGroup *request1 = [[LyURLRequesTaskGroup alloc] initWithUrlString:@"/index.php/api/Auth/uploadImg" method:LyHttpNetWorkTaskMethodPost heard:nil parameter:@{@"uid" : @"1"} uploadFile:file];
    LyURLRequesTaskGroup *request2 = [[LyURLRequesTaskGroup alloc] initWithUrlString:@"/index.php/Api/Circle/messageList" method:LyHttpNetWorkTaskMethodPost heard:nil parameter:@{@"uid" : @"1" , @"p" : @"1"}];
    LyURLRequesTaskGroup *request3 = [[LyURLRequesTaskGroup alloc] initWithUrlString:@"/index.php/Api/Circle/getLabel" method:LyHttpNetWorkTaskMethodPost heard:nil parameter:@{@"uid" : @"1"}];
    
    //3.发送请求
//    LyHttpNetWorkTaskGroup *tool = [[LyHttpNetWorkTaskGroup alloc] initWithURLRequest:@[request1,request2,request3]];
    
    //有设置的发送请求
    LyNetSetting *settingNet = [[LyNetSetting alloc] init];
    settingNet.isCtrlHub = YES;
    settingNet.isCache = NO;
    settingNet.cacheValidTimeInterval = 0;
    settingNet.cachePolicy = LyCacheNormal;
    settingNet.isEncrypt = NO;
    settingNet.baseUrl = @"http://182.254.228.211:9000";
    LyHttpNetWorkTaskGroup *tool = [[LyHttpNetWorkTaskGroup alloc] initWithURLRequest:@[request1,request2,request3] netSetting:settingNet];
    
    //4.收到请求回调
    [tool finishRequestWithsuccess:^(NSArray<id> *resquestArray) {
        for (NSInteger i = 0; i < resquestArray.count; i++) {
            NSLog(@"%ld        %@",i,resquestArray[i]);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"主线刷新UI");
        });

    } failure:^(NSArray<NSError *> *errorArray) {
        
    }];
    
    NSLog(@"主线");
}

//多任务执行，是顺序的
- (void)demo2
{
    LyHttpNetWorkTask *tool = [LyHttpNetWorkTask sharkNetWork];
    LyHttpNetWorkManager *manager = [LyHttpNetWorkManager sharkManager];
    
    LyNetSetting *setting = [[LyNetSetting alloc] init];
    setting.isCtrlHub = NO;
    setting.baseUrl = @"http://182.254.228.211:9000";
    
    manager.settingNetWork = setting;
    
    LyUploadFile *file = [[LyUploadFile alloc] initWithUploadKey:@"img" fileName:@"iphone" fileType:LyUploadFileTypeJpg fileData:[UIImage imageNamed:@"1-1-登录.png"]];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    dispatch_async(queue, ^{
        
        [manager uploadWithUrlString:@"/index.php/api/Auth/uploadImg" parameters:@{@"uid" : @"1"} file:file success:^(id responseData) {
    
            dispatch_semaphore_signal(semaphore);
            NSLog(@"success1 %@",responseData);
    
        } failure:^(NSError *error) {
            NSLog(@"error1   %@",error);
            dispatch_semaphore_signal(semaphore);
        } progress:^(float progress) {
    
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
        [manager post:@"/index.php/Api/Circle/messageList" parameters:@{@"uid" : @"1" , @"p" : @"1"} success:^(id resquestData) {
            NSLog(@"success2   %@",resquestData);
            dispatch_semaphore_signal(semaphore);
        } failure:^(NSError *error) {
            NSLog(@"error2 %@",error);
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
        [manager post:@"/index.php/Api/Circle/getLabel" parameters:@{@"uid" : @"1"} success:^(id resquestData) {
            NSLog(@"success3   %@",resquestData);
            dispatch_semaphore_signal(semaphore);
        } failure:^(NSError *error) {
            NSLog(@"error3 %@",error);
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"主线刷新UI");
        });
        
    });
    
    NSLog(@"主线1");
}

//多任务执行，不保证是顺序的，但是最后在dispatch_group_notify刷新UI
- (void)demo1
{
    LyHttpNetWorkTask *tool = [LyHttpNetWorkTask sharkNetWork];
    LyHttpNetWorkManager *manager = [LyHttpNetWorkManager sharkManager];
    
    LyNetSetting *setting = [[LyNetSetting alloc] init];
    setting.isCtrlHub = NO;
    setting.baseUrl = @"http://182.254.228.211:9000";
    
    manager.settingNetWork = setting;
    
    LyUploadFile *file = [[LyUploadFile alloc] initWithUploadKey:@"img" fileName:@"iphone" fileType:LyUploadFileTypeJpg fileData:[UIImage imageNamed:@"1-1-登录.png"]];
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        [manager uploadWithUrlString:@"/index.php/api/Auth/uploadImg" parameters:@{@"uid" : @"1"} file:file success:^(id responseData) {
            
            dispatch_group_leave(group);
            NSLog(@"success1 %@",responseData);
            
        } failure:^(NSError *error) {
            NSLog(@"error1   %@",error);
            dispatch_group_leave(group);
        } progress:^(float progress) {
            
        }];
    });
    
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        [manager post:@"/index.php/Api/Circle/messageList" parameters:@{@"uid" : @"1" , @"p" : @"1"} success:^(id resquestData) {
            NSLog(@"success2   %@",resquestData);
            dispatch_group_leave(group);
        } failure:^(NSError *error) {
            NSLog(@"error2 %@",error);
            dispatch_group_leave(group);
        }];
    });
    
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        [manager post:@"/index.php/Api/Circle/getLabel" parameters:@{@"uid" : @"1"} success:^(id resquestData) {
            NSLog(@"success3   %@",resquestData);
            dispatch_group_leave(group);
        } failure:^(NSError *error) {
            NSLog(@"error3 %@",error);
            dispatch_group_leave(group);
        }];
    });
    
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"主线刷新UI");
    });
    
    NSLog(@"主线1");
}

@end
