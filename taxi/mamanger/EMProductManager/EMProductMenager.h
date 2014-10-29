//
//  EMProductMenager.h
//  proteplo
//
//  Created by Dmitry Avvakumov on 28.07.14.
//  Copyright (c) 2014 Dima Avvakumov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    EMProductStatusUndefined = 0,
    EMProductStatusLoading = 1,
    EMProductStatusReady = 2,
    EMProductStatusInvalid = 3
} EMProductStatus;

@class EMProductMenager;
@protocol EMProductMenagerDelegate <NSObject>

- (void) productManager: (EMProductMenager *) manager receivedIdentifiers: (NSArray *) identifiers;
- (void) productManager: (EMProductMenager *) manager failureIdentifiers: (NSArray *) identifiers;
- (void) productManager: (EMProductMenager *) manager requestFailureWithError: (NSError *) error;

@end

@interface EMProductMenager : NSObject <SKProductsRequestDelegate>

#pragma mark - Init methods
+ (EMProductMenager *) defaultManager;

- (SKProduct *) productByIdentifier: (NSString *) identifier;
//- (BOOL) productIsInvalid: (NSString *) identifier;
//- (BOOL) productNeedDownload: (NSString *) identifier;
- (EMProductStatus) productStatusByIdentifier: (NSString *) identifier;
- (void) requestInfoByIdentifiers: (NSArray *) ids;

- (void) registerDelegate: (id<EMProductMenagerDelegate>) delegate;
- (void) unregisterDelegate: (id<EMProductMenagerDelegate>) delegate;

@end
