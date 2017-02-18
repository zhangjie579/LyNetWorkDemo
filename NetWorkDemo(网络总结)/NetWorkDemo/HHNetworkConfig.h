//
//  HHNetworkConfig.h
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/18.
//  Copyright © 2017年 张杰. All rights reserved.
//

#ifndef HHNetworkConfig_h
#define HHNetworkConfig_h

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

#endif /* HHNetworkConfig_h */
