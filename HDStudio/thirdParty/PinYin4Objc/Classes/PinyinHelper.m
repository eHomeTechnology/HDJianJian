//
//
//
//  Created by kimziv on 13-9-14.
//

#include "ChineseToPinyinResource.h"
#include "HanyuPinyinOutputFormat.h"
#include "PinyinFormatter.h"
#include "PinyinHelper.h"

#define HANYU_PINYIN @"Hanyu"
#define WADEGILES_PINYIN @"Wade"
#define MPS2_PINYIN @"MPSII"
#define YALE_PINYIN @"Yale"
#define TONGYONG_PINYIN @"Tongyong"
#define GWOYEU_ROMATZYH @"Gwoyeu"

@implementation PinyinHelper

+ (BOOL)isChineseToPinyingWithString:(NSString*)ch containString:(NSString*)searchText
{
@autoreleasepool
{
    NSMutableString *resultPinyinStrBuf = [[NSMutableString alloc] init];
    NSMutableString *resultFirstPinyinStrBuf = [[NSMutableString alloc] init];
    
    NSString* upperSearchText = [searchText uppercaseString];
    NSString *mainPinyinStrOfChar = nil;

    for (int i = 0; i <  ch.length; i++)
    {
        unichar uch = [ch characterAtIndex:i];

        NSMutableArray *pinyinStrArray =[NSMutableArray arrayWithArray:[PinyinHelper getUnformattedHanyuPinyinStringArrayWithChar:uch]];
        
        if ( nil != pinyinStrArray )
        {
//            for (int i = 0; i < (int) [pinyinStrArray count]; i++)
//            {
//                NSString* pinyinStr = [pinyinStrArray objectAtIndex:i];
//                pinyinStr =[pinyinStr stringByReplacingOccurrencesOfString:@"[1-5]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, pinyinStr.length)];
//                
//                pinyinStr =[pinyinStr stringByReplacingOccurrencesOfString:@"u:" withString:@"v"];
//                //pinyinStr = [pinyinStr uppercaseString];
//                
//                [pinyinStrArray replaceObjectAtIndex:i withObject: pinyinStr];
//            }
            
            if ( [pinyinStrArray count] > 0 )
            {
                NSString* pinyinStr = [pinyinStrArray objectAtIndex:0];
                pinyinStr =[pinyinStr stringByReplacingOccurrencesOfString:@"[1-5]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, pinyinStr.length)];
                
                pinyinStr =[pinyinStr stringByReplacingOccurrencesOfString:@"u:" withString:@"v"];
                pinyinStr = [pinyinStr uppercaseString];
                
                if ( [pinyinStr hasPrefix:upperSearchText] )
                {
                    pinyinStrArray = nil;
                    resultFirstPinyinStrBuf = nil;
                    resultPinyinStrBuf = nil;
                    return  YES;
                }
                
                mainPinyinStrOfChar = pinyinStr;
            }
        }
        
        
//        if ((nil != pinyinStrArray) && ((int) [pinyinStrArray count] > 0))
//        {
//            mainPinyinStrOfChar =  [pinyinStrArray objectAtIndex:0];
//        }
        
        pinyinStrArray = nil;
        
        if (nil != mainPinyinStrOfChar)
        {
            [resultPinyinStrBuf appendString:mainPinyinStrOfChar];
            [resultFirstPinyinStrBuf appendString:[mainPinyinStrOfChar substringToIndex:1]];
        }
        else
        {
            [resultPinyinStrBuf appendFormat:@"%C",[ch characterAtIndex:i]];
            [resultFirstPinyinStrBuf appendFormat:@"%C",[ch characterAtIndex:i]];

        }
        mainPinyinStrOfChar = nil;
    }
    
//    NSRange pinyinRange = [[resultPinyinStrBuf uppercaseString] rangeOfString:sContain options:NSCaseInsensitiveSearch];
    NSRange firstPinyinRange = [resultFirstPinyinStrBuf rangeOfString:upperSearchText];

    if ( firstPinyinRange.location != NSNotFound || [resultPinyinStrBuf hasPrefix:upperSearchText] )
    {
        resultPinyinStrBuf = nil;
        resultFirstPinyinStrBuf = nil;
        
        return YES;
    }

    resultPinyinStrBuf = nil;
    resultFirstPinyinStrBuf = nil;
    return NO;
}
}


/* 汉字转大写字母拼音*/
+ (NSString *)chineseToPinyinUppercaseWithString:(NSString *)ch{
    HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeUppercase];
    NSString *outputPinyin=[PinyinHelper toHanyuPinyinStringWithNSString:ch withHanyuPinyinOutputFormat:outputFormat withNSString:@""];
    return outputPinyin;
}
/* 汉字转小写字母拼音*/
+ (NSString *)chineseToPinyinLowercaseWithString:(NSString *)ch{
    HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeLowercase];
    NSString *outputPinyin=[PinyinHelper toHanyuPinyinStringWithNSString:ch withHanyuPinyinOutputFormat:outputFormat withNSString:@""];
    return outputPinyin;
}

/*获取汉字拼音首字母*/
+ (NSString *)getFirstCharFromPinyinStringWithString:(unichar)ch{
    if ( (ch >= 'a' && ch <='z') || (ch >= 'A' && ch <='Z') )
    {
        return [NSString stringWithCharacters:&ch length:1];
    }
    
    HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeUppercase];
    NSString *char_t = [self getFirstHanyuPinyinStringWithChar:ch withHanyuPinyinOutputFormat:outputFormat];
    if (char_t == nil || [char_t isEqualToString:@""]) {
        char_t = @"#";
    }
    else
    {
        char_t = [char_t substringToIndex:1];
    }
    
    return char_t;
}

