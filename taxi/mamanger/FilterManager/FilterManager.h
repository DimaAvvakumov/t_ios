//
//  FilterManager.h
//  igazeta
//
//  Created by Dima Avvakumov on 31.12.13.
//  Copyright (c) 2013 East-media. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FilterManager_ChangeFontNotification @"FilterManager_ChangeFontNotification"

@protocol FilterManagerDelegate <NSObject>

@optional
- (void) filterManagerParamsChanged;

@end

@interface FilterManager : NSObject

+ (FilterManager *) defaultManager;

- (void) setCurrentIssueID: (NSInteger) issueID;
- (NSInteger) currentIssueID;

- (void) setCurrentCatgoryID: (NSInteger) categoryID;
- (NSInteger) currentCategoryID;

- (void) addObserver: (id <FilterManagerDelegate>) observer;
- (void) removeObserver: (id <FilterManagerDelegate>) observer;

@end
