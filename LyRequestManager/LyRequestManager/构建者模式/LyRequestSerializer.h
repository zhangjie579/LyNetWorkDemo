//
//  LyRequestSerializer.h
//  LyRequestManager
//
//  Created by 张杰 on 2017/6/21.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LyURLRequestManager.h"

@interface LyRequestSerializer : NSObject

+ (instancetype)shareManager;

- (void)request:(LyURLRequestManager *)urlRequest success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure;

@end
