//
//  LyHttpNetWorkTaskGroup.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/18.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LyHttpNetWorkTaskGroup.h"
#import "LyHttpNetWork.h"

@implementation LyHttpNetWorkTaskGroup

+ (instancetype)shareGroup
{
    static LyHttpNetWorkTaskGroup *group = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        group = [[self alloc] init];
    });
    return group;
}

- (instancetype)init
{
    if (self = [super init]) {
//        LyHttpNetWork *manager = [LyHttpNetWork sharkNetWork];
        
    }
    return self;
}
//
//- (void)post:(NSArray *)urlArray token:(NSArray *)tokenArray parameters:(NSArray<NSDictionary *> *)parameters success:(void (^)(NSArray<id > *resquestData))success failure:(void (^)(NSArray<NSError *> *error))failure
//{
//    LyHttpNetWork *manager = [LyHttpNetWork sharkNetWork];
//    
//    NSMutableArray *requestArray = [[NSMutableArray alloc] init];
//    NSMutableArray *errorArray = [[NSMutableArray alloc] init];
//    
//    for (NSInteger i = 0 ; i < urlArray.count; i++) {
//        [requestArray addObject:@""];
//        [errorArray addObject:@""];
//    }
//    
//    for (NSInteger i = 0 ; i < urlArray.count; i++)
//    {
//        [manager post:urlArray[i] token:tokenArray[i] parameters:parameters[i] success:^(id resquestData) {
//            requestArray[i] = resquestData;
//        } failure:^(NSError *error) {
//            
//        }];
//    }
//}

@end
