//
//  NSArray+log.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/9.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "NSArray+log.h"
#import <objc/message.h>

@implementation NSArray (log)

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
-(NSString *)descriptionWithLocale:(id)locale
{
    return [self description];
    
//    NSMutableString *string = [NSMutableString string];
//    //设置开始
//    [string appendString:@"["];
//
//    //设置key-value
//    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [string appendFormat:@"%@,",obj];
//    }];
//    //设置结尾
//    [string appendString:@"]"];
//
//    NSRange range = [string rangeOfString:@"," options:NSBackwardsSearch];
//    if (range.location != NSNotFound) {
//        [string deleteCharactersInRange:range];
//    }
//  
//    return string;
}

@end
