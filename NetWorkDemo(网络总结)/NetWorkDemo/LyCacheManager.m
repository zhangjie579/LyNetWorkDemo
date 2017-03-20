//
//  LyCacheManager.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/3/20.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LyCacheManager.h"
#import "FMDB.h"
#import <objc/message.h>

@interface LyCacheManager ()

@property(nonatomic,strong)FMDatabaseQueue *queue;

@end

@implementation LyCacheManager

- (instancetype)initWithTable:(NSString *)name keys:(NSArray<NSString *> *)keys
{
    if (self = [super init]) {
        [self creatName:name key:keys];
    }
    return self;
}

/**
 *  存储数据
 *
 *  @param name  表名
 *  @param array 存储key的字典数组
 */
- (void)insertDataWithSqliteName:(NSString *)name array:(NSArray<NSDictionary *> *)array
{
    for (NSInteger i = 0; i < array.count; i++)
    {
        [self insertDataWithSqliteName:name dict:array[i]];
    }
}

/**
 *  存储数据
 *
 *  @param name 表名
 *  @param dict key的值
 */
- (void)insertDataWithSqliteName:(NSString *)name dict:(NSDictionary *)dict
{
//        [db executeUpdate:@"insert into t_messageModel (id ,send_worker_id ,type ,comment ,create_time ,img ,content ,circle_id) values (? ,? ,? ,? ,? ,? ,? ,? );"];
    //存储
    [self.queue inDatabase:^(FMDatabase *db) {
        
        NSMutableString *string = [[NSMutableString alloc] init];
        NSMutableString *last = [[NSMutableString alloc] init];
        NSString *first = [NSString stringWithFormat:@"insert into t_%@ (",name];
        [string appendString:first];
        NSMutableArray *array_value = [[NSMutableArray alloc] init];
        
        for (NSString *key in dict.keyEnumerator)
        {
            [array_value addObject:dict[key]];
            if (array_value.count == dict.allKeys.count)//最后一个
            {
                [string appendString:[NSString stringWithFormat:@"%@ ) values (",key]];
                [last appendString:@"? );"];
            }
            else
            {
                [string appendString:[NSString stringWithFormat:@"%@ ,",key]];
                [last appendString:@"? ,"];
            }
        }

        [string appendString:last];
        
        BOOL result = [db executeUpdate:string withArgumentsInArray:array_value];
        if (result) {
            NSLog(@"添加成功");
        }
        
    }];
    
    [self.queue close];
}

/**
 *  查询所有数据
 *
 *  @param name 表名
 *  @param keys 需要查询的key
 *
 *  @return 查询的dict
 */
