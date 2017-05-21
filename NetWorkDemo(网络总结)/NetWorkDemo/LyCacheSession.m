//
//  LyCacheSession.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/5/20.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LyCacheSession.h"
#import <objc/message.h>
#import "FMDB.h"

@interface LyCacheSession ()

@property(nonatomic,strong)FMDatabaseQueue     *queue;
@property(nonatomic,strong)NSMutableDictionary *dictClassName;//根据类名，保存 key = 属性名 value = 属性类型

@end

@implementation LyCacheSession

/**
 创建表

 @param className 类名
 */
- (void)creatTableWithClassName:(NSString *)className
{
    [self queueWithClassName:className];
    
    __weak typeof(self) weakSelf = self;
    [self.queue inDatabase:^(FMDatabase *db) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf creat:db className:className];
    }];
    
    //关闭
    [self.queue close];
}

#pragma mark - 增
- (void)insertWithModel:(id)model className:(NSString *)className
{
    [self insertWithArrayModel:@[model] className:className];
}

- (void)insertWithArrayModel:(NSArray<id> *)arraymodel className:(NSString *)className
{
    if (self.queue == nil) {
        [self queueWithClassName:className];
    }
    
    //    [db executeUpdate:@"insert into t_messageModel (id ,send_worker_id ,type ,comment ,create_time ,img ,content ,circle_id) values (? ,? ,? ,? ,? ,? ,? ,? );"];
    NSMutableString *sql = [[NSMutableString alloc] initWithFormat:@"insert into t_%@ (",className];
    
    if (self.dictClassName == nil) {
        NSMutableDictionary *dict = [self getProprtyAndNameWithClassName:className];
        self.dictClassName = dict;
    }
    
    NSMutableString *last = [[NSMutableString alloc] init];
    
    for (NSInteger j = 0; j < arraymodel.count; j++)
    {
        id model = arraymodel[j];
        
        for (NSInteger i = 0; i < self.dictClassName.allKeys.count; i++)
        {
            NSString *key = self.dictClassName.allKeys[i];
            NSString *property = self.dictClassName.allValues[i];
            id value = [model valueForKey:key];
            
            //只有value有值的时候才存
            if (value != nil)
            {
                if (i == self.dictClassName.allKeys.count - 1)//最后一个
                {
                    [sql appendFormat:@" %@) values (",key];
                    
                    //注意:如果为字符串需要加''
                    if ([property isEqualToString:@"NSString"]) {
                        [last appendFormat:@" '%@');",value];
                    } else {
                        [last appendFormat:@" %@);",value];
                    }
                }
                else
                {
                    [sql appendFormat:@"%@ ,",key];
                    //注意:如果为字符串需要加''
                    if ([property isEqualToString:@"NSString"]) {
                        [last appendFormat:@"'%@' ,",value];
                    } else {
                        [last appendFormat:@"%@ ,",value];
                    }
                }
            }
            else
            {
                if (i == self.dictClassName.allKeys.count - 1)//最后一个
                {
                    //需要去掉,
                    NSString *first = [sql substringToIndex:sql.length - 1];
                    NSString *end = [last substringToIndex:last.length - 1];
                    
                    sql = [[NSMutableString alloc] initWithFormat:@"%@) values (%@);",first,end];
                }
            }
        }
        
        [sql appendString:last];
        
        [self.queue inDatabase:^(FMDatabase *db) {
            
            BOOL result = [db executeUpdate:sql];
            if (result) {
                NSLog(@"添加数据成功");
            } else {
                NSLog(@"添加数据失败");
            }
        }];
    }
    
    [self.queue close];
}

#pragma mark - 删
- (void)deleteWithDict:(NSDictionary *)dict className:(NSString *)className
{
    if (self.queue == nil) {
        [self queueWithClassName:className];
    }
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"delete from t_%@ where",className];
    
    [sql appendString:[self formateWithDict:dict]];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sql];
        if (result) {
            NSLog(@"删除成功");
        } else {
            NSLog(@"删除失败");
        }
    }];
    
    [self.queue close];
}

/**
 更新数据

 @param className 类名
 @param dict 更新的数据
 @param dependDict 根据那些来更新数据 ，全部更新时候为nil
 */
