//
//  EMStoreManagerBuyOperation.m
//  proteplo
//
//  Created by Dmitry Avvakumov on 28.07.14.
//  Copyright (c) 2014 Dima Avvakumov. All rights reserved.
//

#import "EMStoreManagerBuyOperation.h"

@implementation EMStoreManagerBuyOperation

- (id)initWithProduct: (SKProduct *) product {
    self = [super init];
    if (self) {
        self.product = product;
    }
    return self;
}

- (EMStoreManagerOperationType) type {
    return EMStoreManagerOperationTypeBuy;
}

@end
