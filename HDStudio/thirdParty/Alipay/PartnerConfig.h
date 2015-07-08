//
//  PartnerConfig.h
//  AlipaySdkDemo
//
//  Created by ChaoGanYing on 13-5-3.
//  Copyright (c) 2013年 RenFei. All rights reserved.
//
//  提示：如何获取安全校验码和合作身份者id
//  1.用您的签约支付宝账号登录支付宝网站(www.alipay.com)
//  2.点击“商家服务”(https://b.alipay.com/order/myorder.htm)
//  3.点击“查询合作者身份(pid)”、“查询安全校验码(key)”
//

#ifndef MQPDemo_PartnerConfig_h
#define MQPDemo_PartnerConfig_h

//合作身份者id，以2088开头的16位纯数字
#define PartnerID @"2088711135176954"
//收款支付宝账号
#define SellerID  @"2088711135176954"

//安全校验码（MD5）密钥，以数字和字母组成的32位字符
#define MD5_KEY @"22rh0diu8689zgquvbmh26d9y404lwcd"

//商户私钥，自助生成
#define PartnerPrivKey @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBALu9BLUx3DA/eLhe7qPPyr1fkU5LvDAXO1TAkcRz0JXHTr6UYXbz33y9Z/2RHj4eSZJWgd6iwE1XMkH05udpXbfYel6nhF1nlRKAo4JE5lUz0rItMNKuHWE/NfgxlrbbIhCpx1YJaCRo3ZV9PpoEPjIOmjlAzGf0gnjTxTg2z13hAgMBAAECgYBKa3xBQ3mQWqjFFUSuBQHOHeMg0V7RBXSMfSWLZYmKxg4N+A3GtJekAAUH/A2r/B+X9djXY1atkeInSSh7FUaDmutgRrp8at7ifCKnQB1kbQ3Fmw2USDE42E3mYVbTYds8/UosPKt5REs9e5Pg+bRsi9PP4IInXqbzGoDJ3aXrLQJBAOx3rcD6RieAIPQCPfPhrfLaZIxyISgMyJa44TbpG4ZCKYq2gBpN3Vf6wKqiGl+leZX5fJSq+0juRXDkU3aU8x8CQQDLPurchScIeNnUjcMDWgEb6qELcYNCySxgQCo2SyMp7J27iaHOqm8diKOLSJ/y5zxWIoxTL+G1nfp5ankZqo7/AkB1ivQK5h1zSySWRnsHPNpbyqWKjrzejKQ1D8ebpPoynbbKpfc9nBD3x8R3zUZw3u92VmLP/8ITOaW4/TZjzpyfAkAwLkoe3LHUIFIDQVfpg3yf0Y871zz2qBoM9ykKleVQGveJbaceBukwZyPd8Ol5+7ch9C6vyboIA9tMzSDIJNahAkEApes4wAxNCwhNkGtp84sT/Epn6GpBtxu2kU//qGZYB2mefhg9CFC0C0p6Pj9qUihzvso5xYqT0yHMzTSdBPvrjg=="


//支付宝公钥
#define AlipayPubKey   @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB"

#endif
