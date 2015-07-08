//
//  
//
//  Created by kimziv on 13-9-14.
//

#ifndef _PinyinHelper_H_
#define _PinyinHelper_H_

@class HanyuPinyinOutputFormat;

@interface PinyinHelper : NSObject {

}

+ (BOOL)isChineseToPinyingWithString:(NSString*)ch containString:(NSString*)searchText;
/* 汉字转大写字母拼音*/
+ (NSString *)chineseToPinyinUppercaseWithString:(NSString *)ch;
/* 汉字转小写字母拼音*/
+ (NSString *)chineseToPinyinLowercaseWithString:(NSString *)ch;
/*获取汉字拼音首字母*/
+ (NSString *)getFirstCharFromPinyinStringWithString:(unichar)ch;
+ (NSArray *)toHanyuPinyinStringArrayWithChar:(unichar)ch;
+ (NSArray *)toHanyuPinyinStringArrayWithChar:(unichar)ch
                         withHanyuPinyinOutputFormat:(HanyuPinyinOutputFormat *)outputFormat;
+ (NSArray *)getFormattedHanyuPinyinStringArrayWithChar:(unichar)ch
                                   withHanyuPinyinOutputFormat:(HanyuPinyinOutputFormat *)outputFormat;
+ (NSArray *)getUnformattedHanyuPinyinStringArrayWithChar:(unichar)ch;
+ (NSArray *)toTongyongPinyinStringArrayWithChar:(unichar)ch;
+ (NSArray *)toWadeGilesPinyinStringArrayWithChar:(unichar)ch;
+ (NSArray *)toMPS2PinyinStringArrayWithChar:(unichar)ch;
+ (NSArray *)toYalePinyinStringArrayWithChar:(unichar)ch;
+ (NSArray *)convertToTargetPinyinStringArrayWithChar:(unichar)ch
                                  withPinyinRomanizationType:(NSString *)targetPinyinSystem;
+ (NSArray *)toGwoyeuRomatzyhStringArrayWithChar:(unichar)ch;
+ (NSArray *)convertToGwoyeuRomatzyhStringArrayWithChar:(unichar)ch;
+ (NSString *)toHanyuPinyinStringWithNSString:(NSString *)str
                  withHanyuPinyinOutputFormat:(HanyuPinyinOutputFormat *)outputFormat
                                 withNSString:(NSString *)seperater;
+ (NSString *)getFirstHanyuPinyinStringWithChar:(unichar)ch
                    withHanyuPinyinOutputFormat:(HanyuPinyinOutputFormat *)outputFormat;
- (id)init;
@end

#endif // _PinyinHelper_H_
