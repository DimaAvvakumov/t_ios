//
//  DownloadBannersOperation.m
//  proteplo
//
//  Created by Dima Avvakumov on 09.04.14.
//  Copyright (c) 2014 Dima Avvakumov. All rights reserved.
//

#import "DownloadBannersOperation.h"

@interface DownloadBannersOperation() {
    long long downloadedSize;
    long long downloadTotalSize;
}

@end

@implementation DownloadBannersOperation

#pragma mark - NSOperation methods

- (void) start {
    [self beforeStart];
    
    BOOL result = YES;
    
    // download banners
    if (result) {
        result = [self downloadBanners];
    }
    
    // finished block
    if (result && !_isCancelled) {
        [[CoreDataManager defaultManager] saveContext];
        
        [self executeBlock];
    } else {
        [self finish];
    }
}

#pragma mark - Banners operation

- (BOOL) downloadBanners {
    
    // performing params
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:@1 forKey:@"jsonResponse"];
    [params setObject:((IS_PAD) ? @"iPad" : @"iPhone") forKey:@"family"];
    if (IS_IPHONE5) {
        [params setObject:@"iPhone5" forKey:@"model"];
    }
    if ([UIScreen isRetina]) {
        [params setObject:@1 forKey:@"retina"];
    }
    [params setObject:ALLocalizationGetLanguage forKey:@"lang"];
    
    // ids
    NSMutableArray *idsTags = nil;
    NSArray *items = [[CoreDataManager defaultManager] allBanners];
    if (items) {
        idsTags = [NSMutableArray arrayWithCapacity:[items count]];
        for (BannerItem *item in items) {
            NSString *tag = [NSString stringWithFormat:@"%d:%d", item.bannerID, item.version];
            
            [idsTags addObject:tag];
        }
    }
    if (idsTags) {
        [params setObject:[idsTags componentsJoinedByString:@","] forKey:@"ids"];
    }
    
    // performing request
//    NSURL *baseURL = [ConfigManager defaultManager].serverURL;
//    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL: baseURL];
//    NSString *path = [NSString stringWithFormat:@"%@/banners/list.html", ALLocalizationGetLanguage];
//    NSMutableURLRequest *request = [client requestWithMethod:@"POST" path:path parameters:params];
//    [request setCachePolicy: NSURLRequestReloadIgnoringCacheData];
//    [request setTimeoutInterval: 30.0];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *path = [NSString stringWithFormat:@"%@%@/banners/list.html", [ConfigManager defaultManager].serverAbsolutePath, ALLocalizationGetLanguage];
    
    AFURLConnectionOperation *operation = [manager POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *JSON = (NSDictionary *) responseObject;
        
        NSInteger resultCode = [[ServerManager defaultManager] parseResultCode:JSON];
        if (resultCode != 0) {
            
            self.error = resultCode;
            self.whileDownloading = NO;
            self.successDownload = NO;
            
            return;
        }
        
        self.JSON = JSON;
        self.whileDownloading = NO;
        self.successDownload = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.error = ServerParams_ErrorServerIsUnavailable;
        
        self.whileDownloading = NO;
        self.successDownload = NO;
    }];
    
    BOOL operationResult = [self waitOperation:operation asCritical:YES];
    if (operationResult == NO) return NO;
    
    [self parseBannersInfo: self.JSON];
    
    return YES;
}

