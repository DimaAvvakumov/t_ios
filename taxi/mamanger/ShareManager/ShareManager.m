//
//  ShareManager.m
//
//  Created by Maxim Keegan on 31.12.13.
//  Copyright (c) 2014 East-media. All rights reserved.
//

#import "ShareManager.h"

@interface ShareManager() <MFMailComposeViewControllerDelegate> {
}

@property (strong, nonatomic) SLComposeViewController *mySLComposerSheet;

@end



@implementation ShareManager

- (id) init {
    self = [super init];
    if (self) {
    }
    return self;
}

+ (ShareManager *) defaultManager {
    static ShareManager *instance = nil;
    if (instance == nil) {
        instance = [[ShareManager alloc] init];
    }
    return instance;
}

- (void) shareFacebook: (ShareItem *) shareItem {
    if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Не удалось разместить запись в Facebook!" message:@"Пожалуйста войдите в Facebook в настройках устройства." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // Config manager
    ConfigManager *configManager = [ConfigManager defaultManager];
    
    self.mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if (shareItem.title) {
        [array addObject:shareItem.title];
    }
    
    if (shareItem.description) {
        [array addObject:shareItem.description];
    }
    
    if (shareItem.imagePath || shareItem.imageURL) {
        [array addObject:configManager.itunesAppShortLink];
    } else {
        [self.mySLComposerSheet addURL:configManager.itunesAppShortLinkURL];
    }
    
    [self.mySLComposerSheet setInitialText:[array componentsJoinedByString:@"\n"]];
    
    if (shareItem.imagePath) {
        [self.mySLComposerSheet addImage:[UIImage imageWithContentsOfFile:shareItem.imagePath]];
    } else if (shareItem.imageURL) {
        
        NSString *imageKey = [NSString stringWithFormat:@"%p", self];
        [[DMImageManager defaultManager] cancelBindingByIdentifier:imageKey];
        
        NSString *localImagePath = [[shareItem.imageURL absoluteString] stringByReplacingOccurrencesOfString:@"://" withString:@"_"];
        NSString *imagePath = [[[NSFileManager defaultManager] cacheDataPath] stringByAppendingPathComponent:localImagePath];
        
        DMImageOperation *operation = [[DMImageOperation alloc] initWithImagePath:imagePath identifer:imageKey  andBlock:^(UIImage *image) {
            [self.mySLComposerSheet addImage:image];
        }];
        operation.downloadURL = shareItem.imageURL;
        
        [[DMImageManager defaultManager] addOperation: operation];
        
        
    }
    
    [[ShareManager currentViewController] presentViewController:self.mySLComposerSheet animated:YES completion:nil];
    
    [self.mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        if (result == SLComposeViewControllerResultDone) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:@"Опубликовано" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
}

- (void) shareTwitter: (ShareItem *) shareItem {
    if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) //check if Facebook Account is linked
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Не удалось разместить запись в Twitter!" message:@"Пожалуйста войдите в Twitter в настройках устройства." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // Config manager
    ConfigManager *configManager = [ConfigManager defaultManager];
    
    self.mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if (shareItem.title) {
        [array addObject:shareItem.title];
    }
    
    if (shareItem.description) {
        [array addObject:shareItem.description];
    }
    
    if (shareItem.imagePath || shareItem.imageURL) {
        [array addObject:configManager.itunesAppShortLink];
    } else {
        [self.mySLComposerSheet addURL:configManager.itunesAppShortLinkURL];
    }
    
    [self.mySLComposerSheet setInitialText:[array componentsJoinedByString:@" "]];
    
    if (shareItem.imagePath) {
        [self.mySLComposerSheet addImage:[UIImage imageWithContentsOfFile:shareItem.imagePath]];
    } else if (shareItem.imageURL) {
        
        NSString *imageKey = [NSString stringWithFormat:@"%p", self];
        [[DMImageManager defaultManager] cancelBindingByIdentifier:imageKey];
        
        NSString *localImagePath = [[shareItem.imageURL absoluteString] stringByReplacingOccurrencesOfString:@"://" withString:@"_"];
        NSString *imagePath = [[[NSFileManager defaultManager] cacheDataPath] stringByAppendingPathComponent:localImagePath];
    
        DMImageOperation *operation = [[DMImageOperation alloc] initWithImagePath:imagePath identifer:imageKey  andBlock:^(UIImage *image) {
            [self.mySLComposerSheet addImage:image];
            
        }];
        operation.downloadURL = shareItem.imageURL;
            
        [[DMImageManager defaultManager] addOperation: operation];

    }
    
    [[ShareManager currentViewController] presentViewController:self.mySLComposerSheet animated:YES completion:nil];
    
    [self.mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        if (result == SLComposeViewControllerResultDone) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:@"Опубликовано" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
}

- (void) shareEmail: (ShareItem *) shareItem {

    
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        // Forming message body
        NSMutableArray *messageBodyArray = [NSMutableArray arrayWithCapacity:10];
        // Add appStore link
        NSString *appStoreLink = [NSString stringWithFormat:@"Приложение %@ можно скачать по <a href=\"%@\">ссылке</a> для AppStore.", [ConfigManager defaultManager].magazineLabel, [ConfigManager defaultManager].itunesAppShortLink];
        [messageBodyArray addObject:appStoreLink];
        
        // Add main message
        [messageBodyArray addObject:shareItem.description];
        
        // Join message body
        NSString *messageBody = [messageBodyArray componentsJoinedByString:@"<br /><br />"];
        
        [picker setSubject:shareItem.title];
        [picker setMessageBody:messageBody isHTML:YES];
        
        if (shareItem.imagePath) {
            [picker addAttachmentData:[NSData dataWithContentsOfFile:shareItem.imagePath] mimeType:@"image/jpeg" fileName:@"image.jpg"];
        } else if (shareItem.imageURL) {
            
            NSString *imageKey = [NSString stringWithFormat:@"%p", self];
            [[DMImageManager defaultManager] cancelBindingByIdentifier:imageKey];
            
            NSString *localImagePath = [[shareItem.imageURL absoluteString] stringByReplacingOccurrencesOfString:@"://" withString:@"_"];
            NSString *imagePath = [[[NSFileManager defaultManager] cacheDataPath] stringByAppendingPathComponent:localImagePath];
            
            DMImageOperation *operation = [[DMImageOperation alloc] initWithImagePath:imagePath identifer:imageKey  andBlock:^(UIImage *image) {
                [picker addAttachmentData:UIImageJPEGRepresentation(image, 1.0) mimeType:@"image/jpeg" fileName:@"image.jpg"];
            }];
            operation.downloadURL = shareItem.imageURL;
            
            [[DMImageManager defaultManager] addOperation: operation];
            
        }
        
        [[ShareManager currentViewController] presentViewController:picker animated:YES completion:^{
        }];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Не могу создать письмо!" message:@"Почтовый клиент не настроен." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [[ShareManager currentViewController] dismissViewControllerAnimated:YES completion:^{
    }];
}

+ (UIViewController *) currentViewController {
    UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
    
    if (window.rootViewController.presentedViewController) {
        return window.rootViewController.presentedViewController;
    }
    
    if (window.rootViewController) {
        return window.rootViewController;
    }

    return nil;
}

@end




@implementation ShareItem

@end
