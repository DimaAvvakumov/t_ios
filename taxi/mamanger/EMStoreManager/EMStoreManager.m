//
//  EMStoreManager.m
//  proteplo
//
//  Created by Dmitry Avvakumov on 28.07.14.
//  Copyright (c) 2014 Dima Avvakumov. All rights reserved.
//

#define EMStoreManager_NSUserDefaults_StoreKeyProducts @"EMStoreManager_StoreKeyProducts"
#define EMStoreManager_NSUserDefaults_StoreKeySubscription @"EMStoreManager_StoreKeySubscription"

#import "EMStoreManager.h"

#import "EMStoreManagerReceipt.h"

@interface EMStoreManager()

@property (strong, nonatomic) id<EMStoreManagerOperation> currentOperation;

@property (strong, nonatomic) NSMutableDictionary *restoreProducts;
@property (strong, nonatomic) NSMutableDictionary *restoreSubscriptions;

@property (strong, nonatomic) NSMutableDictionary *procesingTransactions;

@end

@implementation EMStoreManager

#pragma mark - Init

- (id)init {
    self = [super init];
    if (self) {
        // weak self
        __weak EMStoreManager *weakSelf = self;
        
        self.sharedSecret = nil;
        
        self.restoreProducts = [NSMutableDictionary dictionaryWithCapacity:10];
        self.restoreSubscriptions = [NSMutableDictionary dictionaryWithCapacity:10];
        
        self.procesingTransactions = [NSMutableDictionary dictionaryWithCapacity:10];
        
        [self restoreFromUserDefaults];
        
        // transaction observer
        [[SKPaymentQueue defaultQueue] addTransactionObserver:[CargoBay sharedManager]];
        
        // Base notificatoin
        [[CargoBay sharedManager] setPaymentQueueUpdatedTransactionsBlock:^(SKPaymentQueue *queue, NSArray *transactions) {
            
            [weakSelf paymentUpdateTransactions: transactions];
        }];
        
        // Restore notification, not in this app
        [[CargoBay sharedManager] setPaymentQueueRestoreCompletedTransactionsWithSuccess:^(SKPaymentQueue *queue) {
            NSLog(@"Payment QueueRestoreCompletedTransactionsWithSuccess!");
            
            if ([_procesingTransactions count] == 0) {
                // save restore information
                [self saveReceiptsInUserDefaults];
                
                // send by blocks
                id<EMStoreManagerOperation> currentOperation = _currentOperation;
                if (currentOperation && currentOperation.finishBlock) {
                    currentOperation.finishBlock();
                }
                
                // send push notification
                [[NSNotificationCenter defaultCenter] postNotificationName:EMStoreManagerRestoreNotification object:nil userInfo:nil];
            }
            
        } failure:^(SKPaymentQueue *queue, NSError *error) {
            // _isRestore = NO;
            NSLog(@"Payment QueueRestoreCompletedTransactionsWithError: %@", error);
            
            // send operation
            id<EMStoreManagerOperation> currentOperation = _currentOperation;
            if (currentOperation && currentOperation.type == EMStoreManagerOperationTypeRestore) {
                if (currentOperation) {
                    currentOperation.failureBlock( error );
                }
            }
        }];
    }
    return self;
}

