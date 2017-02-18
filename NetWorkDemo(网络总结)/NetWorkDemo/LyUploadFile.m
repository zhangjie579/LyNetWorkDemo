//
//  LyUploadFile.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/2/18.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LyUploadFile.h"
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>

@interface LyUploadFile()

@property (copy, nonatomic) NSString *uploadKey;
@property (copy, nonatomic) NSString *fileName;
@property (copy, nonatomic) NSString *fileType;
@property (copy, nonatomic) NSString *md5String;
@property (strong, nonatomic) NSData *fileData;

@end

@implementation LyUploadFile

- (instancetype)initWithUploadKey:(NSString *)uploadKey fileName:(NSString *)fileName fileType:(LyUploadFileType)type fileData:(id)fileData
{
    if (self = [super init])
    {
        self.uploadKey = uploadKey;
        
        switch (type) {
            case LyUploadFileTypePng: {
                
                self.fileType = @"image/png";
                self.fileName = [fileName stringByAppendingString:@".png"];
                
                if ([fileData isKindOfClass:[UIImage class]]) {
                    self.fileData = UIImageJPEGRepresentation(fileData, 0.5);
                }
                
            }   break;
                
            case LyUploadFileTypeJpg: {
                
                self.fileType = @"image/jpeg";
                self.fileName = [fileName stringByAppendingString:@".jpeg"];
                
                if ([fileData isKindOfClass:[UIImage class]]) {
                    self.fileData = UIImageJPEGRepresentation(fileData, 0.5);
                }
            }   break;
                
            case LyUploadFileTypeMp3: {
                
                self.fileType = @"audio/mp3";
                self.fileName = [fileName stringByAppendingString:@".mp3"];
            }   break;
        }
        
        self.md5String = self.fileData.length > 0 ? [LyUploadFile md5WithData:self.fileData] : @"";
    }
    return self;
}

#pragma mark - Utils

+ (NSString *)md5WithData:(NSData *)data {
    unsigned char result[16];
    CC_MD5(data.bytes, data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
