//
//  LyKeyChainItem.h
//  LyRequestManager
//
//  Created by 张杰 on 2017/3/22.
//  Copyright © 2017年 张杰. All rights reserved.
//  储存敏感数据

/*
 导入KeychainItemWrapper前，-> 工程 -> capabilities -> Keychain share ,open打开
 */

typedef enum {
    LyKeyChainTypeAccount,
    LyKeyChainTypeToken,
    LyKeyChainTypeMima,
}LyKeyChainType;

#import <Foundation/Foundation.h>

@interface LyKeyChainItem : NSObject

+ (void)saveThingWithIdentifier:(NSString *)identifier itemType:(LyKeyChainType)itemType value:(id)value;

+ (id)readWithIdentifier:(NSString *)identifier itemType:(LyKeyChainType)itemType;

@end
