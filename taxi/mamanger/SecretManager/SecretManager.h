//
//  SecretManager.h
//  antologia
//
//  Created by Dima Avvakumov on 19.10.12.
//  Copyright (c) 2012 East Media Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SecretManagerChangeFontNotification @"SecretManagerChangeFontNotification"

@protocol SecretManagerDelegate <NSObject>

@optional
- (void) secretManagerModeChanged;

@end

@interface SecretManager : NSObject

+ (SecretManager *) defaultManager;

- (void) modeEnabled: (BOOL) enabled;
- (void) switchMode;
- (BOOL) isEnabled;

- (void) addObserver: (id <SecretManagerDelegate>) observer;
- (void) removeObserver: (id <SecretManagerDelegate>) observer;

@end
