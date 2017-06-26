//
//  TestProtocolViewController.m
//  LyRequestManager
//
//  Created by 张杰 on 2017/6/21.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "TestProtocolViewController.h"
#import "LyURLRequestManager.h"
#import "LyRequestSerializer.h"

@interface TestProtocolViewController ()

@property(nonatomic,strong)LyRequestSerializer          *requestSerializer;

@end

@implementation TestProtocolViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    [self demoWithTwo];
}

- (void)demoWithTwo
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        LyURLRequestManager *urlRequest = [LyURLRequestManager shareManager];
        urlRequest.method(@"post").url(@"/index.php/Api/Worker/getUntreatedJob").param(@{@"uid" : @"1"});
        
        [self.requestSerializer request:urlRequest success:^(id responseObject) {
            dispatch_group_leave(group);
            NSLog(@"1\n%@",responseObject);
        } failure:^(NSError *error) {
            dispatch_group_leave(group);
        }];
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        LyURLRequestManager *urlRequest = [LyURLRequestManager shareManager];
        urlRequest.method(@"post").url(@"/index.php/Api/Circle/index").param(@{@"uid" : @"1"});
        
        [self.requestSerializer request:urlRequest success:^(id responseObject) {
            dispatch_group_leave(group);
            NSLog(@"2\n%@",responseObject);
        } failure:^(NSError *error) {
            dispatch_group_leave(group);
        }];
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        LyURLRequestManager *urlRequest = [LyURLRequestManager shareManager];
        urlRequest.method(@"post").url(@"/index.php/Api/ServiceContact/index").param(@{@"uid" : @"1"});;
        
        [self.requestSerializer request:urlRequest success:^(id responseObject) {
            dispatch_group_leave(group);
            NSLog(@"3\n%@",responseObject);
        } failure:^(NSError *error) {
            dispatch_group_leave(group);
        }];
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"刷新数据");
    });
}

- (LyRequestSerializer *)requestSerializer
{
    if (!_requestSerializer) {
        _requestSerializer = [LyRequestSerializer shareManager];
    }
    return _requestSerializer;
}

@end