+ (EMStoreManager *) defaultManager {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Buy identifier

- (void) paymentUpdateTransactions:(NSArray *) transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            // Failure transaction
            case SKPaymentTransactionStateFailed: {
                NSLog(@"%@", transaction.error);
                
                // finish transaction
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                
                // send operation
                id<EMStoreManagerOperation> currentOperation = _currentOperation;
                if (currentOperation && currentOperation.type == EMStoreManagerOperationTypeBuy) {
                    if (currentOperation) {
                        currentOperation.failureBlock( transaction.error );
                    }
                }
                
                break;
            }
                // Restored transaction
            case SKPaymentTransactionStateRestored: {
                [self successProductActionWithTransaction:transaction];
                
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                
                // [self performSelector:@selector(changeStatePurchaseProcessing) withObject:nil afterDelay:1.0];
                
                break;
            }
                // Purchased
            case SKPaymentTransactionStatePurchased: {
                [self successProductActionWithTransaction:transaction];
                
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                
                // [self performSelector:@selector(changeStatePurchaseProcessing) withObject:nil afterDelay:1.0];
                NSLog(@"Транзакция с iTunes прошла успешно");
                
                break;
            }
            // In process...
            case SKPaymentTransactionStatePurchasing: {
                // self.isPurchaseProcessing = YES;
                NSLog(@"Подождите покупаем...");
                break;
            }
            default:
                break;
        }
    }
}

- (void) successProductActionWithTransaction:(SKPaymentTransaction*) transaction {
    NSAssert(_sharedSecret!=nil, @"Set up EMStoreManager share secret in you AppDelegate!");
    
    // current operation
    BOOL isRestore = NO;
    id<EMStoreManagerOperation> currentOperation = _currentOperation;
    if (currentOperation && currentOperation.type == EMStoreManagerOperationTypeRestore) {
        isRestore = YES;
    }
    
    // if is restoring process, add transaction to queue
    NSString *transactionKey = [NSString stringWithFormat:@"%p", transaction];
    if (isRestore) {
        [_procesingTransactions setObject:transactionKey forKey:transactionKey];
    }
    
    // NSString *productID = transaction.payment.productIdentifier;
    
    [[CargoBay sharedManager] verifyTransaction:transaction password:_sharedSecret success:^(NSDictionary *rawReceipt) {
        
        NSDictionary *receiptInfo = (NSDictionary *)[rawReceipt objectForKey:@"receipt"];
        EMStoreManagerReceipt *receipt = [EMStoreManagerReceipt receiptFromDictionary:receiptInfo];
        
        if (receipt) {
            if (receipt.isProduct) {
                [_restoreProducts setObject:receipt forKey:receipt.productID];
            } else {
                [_restoreSubscriptions setObject:receipt forKey:receipt.uniqueID];
            }
        }
        
        // success block condition
        BOOL performSuccessBlock = NO;
        // if current operation is buy, when transaction only one
        // and we can send notify
        if (currentOperation && currentOperation.type == EMStoreManagerOperationTypeBuy) {
            performSuccessBlock = YES;
        }
        // if it is restore operation, transaction can be multiple
        // check them all
        if (currentOperation && currentOperation.type == EMStoreManagerOperationTypeRestore) {
            [_procesingTransactions removeObjectForKey:transactionKey];
            
            if ([_procesingTransactions count] == 0) {
                performSuccessBlock = YES;
            }
        }
        
        // perform success block
        if (performSuccessBlock) {
            // save in NSUserDefaults
            [self saveReceiptsInUserDefaults];

            if (currentOperation) {
                currentOperation.finishBlock();
            }
            
            // send push notification
            [[NSNotificationCenter defaultCenter] postNotificationName:EMStoreManagerRestoreNotification object:nil userInfo:nil];
        }
        
    } failure:^(NSError *error) {
        
        NSLog(@"Purchased Failure %@", [error localizedDescription]);
        
        // success block condition
        BOOL performFailureBlock = NO;
        // if current operation is buy, when transaction only one
        // and we can send notify
        if (currentOperation && currentOperation.type == EMStoreManagerOperationTypeBuy) {
            performFailureBlock = YES;
        }
        // if it is restore operation, transaction can be multiple
        // check them all
        if (currentOperation && currentOperation.type == EMStoreManagerOperationTypeRestore) {
            [_procesingTransactions removeObjectForKey:transactionKey];
            
            if ([_procesingTransactions count] == 0) {
                performFailureBlock = YES;
            }
        }
        
        // perform success block
        if (performFailureBlock) {
            // save in NSUserDefaults
            [self saveReceiptsInUserDefaults];
            
            if (currentOperation) {
                currentOperation.failureBlock( error );
            }
            
            // send push notification
            [[NSNotificationCenter defaultCenter] postNotificationName:EMStoreManagerRestoreNotification object:nil userInfo:nil];
        }
        
    }];
}

