//
//  NewsstandManager.m
//  proteplo
//
//  Created by Dima Avvakumov on 27.03.14.
//  Copyright (c) 2014 Dima Avvakumov. All rights reserved.
//

#import "NewsstandManager.h"

@implementation NewsstandManager

- (id) init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (NewsstandManager *) defaultManager {
    static NewsstandManager *instance = nil;
    if (instance == nil) {
        instance = [[NewsstandManager alloc] init];
    }
    return instance;
}

- (void) setIconByIssue: (NSInteger) issueID {
    IssueItem *item = [[CoreDataManager defaultManager] issueItemByID:issueID];
    if (item.imageNewsstandPath == nil) return;
    
    // cancel previos binding
    NSString *imageKey = [NSString stringWithFormat:@"%p", self];
    [[DMImageManager defaultManager] cancelBindingByIdentifier:imageKey];
    
    // binding image
    NSString *localImagePath = [item.imageNewsstandPath stringByReplacingOccurrencesOfString:@"://" withString:@"_"];
    NSString *imagePath = [[[NSFileManager defaultManager] cacheDataPath] stringByAppendingPathComponent:localImagePath];
    NSString *imageURL = item.imageNewsstandPath;
    
    DMImageOperation *operation = [[DMImageOperation alloc] initWithImagePath:imagePath identifer:imageKey andBlock:^(UIImage *image) {
        
        [[UIApplication sharedApplication] setNewsstandIconImage:image];
    }];
    operation.downloadURL = [NSURL URLWithString: imageURL];
    [[DMImageManager defaultManager] addOperation: operation];
}

@end
