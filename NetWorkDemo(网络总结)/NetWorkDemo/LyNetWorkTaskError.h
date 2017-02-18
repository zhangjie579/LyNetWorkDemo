//
//  LyNetWorkTaskError.h
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/18.
//  Copyright © 2017年 张杰. All rights reserved.
//

#ifndef LyNetWorkTaskError_h
#define LyNetWorkTaskError_h

typedef enum : NSUInteger {
    LyNetworkTaskErrorTimeOut = 101,
    LyNetworkTaskErrorCannotConnectedToInternet = 102,
    LyNetworkTaskErrorCanceled = 103,
    LyNetworkTaskErrorDefault = 104,
    LyNetworkTaskErrorNoData = 105,
    LyNetworkTaskErrorNoMoreData = 106,
    LyNetworkTaskErrorUnsupportedURL = 107
} LyNetworkTaskError;

static NSError *LyError(NSString *domain, int code) {
    return [NSError errorWithDomain:domain code:code userInfo:nil];
}

static NSString *const LyNoDataErrorNotice = @"这里什么也没有~";
static NSString *const LyNetworkErrorNotice = @"当前网络差, 请检查网络设置~";
static NSString *const LyTimeoutErrorNotice = @"请求超时了~";
static NSString *const LyDefaultErrorNotice = @"请求失败了~";
static NSString *const LyNoMoreDataErrorNotice = @"没有更多了~";
static NSString *const LyErrorUnsupportedURL = @"链接不支持";

#endif /* LyNetWorkTaskError_h */
