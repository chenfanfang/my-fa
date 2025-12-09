#import "FALocalizationHelper.h"

@implementation FALocalizationHelper

static NSString * const kAppLanguageKey = @"AppLanguage";

+ (FALanguage)currentLanguage {
    NSString *code = [[NSUserDefaults standardUserDefaults] stringForKey:kAppLanguageKey];
    if ([code isEqualToString:@"zh-Hans"]) {
        return FALanguageChinese;
    } else if ([code isEqualToString:@"en"]) {
        return FALanguageEnglish;
    }
    
    // Default
    NSString *lang = [[NSLocale currentLocale] languageCode];
    if ([lang hasPrefix:@"zh"]) return FALanguageChinese;
    
    return FALanguageEnglish;
}

+ (void)setLanguage:(FALanguage)language {
    NSString *code = (language == FALanguageChinese) ? @"zh-Hans" : @"en";
    [[NSUserDefaults standardUserDefaults] setObject:code forKey:kAppLanguageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LanguageChanged" object:nil];
}

+ (void)setLanguageWithCode:(NSString *)code {
    if ([code isEqualToString:@"zh-Hans"]) {
        [self setLanguage:FALanguageChinese];
    } else {
        [self setLanguage:FALanguageEnglish];
    }
}

+ (NSString *)currentLanguageCode {
    return ([self currentLanguage] == FALanguageChinese) ? @"zh-Hans" : @"en";
}

+ (NSString *)currentLanguageDisplayName {
    return ([self currentLanguage] == FALanguageChinese) ? @"简体中文" : @"English";
}

+ (NSBundle *)resourceBundle {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Check Main Bundle
        if ([[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"]) {
            bundle = [NSBundle mainBundle];
        } else {
            // Check Frameworks
            NSArray *candidates = [[NSBundle allFrameworks] arrayByAddingObjectsFromArray:[NSBundle allBundles]];
            for (NSBundle *b in candidates) {
                if ([b pathForResource:@"en" ofType:@"lproj"]) {
                    bundle = b;
                    break;
                }
            }
        }
        if (!bundle) bundle = [NSBundle mainBundle];
    });
    return bundle;
}

+ (NSString *)localized:(NSString *)key {
    NSString *code = [self currentLanguageCode];
    NSBundle *bundle = [self resourceBundle];
    
    NSString *path = [bundle pathForResource:code ofType:@"lproj"];
    if (path) {
        bundle = [NSBundle bundleWithPath:path];
    }
    
    return [bundle localizedStringForKey:key value:@"" table:nil];
}

@end
