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

@interface ZJViewController ()

@end

@implementation ZJViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self demo1];
}

- (void)dealloc
{
    NSLog(@"销毁了");
}

- (void)demo1
{
    LyHttpNetWorkTask *tool = [LyHttpNetWorkTask sharkNetWork];
    LyHttpNetWorkManager *manager = [LyHttpNetWorkManager sharkManager];
    
    LyNetSetting *setting = [[LyNetSetting alloc] init];
    setting.isCtrlHub = YES;
    setting.baseUrl = @"http://182.254.228.211:9000";
    
    manager.settingNetWork = setting;
    
    [manager post:@"/index.php/Api/Circle/getLabel" parameters:@{@"uid" : @"1"} success:^(id resquestData) {
        NSLog(@"success1   %@",resquestData);
    } failure:^(NSError *error) {
        NSLog(@"error1 %@",error);
    }];
    
    [manager post:@"/index.php/Api/Circle/messageList" parameters:@{@"uid" : @"1" , @"p" : @"1"} success:^(id resquestData) {
        NSLog(@"success2   %@",resquestData);
    } failure:^(NSError *error) {
        NSLog(@"error2 %@",error);
    }];
    
    LyUploadFile *file = [[LyUploadFile alloc] initWithUploadKey:@"img" fileName:@"iphone" fileType:LyUploadFileTypeJpg fileData:[UIImage imageNamed:@"1-1-登录.png"]];
    
    [manager uploadWithUrlString:@"/index.php/api/Auth/uploadImg" parameters:@{@"uid" : @"1"} file:file success:^(id responseData) {
        
        NSLog(@"success3 %@",responseData);
        
    } failure:^(NSError *error) {
        NSLog(@"error3   %@",error);
    } progress:^(float progress) {
        
    }];

//    [manager upLoad:@"http://182.254.228.211:9000/index.php/api/Auth/uploadImg" imageName:@"1-1-登录.png" parameters:@{@"uid" : @"1"} uploadKey:@"img" success:^(NSDictionary *dict) {
//        
//        dispatch_group_leave(dispatchGroup);
//        NSLog(@"success   1");
//        
//    } failure:^(NSError *error) {
//        
//        dispatch_group_leave(dispatchGroup);
//        NSLog(@"error   1");
//    }];
    
//    [manager cancelHttpRequestWithRequestMethod:@"POST" requestUrlString:@"http://182.254.228.211:9000/index.php/Api/Circle/messageList"];
    
//    [tool post:@"http://182.254.228.211:9000/index.php/Api/Circle/getLabel" parameters:@{@"uid" : @"1"} success:^(id resquestData) {
//        NSLog(@"success1   %@",resquestData);
//    } failure:^(NSError *error) {
//        NSLog(@"error1 %@",error);
//    }];
//    
//    [tool post:@"http://182.254.228.211:9000/index.php/Api/Circle/messageList" parameters:@{@"uid" : @"1" , @"p" : @"1"} success:^(id resquestData) {
//        NSLog(@"success2   %@",resquestData);
//    } failure:^(NSError *error) {
//        NSLog(@"error2 %@",error);
//    }];
//    
//    [tool cancelHttpRequestWithRequestMethod:@"POST" requestUrlString:@"/index.php/Api/Circle/messageList"];
    //    [tool cancelAllRequest];
}

@end
