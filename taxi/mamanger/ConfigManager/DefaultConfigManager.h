//
//  DefaultConfigManager.h
//  proteplo
//
//  Created by Dima Avvakumov on 11.04.14.
//  Copyright (c) 2014 Dima Avvakumov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DefaultConfigManager : NSObject

#pragma mark - Lang
- (BOOL) isMultilanguage;
- (NSArray *) languageList;

#pragma mark - Google analytics
- (NSString *) googleAnalyticsTrackID;
- (NSString *) googleMapsAPIKey;

#pragma mark - Facebook
- (NSString *) facebookAppID;
- (NSString *) facebookAppSecret;

#pragma mark - Twitter
- (NSString *) twitterAppKey;
- (NSString *) twitterAppSecret;

#pragma mark - Magazine params
- (NSString *) magazineLabel;

#pragma mark - Server params
- (NSString *) serverHost;
- (NSString *) serverProtocol;
- (NSString *) serverAbsolutePath;
- (NSURL *) serverURL;

- (NSString *) apnsAbsolutePath;

#pragma mark - InAppPurchase params
- (NSString *) inAppPurchaseSharedSecret;
- (BOOL) isFreeSubscription;
- (NSString *) purchaseSubscription;
- (NSString *) purchaseFreeSubscription;
- (NSString *) purchasePaidSubscriptionOneMonth;
- (NSString *) purchasePaidSubscriptionSixMonth;
- (NSString *) purchasePaidSubscriptionYear;

#pragma mark - Share settings
- (NSString *) itunesAppID;
- (NSString *) itunesAppShortLink;
- (NSURL *) itunesAppShortLinkURL;

#pragma mark - Font params
- (UIFont *) progressFont;
- (UIFont *) systemSmallFont;
- (UIFont *) systemLargeFont;
- (UIFont *) navigationTitleFont;
- (UIFont *) textFieldFont;

#pragma mark - Colours
- (UIColor *) mainColor;
- (UIColor *) mainBackColor;

#pragma mark - Kiosk
- (UIFont *) kioskTitleFont;
- (UIFont *) kioskCaptionFont;

#pragma mark - List
- (UIFont *) listTitleFont;
- (UIFont *) listBodyFont;
- (UIFont *) listCaptionFont;

#pragma mark - Filter
- (UIFont *) filterCategoryFont;
- (UIFont *) filterCategoryBoldFont;
- (BOOL) filterCategoryUpperFirstChar;

- (UIFont *) filterMagazineNameFont;
- (UIFont *) filterIssueNameFont;
- (UIFont *) filterDateNameFont;

#pragma mark - Form settings
- (UIFont *) formButtonFont;
- (UIFont *) formHeadFont;
- (UIFont *) formBodyFont;
- (UIFont *) formCaptionFont;

#pragma mark - Favorite
- (UIFont *) favoriteTitleFont;
- (UIFont *) favoriteBodyFont;
- (UIFont *) favoriteCaptionFont;

#pragma mark - Article
- (UIFont *) articleHeadFont;
- (CGFloat) articleHeadLineHeight;
- (UIFont *) articleBodyFont;

- (UIFont *) articleRegularFont;
- (UIFont *) articleRegularBoldFont;

#pragma mark - Comments
- (NSString *) commentFontName;
- (UIFont *) commentTitleFont;
- (UIFont *) commentCaptionFont;

#pragma mark - Search
- (UIFont *) searchHeadFont;
- (UIFont *) searchCaptionFont;

@end
