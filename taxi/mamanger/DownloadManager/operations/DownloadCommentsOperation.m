//
//  DownloadCommentsOperation.m
//  igazeta
//
//  Created by Lobanov Aleksey on 12/02/14.
//  Copyright (c) 2014 East-media. All rights reserved.
//

#import "DownloadCommentsOperation.h"

@interface DownloadCommentsOperation()

@property (strong, nonatomic) NSArray *existCommentIDs;
@property (assign, nonatomic) NSInteger nodeID;
@property (assign, nonatomic) NSInteger offset;
@property (assign, nonatomic) NSInteger length;
@property (copy, nonatomic) DownloadCommentsOperationCompetitionBlock block;

@property (assign, nonatomic) BOOL isActualState;

@end

@implementation DownloadCommentsOperation

- (id) initWithNodeID:(NSInteger)nodeID
      existCommentIds:(NSArray *)commentIDs
               offset:(NSInteger)offset
               length:(NSInteger)length
             andBlock:(DownloadCommentsOperationCompetitionBlock)block
{
    self = [super init];
    if (self) {
        self.nodeID = nodeID;
        self.existCommentIDs = commentIDs;
        self.offset = offset;
        self.length = length;
        self.block = block;
        self.isActualState = YES;
    }
    return self;
}

#pragma mark - NSOperation methods

- (void) start {
    [self beforeStart];
    
    [self downloadItems];
    
    [[CoreDataManager defaultManager] saveContext];
    [self executeBlock];
    [self finish];
}

- (NSString *) addVersionForCommentsIds:(NSArray *) comments {
    NSMutableArray *cemmentMetaIds = nil;
    if (comments && [comments count] > 0) {
        cemmentMetaIds = [NSMutableArray arrayWithCapacity:[comments count]];
        for (CommentItem *item in comments) {
            NSString *metaId = [NSString stringWithFormat:@"%d:%d", item.commentID, item.version];
            
            [cemmentMetaIds addObject:metaId];
        }
    }
    if (cemmentMetaIds && [cemmentMetaIds count] > 0) {
        return [cemmentMetaIds componentsJoinedByString:@","];
    } else {
        return @"";
    }
}

- (BOOL) downloadItems {
    // performing params
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:[NSNumber numberWithInt:1] forKey:@"jsonResponse"];
    [params setObject:((IS_PAD) ? @"iPad" : @"iPhone") forKey:@"family"];
    [params setObject:[NSNumber numberWithInt:(([UIScreen isRetina]) ? 1 : 0)] forKey:@"retina"];
    [params setObject:[self addVersionForCommentsIds:_existCommentIDs] forKey:@"ids"];
    [params setObject:[NSNumber numberWithInteger:_nodeID] forKey:@"nodeID"];
    [params setObject:[NSNumber numberWithInteger:_offset] forKey:@"offset"];
    [params setObject:[NSNumber numberWithInteger:_length] forKey:@"length"];
    
    // performing request
//    NSURL *baseURL = [ConfigManager defaultManager].serverURL;
//    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL: baseURL];
//    NSString *path = [NSString stringWithFormat:@"%@/comments/load.html", ALLocalizationGetLanguage];
//    NSMutableURLRequest *request = [client requestWithMethod:@"POST" path:path parameters:params];
//    [request setCachePolicy: NSURLRequestReloadIgnoringCacheData];
//    [request setTimeoutInterval: 30.0];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *path = [NSString stringWithFormat:@"%@%@/comments/load.html", [ConfigManager defaultManager].serverAbsolutePath, ALLocalizationGetLanguage];
    
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
    
//    NSLog(@"Operation sleep download!");
    
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
    
//    NSLog(@"Operation wake up!");
    
    if (self.error) {
        [self executeBlock];
        return NO;
    }
    
    [self parseDownloadInfo: self.JSON];
    
    return YES;
}

- (void) parseDownloadInfo:(NSDictionary *)json {
    
#pragma mark parse request
    NSArray *commentItems = [json objectForKey: @"comments"];
    if (commentItems && [commentItems isKindOfClass: [NSArray class]]) {
        if ([commentItems count] > 0) {
            self.isActualState = NO;
        }
        
        for (NSDictionary *itemInfo in commentItems) {
            [[CoreDataManager defaultManager] parseCommentItem:itemInfo withNodeID:_nodeID];
        }
    }
}

- (void) executeBlock {
    if (_block && !_isCancelled) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            _block(self.error , _isActualState);
        });
    }
}


@end
