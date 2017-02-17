//
//  NSString+Lybase64.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/13.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "NSString+Lybase64.h"

@implementation NSString (Lybase64)

/**
 加密Base64

 @param string 需要加密的字符串
 @return 加密后的字符串
 */
- (NSString *)addBase64:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}

/**
 解密Base64

 @param string 需要解密的字符串
 @return 解密后的字符串
 */
- (NSString *)removeBase64:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    // 解密 base64 数据
    NSData *baseData = [[NSData alloc] initWithBase64EncodedData:data options:0];
    
    return [[NSString alloc] initWithData:baseData encoding:NSUTF8StringEncoding];
}

@end