- (NSDictionary *)selectAllWithSqliteName:(NSString *)name key:(NSArray<NSString *> *)keys
{
    __block NSMutableDictionary *dictArray = nil;
    
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
 *  查询所有数据
 *
 *  @param name 表名
 *  @param keys 需要查询的key
 *
 *  @return 查询的字典数组
 */
- (NSArray *)selectAllArrayWithSqliteName:(NSString *)name key:(NSArray<NSString *> *)keys
{
    return [self selectOnlyWithSqliteName:name dict:nil keys:keys];
}

/**
 *  查询特定数据
 *
 *  @param name  表名
 *  @param dict  根据哪个特定的值
 *  @param keys  需要查询的key
 *
 *  @return 查询特定数据的字典数组
 */
- (NSArray<NSDictionary *> *)selectOnlyWithSqliteName:(NSString *)name dict:(NSDictionary *)dict keys:(NSArray<NSString *> *)keys
{
    __block NSMutableArray *dictArray = nil;
    
    NSMutableString *string;
    if (dict == nil) {
        string = [NSMutableString stringWithString:[NSString stringWithFormat:@"select * from t_%@",name]];
    }
    else
    {
        string = [NSMutableString stringWithString:[NSString stringWithFormat:@"select * from t_%@ where",name]];
    }
    
    NSInteger i = 1;
    for (NSString *key in dict.keyEnumerator) {
        
        if (i == dict.allKeys.count)
        {
            [string appendString:[NSString stringWithFormat:@" %@='%@';",key,dict[key]]];
        }
        else
        {
            [string appendString:[NSString stringWithFormat:@" %@='%@' and",key,dict[key]]];
        }
        i++;
    }
    
    //2.查询
    [self.queue inDatabase:^(FMDatabase *db) {
        
        dictArray = [[NSMutableArray alloc] init];
        
        FMResultSet *rs = [db executeQuery:string];
        
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
 *  @param dict  根据哪个值删除
 */
- (void)deleteDataSqliteName:(NSString *)name dict:(NSDictionary *)dict
{
    NSMutableString *sql = [NSMutableString stringWithString:[NSString stringWithFormat:@"delete from t_%@ where",name]];
    NSInteger i = 1;
    for (NSString *key in dict.keyEnumerator) {
        
        if (i == dict.allKeys.count)
        {
            [sql appendString:[NSString stringWithFormat:@" %@='%@';",key,dict[key]]];
        }
        else
        {
            [sql appendString:[NSString stringWithFormat:@" %@='%@' and",key,dict[key]]];
        }
        i++;
    }
    
    [self.queue inDatabase:^(FMDatabase *db) {
        
        //删除特定的数据
        BOOL result = [db executeUpdate:sql];
        if (result) {
            NSLog(@"删除成功");
        }
        
    }];
    
    [self.queue close];
}

/**
 更新数据

 @param name 表名
 @param dict 需要更新的数据
 */
- (void)updateDataSqliteName:(NSString *)name dict:(NSDictionary *)dict
{
    [self updateWithName:name dict:dict dependDict:nil];
}

/**
 更新数据
 
 @param name 表名
 @param dict 需要更新的数据
 @param dependDict 根据哪里数据来改
 */
- (void)updateWithName:(NSString *)name dict:(NSDictionary *)dict dependDict:(NSDictionary *)dependDict
{
    NSMutableString *sql = [NSMutableString stringWithString:[NSString stringWithFormat:@"update t_%@ set",name]];
    NSInteger i = 1;
    for (NSString *key in dict.keyEnumerator) {
        
        if (i == dict.allKeys.count)
        {
            if (dependDict == nil)
            {
                [sql appendString:[NSString stringWithFormat:@" %@='%@';",key,dict[key]]];
            }
            else
            {
                [sql appendString:[NSString stringWithFormat:@" %@='%@' where",key,dict[key]]];
            }
        }
        else
        {
            [sql appendString:[NSString stringWithFormat:@" %@='%@' and",key,dict[key]]];
        }
        i++;
    }
    
    i = 1;
    for (NSString *key in dependDict.keyEnumerator) {
        
        if (i == dependDict.allKeys.count)
        {
            [sql appendString:[NSString stringWithFormat:@" %@='%@';",key,dependDict[key]]];
        }
        else
        {
            [sql appendString:[NSString stringWithFormat:@" %@='%@' and",key,dependDict[key]]];
        }
        i++;
    }
    
    [self.queue inDatabase:^(FMDatabase *db) {
        
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

#pragma mark - 使用runtime，

/**
 根据类名创建表,类名也为表名t_className，存储类中所有的key

 @param className 类名
 */
- (void)creatTableWithClassName:(NSString *)className
{
    NSArray *model_key = [self getModelKeyWithClassName:className];
    
    [self creatName:className key:model_key];
}
#pragma mark - 增

/**
 添加数据

 @param className 类名
 @param model 模型数据
 */
- (void)insertWithClassName:(NSString *)className model:(id)model
{
    Class name = NSClassFromString(className);
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList(name, &outCount);
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    for (NSInteger i = 0; i < outCount; i++)
    {
        Ivar ivar = ivars[i];
        NSString *key = [[NSString stringWithUTF8String:ivar_getName(ivar)] substringFromIndex:1];
        NSString *value = [model valueForKey:key];
        
        [dict setObject:value forKey:key];
    }
    
    [self insertDataWithSqliteName:className dict:dict];
}

/**
 添加数据
 
 @param className 类名
 @param modelArray 模型数组数据
 */
- (void)insertWithClassName:(NSString *)className modelArray:(NSArray<id> *)modelArray
{
    NSArray *model_key = [self getModelKeyWithClassName:className];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (id model in modelArray)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (NSString *key in model_key)
        {
            NSString *value = [model valueForKey:key];
            dict[key] = value;
        }
        [array addObject:dict];
    }
    [self insertDataWithSqliteName:className array:array];
}


/**
 查询所有数据

 @param className 类名
 @return model
 */
- (id)selectWithClassName:(NSString *)className
{
    Class name = NSClassFromString(className);
    
    id model = [[name alloc] init];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from t_%@;",className]];
        
        while (rs.next)
        {
            unsigned int outCount = 0;
            Ivar *ivars = class_copyIvarList(name, &outCount);
            for (NSInteger i = 0; i < outCount; i++)
            {
                Ivar ivar = ivars[i];
                NSString *key = [[NSString stringWithUTF8String:ivar_getName(ivar)] substringFromIndex:1];
                NSString *value = [rs stringForColumn:key];
                object_setIvar(model, ivar, value);
            }
        }
        
    }];
    
    [self.queue close];
    return model;
}

/**
 查询所有数据
 
 @param className 类名
 @return modelArray模型数组
 */
- (NSArray<id> *)selectAllWithClassName:(NSString *)className
{
    return [self selectAllWithClassName:className dependDict:nil];
}

/**
 根据查询
 
 @param className 类名
 @return dependDict 根据的数值
 @return modelArray 模型数组
 */
- (NSArray<id> *)selectAllWithClassName:(NSString *)className dependDict:(NSDictionary *)dependDict
{
    Class name = NSClassFromString(className);
    
    __block NSMutableArray *modelArray;
    
    NSMutableString *string;
    if (dependDict == nil)
    {
        string = [NSMutableString stringWithString:[NSString stringWithFormat:@"select * from t_%@",name]];;
    }
    else
    {
        string = [NSMutableString stringWithString:[NSString stringWithFormat:@"select * from t_%@ where",name]];
        NSInteger i = 1;
        for (NSString *key in dependDict.keyEnumerator) {
            
            if (i == dependDict.allKeys.count)
            {
                [string appendString:[NSString stringWithFormat:@" %@='%@';",key,dependDict[key]]];
            }
            else
            {
                [string appendString:[NSString stringWithFormat:@" %@='%@' and",key,dependDict[key]]];
            }
            i++;
        }

    }
    [self.queue inDatabase:^(FMDatabase *db) {
        
        modelArray = [[NSMutableArray alloc] init];
        
        FMResultSet *rs = [db executeQuery:string];
        
        while (rs.next)
        {
            id model = [[name alloc] init];
            
            unsigned int outCount = 0;
            Ivar *ivars = class_copyIvarList(name, &outCount);
            for (NSInteger i = 0; i < outCount; i++)
            {
                Ivar ivar = ivars[i];
                NSString *key = [[NSString stringWithUTF8String:ivar_getName(ivar)] substringFromIndex:1];
                NSString *value = [rs stringForColumn:key];
                object_setIvar(model, ivar, value);
            }
            [modelArray addObject:model];
        }
        
    }];
    
    [self.queue close];
    return modelArray;
}

//根据类名，得到类所有的key
- (NSArray<NSString *> *)getModelKeyWithClassName:(NSString *)className
{
    Class name = NSClassFromString(className);
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList(name, &outCount);
    
    NSMutableArray *model_key = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < outCount; i++)
    {
        Ivar ivar = ivars[i];
        NSString *key = [[NSString stringWithUTF8String:ivar_getName(ivar)] substringFromIndex:1];
        //NSInteger的类型居然得不到
//        NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        [model_key addObject:key];
    }
    return model_key;
}

@end
