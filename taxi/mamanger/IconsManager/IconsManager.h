//
//  IconsManager.h
//  proteplo
//
//  Created by Dima Avvakumov on 13.04.14.
//  Copyright (c) 2014 Dima Avvakumov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IconsManager : NSObject

@property (strong, nonatomic) UIColor *mainColor;

+(IconsManager *) defaultManager;

#pragma mark - Close icon
- (UIImage *) closeIcon;
- (UIImage *) closeIconWithColor: (UIColor *) color;

#pragma mark - List icon
- (UIImage *) listIcon;
- (UIImage *) listIconWithColor: (UIColor *) color;

#pragma mark - Search icon
- (UIImage *) searchIcon;
- (UIImage *) searchIconWithColor: (UIColor *) color;

#pragma mark - Send comment
- (UIImage *) commentsIcon;
- (UIImage *) commentsIconWithColor: (UIColor *) color;

#pragma mark - Dot 
- (UIImage *) dotIcon;
- (UIImage *) dotIconWithColor: (UIColor *) color;

#pragma mark - Right arrow
- (UIImage *) rightArrow;
- (UIImage *) rightArrowWithColor: (UIColor *) color;

@end
