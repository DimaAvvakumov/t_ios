//
//  SecretManager.m
//  antologia
//
//  Created by Dima Avvakumov on 19.10.12.
//  Copyright (c) 2012 East Media Ltd. All rights reserved.
//

#import "SecretManager.h"
#import "ObserverWrapper.h"

#define SecretManager_NSUserDefaults_UniquePrefix @"SecretManager"
#define SecretManager_NSUserDefaults_Key_Enabled @"enabled"

@interface SecretManager () {
    BOOL _isEnabled;
}

@property (strong, nonatomic) NSMutableArray *listObservers;

@end

@implementation SecretManager

- (id) init {
    self = [super init];
    if (self) {
        _isEnabled = [self restoreBoolFromPersistent: SecretManager_NSUserDefaults_Key_Enabled];
        
        // observers
        self.listObservers = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

+ (SecretManager *) defaultManager {
    static SecretManager *instance = nil;
    if (instance == nil) {
        instance = [[SecretManager alloc] init];
    }
    return instance;
}

- (void) modeEnabled: (BOOL) enabled {
    _isEnabled = enabled;
    
    // store in user defaults
    [self saveBoolValue:enabled inPersistentForKey:SecretManager_NSUserDefaults_Key_Enabled];
    
    // send information to server
    if (enabled) {
        [self notifyServer];
    }
    
    // send observers notifications
    for (ObserverWrapper *observerWrapper in _listObservers) {
        id <SecretManagerDelegate>observer = observerWrapper.observerObject;
        if (observer == nil) continue;
        
        if ([observer respondsToSelector:@selector(secretManagerModeChanged)]) {
            [observer secretManagerModeChanged];
        }
    }

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:SecretManagerChangeFontNotification object:nil];
}

- (void) switchMode {
    [self modeEnabled: !_isEnabled];
}

- (BOOL) isEnabled {
    return _isEnabled;
}

#pragma mark - Notify server about activate secret mode

- (void) notifyServer {
#ifdef DEBUG
    // return;
#endif
    // Config manager
    // ConfigManager *configManager = [ConfigManager defaultManager];

    // NSURL *url = configManager.serverURL;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if( [UIDevice instancesRespondToSelector:@selector(identifierForVendor)] ) {
        NSString *identifierForVendor = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        // NSLog(@"vendor identifier: %@", identifierForVendor);
        
        [params setValue:identifierForVendor forKey:@"device"];
    }
    
#ifdef DEBUG
    [params setValue:@"develop" forKey:@"mode"];
#else
    [params setValue:@"production" forKey:@"mode"];
#endif
    [params setValue:[[NSBundle mainBundle] bundleIdentifier] forKey:@"bundle"];
    [params setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forKey:@"version"];
    [params setValue:[[UIDevice currentDevice] family] forKey:@"family"];
    
//    NSURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"apns/add_developer_device" parameters:params];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *path = [NSString stringWithFormat:@"%@%@/apns/add_developer_device", [ConfigManager defaultManager].serverAbsolutePath, ALLocalizationGetLanguage];
    
    AFURLConnectionOperation *operation = [manager POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    [operation start];
}

#pragma mark - Observer methods

- (void) addObserver: (id <SecretManagerDelegate>) observer {
    NSUInteger index = [self findObjectInObservers:observer];
    if (index != NSNotFound) return;
    
    ObserverWrapper *observerWrapper = [[ObserverWrapper alloc] init];
    observerWrapper.observerObject = observer;
    
    [_listObservers addObject:observerWrapper];
}

- (void) removeObserver: (id <SecretManagerDelegate>) observer {
    NSUInteger index = [self findObjectInObservers:observer];
    if (index == NSNotFound) return;
    
    [_listObservers removeObjectAtIndex:index];
}

- (NSInteger) findObjectInObservers: (id) object {
    for (int i = 0; i < [_listObservers count]; i++) {
        ObserverWrapper *observer = [_listObservers objectAtIndex:i];
        if ([observer.observerObject isEqual:object]) {
            return i;
        }
    }
    
    return NSNotFound;
}

#pragma mark - Persistent methods

- (BOOL) restoreBoolFromPersistent: (NSString *) key {
    NSString *uniqueKey = [self persistentUniqueKey: key];
    NSUserDefaults *store = [NSUserDefaults standardUserDefaults];
    NSNumber *obj = [store objectForKey: uniqueKey];
    if (obj == nil) return NO;
    
    return [obj boolValue];
}

- (void) saveBoolValue: (BOOL) value inPersistentForKey: (NSString *) key {
    NSString *uniqueKey = [self persistentUniqueKey: key];
    NSUserDefaults *store = [NSUserDefaults standardUserDefaults];
    
    [store setBool:value forKey:uniqueKey];
    [store synchronize];
}

- (NSString *) persistentUniqueKey: (NSString *) key {
    return [NSString stringWithFormat:@"%@_%@", SecretManager_NSUserDefaults_UniquePrefix, key];
}

@end
