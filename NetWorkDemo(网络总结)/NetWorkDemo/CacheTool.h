//
//  CacheTool.h
//  028
//
//  Created by bona on 16/10/23.
//  Copyright © 2016年 bona. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheTool : NSObject

/**
 *  存储数据
 *
 *  @param name 表名
 *  @param keys 需要存储的key
 *  @param dict key的值
 */
- (void)insertDataWithSqliteName:(NSString *)name key:(NSArray *)keys dict:(NSDictionary *)dict;

/**
 *  存储数据
 *
 *  @param name  表名
 *  @param keys  需要存储的key
 *  @param array 存储key的字典数组
 */
- (void)insertDataWithSqliteName:(NSString *)name key:(NSArray *)keys array:(NSArray *)array;

/**
 *  查询所有数据
 *
 *  @param name 表名
 *  @param keys 需要查询的key
 *
 *  @return 查询的dict
 */
- (NSDictionary *)selectAllWithSqliteName:(NSString *)name key:(NSArray *)keys;

/**
 *  查询所有数据
 *
 *  @param name 表名
 *  @param keys 需要查询的key
 *
 *  @return 查询的字典数组
 */
- (NSArray *)selectAllArrayWithSqliteName:(NSString *)name key:(NSArray *)keys;

/**
 *  查询特定数据
 *
 *  @param name  表名
 *  @param keys  需要查询的key
 *  @param key   根据哪个特定的key
 *  @param value key的值
 *
 *  @return 查询特定数据的字典数组
 */
- (NSArray *)selectOnlyWithSqliteName:(NSString *)name keys:(NSArray *)keys key:(NSString *)key value:(NSString *)value;

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
 *  @param key   根据哪个key删除
 *  @param value key的值
 */
- (void)deleteDataSqliteName:(NSString *)name key:(NSString *)key value:(NSString *)value;


- (void)updateDataSqliteName:(NSString *)name keys:(NSArray *)keys key:(NSString *)key value:(NSString *)value;

@end
