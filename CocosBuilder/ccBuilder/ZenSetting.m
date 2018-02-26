//
//  ZenSetting.m
//  CocosBuilder
//
//  Created by Wang Hui on 24/02/2018.
//

#import <Foundation/Foundation.h>
#import "CocosBuilderAppDelegate.h"
#import "ResourceManager.h"
#import "ZenSetting.h"

@implementation ZenSetting

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    festival = FESTIVAL_DEFAULT;
    language = LANGUAGE_DEFAULT;
    return self;
}

- (BOOL) isFileExists: (id)file {
    return [[ResourceManager sharedManager] toAbsolutePath:file] != NULL;
}


- (NSString *) fixResourceFilePath:(id)file
{
    if ([file isEqualToString:@""]) {
        return file;
    }
    
    NSMutableArray * list = [NSMutableArray array];
    BOOL hasFestival = ![festival isEqualToString:FESTIVAL_DEFAULT] && ![festival isEqualToString:@""];
    BOOL hasLanguage = ![language isEqualToString:LANGUAGE_DEFAULT] && ![language isEqualToString:@""];
    
    if (hasFestival && hasLanguage) {
        [list addObject:[NSString stringWithFormat: @"%@/%@/native/%@", festival, language, file]];
    }
    
    if (hasFestival) {
        [list addObject:[NSString stringWithFormat: @"%@/native/%@", festival, file]];
    }
    
    if (hasLanguage) {
        [list addObject:[NSString stringWithFormat: @"%@/native/%@", language, file]];
    }
    
    for(id item in list) {
        if ([self isFileExists:item]) {
            return item;
        }
    }
    return file;
}

- (void) setLanguage:(NSString *) l {
    if (![language isEqualToString:l]) {
        language = [l copy];
        [[CocosBuilderAppDelegate appDelegate] reloadCurrentDocument];
    }
    
}

- (void) setFestival:(NSString *) f {
    if (![f isEqualToString:festival]) {
        festival = [f copy];
        [[CocosBuilderAppDelegate appDelegate] reloadCurrentDocument];
    }
}

static id sharedInstance = nil;

+ (ZenSetting *)sharedInstance
{
    if (sharedInstance == nil) {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

@end
