//
//  SettingsManager.m
//  igazeta
//
//  Created by Dima Avvakumov on 28.12.13.
//  Copyright (c) 2013 East-media. All rights reserved.
//

#import "SettingsManager.h"

@interface SettingsManager()

@property (assign, nonatomic) SettingsManagerFontSize storeFontSize;
@property (assign, nonatomic) SettingsManagerColorScheme storeColorSchemeType;
@property (assign, nonatomic) SettingsManagerMapType storeMapType;

@property (strong, nonatomic) UIFont *articleTitle;
@property (strong, nonatomic) UIFont *articleDetails;
@property (strong, nonatomic) NSString *articleCss;

@property (strong, nonatomic) NSString *articleSchemeCss;

- (void) buildFonts;

@end

@implementation SettingsManager

- (id) init {
    self = [super init];
    if (self) {
        [self initFromUserdefault];
    }
    return self;
}

+ (SettingsManager *) defaultManager {
    static SettingsManager *instance = nil;
    if (instance == nil) {
        instance = [[SettingsManager alloc] init];
        
    }
    
    return instance;
}

#pragma mark - init from userdefault

- (void) initFromUserdefault {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // SCHEME
    if ([defaults objectForKey:UserdefaultsKey_ColorScheme]) {
        self.storeColorSchemeType = (SettingsManagerColorScheme) [[defaults objectForKey:UserdefaultsKey_ColorScheme] integerValue];
    } else {
        self.storeColorSchemeType = SettingsManagerColorSchemeLight;
    }
    
    // FONT
    if ([defaults objectForKey:UserdefaultsKey_Font]) {
        self.storeFontSize = (SettingsManagerFontSize) [[defaults objectForKey:UserdefaultsKey_Font] integerValue];
    } else {
        self.storeFontSize = SettingsManagerFontSizeSmall;
    }
    
    // MAP
    if ([defaults objectForKey:UserdefaultsKey_Map]) {
        self.storeMapType = (![[defaults objectForKey:UserdefaultsKey_Map] boolValue])?SettingsManagerMapTypeGoogle:SettingsManagerMapTypeApple;
    } else {
        self.storeMapType = SettingsManagerMapTypeApple;
    }
    
    
    [self buildFonts];
    [self buildColorScheme];
}

#pragma mark - Font methods

- (SettingsManagerFontSize) currentFontSize {
    return _storeFontSize;
}

- (void) setCurrentFontSize: (SettingsManagerFontSize) size {
    if (_storeFontSize == size) return;
    
    self.storeFontSize = size;
    [self buildFonts];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:size] forKey:UserdefaultsKey_Font];
    [defaults synchronize];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:SettingsManagerChangeFontNotification object:nil];
}

- (void) buildFonts {
    switch (_storeFontSize) {
        default:
        case SettingsManagerFontSizeSmall: {
            self.articleTitle = [UIFont fontWithName: @"PTSans-Bold" size: 24.0];
            self.articleDetails = [UIFont fontWithName: @"PTSans-Regular" size: 13.0];
            

            self.articleCss = (IS_PAD) ? @"articleFontSmallPad.css" : @"articleFontSmall.css";
            
            break;
        }
        case SettingsManagerFontSizeMedium: {
            self.articleTitle = [UIFont fontWithName: @"PTSans-Bold" size: 26.0];
            self.articleDetails = [UIFont fontWithName: @"PTSans-Regular" size: 15.0];
            self.articleCss = (IS_PAD) ? @"articleFontMediumPad.css" : @"articleFontMedium.css";
            
            break;
        }
        case SettingsManagerFontSizeLarge: {
            self.articleTitle = [UIFont fontWithName: @"PTSans-Bold" size: 28.0];
            self.articleDetails = [UIFont fontWithName: @"PTSans-Regular" size: 17.0];
            
            self.articleCss = (IS_PAD) ? @"articleFontLargePad.css" : @"articleFontLarge.css";
            
            break;
        }
    }
}

- (UIFont *) articleTitleFont {
    return _articleTitle;
}

- (UIFont *) articleDetailsFont {
    return _articleDetails;
}

- (NSString *) articleCssLink {
    return _articleCss;
}

#pragma mark - Color scheme methods

- (SettingsManagerColorScheme) currentColorScheme {
    return _storeColorSchemeType;
}

- (void) setCurrentColorScheme:(SettingsManagerColorScheme) scheme {
    if (_storeColorSchemeType == scheme) return;
    self.storeColorSchemeType = scheme;
    
    [self buildColorScheme];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:scheme] forKey:UserdefaultsKey_ColorScheme];
    [defaults synchronize];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:SettingsManagerChangeColorSchemeNotification object:nil];
}

- (void) buildColorScheme {
    switch (_storeColorSchemeType) {
        default:
        case SettingsManagerColorSchemeLight: {
            self.articleSchemeCss = @"lightScheme.css";
            
            break;
        }
            
        case SettingsManagerColorSchemeDark: {
            self.articleSchemeCss = @"darkScheme.css";
            
            break;
        }
    }
}

- (NSString *) articleScemeCssLink {
    return _articleSchemeCss;
}

#pragma mark - Map methods

- (SettingsManagerMapType) currentMapType {
    return _storeMapType;
}

- (void) setCurrentMapType: (SettingsManagerMapType) type {
    if (_storeMapType == type) return;
    
    self.storeMapType = type;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (self.storeMapType == SettingsManagerMapTypeGoogle) {
        [defaults setBool:NO forKey:UserdefaultsKey_Map];
    } else {
        [defaults setBool:YES forKey:UserdefaultsKey_Map];
    }
    [defaults synchronize];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:SettingsManagerChangeMapNotification object:nil];
}

@end
