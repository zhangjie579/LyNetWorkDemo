//
//  LyJsonTool.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/9.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LyJsonTool.h"

@implementation LyJsonTool

/**
 转为json字符串
 
 @param object dict，array
 @return json字符串
 */
+ (NSString *)jsonWithObject:(id)object
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

/**
 转为dict
 
 @param str json字符串
 @return dict
 */
+ (NSDictionary *)dictWithJson:(NSString *)str
{
    NSDictionary *resultDic = nil;
    if (![self isBlankString:str]) {
        NSString *requestTmp = [NSString stringWithString:str];
        NSData *resData = [[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        resultDic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
    }
    return resultDic;
}

//判断某字符串是否为空
+ (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

@end
