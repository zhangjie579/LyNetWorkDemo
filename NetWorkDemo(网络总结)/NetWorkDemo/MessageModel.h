//
//  MessageModel.h
//  028
//
//  Created by bona on 16/10/20.
//  Copyright © 2016年 bona. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageModel : NSObject

@property (nonatomic,copy  ) NSString *id;
@property (nonatomic,copy  ) NSString *send_worker_id;
@property (nonatomic,copy  ) NSString *type;
@property (nonatomic,copy  ) NSString *comment;
@property (nonatomic,copy  ) NSString *create_time;
@property (nonatomic,strong) NSArray  *img;
@property (nonatomic,copy  ) NSString *content;
@property (nonatomic,copy  ) NSString *circle_id;

@end
