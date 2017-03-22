//
//  LyNetworkCacheManager.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/19.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LyNetworkCacheManager.h"

@interface LyNetworkCache ()

@property (strong, nonatomic) id data;//缓存的数据
@property (assign, nonatomic) NSUInteger cacheTime;//何时缓存的
@property (assign, nonatomic) NSUInteger validTimeInterval;//缓存有效时长

@end

//默认缓存有效时长
#define ValidTimeInterval 60
@implementation LyNetworkCache

+ (instancetype)cacheWithData:(id)data
{
    return [self cacheWithData:data validTimeInterval:ValidTimeInterval];
}

+ (instancetype)cacheWithData:(id)data validTimeInterval:(NSUInteger)interterval
{
    LyNetworkCache *cache = [[LyNetworkCache alloc] init];
    cache.data = data;
    cache.cacheTime = [[NSDate date] timeIntervalSince1970];
    cache.validTimeInterval = interterval > 0 ? interterval : ValidTimeInterval;
    return cache;
}

//缓存是否存在
- (BOOL)isValid
{
    if (self.data) {
        return [[NSDate date] timeIntervalSince1970] - self.cacheTime < self.validTimeInterval;
    }
    return NO;
}

@end

#pragma mark - LyNetworkCacheManager
@interface LyNetworkCacheManager ()

@property (strong, nonatomic) NSCache *cache;

@end

@implementation LyNetworkCacheManager

+ (instancetype)sharedManager {
    static LyNetworkCacheManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedManager = [[super allocWithZone:NULL] init];
        [sharedManager configuration];
    });
    return sharedManager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedManager];
}

- (void)configuration {
    
    self.cache = [NSCache new];
    self.cache.totalCostLimit = 1024 * 1024 * 20;
}

- (void)dealloc
{
    [self.cache removeAllObjects];
}

- (void)removeObejectForKey:(id)key
{
    [self.cache removeObjectForKey:key];
}

- (void)setObjcet:(LyNetworkCache *)object forKey:(id)key
{
    [self.cache setObject:object forKey:key];
}

- (LyNetworkCache *)objcetForKey:(id)key
{
    return [self.cache objectForKey:key];
}

@end
