//
//  LyNetWorkReachTool.h
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/18.
//  Copyright © 2017年 张杰. All rights reserved.
//  判断网络的状态

#import <Foundation/Foundation.h>
#import "HHNetworkConfig.h"

@interface LyNetWorkReachTool : NSObject

+ (instancetype)sharedInstance;

//判断网络是否连接
- (BOOL)isReachable;

//判断网络的状态
- (void)judgeNetWorkStatus:(void(^)(LyNetWorkStatus status))finish;

@end
