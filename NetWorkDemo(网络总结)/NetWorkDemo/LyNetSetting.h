//
//  LyNetSetting.h
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/18.
//  Copyright © 2017年 张杰. All rights reserved.
//  网络的一些设置

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, LyCacheTime) {
    
    LyCacheNoRead = 0,
    LyCacheNoSave = -1,
    LyCacheNormal = 5,
    LyCacheOneMinute = 1,
    LyCacheOneDay = 24 * 60,
};

@interface LyNetSetting : NSObject

//加载动画控制方式，yes表示由调用的控制器控制，NO表示有AFNetWork类控制
@property (nonatomic,assign) BOOL isCtrlHub;

//缓存的策略
@property (nonatomic,assign) LyCacheTime cachePolicy;

//是否加密
@property (nonatomic,assign) BOOL isEncrypt;

//baseUrl
@property(nonatomic,copy  )NSString *baseUrl;

@end
