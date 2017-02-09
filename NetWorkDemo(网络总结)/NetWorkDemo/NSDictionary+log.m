//
//  NSDictionary+log.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/9.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "NSDictionary+log.h"
#import <objc/message.h>

@implementation NSDictionary (log)

+ (void)load
{
    Method early = class_getInstanceMethod(self, @selector(description));
    Method now = class_getInstanceMethod(self, @selector(my_description));
    
    method_exchangeImplementations(early, now);
}

- (NSString*)my_description
{
    NSString *desc = [self my_description];
    desc = [NSString stringWithCString:[desc cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
    return desc;
}

//控制输出:对字典或者是数组进行排版
- (NSString *)descriptionWithLocale:(id)locale
{
    NSString *desc = [self description];
    return desc;
    
//    NSMutableString *string = [NSMutableString string];
//    //设置开始
//    [string appendString:@"{\n"];
//    //设置key-value
//    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        [string appendFormat:@"%@:",key];
//        [string appendFormat:@"%@,\n",obj];
//    }];
//    //设置结尾
//    [string appendString:@"}"];
//
//    //删除最后的逗号
//    NSRange range = [string rangeOfString:@"," options:NSBackwardsSearch];
//    if (range.location != NSNotFound) {
//        [string deleteCharactersInRange:range];
//    }
//    return string;
}

/*
-(NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    NSMutableString *string = [NSMutableString string];
    //设置开始
    [string appendString:@"{"];

    //设置key-value
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [string appendFormat:@"%@:",key];
        [string appendFormat:@"%@",obj];
    }];
    //设置结尾
    [string appendString:@"}"];
    return string;
}
*/

@end
