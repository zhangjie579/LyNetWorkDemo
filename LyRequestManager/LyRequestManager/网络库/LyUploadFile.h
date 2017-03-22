//
//  LyUploadFile.h
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/18.
//  Copyright © 2017年 张杰. All rights reserved.
//  初始化上传文件

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    LyUploadFileTypePng,
    LyUploadFileTypeJpg,
    LyUploadFileTypeMp3
} LyUploadFileType;

@interface LyUploadFile : NSObject

@property (copy, nonatomic, readonly) NSString *uploadKey;
@property (copy, nonatomic, readonly) NSString *fileName;
@property (copy, nonatomic, readonly) NSString *fileType;
@property (copy, nonatomic, readonly) NSString *md5String;
@property (strong, nonatomic, readonly) NSData *fileData;

- (instancetype)initWithUploadKey:(NSString *)uploadKey fileName:(NSString *)fileName fileType:(LyUploadFileType)type fileData:(id)fileData;

@end
