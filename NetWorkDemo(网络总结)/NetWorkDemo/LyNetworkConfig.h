//
//  HHNetworkConfig.h
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/18.
//  Copyright © 2017年 张杰. All rights reserved.
//

#ifndef LyNetworkConfig_h
#define LyNetworkConfig_h

//请求方式
typedef enum {
    LyHttpNetWorkTaskMethodGet,
    LyHttpNetWorkTaskMethodPost
}LyHttpNetWorkTaskMethod;

//网络的状态，3G,WIFI...
typedef enum {
    LyNetWorkStatusUnknown, //未知
    LyNetWorkStatusNotReachable, //未连接
    LyNetWorkStatusWIFI, //wifi
    LyNetWorkStatusViaWWAN, //3G
}LyNetWorkStatus;

#endif /* LyNetworkConfig_h */


/*
 
 1.一个error错误类处理//LyNetWorkTaskError
 2.一些枚举//LyNetworkConfig
 3.一个网络设置的类（弹框，baseUrl，加密....）//LyNetSetting
 4.一个上传文件的处理类//LyUploadFile
 5.判断网络状态的类//LyNetWorkReachTool
 6.缓存处理的类//LyNetworkCacheManager
 7.创建网络请求NSMutableURLRequest的类//LyURLRequestManager
 8.请求网络的类，最底层封装//LyHttpNetWorkTask
 9.处理网络请求的类，供外部调用，做了些处理//LyHttpNetWorkManager
 10.处理多个网络请求的类//LyHttpNetWorkTaskGroup

*/
