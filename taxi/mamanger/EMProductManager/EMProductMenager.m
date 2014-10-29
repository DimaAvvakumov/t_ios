//
//  EMProductMenager.m
//  proteplo
//
//  Created by Dmitry Avvakumov on 28.07.14.
//  Copyright (c) 2014 Dima Avvakumov. All rights reserved.
//

#import "EMProductMenager.h"
#import "WeakReference.h"

@interface EMProductMenager()

@property (strong, nonatomic) NSMutableArray *products;
@property (strong, nonatomic) NSMutableDictionary *pandingProducts;
@property (strong, nonatomic) NSMutableDictionary *pandingRequests;
@property (strong, nonatomic) NSMutableArray *invalidProducts;

@property (strong, nonatomic) NSMutableDictionary *registerDelegate;

@end

@implementation EMProductMenager

#pragma mark - Init

- (id)init {
    self = [super init];
    if (self) {
        self.products = [NSMutableArray arrayWithCapacity:10];
        self.pandingProducts = [NSMutableDictionary dictionaryWithCapacity:10];
        self.pandingRequests = [NSMutableDictionary dictionaryWithCapacity:10];
        self.invalidProducts = [NSMutableArray arrayWithCapacity:10];
        
        self.registerDelegate = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return self;
}

+ (EMProductMenager *) defaultManager {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (SKProduct *) productByIdentifier: (NSString *) identifier {
    NSInteger index = [self indexOfDownloadedProduct:identifier];
    if (index == NSNotFound) return nil;
    
    return (SKProduct *) [_products objectAtIndex:index];
}

- (BOOL) productIsInvalid: (NSString *) identifier {
    NSInteger index = [self indexOfInvalidProduct:identifier];
    if (index == NSNotFound) return NO;
    
    return YES;
}

- (BOOL) productIsPadding: (NSString *) identifier {
    BOOL isPanding = ([_pandingProducts objectForKey:identifier]) ? YES : NO;
    
    return isPanding;
}

//- (BOOL) productNeedDownload: (NSString *) identifier {
//    SKProduct *product = [self productByIdentifier:identifier];
//    if (product) return NO;
//    
//    if ([self productIsPadding:identifier]) return NO;
//    
//    if ([self productIsInvalid:identifier]) return NO;
//    
//    return YES;
//}

- (EMProductStatus)productStatusByIdentifier:(NSString *)identifier {
    SKProduct *product = [self productByIdentifier:identifier];
    if (product) return EMProductStatusReady;
    
    if ([self productIsPadding:identifier]) return EMProductStatusLoading;
    
    if ([self productIsInvalid:identifier]) return EMProductStatusInvalid;
    
    return EMProductStatusUndefined;
}

- (void) requestInfoByIdentifiers: (NSArray *) ids {
	NSMutableArray *productToDownload = [NSMutableArray arrayWithCapacity: [ids count]];
	for (int i = 0; i < [ids count]; i++) {
		NSString *identifier = [ids objectAtIndex: i];
        
        EMProductStatus status = [self productStatusByIdentifier:identifier];
        if (status != EMProductStatusUndefined) continue;
        
//        BOOL needDownlaod = [self productNeedDownload:identifier];
//        if (!needDownlaod) return;
        
//		NSInteger index = [self indexOfDownloadedProduct: identifier];
//		if (index != NSNotFound) continue;
//        
////		index = [self indexOfPandingProduct: identifier];
////		if (index != NSNotFound) continue;
        
		[productToDownload addObject: identifier];
        
        // set product to panding
        [_pandingProducts setObject:identifier forKey:identifier];
        
		// [_pandingProducts addObject: identifier];
	}
    
    if ([productToDownload count] == 0) return;
    NSSet *setOfIdentifiers = [NSSet setWithArray:productToDownload];
	SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:setOfIdentifiers];
    
    // products by request
    NSString *requestKey = [NSString stringWithFormat:@"%p", request];
    [_pandingRequests setObject:productToDownload forKey:requestKey];
    
    request.delegate = self;
    [request start];
}

#pragma mark - Internal array search

- (NSInteger) indexOfDownloadedProduct: (NSString *) identifier {
    for (int i = 0; i < [_products count]; i++) {
        SKProduct *product = [_products objectAtIndex:i];
        if ([product.productIdentifier isEqualToString:identifier]) {
            return (NSInteger) i;
        }
    }
    return NSNotFound;
}

//- (NSInteger) indexOfPandingProduct: (NSString *) identifier {
//    for (int i = 0; i < [_pandingProducts count]; i++) {
//        NSString *productIdentifier = [_pandingProducts objectAtIndex:i];
//        if ([productIdentifier isEqualToString:identifier]) {
//            return (NSInteger) i;
//        }
//    }
//    return NSNotFound;
//}

- (NSInteger) indexOfInvalidProduct: (NSString *) identifier {
    for (int i = 0; i < [_invalidProducts count]; i++) {
        NSString *productIdentifier = [_invalidProducts objectAtIndex:i];
        if ([productIdentifier isEqualToString:identifier]) {
            return (NSInteger) i;
        }
    }
    return NSNotFound;
}

#pragma mark - Store products

- (void) registerInvalidIdentifiers: (NSArray *) invalidIdentifiers {
    for (NSString *invalidID in invalidIdentifiers) {
        NSInteger index = [self indexOfInvalidProduct:invalidID];
        
        if (index == NSNotFound) {
            [_invalidProducts addObject:invalidID];
        }
    }
}

- (void) registerProductIdentifiers: (NSArray *) products {
    for (SKProduct *product in products) {
        NSInteger index = [self indexOfDownloadedProduct:product.productIdentifier];
        
        if (index == NSNotFound) {
            [_products addObject:product];
        }
    }
}

#pragma mark - Delegate

- (void) registerDelegate: (id<EMProductMenagerDelegate>) delegate {
    NSString *delegateKey = [NSString stringWithFormat:@"%p", delegate];
    WeakReference *weakDelegate = [WeakReference weakReferenceWithObject:delegate];
    
    [_registerDelegate setObject:weakDelegate forKey:delegateKey];
}

- (void) unregisterDelegate: (id<EMProductMenagerDelegate>) delegate {
    NSString *delegateKey = [NSString stringWithFormat:@"%p", delegate];
    
    [_registerDelegate removeObjectForKey:delegateKey];
}

#pragma mark - SKProductsRequestDelegate

- (void) request:(SKRequest *)request didFailWithError:(NSError *)error {
    // products by request
    NSString *requestKey = [NSString stringWithFormat:@"%p", request];
    NSArray *productToDownload = [_pandingRequests objectForKey:requestKey];
    if (productToDownload) {
        for (NSString *identifiers in productToDownload) {
            [_pandingProducts removeObjectForKey:identifiers];
        }
    }
    
    // send message by delegates
    for (NSString *delegateKey in _registerDelegate) {
        WeakReference *weakDelegate = [_registerDelegate objectForKey:delegateKey];
        id<EMProductMenagerDelegate> delegate = [weakDelegate nonretainedObjectValue];
        if (delegate) {
            [delegate productManager:self requestFailureWithError:error];
        }
    }
    
    // remove information about request
    [_pandingRequests removeObjectForKey:requestKey];
}

- (void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    // products by request
    NSString *requestKey = [NSString stringWithFormat:@"%p", request];
    NSArray *productToDownload = [_pandingRequests objectForKey:requestKey];
    if (productToDownload) {
        for (NSString *identifiers in productToDownload) {
            [_pandingProducts removeObjectForKey:identifiers];
        }
    }
    
    // invalid products
    NSArray *invalidProductIdentifiers = response.invalidProductIdentifiers;
    if (invalidProductIdentifiers && [invalidProductIdentifiers count] > 0) {
        [self registerInvalidIdentifiers:invalidProductIdentifiers];
        
        for (NSString *delegateKey in _registerDelegate) {
            WeakReference *weakDelegate = [_registerDelegate objectForKey:delegateKey];
            id<EMProductMenagerDelegate> delegate = [weakDelegate nonretainedObjectValue];
            if (delegate) {
                [delegate productManager:self failureIdentifiers:invalidProductIdentifiers];
            }
        }
    }
    
    // success products
    NSArray *productIdentifiers = response.products;
    if (productIdentifiers && [productIdentifiers count] > 0) {
        [self registerProductIdentifiers:productIdentifiers];
        
        for (NSString *delegateKey in _registerDelegate) {
            WeakReference *weakDelegate = [_registerDelegate objectForKey:delegateKey];
            id<EMProductMenagerDelegate> delegate = [weakDelegate nonretainedObjectValue];
            if (delegate) {
                [delegate productManager:self receivedIdentifiers:productIdentifiers];
            }
        }
    }
    
    // remove information about request
    [_pandingRequests removeObjectForKey:requestKey];
}

@end
