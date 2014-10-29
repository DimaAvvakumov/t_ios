//
//  ConfigManager.h
//  proteplo
//
//  Created by Dima Avvakumov on 11.04.14.
//  Copyright (c) 2014 Dima Avvakumov. All rights reserved.
//

#import "DefaultConfigManager.h"

#define DMConfigManager \
[ConfigManager defaultManager]

@interface ConfigManager : DefaultConfigManager

+(ConfigManager *) defaultManager;

@end
