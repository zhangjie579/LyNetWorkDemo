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
#import "LyHttpNetWork.h"
#import "LyNetSetting.h"
#import "ZJViewController.h"
#import "DemoViewController.h"

@interface ViewController ()

@property(nonatomic,strong)UIButton *btn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self test3];
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.btn];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    ZJViewController *vc = [[ZJViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)AFNRequest
{
    LyNetSetting *netSetting = [[LyNetSetting alloc] init];
    netSetting.isCtrlHub = YES;
    netSetting.cachePolicy = LyCacheNormal;
    netSetting.isEncrypt = NO;
    netSetting.baseUrl = @"http://182.254.228.211:9000";
    LyHttpNetWork *tool = [LyHttpNetWork sharkNetWorkWithNetSetting:netSetting];
    
    [tool post:@"/index.php/Api/Circle/getLabel" token:nil parameters:@{@"uid" : @"1"} success:^(id resquestData) {
        
        NSLog(@"success1   %@",resquestData);
        
    } failure:^(NSError *error) {
        NSLog(@"error1 %@",error);
    }];
    
    [tool post:@"http://182.254.228.211:9000/index.php/Api/Circle/messageList" parameters:@{@"uid" : @"1" , @"p" : @"1"} success:^(id resquestData) {
        NSLog(@"success2   %@",resquestData);
    } failure:^(NSError *error) {
        NSLog(@"error2 %@",error);
    }];
    
    [tool cancelHttpRequestWithRequestType:@"POST" requestUrlString:@"http://182.254.228.211:9000/index.php/Api/Circle/messageList"];
//    [tool cancelAllRequest];
}

//多个请求的正确操作，注意：不过前面请求不是顺序的
- (void)postMoreRequest
{
//    dispatch_group_t group = dispatch_group_create();
//    dispatch_group_enter(group);
//    //请求1
//    [
//     dispatch_group_leave(group);
//    ];
//    
//    //请求2
//    [
//     dispatch_group_leave(group);
//     ];
//    
//    //请求3
//    [
//     dispatch_group_leave(group);
//     ];
//    
//    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//        
//    });
    
    
    
    LYURLSession *manager = [LYURLSession shareTool];
    
    dispatch_group_t dispatchGroup = dispatch_group_create();
    dispatch_group_enter(dispatchGroup);
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        [manager upLoad:@"http://182.254.228.211:9000/index.php/api/Auth/uploadImg" imageName:@"1-1-登录.png" parameters:@{@"uid" : @"1"} uploadKey:@"img" success:^(NSDictionary *dict) {
            
            dispatch_group_leave(dispatchGroup);
            NSLog(@"success   1");
            
        } failure:^(NSError *error) {
            
            dispatch_group_leave(dispatchGroup);
            NSLog(@"error   1");
        }];
    });
    dispatch_group_enter(dispatchGroup);
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        [manager post:@"http://182.254.228.211:9000/index.php/Api/Circle/index" parameters:@{@"uid" : @"1" , @"p" : @"1"} success:^(NSDictionary *dict) {
            
            dispatch_group_leave(dispatchGroup);
            NSLog(@"success   2");
            
        } failure:^(NSError *error) {
            
            dispatch_group_leave(dispatchGroup);
            NSLog(@"error   2");
        }];

    });
    dispatch_group_enter(dispatchGroup);
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        [manager post:@"http://zzy.bolemayy.com/video/index/index" token:@"8.1489715482.60595.efb58eae7707180960c2db861fa36908" parameters:@{@"p" : @"1"} success:^(NSDictionary *dict) {
            
            dispatch_group_leave(dispatchGroup);
            NSLog(@"success   3");
            
        } failure:^(NSError *error) {
            
            dispatch_group_leave(dispatchGroup);
            NSLog(@"error   3");
            
        }];
    });
    
    dispatch_group_enter(dispatchGroup);
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        [manager upLoad:@"http://zzy.bolemayy.com/user/index/upload-img" imageName:@"1-1-登录.png" token:@"8.1489715482.60595.efb58eae7707180960c2db861fa36908" uploadKey:@"img" success:^(NSDictionary *dict) {
            //        NSLog(@"success   %@",dict);
            dispatch_group_leave(dispatchGroup);
            NSLog(@"success   4");
            
        } failure:^(NSError *error) {
            //        NSLog(@"error  %@",error);
            
            dispatch_group_leave(dispatchGroup);
            NSLog(@"error   4");
            
        }];
    });
    
    //当队列dispatch_queue_t queue上的所有任务执行完毕时会执行dispatch_group_notify里的dispatch_block_t block的代码
    
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{
        NSLog(@"任务完成,主线刷新UI");
    });
    
//    dispatch_group_notify(dispatchGroup, dispatch_get_global_queue(0, 0), ^{
//        NSLog(@"任务完成,主线刷新UI");
//    });

    NSLog(@"主线5");
}

- (void)testMore
{
    // 创建组
    dispatch_group_t group = dispatch_group_create();
    LYURLSession *manager = [LYURLSession shareTool];
    
    dispatch_group_async(group, dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        
        // 创建信号量
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        [manager upLoad:@"http://182.254.228.211:9000/index.php/api/Auth/uploadImg" imageName:@"1-1-登录.png" parameters:@{@"uid" : @"1"} uploadKey:@"img" success:^(NSDictionary *dict) {
            
            dispatch_semaphore_signal(semaphore);
            NSLog(@"success   1");
            
        } failure:^(NSError *error) {
            
            dispatch_semaphore_signal(semaphore);
            NSLog(@"error   1");
        }];
        
        // 在网络请求任务成功之前，信号量等待中
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        
        // 创建信号量
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        [manager upLoad:@"http://182.254.228.211:9000/index.php/api/Auth/uploadImg" imageName:@"1-1-登录.png" parameters:@{@"uid" : @"1"} uploadKey:@"img" success:^(NSDictionary *dict) {
            
            dispatch_semaphore_signal(semaphore);
            NSLog(@"success   2");
            
        } failure:^(NSError *error) {
            
            dispatch_semaphore_signal(semaphore);
            NSLog(@"error   2");
        }];
        
        // 在网络请求任务成功之前，信号量等待中
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        
        // 创建信号量
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        [manager upLoad:@"http://182.254.228.211:9000/index.php/api/Auth/uploadImg" imageName:@"1-1-登录.png" parameters:@{@"uid" : @"1"} uploadKey:@"img" success:^(NSDictionary *dict) {
            
            dispatch_semaphore_signal(semaphore);
            NSLog(@"success   3");
            
        } failure:^(NSError *error) {
            
            dispatch_semaphore_signal(semaphore);
            NSLog(@"error   3");
        }];
        
        // 在网络请求任务成功之前，信号量等待中
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"完成了网络请求，不管网络请求失败了还是成功了。");
    });
}

- (void)groupSync
{
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(5);
        NSLog(@"任务一完成");
        dispatch_group_leave(group);
    });
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(8);
        NSLog(@"任务二完成");
        dispatch_group_leave(group);
    });
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"任务完成");
    });
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

- (void)btnClick
{
    [self.navigationController pushViewController:[[DemoViewController alloc] init] animated:YES];
}

- (UIButton *)btn
{
    if (!_btn) {
        _btn = [[UIButton alloc] init];
        _btn.backgroundColor = [UIColor greenColor];
        [_btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
        _btn.frame = CGRectMake(100, 100, 100, 100);
    }
    return _btn;
}

@end
