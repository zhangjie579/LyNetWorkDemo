//
//  CacheTool.m
//  028
//
//  Created by bona on 16/10/23.
//  Copyright © 2016年 bona. All rights reserved.
//

#import "CacheTool.h"
#import "FMDB.h"

@interface CacheTool ()

@property(nonatomic,strong)FMDatabaseQueue *queue;

@end

@implementation CacheTool

/**
 *  存储数据
 *
 *  @param name 表名
 *  @param keys 需要存储的key
 *  @param dict key的值
 */
- (void)insertDataWithSqliteName:(NSString *)name key:(NSArray *)keys dict:(NSDictionary *)dict
{
    //1.创表
    [self creatName:name key:keys];
    
    //2.存储
    [self.queue inDatabase:^(FMDatabase *db) {
       
        NSMutableString *string = [[NSMutableString alloc] init];
        NSMutableString *last = [[NSMutableString alloc] init];
        NSString *first = [NSString stringWithFormat:@"insert into t_%@ (",name];
        [string appendString:first];
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < keys.count; i++)
        {
            [array addObject:dict[keys[i]]];
            
            if (i == keys.count - 1)
            {
                [string appendString:[NSString stringWithFormat:@"%@ ) values (",keys[i]]];
                [last appendString:@"? );"];
            }
            else
            {
                [string appendString:[NSString stringWithFormat:@"%@ ,",keys[i]]];
                [last appendString:@"? ,"];
            }
        }
        [string appendString:last];
        
//        [db executeUpdate:@"insert into t_messageModel (id ,send_worker_id ,type ,comment ,create_time ,img ,content ,circle_id) values (? ,? ,? ,? ,? ,? ,? ,? );"];
        
        BOOL result = [db executeUpdate:string withArgumentsInArray:array];
        if (result) {
            NSLog(@"添加成功");
        }
        
    }];
    
    [self.queue close];
}

/**
 *  存储数据
 *
 *  @param name  表名
 *  @param keys  需要存储的key
 *  @param array 存储key的字典数组
 */
- (void)insertDataWithSqliteName:(NSString *)name key:(NSArray *)keys array:(NSArray *)array
{
    for (NSInteger i = 0; i < array.count; i++)
    {
        [self insertDataWithSqliteName:name key:keys dict:array[i]];
    }
}

/**
 *  查询所有数据
 *
 *  @param name 表名
 *  @param keys 需要查询的key
 *
 *  @return 查询的dict
 */
- (NSDictionary *)selectAllWithSqliteName:(NSString *)name key:(NSArray *)keys
{
    __block NSMutableDictionary *dictArray = nil;
    
    //1.创表
    [self creatName:name key:keys];
    
    //2.查询
    [self.queue inDatabase:^(FMDatabase *db) {
        
        dictArray = [[NSMutableDictionary alloc] init];
        
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from t_%@;",name]];
        
        while (rs.next)
        {
            for (NSInteger i = 0; i < keys.count; i++)
            {
                NSString *str = keys[i];
                NSString *value = [rs objectForColumnName:str];
                dictArray[str] = value;
            }
        }
        
    }];
    
    [self.queue close];
    return dictArray;
}

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
- (NSArray *)selectOnlyWithSqliteName:(NSString *)name keys:(NSArray *)keys key:(NSString *)key value:(NSString *)value
{
    __block NSMutableArray *dictArray = nil;
    
    //1.创表
    [self creatName:name key:keys];
    
    //2.查询
    [self.queue inDatabase:^(FMDatabase *db) {
        
        dictArray = [[NSMutableArray alloc] init];
        
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from t_%@ where %@ = %@;",name,key,value]];
        
        while (rs.next)
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            for (NSInteger i = 0; i < keys.count; i++)
            {
                NSString *str = keys[i];
                NSString *value = [rs objectForColumnName:str];
                dict[str] = value;
            }
            [dictArray addObject:dict];
        }
        
    }];
    
    [self.queue close];
    return dictArray;

}


/**
 *  查询所有数据
 *
 *  @param name 表名
 *  @param keys 需要查询的key
 *
 *  @return 查询的字典数组
 */
- (NSArray *)selectAllArrayWithSqliteName:(NSString *)name key:(NSArray *)keys
{
    __block NSMutableArray *dictArray = nil;
    
    //1.创表
    [self creatName:name key:keys];
    
    //2.查询
    [self.queue inDatabase:^(FMDatabase *db) {
        
        dictArray = [[NSMutableArray alloc] init];
        
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from t_%@;",name]];
        
        while (rs.next)
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            for (NSInteger i = 0; i < keys.count; i++)
            {
                NSString *str = keys[i];
                NSString *value = [rs objectForColumnName:str];
                dict[str] = value;
            }
            [dictArray addObject:dict];
        }
        
    }];
    
    [self.queue close];
    return dictArray;
}

/**
 *  删除整张表
 *
 *  @param name 表名
 */
- (void)deleteSqliteName:(NSString *)name
{
    [self.queue inDatabase:^(FMDatabase *db) {
        
        //删除整张表
        [db executeUpdate:[NSString stringWithFormat:@"drop table if exists t_%@",name]];
        
    }];
    
    [self.queue close];
}

/**
 *  删除特定数据
 *
 *  @param name  表名
 *  @param key   根据哪个key删除
 *  @param value key的值
 */
- (void)deleteDataSqliteName:(NSString *)name key:(NSString *)key value:(NSString *)value
{
    [self.queue inDatabase:^(FMDatabase *db) {
        
        //删除特定的数据
        NSString *sql = [NSString stringWithFormat:@"delete from t_%@ where %@ = %@;",name,key,value];
        BOOL result = [db executeUpdate:sql];
        if (result) {
            NSLog(@"删除成功");
        }
        
    }];
    
    [self.queue close];
}

- (void)updateDataSqliteName:(NSString *)name keys:(NSArray *)keys key:(NSString *)key value:(NSString *)value
{
    //1.创表
    [self creatName:name key:keys];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"update t_%@ set %@ = %@;",name,key,value];
        [db executeUpdate:sql];
        
    }];
    
    [self.queue close];
}


/**
 *  创表
 *
 *  @param name 表名
 *  @param keys 需要存储的key
 */
- (void)creatName:(NSString *)name key:(NSArray *)keys
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",name]];
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:path];
    
    self.queue = queue;
    
    [queue inDatabase:^(FMDatabase *db) {
        
        NSMutableString *string = [[NSMutableString alloc] init];
        NSString *first = [NSString stringWithFormat:@"create table if not exists t_%@ (aid integer primary key autoincrement",name];
        [string appendString:first];
        for (NSInteger i = 0; i < keys.count; i++)
        {
            NSString *key = keys[i];
            
            if (i == keys.count - 1)
            {
                [string appendString:[NSString stringWithFormat:@", %@ text);",key]];
            }
            else
            {
                [string appendString:[NSString stringWithFormat:@", %@ text",key]];
            }
        }
        
        BOOL result = [db executeUpdate:string];
        
        if (result) {
            NSLog(@"创表成功");
        } else {
            NSLog(@"创表失败");
        }
        
    }];
    
    [self.queue close];
}

@end
