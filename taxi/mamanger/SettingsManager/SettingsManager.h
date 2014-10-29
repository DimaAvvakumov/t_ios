//
//  SettingsManager.h
//  igazeta
//
//  Created by Dima Avvakumov on 28.12.13.
//  Copyright (c) 2013 East-media. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UserdefaultsKey_ColorScheme @"UserdefaultsKey_ColorScheme"
#define UserdefaultsKey_Font @"UserdefaultsKey_Font"
#define UserdefaultsKey_Map @"UserdefaultsKey_Map"

#define SettingsManagerChangeFontNotification @"SettingsManagerChangeFontNotification"
#define SettingsManagerChangeColorSchemeNotification @"SettingsManagerChangeColorSchemeNotification"
#define SettingsManagerChangeMapNotification @"SettingsManagerChangeMapNotification"

typedef enum {
    SettingsManagerFontSizeSmall = 0,
    SettingsManagerFontSizeMedium = 1,
    SettingsManagerFontSizeLarge = 2
} SettingsManagerFontSize;

typedef enum {
    SettingsManagerColorSchemeLight = 0,
    SettingsManagerColorSchemeDark = 1
} SettingsManagerColorScheme;

typedef enum {
    SettingsManagerMapTypeApple = 0,
    SettingsManagerMapTypeGoogle = 1
} SettingsManagerMapType;

@interface SettingsManager : NSObject

+ (SettingsManager *) defaultManager;

#pragma mark - Font methods

- (SettingsManagerFontSize) currentFontSize;
- (void) setCurrentFontSize: (SettingsManagerFontSize) size;

- (UIFont *) articleTitleFont;
- (UIFont *) articleDetailsFont;
- (NSString *) articleCssLink;

#pragma mark - Color scheme

- (SettingsManagerColorScheme) currentColorScheme;
- (void) setCurrentColorScheme:(SettingsManagerColorScheme) scheme;

- (NSString *) articleScemeCssLink;

#pragma mark - Map methods

- (SettingsManagerMapType) currentMapType;
- (void) setCurrentMapType: (SettingsManagerMapType) type;

@end
