//
//  LyJsonTool.h
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/9.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LyJsonTool : NSObject

/**
 转为json字符串

 @param object dict，array
 @return json字符串
 */
+ (NSString *)jsonWithObject:(id)object;

/**
 转为dict

 @param str json字符串
 @return dict
 */
+ (NSDictionary *)dictWithJson:(NSString *)str;

@end
