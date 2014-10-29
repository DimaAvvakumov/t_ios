//
//  DownloadNodesOperation.m
//  igazeta
//
//  Created by Dima Avvakumov on 23.11.13.
//  Copyright (c) 2013 East-media. All rights reserved.
//

#import "DownloadNodesOperation.h"

@interface DownloadNodesOperation()

@property (assign, nonatomic) BOOL isActualState;

@end

@implementation DownloadNodesOperation

#pragma mark - NSOperation methods

- (void) start {
    [self beforeStart];
    
    BOOL operationResult = [self downloadItems];
    if (operationResult) {
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
    
    NSMutableArray *itemsTags = nil;
    if (_issueID) {
        [params setObject:[NSNumber numberWithInteger:_issueID] forKey:@"issueID"];
        
        NSArray *items = [[CoreDataManager defaultManager] nodeItemsWithIssueID:_issueID];
        if (items) {
            itemsTags = [NSMutableArray arrayWithCapacity:[items count]];
            for (NodeItem *item in items) {
                NSString *tag = [NSString stringWithFormat:@"%lld:%d", item.nodeID, item.version];
                
                [itemsTags addObject:tag];
            }
        }
    } else if (_ids) {
        itemsTags = [NSMutableArray array];
        for (NSNumber *nodeId in _ids) {
            NodeItem *item = [[CoreDataManager defaultManager] nodeByID:[nodeId integerValue]];
            NSString *tag;
            if (item) {
                tag = [NSString stringWithFormat:@"%lld:%d", item.nodeID, item.version];
            } else {
                tag = [NSString stringWithFormat:@"%d:%d", [nodeId intValue], 0];
            }
            
            [itemsTags addObject:tag];
        }
    }
    
    if (itemsTags) {
        [params setObject:[itemsTags componentsJoinedByString:@","] forKey:@"ids"];
    }

    // performing request
//    NSURL *baseURL = [ConfigManager defaultManager].serverURL;
//    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL: baseURL];
//    NSString *path = [NSString stringWithFormat:@"%@/node/list.html", ALLocalizationGetLanguage];
//    NSMutableURLRequest *request = [client requestWithMethod:@"POST" path:path parameters:params];
//    [request setCachePolicy: NSURLRequestReloadIgnoringCacheData];
//    [request setTimeoutInterval: 30.0];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *path = [NSString stringWithFormat:@"%@%@/node/list.html", [ConfigManager defaultManager].serverAbsolutePath, ALLocalizationGetLanguage];
    
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
    
    [self parseDownloadInfo: self.JSON];
    
    return YES;
}

- (void) parseDownloadInfo:(NSDictionary *)json {
    CoreDataManager *coreData = [CoreDataManager defaultManager];
    
    self.isActualState = YES;
    
    #pragma mark parse request
    NSArray *nodesItems = [json objectForKey: @"nodeItems"];
    if (nodesItems && [nodesItems isKindOfClass: [NSArray class]]) {
        for (NSDictionary *itemInfo in nodesItems) {
            [coreData parseNodeItem:itemInfo];
            
            self.isActualState = NO;
        }
    }
    
    #pragma mark parse delete request
    NSArray *itemsToDelete = [json objectForKey: @"nodeToDelete"];
    if (itemsToDelete && [itemsToDelete isKindOfClass: [NSArray class]]) {
        for (NSNumber *itemNumber in itemsToDelete) {
            NSInteger itemID = [itemNumber integerValue];
            NodeItem *nodeItem = [coreData nodeByID:itemID];
            
            if (nodeItem) {
                [coreData removeObjectFromContext:nodeItem];
            }
            
            self.isActualState = NO;
        }
    }

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
