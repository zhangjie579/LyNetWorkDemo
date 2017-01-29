//
//  CourseAddCommentApi.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/1/20.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "CourseAddCommentApi.h"

@implementation CourseAddCommentApi

{
    NSString  *_vid;
    NSString  *_content;
}

- (instancetype)initWithVid:(NSString *)vid content:(NSString *)content;
{
    if (self = [super init]) {
        _vid = vid;
        _content = content;
    }
    return self;
}
- (NSString *)requestUrl {
    return @"/video/comment/add";
}

-(YTKRequestMethod)requestMethod
{
    return YTKRequestMethodPOST;
}

#pragma mark 有头文件heard的，设置这个方法
-(NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary
{
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserInfo_token"];
    if ([self isBlankString:token])
    {
        token = @"";
    }
    
    return @{@"token" : token};
}

- (id)requestArgument {
    return @{ @"vid": _vid,
              @"content":_content
              };
}

//判断某字符串是否为空
- (BOOL) isBlankString:(NSString *)string {
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
