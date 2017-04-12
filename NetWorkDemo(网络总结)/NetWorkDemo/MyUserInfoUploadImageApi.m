//
//  MyUserInfoUploadImageApi.m
//  NetWorkDemo
//
//  Created by 张杰 on 2017/1/20.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "MyUserInfoUploadImageApi.h"
#import "AFNetworking.h"

@implementation MyUserInfoUploadImageApi

{
    UIImage  *_image;
    NSNumber *_uid;
}
- (id)initWithImage:(UIImage *)image uid:(NSString *)uid
{
    self = [super init];
    if (self) {
        _image = image;
        _uid = [NSNumber numberWithInteger:uid.integerValue];
    }
    return self;
}


- (NSString *)requestUrl {
//    return @"/api/Auth/uploadImg";
    return @"/web/userBaseCold/updateImagePath.action";
}

-(YTKRequestMethod)requestMethod
{
    return YTKRequestMethodPOST;
}

- (AFConstructingBlock)constructingBodyBlock {
    return ^(id<AFMultipartFormData> formData) {
        
        /**
         *  appendPartWithFileURL   //  指定上传的文件
         *  name                    //  指定在服务器中获取对应文件或文本时的key
         *  fileName                //  指定上传文件的原始文件名
         *  mimeType                //  指定商家文件的MIME类型
         */
        
        NSData *data = UIImageJPEGRepresentation(_image, 0.9);
        NSString *key = @"imageMfile";//这对应服务器的key
        NSString *fileName = @"image.png";
        NSString *type = @"image/png";
        [formData appendPartWithFileData:data name:key fileName:fileName mimeType:type];
    };
}
//
//- (id)jsonValidator {
//    return @{ @"data": [NSString class] };
//}
//
//- (NSString *)responseImageId {
//    NSDictionary *dict = self.responseJSONObject;
//    return dict[@"data"];
//}

- (id)requestArgument {
    return @{ @"userID": _uid
              };
}


@end
