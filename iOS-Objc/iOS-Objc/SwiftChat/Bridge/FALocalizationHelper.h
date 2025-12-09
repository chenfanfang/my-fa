#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FALanguage) {
    FALanguageEnglish,
    FALanguageChinese
};

@interface FALocalizationHelper : NSObject

+ (FALanguage)currentLanguage;
+ (void)setLanguage:(FALanguage)language;
+ (void)setLanguageWithCode:(NSString *)code;
+ (NSString *)currentLanguageCode;
+ (NSString *)currentLanguageDisplayName;

+ (NSString *)localized:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
