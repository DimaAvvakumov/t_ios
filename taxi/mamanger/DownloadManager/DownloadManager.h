//
//  DownloadManager.h
//  DMProject
//
//  Created by Dima Avvakumov on 18.12.12.
//  Copyright (c) 2012 Dima Avvakumov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DownloadInfo.h"

#import "DownloadIssuesOperation.h"
#import "DownloadBannersOperation.h"
#import "DownloadNodesOperation.h"
#import "DownloadCommentsOperation.h"

//#define DownloadManagerUserInfoKeyError @"error"
//#define DownloadManagerUserInfoKeyProgress @"progress"
//#define DownloadManagerUserInfoKeyArticleID @"articleID"
//#define DownloadManagerUserInfoKeyArticleIds @"articleIds"
//#define DownloadManagerUserInfoKeyItemsIds @"itemsIds"
//#define DownloadManagerUserInfoKeyActualState @"actualState"
//#define DownloadManagerUserInfoKeyBannerUpdated @"bannerUpdated"
//#define DownloadManagerUserInfoKeyFileID @"fileID"
//#define DownloadManagerUserInfoKeyIsUpdated @"isUpdated"
//#define DownloadManagerUserInfoKeyChatThreadID @"threadID"

#pragma mark - DownloadManagerDelegate @protocol

@protocol DownloadManagerDelegate <NSObject>

@optional
- (void) downloadManagerIssuesDownloaded: (DownloadInfo *) info;
- (void) downloadManagerCommentsDownloaded: (DownloadInfo *) info;

@end

#pragma mark - DownloadManager @interface

@interface DownloadManager : NSObject

+ (DownloadManager *) defaultManager;

#pragma mark - Observer methods
- (void) addObserver: (id <DownloadManagerDelegate>) observer;
- (void) removeObserver: (id <DownloadManagerDelegate>) observer;

#pragma mark - Add/remove operation methods
- (void) queueAddOperation: (DownloadManagerOperation *) operation;
- (void) queueCancelOperation: (DownloadManagerOperation *) operation;

#pragma mark - Cancel custom operation
- (void) cancelDownloadByIdentifer: (NSString *) identifer;

#pragma mark - Check exist custom operation
- (BOOL) operationWithIdentifierExist: (NSString *) identifer;

#pragma mark - Issues methods
- (BOOL) issuesIsDownloaded;
- (void) downloadIssuesInRange: (NSRange) range;

#pragma mark - Comments
- (void) downloadCommentsWithNodeID:(NSInteger) nodeID
                    existCommentIds:(NSArray*)commentIDs
                             offset:(NSInteger)offset
                             length:(NSInteger)length;

@end