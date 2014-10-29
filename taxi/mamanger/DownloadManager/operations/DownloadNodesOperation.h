//
//  DownloadNodesOperation.h
//  igazeta
//
//  Created by Dima Avvakumov on 23.11.13.
//  Copyright (c) 2013 East-media. All rights reserved.
//

#import "DownloadManagerOperation.h"

typedef void (^DownloadNodesOperationFinishBlock)(NSInteger errorCode, BOOL isActualState);

@interface DownloadNodesOperation : DownloadManagerOperation

@property (copy, nonatomic) DownloadNodesOperationFinishBlock finishBlock;

@property (assign, nonatomic) NSInteger issueID;
@property (assign, nonatomic) NSRange range;
@property (strong, nonatomic) NSArray *ids;

@end
