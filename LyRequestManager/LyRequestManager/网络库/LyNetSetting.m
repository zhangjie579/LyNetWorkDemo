//
//  LyNetSetting.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/18.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LyNetSetting.h"

@implementation LyNetSetting

- (instancetype)initWithCtrlHub:(BOOL)isCtrlHub isCache:(BOOL)isCache timeInterval:(NSTimeInterval)timeInterval cachePolicy:(LyCacheTime)cachePolicy isEncrypt:(BOOL)isEncrypt requestType:(LyRequestSerializerType)requestType responseType:(LyResponseSerializerType)responseType baseUrl:(NSString *)baseUrl
{
    if (self = [super init]) {
        self.isCache = isCache;
        self.isCtrlHub = isCtrlHub;
        self.cacheValidTimeInterval = timeInterval;
        self.cachePolicy = cachePolicy;
        self.isEncrypt = isEncrypt;
        self.requestType = requestType;
        self.responseType = responseType;
        self.baseUrl = baseUrl;
    }
    return self;
}

@end
