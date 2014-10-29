//
//  DownloadBannersOperation.h
//  proteplo
//
//  Created by Dima Avvakumov on 09.04.14.
//  Copyright (c) 2014 Dima Avvakumov. All rights reserved.
//

#import "DownloadManagerOperation.h"

typedef void (^DownloadBannersOperationCompetitionBlock)(NSInteger errorCode);
typedef void (^DownloadBannersOperationProgressBlock)(CGFloat progress);

@interface DownloadBannersOperation : DownloadManagerOperation

@property (copy, nonatomic) DownloadBannersOperationCompetitionBlock finishBlock;
@property (copy, nonatomic) DownloadBannersOperationProgressBlock progressBlock;

@end