- (void)updateWithClassName:(NSString *)className dict:(NSDictionary *)dict dependDict:(NSDictionary *)dependDict
{
    if (self.queue == nil) {
        [self queueWithClassName:className];
    }
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"update t_%@ set ",className];
    
    NSString *value = [self formateWithDict:dict];
    
    if (dependDict == nil)
    {
        [sql appendString:value];
    }
    else
    {
        //去掉;
        value = [value substringToIndex:value.length - 1];
        
        [sql appendFormat:@"%@ where ",value];
        
        [sql appendString:[self formateWithDict:dependDict]];
    }
    
    [self.queue inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sql];
        if (result) {
            NSLog(@"更新成功");
        } else {
            NSLog(@"更新失败");
        }
    }];
    
    [self.queue close];
}

- (void)updateWithClassName:(NSString *)className model:(id)model dependDict:(NSDictionary *)dependDict
{
    if (self.queue == nil) {
        [self queueWithClassName:className];
    }
    
    NSMutableString *sql = [[NSMutableString alloc] initWithFormat:@"update t_%@ set",className];
    
    //获取类对应的 -> 参数类型/参数名
    if (self.dictClassName == nil) {
        NSMutableDictionary *dict = [self getProprtyAndNameWithClassName:className];
        self.dictClassName = dict;
    }
    
    for (NSInteger i = 0; i < self.dictClassName.allKeys.count; i++)
    {
        //参数名
        NSString *key = self.dictClassName.allKeys[i];
        //参数类型
//        NSString *property = dict.allValues[i];
        
        id value = [model valueForKey:key];
        
        if ([value isKindOfClass:[NSString class]])//字符串
        {
            if (i == self.dictClassName.allValues.count - 1)//最后一个
            {
                [sql appendFormat:@" %@ = '%@'",key,value];
            }
            else
            {
                [sql appendFormat:@" %@ = '%@' and",key,value];
            }
        }
        else
        {
            if (i == self.dictClassName.allValues.count - 1)//最后一个
            {
                [sql appendFormat:@" %@ = %@",key,value];
            }
            else
            {
                [sql appendFormat:@" %@ = %@ and",key,value];
            }
        }
    }
    
    if (dependDict == nil)
    {
        [sql appendString:@";"];
    }
    else
    {
        [sql appendString:@" where "];
        [sql appendString:[self formateWithDict:dependDict]];
    }
    
    [self.queue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:sql];
        if (result) {
            NSLog(@"更新成功");
        } else {
            NSLog(@"更新失败");
        }
    }];
    
    [self.queue close];
}

#pragma mark - 查

- (NSArray<id> *)selectAllClassName:(NSString *)className
{
    return [self selectWithClassName:className dependDict:nil];
}

/**
 根据查询
 
 @param className 类名
 @return dependDict 根据的数值
 @return modelArray 模型数组
 */
- (NSArray<id> *)selectWithClassName:(NSString *)className dependDict:(NSDictionary *)dependDict
{
    if (self.queue == nil) {
        [self queueWithClassName:className];
    }
    
    __block NSMutableArray *arrayModel = nil;
    //1.获取类名
    Class class = NSClassFromString(className);
    
    //2.拼接sql
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select * from t_%@",className];
    
    if (dependDict == nil)
    {
        [sql appendString:@";"];
    }
    else
    {
        [sql appendString:@" where "];
        [sql appendString:[self formateWithDict:dependDict]];
    }
    
    //3.查询
    [self.queue inDatabase:^(FMDatabase *db) {
        
        arrayModel = [[NSMutableArray alloc] init];
        
        FMResultSet *rs = [db executeQuery:sql];
        
        while (rs.next)
        {
            //3.1通过runtime转换
            id model = [[class alloc] init];
            
            unsigned int outCount = 0;
            Ivar *ivars = class_copyIvarList(class, &outCount);
            for (NSInteger i = 0; i < outCount; i++)
            {
                Ivar ivar = ivars[i];
                NSString *key = [[NSString stringWithUTF8String:ivar_getName(ivar)] substringFromIndex:1];
                id value = [rs objectForColumnName:key];
                object_setIvar(model, ivar, value);
            }
            [arrayModel addObject:model];
        }
        
    }];
    
    [self.queue close];
    return arrayModel;
}

#pragma mark - 私有方法

