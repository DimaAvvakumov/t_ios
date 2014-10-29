//
//  DownloadCommentsOperation.h
//  igazeta
//
//  Created by Lobanov Aleksey on 12/02/14.
//  Copyright (c) 2014 East-media. All rights reserved.
//

#import "DownloadManagerOperation.h"

typedef void (^DownloadCommentsOperationCompetitionBlock)(NSInteger errorCode, BOOL isActualState);

@interface DownloadCommentsOperation : DownloadManagerOperation

- (id) initWithNodeID:(NSInteger)nodeID
      existCommentIds:(NSArray *)commentIDs
               offset:(NSInteger)offset
               length:(NSInteger)length
             andBlock:(DownloadCommentsOperationCompetitionBlock) block;

@end
