//
//  LyNetworkCacheManager.h
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/19.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LyNetworkCache : NSObject

+ (instancetype)cacheWithData:(id)data;
+ (instancetype)cacheWithData:(id)data validTimeInterval:(NSUInteger)interterval;

- (id)data;
- (BOOL)isValid;

@end

@interface LyNetworkCacheManager : NSObject

+ (instancetype)sharedManager;

- (void)removeObejectForKey:(id)key;
- (void)setObjcet:(LyNetworkCache *)object forKey:(id)key;
- (LyNetworkCache *)objcetForKey:(id)key;

@end
