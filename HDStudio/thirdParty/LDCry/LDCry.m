//
//  LDCry.m
//  liudu
//
//  Created by 91 on 14-8-18.
//
//

#import "LDCry.h"
#import "NSData+Encryption.h"
#import <CommonCrypto/CommonDigest.h>
#import "GTMBase64.h"
static char base64EncodingTable[64] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};


@implementation LDCry

+ (NSString *)encrypt:(NSString *)message password:(NSString *)password {
    NSData *originData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [originData AES256EncryptWithKey:password];
    NSString *temp = [[self hexStringFromByte:data] uppercaseString];
    data = [temp dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64 = [self base64Encode:data];
    return base64;
}

+ (NSString *)decrypt:(NSString *)message key:(NSString *)key{
    NSString *str;
    NSData *d = [GTMBase64 decodeString:message];
    NSString *hexString = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    NSData *data = [self stringToByte:hexString];
    NSData *datas = [data AES256DecryptWithKey:key];
    str = [[NSString alloc] initWithData:datas encoding:NSUTF8StringEncoding];
    return str;
}

+ (NSData*)stringToByte:(NSString*)string
{
    NSString *hexString=[[string uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length] % 2 != 0) {
        return nil;
    }
    Byte tempbyt[1] = {0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    return bytes;
}

+(NSString*)byteToString:(NSData*)data
{
    Byte *plainTextByte = (Byte *)[data bytes];
    NSString *hexStr=@"";
    for(int i = 0; i < [data length]; i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x", plainTextByte[i]&0xff];///16进制数
        Dlog(@"newHexStr = %@", newHexStr);
        if([newHexStr length] == 1)
            hexStr = [NSString stringWithFormat:@"%@0%@", hexStr, newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@", hexStr, newHexStr];
        Dlog(@"hexStr = %@", hexStr);
    }
    return hexStr;
}


+ (NSString *)hexStringFromByte:(NSData *)data{
    
//    NSUInteger len = [data length];
//    SignedByte *byteData = (SignedByte*)malloc(len);
//    memcpy(byteData, [data bytes], len);
//    for (int i = 0; i < len; ++i) {
//        SignedByte item = *(byteData + i);
//        item = item & 0xFF;
//    }
    
    Byte *bytes = (Byte *)[data bytes];
    //Byte->16进制字符串
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x", bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@", hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@", hexStr,newHexStr];
    }
    return hexStr; 
}

+ (NSString *)base64Encode:(NSData *)data {
    
    return [self base64StringFromData:data length:data.length];
}



+ (NSString *)base64StringFromData:(NSData *)data length: (NSUInteger)length {
    unsigned long ixtext, lentext;
    long ctremaining;
    unsigned char input[3], output[4];
    short i, charsonline = 0, ctcopy;
    const unsigned char *raw;
    NSMutableString *result;
    
    lentext = [data length];
    if (lentext < 1) {
        return @"";
    }
    result = [NSMutableString stringWithCapacity: lentext];
    raw = [data bytes];
    ixtext = 0;
    
    while (true) {
        ctremaining = lentext - ixtext;
        if (ctremaining <= 0) {
            break;
        }
        for (i = 0; i < 3; i++) {
            unsigned long ix = ixtext + i;
            if (ix < lentext) {
                input[i] = raw[ix];
            }
            else {
                input[i] = 0;
            }
        }
        output[0] = (input[0] & 0xFC) >> 2;
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        output[3] = input[2] & 0x3F;
        ctcopy = 4;
        switch (ctremaining) {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }
        
        for (i = 0; i < ctcopy; i++) {
            [result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
        }
        
        for (i = ctcopy; i < 4; i++) {
            [result appendString: @"="];
        }
        
        ixtext += 3;
        charsonline += 4;
        
        if ((length > 0) && (charsonline >= length)) {
            charsonline = 0;
        }
    }     
    return result;
}

+ (NSString *)md5:(NSString *)str
{
//    const char *original_str = [str UTF8String];
//    unsigned char result[CC_MD5_DIGEST_LENGTH];
//    CC_MD5(original_str, (int)strlen(original_str), result);
//    NSMutableString *hash = [NSMutableString string];
//    for (int i = 0; i < 16; i++)
//        [hash appendFormat:@"%02X", result[i]];
//    return [hash lowercaseString];
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (int)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

//32位MD5加密方式
+ (NSString *)getMd5_32Bit_String:(NSString *)srcString{
    const char *cStr = [srcString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (int)strlen(cStr), digest);
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02X", digest[i]];
    
    return result;
}

+ (NSString *)getMd5_16Bit_String:(NSString *)srcString{
    //提取32位MD5散列的中间16位
    NSString *md5_32Bit_String = [self getMd5_32Bit_String:srcString];
    NSString *result = [[md5_32Bit_String substringToIndex:24] substringFromIndex:8];//即9～25位
    
    return result;
}
@end
