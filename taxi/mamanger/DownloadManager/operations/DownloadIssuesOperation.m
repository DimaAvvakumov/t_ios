//
//  DownloadIssuesOperation.m
//  proteplo
//
//  Created by Dima Avvakumov on 28.02.14.
//  Copyright (c) 2014 Dima Avvakumov. All rights reserved.
//

#import "DownloadIssuesOperation.h"

@interface DownloadIssuesOperation()

@property (assign, nonatomic) BOOL isActualState;

@end

@implementation DownloadIssuesOperation

#pragma mark - NSOperation methods

- (void) start {
    [self beforeStart];
    
    BOOL result;
    result = [self downloadItems];
    
    if (result) {
        result = [self downloadCategories];
    }
    
    if (result) {
        [[CoreDataManager defaultManager] saveContext];
        
        [self executeBlock];
    } else {
        [self finish];
    }
}

- (BOOL) downloadItems {
    // performing params
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:[NSNumber numberWithInt:1] forKey:@"jsonResponse"];
    [params setObject:((IS_PAD) ? @"iPad" : @"iPhone") forKey:@"family"];
    [params setObject:[NSNumber numberWithInt:(([UIScreen isRetina]) ? 1 : 0)] forKey:@"retina"];
//    [params setObject:[_ids componentsJoinedByString: @","] forKey:@"ids"];
    
    NSMutableArray *issuesTags = nil;
    NSArray *issues = [[CoreDataManager defaultManager] issueItemsWithRange:_range];
    if (issues) {
        issuesTags = [NSMutableArray arrayWithCapacity:[issues count]];
        for (IssueItem *item in issues) {
            NSString *tag = [NSString stringWithFormat:@"%d:%d", item.issueID, item.version];
            
            [issuesTags addObject:tag];
        }
    }
    if (issuesTags) {
        [params setObject:[issuesTags componentsJoinedByString:@","] forKey:@"ids"];
    }
    
    // secret mode
    NSNumber *secretMode = [NSNumber numberWithBool:[[SecretManager defaultManager] isEnabled]];
    [params setObject:secretMode forKey:@"secretMode"];
    
    // performing request
//    NSURL *baseURL = [ConfigManager defaultManager].serverURL;
//    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL: baseURL];
//    NSString *path = [NSString stringWithFormat:@"%@/issues/list.html", ALLocalizationGetLanguage];
//    NSMutableURLRequest *request = [client requestWithMethod:@"POST" path:path parameters:params];
//    [request setCachePolicy: NSURLRequestReloadIgnoringCacheData];
//    [request setTimeoutInterval: 30.0];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *path = [NSString stringWithFormat:@"%@%@/issues/list.html", [ConfigManager defaultManager].serverAbsolutePath, ALLocalizationGetLanguage];
    
    AFURLConnectionOperation *operation = [manager POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
        NSDictionary *JSON = (NSDictionary *) responseObject;
        
        NSInteger resultCode = [[ServerManager defaultManager] parseResultCode:JSON];
        if (resultCode != 0) {
            
            self.error = resultCode;
            self.whileDownloading = NO;
            self.successDownload = NO;
            
            return;
        }
        
        self.JSON = JSON;
        self.whileDownloading = NO;
        self.successDownload = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.error = ServerParams_ErrorServerIsUnavailable;
        
        self.whileDownloading = NO;
        self.successDownload = NO;
    }];
    
    BOOL operationResult = [self waitOperation:operation];
    if (operationResult == NO) return NO;
    
    [self parseDownloadInfo: self.JSON];
    
    return YES;
}

- (void) parseDownloadInfo:(NSDictionary *)json {
    CoreDataManager *coreData = [CoreDataManager defaultManager];
    
    self.isActualState = YES;
    
    #pragma mark parse request
    NSArray *nodesItems = [json objectForKey: @"issues"];
    if (nodesItems && [nodesItems isKindOfClass: [NSArray class]]) {
        for (NSDictionary *itemInfo in nodesItems) {
            [[CoreDataManager defaultManager] parseIssueItem:itemInfo];
            
            self.isActualState = NO;
        }
    }
    
    #pragma mark parse delete request
    NSArray *itemsToDelete = [json objectForKey: @"issuesToDelete"];
    if (itemsToDelete && [itemsToDelete isKindOfClass: [NSArray class]]) {
        for (NSNumber *itemNumber in itemsToDelete) {
            NSInteger issueID = [itemNumber integerValue];
            IssueItem *issueItem = [coreData issueItemByID:issueID];
            
            // nodes
            NSArray *nodeItems = [coreData nodeItemsWithIssueID:issueID];
            if (nodeItems) {
                for (NodeItem *nodeItem in nodeItems) {
                    [coreData removeObjectFromContext:nodeItem];
                }
            }
            
            if (issueItem) {
                [coreData removeObjectFromContext:issueItem];
            }
            
            self.isActualState = NO;
        }
    }
}

