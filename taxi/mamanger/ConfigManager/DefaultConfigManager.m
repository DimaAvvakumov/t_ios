//
//  DefaultConfigManager.m
//  proteplo
//
//  Created by Dima Avvakumov on 11.04.14.
//  Copyright (c) 2014 Dima Avvakumov. All rights reserved.
//

#import "DefaultConfigManager.h"

@implementation DefaultConfigManager

#pragma mark - Lang

- (BOOL) isMultilanguage {
    NSArray *langList = [self languageList];
    if (!langList) return NO;
    
    return ([langList count] > 1) ? YES : NO;
}

- (NSArray *) languageList {
    return @[@{@"ru": @"Русский"}];
}

#pragma mark - Google analytics

- (NSString *) googleAnalyticsTrackID {
    return @"UA-49902297-1";
}

- (NSString *) googleMapsAPIKey {
    return @"";
}

#pragma mark - Facebook

- (NSString *) facebookAppID {
    return @"";
}

- (NSString *) facebookAppSecret {
    return @"";
}

#pragma mark - Twitter

- (NSString *) twitterAppKey {
    return @"";
}

- (NSString *) twitterAppSecret {
    return @"";
}

#pragma mark - Magazine params

- (NSString *) magazineLabel {
    return @"Simple magazine";
}

#pragma mark - Server params

- (NSString *) serverHost {
    return @"proteplo.east-media.ru";
}

- (NSString *) serverProtocol {
    return @"http";
}

- (NSString *) serverAbsolutePath {
    return [NSString stringWithFormat:@"%@://%@/", self.serverProtocol, self.serverHost];
}

- (NSURL *) serverURL {
    return [NSURL URLWithString:self.serverAbsolutePath];
}

- (NSString *) apnsAbsolutePath {
    return @"https://api.east-media.ru";
}

#pragma mark - InAppPurchase params

- (NSString *) inAppPurchaseSharedSecret {
    return @"f56ae71f5d8f49c9b5795d5808c00c14";
}

- (BOOL) isFreeSubscription {
    return YES;
}

- (NSString *) purchaseSubscription {
    if ([self isFreeSubscription]) {
        return [self purchaseFreeSubscription];
    } else {
        return [self purchasePaidSubscriptionYear];
    }
}

- (NSString *) purchaseFreeSubscription {
    return [NSString stringWithFormat:@"%@.freeSubscription", [[NSBundle mainBundle] bundleIdentifier]];
}

- (NSString *) purchasePaidSubscriptionOneMonth {
    return [NSString stringWithFormat:@"%@.paidSubscriptionOneMonth", [[NSBundle mainBundle] bundleIdentifier]];
}

- (NSString *) purchasePaidSubscriptionSixMonth {
    return [NSString stringWithFormat:@"%@.paidSubscriptionSixMonth", [[NSBundle mainBundle] bundleIdentifier]];
}

- (NSString *) purchasePaidSubscriptionYear {
    return [NSString stringWithFormat:@"%@.paidSubscriptionYear", [[NSBundle mainBundle] bundleIdentifier]];
}

#pragma mark - Share settings

- (NSString *) itunesAppID {
    return @"849536392";
}

- (NSString *) itunesAppShortLink {
    return @"http://goo.gl/NvPq5P";
}

- (NSURL *) itunesAppShortLinkURL {
    return [NSURL URLWithString: self.itunesAppShortLink];
}

#pragma mark - Font params

- (UIFont *) progressFont {
    if (IS_PAD) {
        return [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    } else {
        return [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0];
    }
}

- (UIFont *) systemSmallFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
}

- (UIFont *) systemLargeFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
}

- (UIFont *) navigationTitleFont {
    if (IS_PAD) {
        return [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0];
    } else {
        return [UIFont fontWithName:@"HelveticaNeue-Light" size:21.0];
    }
}

- (UIFont *) textFieldFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
}

#pragma mark - Colours

- (UIColor *) mainColor {
    return [UIColor colorWithRed:236.0/255.0 green:142.0/255.0 blue:44.0/255.0 alpha:1.0];
}

- (UIColor *) mainBackColor {
    return [UIColor colorWithRed:249.0/255.0 green:221.0/255.0 blue:191.0/255.0 alpha:1.0];
}

#pragma mark - Kiosk

- (UIFont *) kioskTitleFont {
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
}

- (UIFont *) kioskCaptionFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
}

#pragma mark - List

- (UIFont *) listTitleFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:28.0];
}

- (UIFont *) listBodyFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
}

- (UIFont *) listCaptionFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
}

#pragma mark - Filter

- (UIFont *) filterCategoryBoldFont {
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0];
}

- (UIFont *) filterCategoryFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0];
}

- (BOOL) filterCategoryUpperFirstChar {
    return NO;
}

- (UIFont *) filterMagazineNameFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:19.0];
}

- (UIFont *) filterIssueNameFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:19.0];
}

- (UIFont *) filterDateNameFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
}

#pragma mark - Form settings

- (UIFont *) formButtonFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
}

- (UIFont *) formHeadFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0];
}

- (UIFont *) formBodyFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
}

- (UIFont *) formCaptionFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0];
}

#pragma mark - Favorite

- (UIFont *) favoriteTitleFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0];
}

- (UIFont *) favoriteBodyFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
}

- (UIFont *) favoriteCaptionFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
}

#pragma mark - Article

- (UIFont *) articleHeadFont {
    if (IS_PAD) {
        return [UIFont fontWithName:@"HelveticaNeue-Light" size:32.0];
    } else {
        return [UIFont fontWithName:@"HelveticaNeue-Light" size:23.0];
    }
}

- (CGFloat) articleHeadLineHeight {
    if (IS_PAD) {
        return 32.0;
    } else {
        return 23.0;
    }
}

- (UIFont *) articleBodyFont {
    if (IS_PAD) {
        return [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    } else {
        return [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    }
}

- (UIFont *) articleRegularFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
}

- (UIFont *) articleRegularBoldFont {
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0];
}

#pragma mark - Comments

- (NSString *) commentFontName {
    return @"HelveticaNeue-Light";
}

- (UIFont *) commentTitleFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
}

- (UIFont *) commentCaptionFont {
    if (IS_PAD) {
        return [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    } else {
        return [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    }
}

#pragma mark - Search

- (UIFont *) searchHeadFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
}

- (UIFont *) searchCaptionFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
}


@end
