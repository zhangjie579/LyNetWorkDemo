//
//  LyNetWorkReachTool.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/18.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LyNetWorkReachTool.h"
#import "AFNetworking.h"

@implementation LyNetWorkReachTool

+ (instancetype)sharedInstance {
    
    static LyNetWorkReachTool *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:NULL] init];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    });
    return sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

//判断网络的状态
- (void)judgeNetWorkStatus:(void(^)(LyNetWorkStatus status))finish
{
    /**
     AFNetworkReachabilityStatusUnknown          = -1,  // 未知
     AFNetworkReachabilityStatusNotReachable     = 0,   // 无连接
     AFNetworkReachabilityStatusReachableViaWWAN = 1,   // 3G 花钱
     AFNetworkReachabilityStatusReachableViaWiFi = 2,   // 局域网络,不花钱
     */
//    // 如果要检测网络状态的变化,必须用检测管理器的单例的startMonitoring
//    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    // 检测网络连接的单例,网络变化时的回调方法
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown: {// 未知
                finish(LyNetWorkStatusUnknown);
                return;
            }
            case AFNetworkReachabilityStatusNotReachable: {// 无连接
                finish(LyNetWorkStatusNotReachable);
                return;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN: {// 3G 花钱
                finish(LyNetWorkStatusViaWWAN);
                return;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi: {// 局域网络,不花钱
                finish(LyNetWorkStatusWIFI);
                return;
            }
        }
    }];
}

//判断网络是否连接
- (BOOL)isReachable {
    return [AFNetworkReachabilityManager sharedManager].isReachable;
}


@end
