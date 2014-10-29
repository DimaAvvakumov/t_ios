//
//  IconsManager.m
//  proteplo
//
//  Created by Dima Avvakumov on 13.04.14.
//  Copyright (c) 2014 Dima Avvakumov. All rights reserved.
//

#import "IconsManager.h"

@implementation IconsManager

- (id) init {
    self = [super init];
    if (self) {
        self.mainColor = [UIColor orangeColor];
    }
    return self;
}

+(IconsManager *) defaultManager {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Close icon

- (UIImage *) closeIcon {
    return [self closeIconWithColor:_mainColor];
}

- (UIImage *) closeIconWithColor: (UIColor *) color {
    CGSize size = CGSizeMake(20.0, 20.0);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextMoveToPoint(context, 0.5, 0.5);
    CGContextAddLineToPoint(context, 19.5, 19.5);
    CGContextMoveToPoint(context, 19.5, 0.5);
    CGContextAddLineToPoint(context, 0.5, 20.0);
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokePath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - List icon

- (UIImage *) listIcon {
    return [self listIconWithColor:_mainColor];
}

- (UIImage *) listIconWithColor: (UIColor *) color {
    CGSize size = CGSizeMake(34.0, 34.0);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // stroke color
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    
    // first line
    CGContextMoveToPoint(context, 4.5, 7.5);
    CGContextAddLineToPoint(context, 29.5, 7.5);
    
    // second line
    CGContextMoveToPoint(context, 4.5, 16.5);
    CGContextAddLineToPoint(context, 29.5, 16.5);
    
    // thrid line
    CGContextMoveToPoint(context, 4.5, 25.5);
    CGContextAddLineToPoint(context, 29.5, 25.5);
    
    // draw lines
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokePath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Search icon

- (UIImage *) searchIcon {
    return [self searchIconWithColor:_mainColor];
}

- (UIImage *) searchIconWithColor: (UIColor *) color {
    CGSize size = CGSizeMake(34.0, 34.0);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    
    // circle
    CGContextAddArc(context, 19.0, 15.0, 7.5, 0.0, 2.0 * M_PI, 1);
    
    // line
    CGContextMoveToPoint(context, 6.5, 29.5);
    CGContextAddLineToPoint(context, 14.5, 21.5);
    
    // draw lines
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokePath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Send comment

- (UIImage *) commentsIcon {
    return [self commentsIconWithColor:_mainColor];
}

- (UIImage *) commentsIconWithColor:(UIColor *)color {
    CGSize size = CGSizeMake(23.0, 23.0);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    
    // line
    CGContextMoveToPoint(context, 0.5, 0.5);
    CGContextAddLineToPoint(context, 22.5, 0.5);
    CGContextAddLineToPoint(context, 22.5, 15.5);
    CGContextAddLineToPoint(context, 13.5, 15.5);
    CGContextAddLineToPoint(context, 7.5, 21.5);
    CGContextAddLineToPoint(context, 7.5, 15.5);
    CGContextAddLineToPoint(context, 0.5, 15.5);
    CGContextAddLineToPoint(context, 0.5, 0.5);
    
    // draw lines
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokePath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Dot

- (UIImage *) dotIcon {
    return [self dotIconWithColor:_mainColor];
}

- (UIImage *) dotIconWithColor: (UIColor *) color {
    CGSize size = CGSizeMake(4.0, 4.0);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    // circle
    CGContextAddArc(context, 2.0, 2.0, 2.0, 0.0, 2.0 * M_PI, 1);
    
    // draw lines
    CGContextFillPath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Right arrow

- (UIImage *) rightArrow {
    return [self rightArrowWithColor:_mainColor];
}

- (UIImage *) rightArrowWithColor: (UIColor *) color {
    CGSize size = CGSizeMake(20.0, 20.0);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    
    // line
    CGContextMoveToPoint(context, 5.5, 5.5);
    CGContextAddLineToPoint(context, 10.5, 10.5);
    CGContextAddLineToPoint(context, 5.5, 15.5);
    
    // draw lines
    CGContextSetLineWidth(context, 2.0);
    CGContextStrokePath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
 
}


@end
