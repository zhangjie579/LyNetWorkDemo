//
//  AFNViewController.m
//  028
//
//  Created by bona on 16/10/20.
//  Copyright © 2016年 bona. All rights reserved.
//

#import "AFNViewController.h"
#import "LyHttpNetWork.h"
#import "FMDB.h"
#import "MJExtension.h"
#import "MessageModel.h"
#import "CacheTool.h"

@interface AFNViewController ()

@property (nonatomic,strong ) UIButton        *btn;
@property (nonatomic, strong) FMDatabaseQueue *queue;

@end

@implementation AFNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [self.view addSubview:self.btn];
}

- (void)btnClick
{
    NSArray *array = [self selectData];
    if (array.count != 0)
    {
        for (NSInteger i = 0; i < array.count; i++)
        {
            MessageModel *model = array[i];
            
            NSLog(@"model  id:%@  content:%@  img %@",model.id,model.content,model.img);
        }
        
        [self deleteTable];
    }
    else
    {
        LyHttpNetWork *tool = [LyHttpNetWork sharkNetWork];
        
        [tool getType:LyHttpNetWorkTypePost parameters:@{@"uid":@"1"} urlString:@"http://182.254.228.211:9000/index.php/Api/Circle/messageList" success:^(id resquestData) {
            
            if ([[resquestData[@"status"] description] isEqualToString:@"0"])
            {
                if (![resquestData[@"data"] isEqual:[NSNull null]])
                {
                    
                    
                    NSArray *arrar_model = [MessageModel mj_objectArrayWithKeyValuesArray:resquestData[@"data"]];
                    
                    //1.存储数据
                    [self saveDataWithArray:arrar_model];
                    
//                    NSLog(@"model  %@",model.qq);
                }
            }
            
        } failure:^(NSError *error) {
            
        }];
    }
}

/**
 *  查询全部数据
 *
 *  @return 全部数据
 */
- (NSArray *)selectData
{
    __block NSMutableArray *dictArray = nil;
    
    //1.创表
    [self creatTable];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        
        dictArray = [[NSMutableArray alloc] init];
        
        // 3.查询数据
#warning order by id desc 别忘了id
        FMResultSet *rs = [db executeQuery:@"select * from t_messageModel order by aid desc;"];
        
        while (rs.next)
        {
            MessageModel *model = [[MessageModel alloc] init];
            model.id = [rs objectForColumnName:@"id"];
            model.send_worker_id = [rs objectForColumnName:@"send_worker_id"];
            model.type = [rs objectForColumnName:@"type"];
            model.comment = [rs objectForColumnName:@"comment"];
            model.create_time = [rs objectForColumnName:@"create_time"];
            model.content = [rs objectForColumnName:@"content"];
            model.circle_id = [rs objectForColumnName:@"circle_id"];
            model.img = [[rs objectForColumnName:@"img"] componentsSeparatedByString:@","];
            [dictArray addObject:model];
        }
    }];
    
    [self.queue close];
    
    return dictArray;
}

- (NSArray *)selectFromID
{
    __block NSMutableArray *dictArray = nil;
    
    //1.创表
    [self creatTable];
    
    //2.查询
    [self.queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"select * from t_messageModel where id > '%@';",@"300"];
        
        while (rs.next) {
            MessageModel *model = [[MessageModel alloc] init];
            model.id = [rs objectForColumnName:@"id"];
            model.send_worker_id = [rs objectForColumnName:@"send_worker_id"];
            model.type = [rs objectForColumnName:@"type"];
            model.comment = [rs objectForColumnName:@"comment"];
            model.create_time = [rs objectForColumnName:@"create_time"];
            model.content = [rs objectForColumnName:@"content"];
            model.circle_id = [rs objectForColumnName:@"circle_id"];
            model.img = [[rs objectForColumnName:@"img"] componentsSeparatedByString:@","];
            [dictArray addObject:model];
        }
        
    }];
    
    [self.queue close];
    return dictArray;
}

///**
// *  储存数据
// *
// *  @param dict 储存字典
// */
//- (void)saveDataWithDict:(NSDictionary *)dict
//{
//    //1.创表
//    [self creatTable];
//    
//    //2.存储
//    [self.queue inDatabase:^(FMDatabase *db) {
//        
//        //3.取出要存的数
//        NSString *id = dict[@"id"];
//        NSString *send_worker_id = dict[@"send_worker_id"];
//        NSString *type = dict[@"type"];
//        NSString *comment = dict[@"comment"];
//        NSString *create_time = dict[@"create_time"];
//        NSArray *array = dict[@"img"];
//        NSString *img = [array componentsJoinedByString:@","];
//        NSString *content = dict[@"content"];
//        NSString *circle_id = dict[@"circle_id"];
//        
//        [db executeUpdate:@"insert into t_messageModel (id ,send_worker_id ,type ,comment ,create_time ,img ,content ,circle_id) values (? ,? ,? ,? ,? ,? ,? ,? );",id,send_worker_id,type,comment,create_time,img,content,circle_id];
//        
//    }];
//    
//    [self.queue close];
//}

/**
 *  储存数据
 *
 *  @param dict 储存字典
 */
- (void)saveDataWithDict:(MessageModel *)model
{
    //1.创表
    [self creatTable];
    
    //2.存储
    [self.queue inDatabase:^(FMDatabase *db) {
        
        //3.取出要存的数
        NSString *img = [model.img componentsJoinedByString:@","];
        
        [db executeUpdate:@"insert into t_messageModel (id ,send_worker_id ,type ,comment ,create_time ,img ,content ,circle_id) values (? ,? ,? ,? ,? ,? ,? ,? );",model.id,model.send_worker_id,model.type,model.comment,model.create_time,img,model.content,model.circle_id];
        
    }];
    
    [self.queue close];
}

/**
 *  存储数据
 *
 *  @param array
 */
- (void)saveDataWithArray:(NSArray *)array
{
    for (NSInteger i = 0; i < array.count; i++) {
        [self saveDataWithDict:array[i]];
    }
}

/**
 *  更新数据
 */
- (void)updateData
{
    [self creatTable];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:@"update t_messageModel set content = ? where id < 300;",@"123456789"];
        
    }];
    
    [self.queue close];
}

/**
 *  删除表/删除特定的数据
 */
- (void)deleteTable
{
    [self.queue inDatabase:^(FMDatabase *db) {
        
        //删除特定的数据
        [db executeUpdate:@"delete from t_messageModel where id > ?;",@"300"];
        
        //删除整张表
//        [db executeUpdate:@"drop table if exists t_messageModel"];
        
    }];
    
    [self.queue close];
}


/**
 *  创表
 */
- (void)creatTable
{
    //1.地址
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"messageModel.sqlite"];
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:path];
    self.queue = queue;
    
    [queue inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:@"create table if not exists t_messageModel (aid integer primary key autoincrement, send_worker_id text,  id text ,  type text ,  comment text , create_time text , content text , circle_id text , img text);"];
        
        if (result) {
            NSLog(@"创表成功");
        } else {
            NSLog(@"创表失败");
        }
        
    }];
    
    [queue close];
}

- (UIButton *)btn
{
    if (!_btn) {
        _btn = [[UIButton alloc] init];
        _btn.frame = CGRectMake(100, 100, 50, 50);
        _btn.backgroundColor = [UIColor yellowColor];
        [_btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn;
}

@end
