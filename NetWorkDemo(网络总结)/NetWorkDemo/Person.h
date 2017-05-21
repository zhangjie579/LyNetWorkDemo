//
//  Person.h
//  NetWorkDemo
//
//  Created by 张杰 on 2017/3/20.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Person : NSObject

@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *age;
//@property(nonatomic,copy)NSString *friends;
//@property(nonatomic,copy)NSString *girl;
//@property(nonatomic,copy)NSString *qq;

@property(nonatomic,assign)CGFloat haha;
@property(nonatomic,assign)double  key;

@property(nonatomic,strong)NSNumber *num;
@property(nonatomic,assign)NSInteger count;
@property(nonatomic,assign)int a;
//@property(nonatomic,strong)NSArray *ary;

@end