#pragma mark - Opeartion

- (void) sendOperation: (id<EMStoreManagerOperation>) operation {
    self.currentOperation = operation;
    
    if ([operation isKindOfClass:[EMStoreManagerRestoreOperation class]]) {
        
        // clear transaction queue
        [_procesingTransactions removeAllObjects];
        
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
        
    } else {
        
        SKProduct *product = operation.product;
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
    }
}

#pragma mark - Purchase methods

- (BOOL) subscriptionIsActive {
    NSDate *currentDate = [NSDate date];
    return [self dateUnderSubscription:currentDate];
}

- (BOOL) productIsPurchase: (NSString *) productID {
    return ([_restoreProducts objectForKey:productID]) ? YES : NO;
}

- (BOOL) dateUnderSubscription: (NSDate *) date {
    NSTimeInterval curTime = [date timeIntervalSinceReferenceDate];
    
    for (NSString *uniqueID in _restoreSubscriptions) {
        EMStoreManagerReceipt *receipt = [_restoreSubscriptions objectForKey:uniqueID];
        
        NSTimeInterval purTime = [receipt.purchaseDate timeIntervalSinceReferenceDate];
        NSTimeInterval expTime = [receipt.expireDate timeIntervalSinceReferenceDate];
        
        if (curTime > purTime && curTime < expTime) return YES;
    }
    
    return NO;
}

#pragma mark - NSUserDefaults

- (void) restoreFromUserDefaults {
    NSUserDefaults *store = [NSUserDefaults standardUserDefaults];
    
    // clear all data
    [_restoreProducts removeAllObjects];
    [_restoreSubscriptions removeAllObjects];
    
    // restore products
    NSArray *storeProducts = [store arrayForKey:EMStoreManager_NSUserDefaults_StoreKeyProducts];
    if (storeProducts) {
        for (NSData *encodedObject in storeProducts) {
            EMStoreManagerReceipt *receipt = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
            if (receipt) {
                [_restoreProducts setObject:receipt forKey:receipt.uniqueID];
            }
        }
    }
    
    // restore subscr
    NSArray *storeSubscription = [store arrayForKey:EMStoreManager_NSUserDefaults_StoreKeySubscription];
    if (storeSubscription) {
        for (NSData *encodedObject in storeSubscription) {
            EMStoreManagerReceipt *receipt = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
            if (receipt) {
                [_restoreSubscriptions setObject:receipt forKey:receipt.uniqueID];
            }
        }
    }
}

- (void) saveReceiptsInUserDefaults {
    NSUserDefaults *store = [NSUserDefaults standardUserDefaults];
    
    if (_restoreProducts) {
        NSMutableArray *forStore = [NSMutableArray arrayWithCapacity: [_restoreProducts count]];
        for (NSString *key in _restoreProducts) {
            EMStoreManagerReceipt *receipt = [_restoreProducts objectForKey:key];
            NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:receipt];
            
            [forStore addObject:encodedObject];
        }
        
        [store setObject:forStore forKey:EMStoreManager_NSUserDefaults_StoreKeyProducts];
    }
    if (_restoreSubscriptions) {
        NSMutableArray *forStore = [NSMutableArray arrayWithCapacity: [_restoreSubscriptions count]];
        for (NSString *key in _restoreSubscriptions) {
            EMStoreManagerReceipt *receipt = [_restoreSubscriptions objectForKey:key];
            NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:receipt];
            
            [forStore addObject:encodedObject];
        }
        
        [store setObject:forStore forKey:EMStoreManager_NSUserDefaults_StoreKeySubscription];
    }
    
    
    [store synchronize];
}

@end
