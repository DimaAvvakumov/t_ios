//
//  EMStoreManagerOperation.h
//  proteplo
//
//  Created by Dmitry Avvakumov on 28.07.14.
//  Copyright (c) 2014 Dima Avvakumov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^EMStoreManagerOperationFinishBlock)();
typedef void (^EMStoreManagerOperationFailureBlock)(NSError *error);

typedef enum {
    EMStoreManagerOperationTypeRestore = 0,
    EMStoreManagerOperationTypeBuy = 1
} EMStoreManagerOperationType;

@protocol EMStoreManagerOperation <NSObject>

@property (strong, nonatomic) SKProduct *product;

@property (copy, nonatomic) EMStoreManagerOperationFinishBlock finishBlock;
@property (copy, nonatomic) EMStoreManagerOperationFailureBlock failureBlock;

- (EMStoreManagerOperationType) type;

@end