#pragma mark - categories

- (BOOL) downloadCategories {
    // performing params
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:[NSNumber numberWithInt:1] forKey:@"jsonResponse"];
    [params setObject:((IS_PAD) ? @"iPad" : @"iPhone") forKey:@"family"];
    [params setObject:[NSNumber numberWithInt:(([UIScreen isRetina]) ? 1 : 0)] forKey:@"retina"];
    [params setObject:ALLocalizationGetLanguage forKey:@"lang"];
    //    [params setObject:[_ids componentsJoinedByString: @","] forKey:@"ids"];
    
    NSMutableArray *issuesTags = nil;
    NSArray *issues = [[CoreDataManager defaultManager] nodeCategoryItems];
    if (issues) {
        issuesTags = [NSMutableArray arrayWithCapacity:[issues count]];
        for (NodeCategory *item in issues) {
            NSString *tag = [NSString stringWithFormat:@"%d:%d", item.categoryID, item.version];
            
            [issuesTags addObject:tag];
        }
    }
    if (issuesTags) {
        [params setObject:[issuesTags componentsJoinedByString:@","] forKey:@"ids"];
    }
    
    // performing request
//    NSURL *baseURL = [ConfigManager defaultManager].serverURL;
//    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL: baseURL];
//    NSString *path = [NSString stringWithFormat:@"%@/categories/list.html", ALLocalizationGetLanguage];
//    NSMutableURLRequest *request = [client requestWithMethod:@"POST" path:path parameters:params];
//    [request setCachePolicy: NSURLRequestReloadIgnoringCacheData];
//    [request setTimeoutInterval: 30.0];

    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *path = [NSString stringWithFormat:@"%@%@/categories/list.html", [ConfigManager defaultManager].serverAbsolutePath, ALLocalizationGetLanguage];
    
    AFURLConnectionOperation *operation = [manager POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *JSON = (NSDictionary *) responseObject;
        
        NSInteger resultCode = [[ServerManager defaultManager] parseResultCode:JSON];
        if (resultCode != 0) {
            
            self.error = resultCode;
            self.whileDownloading = NO;
            self.successDownload = NO;
            
            return;
        }
        
        self.JSON = JSON;
        self.whileDownloading = NO;
        self.successDownload = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.error = ServerParams_ErrorServerIsUnavailable;
        
        self.whileDownloading = NO;
        self.successDownload = NO;
    }];
    
    BOOL operationResult = [self waitOperation:operation];
    if (operationResult == NO) return NO;
    
    [self parseDownloadCategories: self.JSON];
    
    return YES;
}

- (void) parseDownloadCategories:(NSDictionary *)json {
    CoreDataManager *coreData = [CoreDataManager defaultManager];
    
    #pragma mark parse request
    NSArray *nodesItems = [json objectForKey: @"categories"];
    if (nodesItems && [nodesItems isKindOfClass: [NSArray class]]) {
        for (NSDictionary *itemInfo in nodesItems) {
            [coreData parseNodeCategory:itemInfo];
        }
    }
    
    #pragma mark parse delete request
    NSArray *itemsToDelete = [json objectForKey: @"categoriesToDelete"];
    if (itemsToDelete && [itemsToDelete isKindOfClass: [NSArray class]]) {
        for (NSNumber *itemNumber in itemsToDelete) {
            NSInteger itemID = [itemNumber integerValue];
            NodeCategory *nodeItem = [coreData nodeCategoryByID:itemID];
            
            if (nodeItem) {
                [coreData removeObjectFromContext:nodeItem];
            }
            
            self.isActualState = NO;
        }
    }

}

- (BOOL) waitOperation: (NSOperation *) operation {
    self.successDownload = NO;
    self.whileDownloading = YES;
    [operation start];
    
    while (self.whileDownloading) {
        if (_isCancelled) {
            [operation cancel];
            return NO;
        }
        if ([operation isCancelled]) {
            break;
        }
        
        [NSThread sleepForTimeInterval: 0.1];
    }
    
    if (self.error) {
        [self executeBlock];
        return NO;
    }
    
    return YES;
}

- (void) executeBlock {
    [self finish];
    
    if (_finishBlock && !_isCancelled) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            _finishBlock(self.error, _isActualState);
        });
    }
}

@end
