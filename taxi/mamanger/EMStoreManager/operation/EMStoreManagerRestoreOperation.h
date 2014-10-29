//
//  EMStoreManagerRestoreOperation.h
//  proteplo
//
//  Created by Dmitry Avvakumov on 28.07.14.
//  Copyright (c) 2014 Dima Avvakumov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMStoreManagerOperation.h"

@interface EMStoreManagerRestoreOperation : NSObject <EMStoreManagerOperation>

@property (strong, nonatomic) SKProduct *product;

@property (copy, nonatomic) EMStoreManagerOperationFinishBlock finishBlock;
@property (copy, nonatomic) EMStoreManagerOperationFailureBlock failureBlock;

@end
