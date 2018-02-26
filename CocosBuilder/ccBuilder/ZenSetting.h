//
//  FestivalLanguage.h
//  CocosBuilder
//
//  Created by Wang Hui on 24/02/2018.
//

#import <Foundation/Foundation.h>

#define LANGUAGE_DEFAULT @"default"
#define FESTIVAL_DEFAULT @"default"

@interface ZenSetting : NSObject {
    NSString * language;
    NSString * festival;
}

+ (ZenSetting *)sharedInstance;

- (NSString *) fixResourceFilePath:(id)file;
- (void) setLanguage:(NSString *) l;
- (void) setFestival:(NSString *) f;

@end