//创建表,类名
- (void)creat:(FMDatabase *)db className:(NSString *)className
{
    //1.根据类名获取参数类型，参数名
    if (self.dictClassName == nil) {
        NSMutableDictionary *dict = [self getProprtyAndNameWithClassName:className];
        self.dictClassName = dict;
    }
    
    if (self.dictClassName == nil) {
        return;
    }

    NSMutableString *sql = [[NSMutableString alloc] initWithFormat:@"create table if not exists t_%@ (aid integer primary key autoincrement",className];
    
    for (NSInteger i = 0; i < self.dictClassName.allKeys.count; i++)
    {
        NSString *key = self.dictClassName.allKeys[i];
        NSString *obj = self.dictClassName.allValues[i];
        
        NSString *subString = @"";
        if (i == self.dictClassName.allKeys.count - 1)//最后一个
        {
            NSString *property = [self propretyWithString:obj];
            subString = [NSString stringWithFormat:@", %@ %@);",key,property];
            
            [sql appendString:subString];
        }
        else
        {
            NSString *property = [self propretyWithString:obj];
            subString = [NSString stringWithFormat:@", %@ %@",key,property];
            
            [sql appendString:subString];
        }
    }
    
//    NSLog(@"%@",sql);
    
    BOOL result = [db executeUpdate:sql];
    if (result) {
        NSLog(@"创表成功");
    } else {
        NSLog(@"创表失败");
    }
}

//根据类名获取参数类型，参数名
- (NSMutableDictionary *)getProprtyAndNameWithClassName:(NSString *)className
{
    //1.获取类
    Class class = NSClassFromString(className);
    
    if (class == nil) return nil;
    
    //2.获取参数
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList(class, &outCount);
    
    for (NSInteger i = 0; i < outCount; i++)
    {
        Ivar ivar = ivars[i];
        
        NSString *key = [[NSString stringWithUTF8String:ivar_getName(ivar)] substringFromIndex:1];
        
        // @\"NSString\"
        NSString *property = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        
        if ([property isEqualToString:@"i"]) {
            property = @"int";
        }
        else if ([property isEqualToString:@"d"]) {
            property = @"double";
        }
        else if ([property isEqualToString:@"q"]) {
            property = @"NSInteger";
        }
        else if ([property containsString:@"\""]) {
            NSRange rang = [property rangeOfString:@"\""];
            property = [property substringFromIndex:rang.location + rang.length];
            rang = [property rangeOfString:@"\""];
            property = [property substringToIndex:rang.location];
        }
        dict[key] = property;
//        NSLog(@"%@  %@\n",property,key);
    }
    
    return dict;
}

//判断数据的类型
- (NSString *)propretyWithString:(NSString *)obj
{
    if ([obj isEqualToString:@"NSString"])//字符串
    {
        return @"text";
    }
    else if ([obj isEqualToString:@"NSNumber"] || [obj isEqualToString:@"int"] || [obj isEqualToString:@"NSInteger"])//整型
    {
        
        return @"integer";
    }
    else if ([obj isEqualToString:@"float"] || [obj isEqualToString:@"CGFloat"] || [obj isEqualToString:@"double"])//浮点型
    {
        return @"real";
    }
    return @"";
}

//格式化字符串 a = 1 and age = '16';
- (NSString *)formateWithDict:(NSDictionary *)dict
{
    NSMutableString *sql = [[NSMutableString alloc] init];
    
    for (NSInteger i = 0; i < dict.allKeys.count; i++)
    {
        NSString *key = dict.allKeys[i];
        id value = dict.allValues[i];
        
        if ([value isKindOfClass:[NSString class]])//字符串
        {
            if (i == dict.allValues.count - 1)//最后一个
            {
                [sql appendFormat:@" %@ = '%@';",key,value];
            }
            else
            {
                [sql appendFormat:@" %@ = '%@' and",key,value];
            }
        }
        else
        {
            if (i == dict.allValues.count - 1)//最后一个
            {
                [sql appendFormat:@" %@ = %@;",key,value];
            }
            else
            {
                [sql appendFormat:@" %@ = %@ and",key,value];
            }
        }
    }
    return sql;
}

- (void)queueWithClassName:(NSString *)className
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",className]];
    
    NSLog(@"path = %@",path);
    
    self.queue = [FMDatabaseQueue databaseQueueWithPath:path];
}

#pragma mark - 单例
static LyCacheSession *_session = nil;
+ (instancetype)defaultSession
{
    if (!_session) {
        _session = [[self alloc] init];
    }
#warning 注意:这里如果不清除为nil的话，当_session存在，dictClassName也就存在
    _session.dictClassName = nil;
    return _session;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    if (!_session) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _session = [super allocWithZone:zone];
        });
    }
    _session.dictClassName = nil;
    return _session;
}

- (id)copy
{
    return _session;
}

- (id)mutableCopy
{
    return _session;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.dictClassName = nil;
    }
    return self;
}

@end
