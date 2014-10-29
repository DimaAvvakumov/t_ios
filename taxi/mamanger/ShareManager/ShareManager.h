//
//  ShareManager.h
//
//  Created by Maxim Keegan on 31.12.13.
//  Copyright (c) 2014 East-media. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ShareItem : NSObject
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *imagePath;
@property (strong, nonatomic) NSURL *imageURL;

@end


@interface ShareManager : NSObject

+ (ShareManager *) defaultManager;

- (void) shareFacebook: (ShareItem *) shareItem;
- (void) shareTwitter: (ShareItem *) shareItem;
- (void) shareEmail: (ShareItem *) shareItem;

@end

