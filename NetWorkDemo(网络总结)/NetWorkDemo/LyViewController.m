//
//  LyViewController.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/1/20.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LyViewController.h"
#import "AFNetworking.h"
#import "LyHttpNetWork.h"
#import "FMDB.h"
#import "StatusModel.h"
#import "MJExtension.h"
#import "AFNViewController.h"
#import "CacheTool.h"

@interface LyViewController ()
- (IBAction)btnClick:(id)sender;

@property (nonatomic, strong) FMDatabaseQueue *queue;
- (IBAction)nextVC:(id)sender;

@end

@implementation LyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

//- (IBAction)btnClick:(id)sender {
//
//
//    //1.先去缓存
//    NSDictionary *dict_cache = [self query];
//    if (dict_cache.allKeys.count != 0)//有缓存
//    {
//        StatusModel *model = [StatusModel mj_objectWithKeyValues:dict_cache];
//
//        NSLog(@"缓存model   %@",dict_cache);
//    }
//    else
//    {
//        HttpNetWork *http = [HttpNetWork sharkNetWork];
//
//        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//        dict[@"uid"] = @"1";
//
//        NSLog(@"%@",[self dictionaryToJson:dict]);
//
//        [http getType:HttpNetWorkTypePost parameters:dict urlString:@"http://182.254.228.211:9000/index.php/Api/ServiceContact/index" success:^(id resquestData) {
//
//            if ([[resquestData[@"status"] description] isEqualToString:@"0"])
//            {
//                if (![resquestData[@"data"] isEqual:[NSNull null]])
//                {
//                    //1.存储数据
//                    [self addinsert:resquestData[@"data"]];
//
//
//                    StatusModel *model = [StatusModel mj_objectWithKeyValues:resquestData[@"data"]];
//
//                    NSLog(@"model  %@",model.qq);
//                }
//            }
//
//            NSLog(@"%@",resquestData);
//        } failure:^(NSError *error) {
//            NSLog(@"失败");
//        }];
//    }
//}

- (IBAction)btnClick:(id)sender {
    
    CacheTool *tool = [[CacheTool alloc] init];
    
    //1.先去缓存
    NSDictionary *dict_cache = [tool selectAllWithSqliteName:@"statusModel" key:@[@"phone",@"qq" ,@"service_time" , @"weixin"]];
    if (dict_cache.allKeys.count != 0)//有缓存
    {
        StatusModel *model = [StatusModel mj_objectWithKeyValues:dict_cache];
        
        NSLog(@"缓存model   %@",dict_cache);
    }
    else
    {
        LyHttpNetWork *http = [LyHttpNetWork sharkNetWork];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[@"uid"] = @"1";
        
        NSLog(@"%@",[self dictionaryToJson:dict]);
        
        [http getType:LyHttpNetWorkTypePost parameters:dict urlString:@"http://182.254.228.211:9000/index.php/Api/ServiceContact/index" success:^(id resquestData) {
            
            if ([[resquestData[@"status"] description] isEqualToString:@"0"])
            {
                if (![resquestData[@"data"] isEqual:[NSNull null]])
                {
                    //1.存储数据
                    //                    [self addinsert:resquestData[@"data"]];
                    
                    
                    [tool insertDataWithSqliteName:@"statusModel" key:@[@"phone",@"qq" ,@"service_time" , @"weixin"] dict:resquestData[@"data"]];
                    
                    StatusModel *model = [StatusModel mj_objectWithKeyValues:resquestData[@"data"]];
                    
                    NSLog(@"model  %@",model.qq);
                }
            }
            
            NSLog(@"%@",resquestData);
        } failure:^(NSError *error) {
            NSLog(@"失败");
        }];
    }
}

/**
 *  创表
 */
-(void)setupsqlite
{
    //1.地址
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"statusModel.sqlite"];
    
    //2.创建对象
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:path];
    self.queue = queue;
    
    //3.创表
    [queue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:@"create table if not exists t_statusModel (id integer primary key autoincrement, phone text,  qq text ,  service_time text ,  weixin text);"];
        
        if (result) {
            NSLog(@"创表成功");
        } else {
            NSLog(@"创表失败");
        }
    }];
    
    [queue close];
}

/**
 *  存储数据
 *
 *  @param dict
 */
-(void)addinsert:(NSDictionary *)dict
{
    //1.创表
    [self setupsqlite];
    
    //2.存储数据
    [self.queue inDatabase:^(FMDatabase *db) {
        
        //3.获得需要存储的数据
        NSString *qq = dict[@"qq"];
        NSString *phone = dict[@"phone"];
        NSString *service_time = dict[@"service_time"];
        NSString *weixin = dict[@"weixin"];
        
        //4.储存
        [db executeUpdate:@"insert into t_statusModel (qq , phone , service_time , weixin) values(? , ? , ? ,?);",qq,phone,service_time,weixin];
        
    }];
    
    [self.queue close];
}

- (void)addinserts:(NSArray *)dictArray
{
    for (NSDictionary *dict in dictArray) {
        [self addinsert:dict];
    }
}

/**
 *  查询数据
 *
 *  @return 查询数据
 */
-(NSDictionary *)query
{
    // 0.定义数组
    __block NSMutableDictionary *dictArray = nil;
    
    //1.创表
    [self setupsqlite];
    
    //2.查询数据
    [self.queue inDatabase:^(FMDatabase *db) {
        
        // 创建数组
        dictArray = [[NSMutableDictionary alloc] init];
        
        // 3.查询数据
#warning order by id desc 别忘了id
        FMResultSet *rs = [db executeQuery:@"select * from t_statusModel order by id desc;"];
        //        FMResultSet *rs = [db executeQuery:@"select * from t_statusModel;"];
        
        //4.遍历
        while (rs.next) {
            NSString *qq = [rs stringForColumn:@"qq"];
            NSString *phone = [rs stringForColumn:@"phone"];
            NSString *service_time = [rs stringForColumn:@"service_time"];
            NSString *weixin = [rs stringForColumn:@"weixin"];
            
            dictArray[@"qq"] = qq;
            dictArray[@"phone"] = phone;
            dictArray[@"service_time"] = service_time;
            dictArray[@"weixin"] = weixin;
        }
        
    }];
    
    [self.queue close];
    return dictArray;
}

/**
 *  字典转json
 *
 *  @param dic  字典
 *
 *  @return  json
 */
- (NSString *)dictionaryToJson:(NSDictionary *)dic

{
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}

- (NSDictionary *)jsonStrToDictionary:(NSString *)str
{
    NSDictionary *resultDic = nil;
    if (![self isBlankString:str]) {
        NSString *requestTmp = [NSString stringWithString:str];
        NSData *resData = [[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        resultDic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
    }
    return resultDic;
}

- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

- (IBAction)nextVC:(id)sender {
    
    AFNViewController *vc = [[AFNViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
