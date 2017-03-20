//
//  LyCacheManager.h
//  NetWorkDemo
//
//  Created by 张杰 on 2017/3/20.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LyCacheManager : NSObject

/**
 *  创表
 *
 *  @param name 表名
 *  @param keys 需要存储的key
 */
- (instancetype)initWithTable:(NSString *)name keys:(NSArray<NSString *> *)keys;

/**
 根据类名创建表,类名也为表名t_className，存储类中所有的key
 
 @param className 类名
 */
- (void)creatTableWithClassName:(NSString *)className;

/**
 *  创表
 *
 *  @param name 表名
 *  @param keys 需要存储的key
 */
- (void)creatName:(NSString *)name key:(NSArray *)keys;

#pragma mark - 增
/**
 *  存储数据
 *
 *  @param name 表名
 *  @param dict key的值
 */
- (void)insertDataWithSqliteName:(NSString *)name dict:(NSDictionary *)dict;

/**
 *  存储数据
 *
 *  @param name  表名
 *  @param array 存储key的字典数组
 */
- (void)insertDataWithSqliteName:(NSString *)name array:(NSArray<NSDictionary *> *)array;

/**
 添加数据
 
 @param className 类名
 @param model 模型数据
 */
- (void)insertWithClassName:(NSString *)className model:(id)model;

#pragma mark - 删
/**
 *  删除整张表
 *
 *  @param name 表名
 */
- (void)deleteSqliteName:(NSString *)name;

/**
 *  删除特定数据
 *
 *  @param name  表名
 *  @param dict  根据哪个值删除
 */
- (void)deleteDataSqliteName:(NSString *)name dict:(NSDictionary *)dict;

#pragma mark - 改

/**
 更新数据
 
 @param name 表名
 @param dict 需要更新的数据
 */
- (void)updateDataSqliteName:(NSString *)name dict:(NSDictionary *)dict;

/**
 更新数据
 
 @param name 表名
 @param dict 需要更新的数据
 @param dependDict 根据哪里数据来改
 */
- (void)updateWithName:(NSString *)name dict:(NSDictionary *)dict dependDict:(NSDictionary *)dependDict;

#pragma mark - 查
/**
 *  查询所有数据
 *
 *  @param name 表名
 *  @param keys 需要查询的key
 *
 *  @return 查询的dict
 */
- (NSDictionary *)selectAllWithSqliteName:(NSString *)name key:(NSArray<NSString *> *)keys;

/**
 *  查询所有数据
 *
 *  @param name 表名
 *  @param keys 需要查询的key
 *
 *  @return 查询的字典数组
 */
- (NSArray *)selectAllArrayWithSqliteName:(NSString *)name key:(NSArray<NSString *> *)keys;

/**
 *  查询特定数据
 *
 *  @param name  表名
 *  @param keys  需要查询的key
 *  @param dict  根据哪个特定的值
 *
 *  @return 查询特定数据的字典数组
 */
- (NSArray<NSDictionary *> *)selectOnlyWithSqliteName:(NSString *)name dict:(NSDictionary *)dict keys:(NSArray<NSString *> *)keys;


/**
 查询数据

 @param className 类名
 @return model
 */
- (id)selectWithClassName:(NSString *)className;

/**
 查询所有数据
 
 @param className 类名
 @return modelArray模型数组
 */
- (NSArray<id> *)selectAllWithClassName:(NSString *)className;

/**
 根据查询
 
 @param className 类名
 @return dependDict 根据的数值
 @return modelArray 模型数组
 */
- (NSArray<id> *)selectAllWithClassName:(NSString *)className dependDict:(NSDictionary *)dependDict;
@end