- (void) parseBannersInfo:(NSDictionary *)json {
    CoreDataManager *coreData = [CoreDataManager defaultManager];
    
    // parameters
    long long bannersSize = 0;
    
    #pragma mark parse banners request
    NSMutableArray *imagesToDownload = nil;
    NSArray *nodesItems = [json objectForKey: @"bannerItems"];
    if (nodesItems && [nodesItems isKindOfClass: [NSArray class]]) {
        imagesToDownload = [NSMutableArray arrayWithCapacity: [nodesItems count] * 2];
        
        for (NSDictionary *itemInfo in nodesItems) {
            BannerItem *item = [coreData parseBannersItem:itemInfo];
            
            // portrait image
            if (item.pathPortrait) {
                NSError *error = nil;
                AFHTTPRequestOperation *operation = [self operationForPath:item.pathPortrait imageSize:item.fileSizePortrait error:error];
                
                if (operation) {
                    [imagesToDownload addObject:operation];
                    
                    bannersSize += item.fileSizePortrait;
                } else if (error) {
                    NSLog(@"Create download operation error: %@", error);
                }
            }
            
            // landscape image
            if (item.pathLandscape) {
                NSError *error = nil;
                AFHTTPRequestOperation *operation = [self operationForPath:item.pathLandscape imageSize:item.fileSizeLandscape error:error];
                
                if (operation) {
                    [imagesToDownload addObject:operation];
                    
                    bannersSize += item.fileSizeLandscape;
                } else if (error) {
                    NSLog(@"Create download operation error: %@", error);
                }
            }
        }
    }
    
    #pragma mark parse banners delete request
    NSArray *itemsToDelete = [json objectForKey: @"bannersToDelete"];
    if (itemsToDelete && [itemsToDelete isKindOfClass: [NSArray class]]) {
        for (NSNumber *itemNumber in itemsToDelete) {
            NSInteger itemID = [itemNumber integerValue];
            BannerItem *nodeItem = [coreData bannerByID:itemID];
            
            if (nodeItem) {
                [coreData removeObjectFromContext:nodeItem];
            }
        }
    }
    
    #pragma mark - Download banner images
    if (imagesToDownload && [imagesToDownload count] > 0) {
        downloadedSize = 0;
        downloadTotalSize = bannersSize;
        
        for (AFHTTPRequestOperation *operation in imagesToDownload) {
            
            [self waitOperation:operation asCritical:NO];
            
        }
    }
}

- (BOOL) waitOperation: (NSOperation *) operation asCritical: (BOOL) isCritical {
    self.successDownload = NO;
    self.whileDownloading = YES;
    [operation start];
    
    while (self.whileDownloading) {
        if (_isCancelled) {
            [operation cancel];
            return NO;
        }
        if ([operation isCancelled]) {
            break;
        }
        
        [NSThread sleepForTimeInterval: 0.1];
    }
    
    if (self.error) {
        if (isCritical) {
            [self executeBlock];
        }
        return NO;
    }
    
    return YES;
}

- (void) executeBlock {
    [self finish];
    
    if (_finishBlock && !_isCancelled) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            _finishBlock(self.error);
        });
    }
}

- (AFHTTPRequestOperation *) operationForPath: (NSString *) imagePath imageSize: (NSUInteger) imageSize error: (NSError *) error {
    NSString *safeImagePath = [imagePath stringByReplacingOccurrencesOfString:@"://" withString:@"_"];
    NSString *localPath = [[[NSFileManager defaultManager] cacheDataPath] stringByAppendingPathComponent:safeImagePath];
    NSString *imageURL = imagePath;
    
    // check cache file
    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        return nil;
    }
    
    NSURL *pathURL = [NSURL URLWithString: imageURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:pathURL
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30.0];
    
    NSString *destPath = localPath;
    NSString *folder = [destPath stringByDeletingLastPathComponent];
    
    NSString *tmpPath = [destPath stringByAppendingString: @".tmp"];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:folder
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath: tmpPath append: NO];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // init error variable
        NSError *error = nil;
        
        // start up parameters
        self.successDownload = NO;
        self.whileDownloading = NO;
        
        // check image size
        NSDictionary *fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:tmpPath error:&error];
        if (error) {
            NSLog(@"Can`t get downloaded file attributes: %@", error);
            
            return;
        }
        unsigned long long realFileSize = [[fileAttr objectForKey:NSFileSize] unsignedLongLongValue];
        if (realFileSize != imageSize) {
            NSLog(@"Downloaded banner size(%llu) not equal to expected size(%lu)", realFileSize, (unsigned long) imageSize);
            
            return;
        }
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
            if (![[NSFileManager defaultManager] removeItemAtPath:destPath error:&error]) {
                NSLog(@"remove file into dm error: %@", error);
                
                return;
            }
        }
        
        if (![[NSFileManager defaultManager] moveItemAtPath:tmpPath toPath:destPath error:&error]) {
            NSLog(@"move file into dm error: %@", error);
            
            return;
        }
        
        self.successDownload = YES;
        // NSLog(@"Banner tmp %@ path: %@", tmpPath, destPath);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.successDownload = NO;
        self.whileDownloading = NO;
        
        NSLog(@"server error: %@", error);
    }];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        downloadedSize += bytesRead;
        
        // float progress = 0.5 * downloadedSize / (float) downloadTotalSize;
        CGFloat progress = 1.0 * downloadedSize / (CGFloat) downloadTotalSize;
        // NSLog(@"progress: %f", progress);
        
        if (_progressBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _progressBlock(progress);
            });
        }
    }];
    
    return operation;
}

@end
