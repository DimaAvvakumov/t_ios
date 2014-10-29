//
//  DownloadIssuesOperation.h
//  proteplo
//
//  Created by Dima Avvakumov on 28.02.14.
//  Copyright (c) 2014 Dima Avvakumov. All rights reserved.
//

#import "DownloadManagerOperation.h"

typedef void (^DownloadIssuesOperationFinishBlock)(NSInteger errorCode, BOOL isActualState);

@interface DownloadIssuesOperation : DownloadManagerOperation

@property (copy, nonatomic) DownloadIssuesOperationFinishBlock finishBlock;

@property (assign, nonatomic) NSRange range;

@end
