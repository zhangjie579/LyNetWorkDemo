//
//  LyCacheSession.h
//  NetWorkDemo
//
//  Created by 张杰 on 2017/5/20.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LyCacheSession : NSObject

+ (instancetype)defaultSession;

/**
 创建表
 
 @param className 类名
 */
- (void)creatTableWithClassName:(NSString *)className;

#pragma mark - 增

- (void)insertWithModel:(id)model className:(NSString *)className;

- (void)insertWithArrayModel:(NSArray<id> *)arraymodel className:(NSString *)className;

#pragma mark - 删

- (void)deleteWithDict:(NSDictionary *)dict className:(NSString *)className;

#pragma mark - 改

/**
 更新数据
 
 @param className 类名
 @param dict 更新的数据
 @param dependDict 根据那些来更新数据 ，全部更新时候为nil
 */
- (void)updateWithClassName:(NSString *)className dict:(NSDictionary *)dict dependDict:(NSDictionary *)dependDict;

- (void)updateWithClassName:(NSString *)className model:(id)model dependDict:(NSDictionary *)dependDict;

#pragma mark - 查

- (NSArray<id> *)selectAllClassName:(NSString *)className;

/**
 根据查询
 
 @param className 类名
 @return dependDict 根据的数值
 @return modelArray 模型数组
 */
- (NSArray<id> *)selectWithClassName:(NSString *)className dependDict:(NSDictionary *)dependDict;

@end
