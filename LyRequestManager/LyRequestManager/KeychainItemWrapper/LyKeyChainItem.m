//
//  LyKeyChainItem.m
//  LyRequestManager
//
//  Created by 张杰 on 2017/3/22.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LyKeyChainItem.h"
#import "KeychainItemWrapper.h"

static NSString* kidentifier = @"bona.LyRequestManager";

@implementation LyKeyChainItem

+ (void)saveThingWithIdentifier:(NSString *)identifier itemType:(LyKeyChainType)itemType value:(id)value
{
    KeychainItemWrapper *wap = [[KeychainItemWrapper alloc] initWithIdentifier:identifier accessGroup:nil];
//    //保存帐号
//    [wap setObject:@"张三" forKey:(__bridge id)kSecAttrAccount];
//    [wap setObject:@"212121" forKey:(__bridge id)kSecValueData];
    [wap resetKeychainItem];
    
    switch (itemType) {
        case LyKeyChainTypeMima:
             [wap setObject:value forKey:(__bridge id)kSecValueData];
            break;
        case LyKeyChainTypeToken:
            [wap setObject:value forKey:(__bridge id)kSecAttrTokenID];
            break;
        case LyKeyChainTypeAccount:
            [wap setObject:value forKey:(__bridge id)kSecAttrAccount];
            break;
            
        default:
            break;
    }
}

+ (id)readWithIdentifier:(NSString *)identifier itemType:(LyKeyChainType)itemType
{
    KeychainItemWrapper *wap = [[KeychainItemWrapper alloc] initWithIdentifier:kidentifier accessGroup:nil];
    
    id value;
    
    switch (itemType) {
        case LyKeyChainTypeMima:
            value = [wap objectForKey:(__bridge id)kSecValueData];
            break;
        case LyKeyChainTypeToken:
            value = [wap objectForKey:(__bridge id)kSecAttrTokenID];
            break;
        case LyKeyChainTypeAccount:
            value = [wap objectForKey:(__bridge id)kSecAttrAccount];
            break;
            
        default:
            break;
    }
    return value;
}

@end
