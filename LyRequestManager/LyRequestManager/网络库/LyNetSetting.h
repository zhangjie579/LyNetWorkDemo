//
//  LyNetSetting.h
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/18.
//  Copyright © 2017年 张杰. All rights reserved.
//  网络的一些设置

#import <Foundation/Foundation.h>
#import "LyNetworkConfig.h"

typedef NS_ENUM(int, LyCacheTime) {
    
    LyCacheNoRead = 0,
    LyCacheNoSave = -1,
    LyCacheNormal = 5,
    LyCacheOneMinute = 1,
    LyCacheOneDay = 24 * 60,
};

@interface LyNetSetting : NSObject

- (instancetype)initWithCtrlHub:(BOOL)isCtrlHub isCache:(BOOL)isCache timeInterval:(NSTimeInterval)timeInterval cachePolicy:(LyCacheTime)cachePolicy isEncrypt:(BOOL)isEncrypt requestType:(LyRequestSerializerType)requestType responseType:(LyResponseSerializerType)responseType baseUrl:(NSString *)baseUrl;

//加载动画控制方式，NO表示由调用的控制器控制，yes表示有AFNetWork类控制
@property (nonatomic,assign) BOOL isCtrlHub;

//是否缓存
@property (nonatomic,assign) BOOL isCache;

//缓存时长
@property (nonatomic,assign) NSTimeInterval cacheValidTimeInterval;

//缓存的策略
@property (nonatomic,assign) LyCacheTime cachePolicy;

//是否加密
@property (nonatomic,assign) BOOL isEncrypt;

@property (nonatomic,copy  ) NSString *baseUrl;

////请求数据的类型
@property (nonatomic,assign)LyRequestSerializerType requestType;

//响应数据的类型
@property (nonatomic,assign)LyResponseSerializerType responseType;

@end