+ (NSArray *)toHanyuPinyinStringArrayWithChar:(unichar)ch {
    return [PinyinHelper getUnformattedHanyuPinyinStringArrayWithChar:ch];
}

+ (NSArray *)toHanyuPinyinStringArrayWithChar:(unichar)ch
                  withHanyuPinyinOutputFormat:(HanyuPinyinOutputFormat *)outputFormat {
    return [PinyinHelper getFormattedHanyuPinyinStringArrayWithChar:ch withHanyuPinyinOutputFormat:outputFormat];
}

+ (NSArray *)getFormattedHanyuPinyinStringArrayWithChar:(unichar)ch
                            withHanyuPinyinOutputFormat:(HanyuPinyinOutputFormat *)outputFormat {
    NSMutableArray *pinyinStrArray =[NSMutableArray arrayWithArray:[PinyinHelper getUnformattedHanyuPinyinStringArrayWithChar:ch]];
    if (nil != pinyinStrArray) {
        for (int i = 0; i < (int) [pinyinStrArray count]; i++) {
            [pinyinStrArray replaceObjectAtIndex:i withObject:[PinyinFormatter formatHanyuPinyinWithNSString:
                                                               [pinyinStrArray objectAtIndex:i]withHanyuPinyinOutputFormat:outputFormat]];
        }
        return pinyinStrArray;
    }
    else return nil;
}

+ (NSArray *)getUnformattedHanyuPinyinStringArrayWithChar:(unichar)ch {
    return [[ChineseToPinyinResource getInstance] getHanyuPinyinStringArrayWithChar:ch];
}

+ (NSArray *)toTongyongPinyinStringArrayWithChar:(unichar)ch {
    return [PinyinHelper convertToTargetPinyinStringArrayWithChar:ch withPinyinRomanizationType: TONGYONG_PINYIN];
}

+ (NSArray *)toWadeGilesPinyinStringArrayWithChar:(unichar)ch {
    return [PinyinHelper convertToTargetPinyinStringArrayWithChar:ch withPinyinRomanizationType: WADEGILES_PINYIN];
}

+ (NSArray *)toMPS2PinyinStringArrayWithChar:(unichar)ch {
    return [PinyinHelper convertToTargetPinyinStringArrayWithChar:ch withPinyinRomanizationType: MPS2_PINYIN];
}

+ (NSArray *)toYalePinyinStringArrayWithChar:(unichar)ch {
    return [PinyinHelper convertToTargetPinyinStringArrayWithChar:ch withPinyinRomanizationType: YALE_PINYIN];
}

+ (NSArray *)convertToTargetPinyinStringArrayWithChar:(unichar)ch
                           withPinyinRomanizationType:(NSString *)targetPinyinSystem {
    NSArray *hanyuPinyinStringArray = [PinyinHelper getUnformattedHanyuPinyinStringArrayWithChar:ch];
    if (nil != hanyuPinyinStringArray) {
        NSMutableArray *targetPinyinStringArray = [NSMutableArray arrayWithCapacity:hanyuPinyinStringArray.count];
        for (int i = 0; i < (int) [hanyuPinyinStringArray count]; i++) {
            
        }
        return targetPinyinStringArray;
    }
    else return nil;
}

+ (NSArray *)toGwoyeuRomatzyhStringArrayWithChar:(unichar)ch {
    return [PinyinHelper convertToGwoyeuRomatzyhStringArrayWithChar:ch];
}

+ (NSArray *)convertToGwoyeuRomatzyhStringArrayWithChar:(unichar)ch {
    NSArray *hanyuPinyinStringArray = [PinyinHelper getUnformattedHanyuPinyinStringArrayWithChar:ch];
    if (nil != hanyuPinyinStringArray) {
        NSMutableArray *targetPinyinStringArray =[NSMutableArray arrayWithCapacity:hanyuPinyinStringArray.count];
        for (int i = 0; i < (int) [hanyuPinyinStringArray count]; i++) {
        }
        return targetPinyinStringArray;
    }
    else return nil;
}

+ (NSString *)toHanyuPinyinStringWithNSString:(NSString *)str
                  withHanyuPinyinOutputFormat:(HanyuPinyinOutputFormat *)outputFormat
                                 withNSString:(NSString *)seperater {
    NSMutableString *resultPinyinStrBuf = [[NSMutableString alloc] init];
    for (int i = 0; i <  str.length; i++) {
        NSString *mainPinyinStrOfChar = [PinyinHelper getFirstHanyuPinyinStringWithChar:[str characterAtIndex:i] withHanyuPinyinOutputFormat:outputFormat];
        if (nil != mainPinyinStrOfChar) {
            [resultPinyinStrBuf appendString:mainPinyinStrOfChar];
            if (i != [str length] - 1) {
                [resultPinyinStrBuf appendString:seperater];
            }
        }
        else {
            [resultPinyinStrBuf appendFormat:@"%C",[str characterAtIndex:i]];
        }
    }
    return resultPinyinStrBuf;
}

+ (NSString *)getFirstHanyuPinyinStringWithChar:(unichar)ch
                    withHanyuPinyinOutputFormat:(HanyuPinyinOutputFormat *)outputFormat {
    NSArray *pinyinStrArray = [PinyinHelper getFormattedHanyuPinyinStringArrayWithChar:ch withHanyuPinyinOutputFormat:outputFormat];
    if ((nil != pinyinStrArray) && ((int) [pinyinStrArray count] > 0)) {
        return [pinyinStrArray objectAtIndex:0];
    }
    else {
        return nil;
    }
}

- (id)init {
    return [super init];
}

@end
