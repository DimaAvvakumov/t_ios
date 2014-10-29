//
//  EMStoreManagerReceipt.h
//  proteplo
//
//  Created by Dmitry Avvakumov on 29.07.14.
//  Copyright (c) 2014 Dima Avvakumov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMStoreManagerReceipt : NSObject

@property (assign, nonatomic) BOOL isProduct;
@property (strong, nonatomic) NSString *productID;
@property (strong, nonatomic) NSString *uniqueID;
@property (strong, nonatomic) NSDate *purchaseDate;
@property (strong, nonatomic) NSDate *expireDate;

+ (EMStoreManagerReceipt *) receiptFromDictionary: (NSDictionary *) itemInfo;

@end
