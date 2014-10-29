//
//  EMStoreManager.h
//  proteplo
//
//  Created by Dmitry Avvakumov on 28.07.14.
//  Copyright (c) 2014 Dima Avvakumov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CargoBay.h"

#import "EMStoreManagerRestoreOperation.h"
#import "EMStoreManagerBuyOperation.h"

#define EMStoreManagerRestoreNotification @"EMStoreManagerRestoreNotification"

@interface EMStoreManager : NSObject

@property (strong, nonatomic) NSString *sharedSecret;

+ (EMStoreManager *) defaultManager;

- (void) sendOperation: (id<EMStoreManagerOperation>) operation;

- (BOOL) subscriptionIsActive;
- (BOOL) productIsPurchase: (NSString *) productID;
- (BOOL) dateUnderSubscription: (NSDate *) date;

@end
