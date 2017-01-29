//
//  CourseAddCommentApi.h
//  NetWorkDemo
//
//  Created by 张杰 on 2017/1/20.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import <YTKNetwork/YTKNetwork.h>

@interface CourseAddCommentApi : YTKRequest

- (instancetype)initWithVid:(NSString *)vid content:(NSString *)content;

@end
