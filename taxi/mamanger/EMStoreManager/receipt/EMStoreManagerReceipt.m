NSString *uniqueID = nil;//
//  EMStoreManagerReceipt.m
//  proteplo
//
//  Created by Dmitry Avvakumov on 29.07.14.
//  Copyright (c) 2014 Dima Avvakumov. All rights reserved.
//

#import "EMStoreManagerReceipt.h"

@implementation EMStoreManagerReceipt

#pragma mark - NSKeyArchived

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeBool:_isProduct forKey:@"isProduct"];
    if (_productID) {
        [encoder encodeObject:_productID forKey:@"productID"];
    }
    if (_uniqueID) {
        [encoder encodeObject:_uniqueID forKey:@"uniqueID"];
    }
    if (_purchaseDate) {
        [encoder encodeObject:_purchaseDate forKey:@"purchaseDate"];
    }
    if (_expireDate) {
        [encoder encodeObject:_expireDate forKey:@"expireDate"];
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.isProduct = [decoder decodeBoolForKey:@"isProduct"];
        self.productID = [decoder decodeObjectForKey:@"productID"];
        self.uniqueID  = [decoder decodeObjectForKey:@"uniqueID"];
        self.purchaseDate = [decoder decodeObjectForKey:@"purchaseDate"];
        self.expireDate = [decoder decodeObjectForKey:@"expireDate"];
    }
    return self;
}

+ (EMStoreManagerReceipt *) receiptFromDictionary: (NSDictionary *) itemInfo {
    
    EMStoreManagerReceipt *receipt = [[EMStoreManagerReceipt alloc] init];
    
    BOOL isProduct = YES;
    NSString *productID = [itemInfo objectForKey:@"product_id"];
    NSString *uniqueID = productID;
    NSDate *purchaseDate = nil;
    NSDate *expireDate = nil;
    
    // expire date
    NSNumber *expireDateString = [itemInfo objectForKey:@"expires_date"];
    if (expireDateString != nil) {
        isProduct = NO;
        expireDate = [NSDate dateWithTimeIntervalSince1970:([expireDateString doubleValue]/1000.0)];
        
        NSNumber *purchaseDateString = [itemInfo objectForKey:@"original_purchase_date_ms"];
        if (!purchaseDateString) {
            return nil;
        }
        purchaseDate = [NSDate dateWithTimeIntervalSince1970:([purchaseDateString doubleValue]/1000.0)];
        
        //unique id
        uniqueID = [NSString stringWithFormat:@"%@:%@-%@", productID, purchaseDate, expireDate];
    }
    
    receipt.isProduct = isProduct;
    receipt.productID = productID;
    receipt.uniqueID = uniqueID;
    receipt.expireDate = expireDate;
    receipt.purchaseDate = purchaseDate;
    
    return receipt;
}

@end
