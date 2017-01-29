//
//  StatusModel.h
//  028
//
//  Created by bona on 16/10/20.
//  Copyright © 2016年 bona. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StatusModel : NSObject

@property (nonatomic,assign) NSInteger id;
@property (nonatomic,copy  ) NSString  *phone;
@property (nonatomic,copy  ) NSString  *qq;
@property (nonatomic,copy  ) NSString  *service_time;
@property (nonatomic,copy  ) NSString  *weixin;

@end
