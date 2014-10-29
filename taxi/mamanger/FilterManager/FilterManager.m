//
//  FilterManager.m
//  igazeta
//
//  Created by Dima Avvakumov on 31.12.13.
//  Copyright (c) 2013 East-media. All rights reserved.
//

#import "FilterManager.h"
#import "ObserverWrapper.h"

@interface FilterManager() {
    NSInteger _currentIssue;
    NSInteger _currentCategory;
}

@property (strong, nonatomic) NSMutableArray *listObservers;

@end

@implementation FilterManager

- (id) init {
    self = [super init];
    if (self) {
        _currentIssue = -1;
        _currentCategory = -1;
        
        // observers
        self.listObservers = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

+ (FilterManager *) defaultManager {
    static FilterManager *instance = nil;
    if (instance == nil) {
        instance = [[FilterManager alloc] init];
    }
    return instance;
}

- (void) setCurrentIssueID: (NSInteger) issueID {
    _currentIssue = issueID;
    
    // send observers notifications
    for (ObserverWrapper *observerWrapper in _listObservers) {
        id <FilterManagerDelegate>observer = observerWrapper.observerObject;
        if (observer == nil) continue;
        
        if ([observer respondsToSelector:@selector(filterManagerParamsChanged)]) {
            [observer filterManagerParamsChanged];
        }
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:FilterManager_ChangeFontNotification object:nil];
}

- (NSInteger) currentIssueID {
    return _currentIssue;
}

- (void) setCurrentCatgoryID:(NSInteger)categoryID {
    _currentCategory = categoryID;
    
    // send observers notifications
    for (ObserverWrapper *observerWrapper in _listObservers) {
        id <FilterManagerDelegate>observer = observerWrapper.observerObject;
        if (observer == nil) continue;
        
        if ([observer respondsToSelector:@selector(filterManagerParamsChanged)]) {
            [observer filterManagerParamsChanged];
        }
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:FilterManager_ChangeFontNotification object:nil];
}

- (NSInteger) currentCategoryID {
    return _currentCategory;
}

#pragma mark - Observer methods

- (void) addObserver: (id <FilterManagerDelegate>) observer {
    NSUInteger index = [self findObjectInObservers:observer];
    if (index != NSNotFound) return;
    
    ObserverWrapper *observerWrapper = [[ObserverWrapper alloc] init];
    observerWrapper.observerObject = observer;
    
    [_listObservers addObject:observerWrapper];
}

- (void) removeObserver: (id <FilterManagerDelegate>) observer {
    NSUInteger index = [self findObjectInObservers:observer];
    if (index == NSNotFound) return;
    
    [_listObservers removeObjectAtIndex:index];
}

- (NSInteger) findObjectInObservers: (id) object {
    for (int i = 0; i < [_listObservers count]; i++) {
        ObserverWrapper *observer = [_listObservers objectAtIndex:i];
        if ([observer.observerObject isEqual:object]) {
            return i;
        }
    }
    
    return NSNotFound;
}


@end
