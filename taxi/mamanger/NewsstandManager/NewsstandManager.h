//
//  NewsstandManager.h
//  proteplo
//
//  Created by Dima Avvakumov on 27.03.14.
//  Copyright (c) 2014 Dima Avvakumov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsstandManager : NSObject

+ (NewsstandManager *) defaultManager;

- (void) setIconByIssue: (NSInteger) issueID;

@end
