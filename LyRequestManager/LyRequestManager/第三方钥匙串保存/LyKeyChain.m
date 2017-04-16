//
//  LyKeyChain.m
//  LyRequestManager
//
//  Created by 张杰 on 2017/4/14.
//  Copyright © 2017年 张杰. All rights reserved.
//  第三方钥匙串，保存敏感数据

#import "LyKeyChain.h"
#import "JNKeychain.h"

@implementation LyKeyChain

+ (BOOL)ly_saveValue:(NSString *)value forKey:(NSString *)key
{
    NSString *bundleID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    BOOL i = [JNKeychain saveValue:value forKey:key forAccessGroup:bundleID];
    return i;
}

+ (id)ly_getValueForKey:(NSString *)key
{
    NSString *bundleID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    id a = [JNKeychain loadValueForKey:key forAccessGroup:bundleID];
    return a;
}

+ (BOOL)ly_deleteValueForKey:(NSString *)key
{
//    [JNKeychain getBundleSeedIdentifier]
    NSString *bundleID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    BOOL i = [JNKeychain deleteValueForKey:key forAccessGroup:bundleID];
    return i;
}

@end
