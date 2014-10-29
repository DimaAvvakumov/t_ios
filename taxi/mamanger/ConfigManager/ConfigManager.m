//
//  ConfigManager.m
//  proteplo
//
//  Created by Dima Avvakumov on 11.04.14.
//  Copyright (c) 2014 Dima Avvakumov. All rights reserved.
//

#import "ConfigManager.h"

@implementation ConfigManager

+(ConfigManager *) defaultManager {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}


#pragma mark - Lang
- (NSArray *) languageList {
    return @[@{@"ru": @"Русский", @"isDefault":@""}];
}

#pragma mark - Google analytics

- (NSString *) googleAnalyticsTrackID {
    return @"UA-49902297-1";
}

- (NSString *) googleMapsAPIKey {
    return @"AIzaSyAgumO-4ZnPPgxxyBl3Cjrn_2fsiGX8lzY";
}

#pragma mark - Facebook

- (NSString *) facebookAppID {
    return @"379264172211630";
}

- (NSString *) facebookAppSecret {
    return @"a34d878e39ce557339075d7d5494b2ae";
}

#pragma mark - Twitter

- (NSString *) twitterAppKey {
    return @"a018JNk9ImoQAkkg2O1Ug";
}

- (NSString *) twitterAppSecret {
    return @"QMGnbadyVjBOGmVRfcqV284Ogc56O3g8LViuL5PAQ";
}

#pragma mark - Magazine params

- (NSString *) magazineLabel {
    return @"PROТЕПЛО";
}

#pragma mark - Server params

- (NSString *) serverHost {
    return @"proteplo.east-media.ru";
}

- (NSString *) apnsAbsolutePath {
    return @"http://proteplo.east-media.ru";
}

#pragma mark - InAppPurchase params

- (NSString *) inAppPurchaseSharedSecret {
    return @"f56ae71f5d8f49c9b5795d5808c00c14";
}

#pragma mark - Share settings

- (NSString *) itunesAppID {
    return @"849536392";
}

- (NSString *) itunesAppShortLink {
    return @"http://goo.gl/NvPq5P";
}

#pragma mark - Font params

- (UIFont *) progressFont {
    return [UIFont fontWithName:@"Circe-Bold" size:12.0];
}

- (UIFont *) systemSmallFont {
    return [UIFont fontWithName:@"Circe-Light" size:12.0];
}

- (UIFont *) systemLargeFont {
    return [UIFont fontWithName:@"Circe-Light" size:17.0];
}

- (UIFont *) navigationTitleFont {
    if (IS_PAD) {
        return [UIFont fontWithName:@"Circe-Light" size:24.0];
    } else {
        return [UIFont fontWithName:@"Circe-Light" size:21.0];
    }
}

- (UIFont *) textFieldFont {
    return [UIFont fontWithName:@"Circe-Light" size:16.0];
}

#pragma mark - Colours

- (UIColor *) mainColor {
    return [UIColor colorWithRed:236.0/255.0 green:142.0/255.0 blue:44.0/255.0 alpha:1.0];
}

- (UIColor *) mainBackColor {
    return [UIColor colorWithRed:236.0/255.0 green:142.0/255.0 blue:44.0/255.0 alpha:0.25];
    // return [UIColor colorWithRed:249.0/255.0 green:221.0/255.0 blue:191.0/255.0 alpha:1.0];
}

#pragma mark - Kiosk

- (UIFont *) kioskTitleFont {
    return [UIFont fontWithName:@"Circe-Bold" size:18.0];
}

- (UIFont *) kioskCaptionFont {
    return [UIFont fontWithName:@"Circe-Light" size:18.0];
}

#pragma mark - List

- (UIFont *) listTitleFont {
    return [UIFont fontWithName:@"Circe-Light" size:28.0];
}

- (UIFont *) listBodyFont {
    return [UIFont fontWithName:@"Circe-Light" size:18.0];
}

- (UIFont *) listCaptionFont {
    return [UIFont fontWithName:@"Circe-Light" size:15.0];
}

#pragma mark - Filter

- (UIFont *) filterCategoryFont {
    return [UIFont fontWithName:@"Circe-Light" size:24.0];
}

- (UIFont *) filterCategoryBoldFont {
    return [UIFont fontWithName:@"Circe-Bold" size:24.0];
}

- (BOOL) filterCategoryUpperFirstChar {
    return YES;
}

- (UIFont *) filterMagazineNameFont {
    return [UIFont fontWithName:@"Circe-Light" size:19.0];
}

- (UIFont *) filterIssueNameFont {
    if (IS_PAD) {
        return [UIFont fontWithName:@"Circe-Light" size:19.0];
    } else {
        return [UIFont fontWithName:@"Circe-Light" size:16.0];
    }
}

- (UIFont *) filterDateNameFont {
    return [UIFont fontWithName:@"Circe-Light" size:15.0];
}

#pragma mark - Form settings

- (UIFont *) formButtonFont {
    return [UIFont fontWithName:@"Circe-Light" size:18.0];
}

- (UIFont *) formHeadFont {
    return [UIFont fontWithName:@"Circe-Light" size:22.0];
}

- (UIFont *) formBodyFont {
    return [UIFont fontWithName:@"Circe-Light" size:15.0];
}

- (UIFont *) formCaptionFont {
    return [UIFont fontWithName:@"Circe-Light" size:13.0];
}

#pragma mark - Favorite

- (UIFont *) favoriteTitleFont {
    return [UIFont fontWithName:@"Circe-Light" size:24.0];
}

- (UIFont *) favoriteBodyFont {
    return [UIFont fontWithName:@"Circe-Light" size:18.0];
}

- (UIFont *) favoriteCaptionFont {
    return [UIFont fontWithName:@"Circe-Light" size:15.0];
}

#pragma mark - Article

- (UIFont *) articleHeadFont {
    if (IS_PAD) {
        return [UIFont fontWithName:@"Circe-Light" size:32.0];
    } else {
        return [UIFont fontWithName:@"Circe-Light" size:23.0];
    }
}

- (CGFloat) articleHeadLineHeight {
    if (IS_PAD) {
        return 30.0;
    } else {
        return 23.0;
    }
}

- (UIFont *) articleRegularFont {
    return [UIFont fontWithName:@"Circe-Light" size:15.0];
}

- (UIFont *) articleRegularBoldFont {
    return [UIFont fontWithName:@"Circe-Bold" size:15.0];
}

- (UIFont *) articleBodyFont {
    if (IS_PAD) {
        return [UIFont fontWithName:@"Circe-Light" size:18.0];
    } else {
        return [UIFont fontWithName:@"Circe-Light" size:15.0];
    }
}

#pragma mark - Comments

- (NSString *) commentFontName {
    return @"Circe-Light";
}

- (UIFont *) commentTitleFont {
    return [UIFont fontWithName:@"Circe-Light" size:14.0];
}

- (UIFont *) commentCaptionFont {
    if (IS_PAD) {
        return [UIFont fontWithName:@"Circe-Light" size:15.0];
    } else {
        return [UIFont fontWithName:@"Circe-Light" size:12.0];
    }
}

#pragma mark - Search

- (UIFont *) searchHeadFont {
    return [UIFont fontWithName:@"Circe-Light" size:16.0];
}

- (UIFont *) searchCaptionFont {
    return [UIFont fontWithName:@"Circe-Light" size:12.0];
}

@end
