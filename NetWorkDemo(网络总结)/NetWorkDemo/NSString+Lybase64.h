//
//  NSString+Lybase64.h
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/13.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Lybase64)

/**
 加密Base64
 
 @param string 需要加密的字符串
 @return 加密后的字符串
 */
- (NSString *)addBase64:(NSString *)string;

/**
 解密Base64
 
 @param string 需要解密的字符串
 @return 解密后的字符串
 */
- (NSString *)removeBase64:(NSString *)string;

@end
