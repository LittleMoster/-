//
//  DtCaculateTool.m
//  chuangyejia
//
//  Created by SamWu on 15/10/12.
//  Copyright © 2015年 zhishi. All rights reserved.
//

#import "DtCaculateTool.h"

#define urlRegixted @"[a-zA-z]+://[^\\s]*"
#define urlRegixted2 @"((http|https|Http|Https)://)(([a-zA-Z0-9\\._-]+\\.[a-zA-Z]{2,6})|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9\\&%_\\./-~-]*)?"

@implementation DtCaculateTool



/**
 *  @author SamWu
 *
 *  @brief  为了计算出文本的正确高度，把表情的文字替换为对应高度的文字，便于计算
 *
 *  @param contentStr toStr
 *
 *  @return backStr
 */
+(NSString *)replaceEmojiForCaculateheight:(NSString *)contentStr
{
    NSString *regexEmoj = @"\\[(\\w+?)\\]";
    NSString *replaceWithString= @"E  ";//用这个替换掉来计算表情的宽度
    return [contentStr stringByReplacingOccurrencesOfRegex:regexEmoj withString:replaceWithString];
    ;
}


+(NSString *)replaceH5:(NSString *)contentStr
{
    //h5代码替换
    NSString *getStr = contentStr;
    contentStr = [[contentStr
                   stringByReplacingOccurrencesOfRegex:@"<([^>]*)>" withString:@""] stringByReplacingOccurrencesOfRegex:@"\\*|\t|\r|\n" withString:@""];
    if (![contentStr isEqualToString:getStr]) {
        if ([getStr rangeOfString:@"myRegularId="].length>0) {
            contentStr = [contentStr stringByReplacingOccurrencesOfString:ReplaceH5String withString:@""];
        }
    }
    return contentStr;
    
}

//替换掉所有富文本，获得实际展示的文本
+(NSString *)replaceAllStr:(NSString *)allStr
{
    allStr = [self replaceEmojiForCaculateheight:allStr];
    allStr = [self replaceHtmlLanguageWithSpace:allStr];
    return allStr;
}


+(NSString *)replaceEmoji:(NSString *)contentStr
{
    //表情替换
    NSString *regexEmoj = @"\\[(\\w+?)\\]";
    NSString *replaceWithString = @"\\[$1,13,13\\]";
    contentStr = [contentStr stringByReplacingOccurrencesOfRegex:regexEmoj withString:replaceWithString];
    contentStr =  [contentStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    
    return contentStr;
    
}

+(NSString *)replaceUrl:(NSString *)contentStr
{
    contentStr = [contentStr stringByReplacingOccurrencesOfRegex:urlRegixted2 withString:NetWorkConnetString];
    return contentStr;
    
}


/**
 *  @author SamWu
 *
 *  @brief  替换掉h5的代码，把超链接换成“访问链接+”,把表情换成能识别的
 *
 *  @param contentStr 。
 *
 *  @return 返回字符串
 */
+(NSString *)replaceHtmlLanguageWithSpace:(NSString *)contentStr
{
    if (!contentStr||!NOTNULL(contentStr)) {
        return @"";
    }
    contentStr = [self replaceH5:contentStr];
    contentStr = [self replaceUrl:contentStr];
    return contentStr;
}

/**
 *  @author SamWu
 *
 *  @brief  获取文本高度
 *
 *  @param labelWidth labelWidth
 *  @param containStr 文本
 *
 *  @return height
 */
+(CGFloat)getLabelHight:(CGFloat)labelWidth :(NSString *)containStr :(NSInteger)font
{
    if (!NOTNULL(containStr)||!containStr||[containStr isEqualToString:@""]) {
        return 0;
    }
    TYAttributedLabel *tyLabel = [TYAttributedLabel new];
    tyLabel = [DtCaculateTool getAllTextAttributeLabel:containStr :tyLabel :font];
    tyLabel.linesSpacing = LINESPACE;
    tyLabel.characterSpacing = PERSPACE;
    [tyLabel setFrameWithOrign:CGPointMake(0,0) Width:labelWidth];
    [tyLabel sizeToFit];
    CGFloat height= HEIGHT(tyLabel);
    tyLabel = nil;
    return height;
}




+(CGFloat)getWebReplyLabelHight:(CGFloat)labelWidth :(NSString *)containStr :(NSInteger)font
{
    if (!NOTNULL(containStr)||!containStr||[containStr isEqualToString:@""]) {
        return 0;
    }
    TYAttributedLabel *tyLabel = [TYAttributedLabel new];
    tyLabel = [DtCaculateTool getAllTextAttributeLabel:containStr :tyLabel :font];
    [tyLabel setFrameWithOrign:CGPointMake(0,0) Width:labelWidth];
    [tyLabel sizeToFit];
    CGFloat height= HEIGHT(tyLabel);
    tyLabel = nil;
    return height;
}


//时间戳转换成字符串
+ (NSString *)formateTime:(NSString *)time
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *nowDate = [NSDate dateWithTimeIntervalSince1970:time.integerValue];
    NSInteger timeInterval = -[nowDate timeIntervalSinceNow];
    if (timeInterval < 60*5) {
        return @"刚刚";
    } else if (timeInterval < 3600) {//1小时内
        return [NSString stringWithFormat:@"%@分钟前", @(timeInterval / 60)];
    } else if (timeInterval < 21600) {//6小时内
        return [NSString stringWithFormat:@"%@小时前", @(timeInterval / 3600)];
    } else{
        return [self formateZxTime:time];
    }
    return @"";
    
}

//资讯时间戳转换成字符串
+ (NSString *)formateZxTime:(NSString *)time
{
    if (!time) {
        return @"";
    }
    NSTimeInterval secondsPer = 24*60*60;
    NSDate *today = [[NSDate alloc]init];
    NSDate *yesterday = [today dateByAddingTimeInterval:-secondsPer];
    NSString *yesterdayString = [[yesterday description]substringToIndex:10];
    NSString *todayString = [[today description]substringToIndex:10];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time.integerValue];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    NSString *dateString = [[localeDate description]substringToIndex:10];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *nowDate = [NSDate dateWithTimeIntervalSince1970:time.integerValue];
    NSString *theDay = [dateFormatter stringFromDate:nowDate];//日期的年月日
    NSString *currentDay = [dateFormatter stringFromDate:[NSDate date]];//当前年月日
    NSString *nowYearStr = [currentDay substringToIndex:4];
    NSString *yearStr = [theDay substringToIndex:4];
    if ([dateString isEqualToString:todayString]) {
        return [NSString stringWithFormat:@"%@",[theDay substringFromIndex:11]];
    }else if ([dateString isEqualToString:yesterdayString]){
        return [NSString stringWithFormat:@"昨天 %@",[theDay substringFromIndex:11]];
    }else{
        if ([yearStr isEqualToString:nowYearStr]) {
            return [[theDay substringFromIndex:5]substringToIndex:5];
        }
        return [theDay substringToIndex:10];
    }
    
}

/**
 *  @author SamWu
 *
 *  @brief  判断当前的时间戳是否超过了
 *
 *  @param time 返回时间
 *
 *  @return y/n
 */
+(BOOL)isOutToday:(NSString *)time
{
    NSDate *localDate = [NSDate date]; //获取当前时间
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[localDate timeIntervalSince1970]];
    if (timeSp.integerValue<time.integerValue) {
        return YES;
    }else{
        return NO;
    }
}



#pragma mark<cell delegates>

/**
 *  @author SamWu
 *
 *  @brief  获取富文本替换的部分
 *
 *  @param str 文本.参数一定要是完整的，url没被替换的
 *
 *  @return 富文本数组
 */
+(NSMutableArray *)getTyStoreArrs:(NSString *)allCommStr :(NSInteger)font nameColor:(UIColor *)nameColor
{
    if (!nameColor) {
        nameColor = NAMEBLUE;
    }
    
    NSMutableArray *tmpArray = [NSMutableArray new];
    //正则匹配和替换H5
    NSString *orangStr = allCommStr;
    allCommStr = [self replaceH5:allCommStr];
    __block NSMutableArray *urlArr = [NSMutableArray new];
    // 正则匹配网址
    [allCommStr enumerateStringsMatchedByRegex:urlRegixted2 usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        if (captureCount>0) {
            NSString *str = *capturedStrings;
            [urlArr addObject:str];
        }
    }];
    
    //如果有网址
    allCommStr = [self replaceUrl:allCommStr];
    if (urlArr.count>0) {
        int i = 0;
        for (NSString *str in urlArr) {
            TYLinkTextStorage *textStorage = [[TYLinkTextStorage alloc]init];
            textStorage.textColor = NAMEBLUE;
            textStorage.font = SYSTEMFONT(font);
            textStorage.linkData = str;
            textStorage.underLineStyle = kCTUnderlineStyleNone;
            textStorage.range = [allCommStr rangeOfString:NetWorkConnetString];
            allCommStr = [allCommStr stringByReplacingCharactersInRange:textStorage.range withString:[NSString stringWithFormat:@"访问连%d%d",arc4random()%10,arc4random()%10]];
            textStorage.text = NetWorkConnetString;
            textStorage.type = WebUrlTOUCH;
            [tmpArray addObject:textStorage];
            i++;
        }
    }
    
    
    //话题
    [allCommStr enumerateStringsMatchedByRegex:@"#([^@]+?)#" usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        
        if (captureCount > 0) {
            // 话题信息
            TYLinkTextStorage *textStorage = [[TYLinkTextStorage alloc]init];
            textStorage.textColor = NAMEBLUE;
            textStorage.font = SYSTEMFONT(font);
            NSString *linkStr = *capturedStrings;
            textStorage.linkData = [linkStr stringByReplacingOccurrencesOfString:@"#" withString:@""];
            textStorage.underLineStyle = kCTUnderlineStyleNone;
            textStorage.range = [allCommStr rangeOfString:*capturedStrings];
            textStorage.text = *capturedStrings;
            textStorage.type = HuatiTouch;
            [tmpArray addObject:textStorage];
        }
    }];
    
    //表情
    [allCommStr enumerateStringsMatchedByRegex:@"\\[(\\w+?)\\]" usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        if (captureCount > 0) {
            // 图片信息储存,判断是不是本地有这个表情
            if ([[self emojiStringArray]indexOfObject:(*capturedStrings)]!=NSNotFound) {
                TYImageStorage *imageStorage = [[TYImageStorage alloc]init];
                imageStorage.imageName = *capturedStrings;
                imageStorage.range = capturedRanges[0];
                imageStorage.size = CGSizeMake(font+2,font+2);
                [tmpArray addObject:imageStorage];
            }
        }
    }];
    
    
    __block NSMutableArray *uidArr;
    __block NSMutableArray *nameArr;
    uidArr = [NSMutableArray new];
    nameArr = [NSMutableArray new];
    NSArray *getUidArr ;
    //如果有@的人,形式是h5的,因为考虑了uid所以原本的数据肯定和显示不同，但是TS非要用uname就不做这个判断,还有些没有以该形式的在else里面
    if ([orangStr rangeOfString:@"</a>"].length>0&&[orangStr componentsSeparatedByString:@"</a>"].count>0) {
        getUidArr = [orangStr componentsSeparatedByString:@"</a>"];
        
        NSString *myStr = [NSString stringWithFormat:@">%@",ReplaceH5String];
        
        for (NSString *strU in getUidArr) {
            if ([strU rangeOfString:@"uid="].length>0&&[strU rangeOfString:@">@"].length>0) {
                //关键代码，截取uid，现在按照uname的话就用uname
                //                    NSRange tempRange = [strU rangeOfString:@"uid="];
                //                    [uidArr addObject:[NSString stringWithFormat:@"%d",[[strU substringFromIndex:(tempRange.location+tempRange.length)]intValue]]];
                NSRange nameRange = [strU rangeOfString:@">@"];
                NSString *tNames = [NSString stringWithFormat:@"@%@",[strU substringFromIndex:(nameRange.location+nameRange.length)]];
                NSString *uidName = tNames;//去掉@
                if ([[tNames substringToIndex:1]isEqualToString:@"@"]) {
                    //如果是有@人的形式要去掉
                    uidName = [tNames substringFromIndex:1];
                }
                [nameArr addObject:tNames];
                [uidArr addObject:uidName];//暂时uid添加的也是uname的
            }else if ([strU rangeOfString:@"myRegularId="].length>0&&[strU rangeOfString:myStr].length>0){
                //关键代码，截取uid，现在按照uname的话就用uname
                //                    NSRange tempRange = [strU rangeOfString:@"myRegularId="];
                //                    NSString *uidStrss = [strU substringFromIndex:(tempRange.location+tempRange.length)];
                //                    NSRange toUidR = [uidStrss rangeOfString:[NSString stringWithFormat:@">%@",ReplaceH5String]];
                //                    [uidArr addObject:[uidStrss substringWithRange:NSMakeRange(0, toUidR.location)]];
                NSRange nameRange = [strU rangeOfString:myStr];
                NSString *tNames = [NSString stringWithFormat:@"%@",[strU substringFromIndex:(nameRange.location+nameRange.length)]];
                NSString *uidName = tNames;//去掉@
                if ([[tNames substringToIndex:1]isEqualToString:@"@"]) {
                    //如果是有@人的形式要去掉
                    uidName = [tNames substringFromIndex:1];
                }
                [nameArr addObject:tNames];
                [uidArr addObject:uidName];//暂时uid添加的也是uname的
            }
        }
    }
    //@的人做成超链接
    if (uidArr.count>0) {
        int i = 0;
        for (NSString *str in uidArr) {
            TYLinkTextStorage *textStorage = [[TYLinkTextStorage alloc]init];
            textStorage.textColor = nameColor;
            textStorage.font = SYSTEMFONT(font);
            textStorage.linkData = str;
            textStorage.underLineStyle = kCTUnderlineStyleNone;
            textStorage.range = [allCommStr rangeOfString:nameArr[i]];
            textStorage.text = nameArr[i];
            //用一个永远不会看到的字符来替换@，避免重复字符，识别不了
            // 修复 发布url@XX 全站crash的bug
            if ([nameArr[i] length]>0 && [allCommStr containsString:nameArr[i]]) {
                NSString *atString = [allCommStr substringWithRange:NSMakeRange(textStorage.range.location, 1)];
                if ([atString isEqualToString:@"@"]) {
                    allCommStr = [allCommStr stringByReplacingCharactersInRange:NSMakeRange(textStorage.range.location,1) withString:@"ç"];
                }
            }
            
            textStorage.type = NAMETOUCH;
            [tmpArray addObject:textStorage];
            i++;
        }
    }
    
    // 正则匹配@人,手动输入的
    [uidArr removeAllObjects];
    [nameArr removeAllObjects];

    [allCommStr enumerateStringsMatchedByRegex:@"@([\\x{4e00}-\\x{9fa5}A-Za-z0-9_\\-]+)" usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        if (captureCount>0) {
            NSString *str = *capturedStrings;
            [uidArr addObject:str];
            [nameArr addObject:str];
        }
    }];
    
    //@的人,手动输入的
    if (uidArr.count>0) {
        int i = 0;
        for (NSString *str in uidArr) {
            TYLinkTextStorage *textStorage = [[TYLinkTextStorage alloc]init];
            textStorage.textColor = NAMEBLUE;
            textStorage.font = SYSTEMFONT(font);
            if ([[str substringToIndex:1]isEqualToString:@"@"]) {
                //如果是有@人的形式要去掉
                textStorage.linkData = [str substringFromIndex:1];
            }else
                textStorage.linkData = str;
            textStorage.underLineStyle = kCTUnderlineStyleNone;
            textStorage.range = [allCommStr rangeOfString:nameArr[i]];
            textStorage.text = nameArr[i];
            if ([nameArr[i] length]>0) {
                NSString *atString = [allCommStr substringWithRange:NSMakeRange(textStorage.range.location, 1)];
                if ([atString isEqualToString:@"@"]) {
                    allCommStr = [allCommStr stringByReplacingCharactersInRange:NSMakeRange(textStorage.range.location,1) withString:@"ç"];
                }
            }
            textStorage.type = NAMETOUCH;
            [tmpArray addObject:textStorage];
            i++;
        }
    }
    
    return tmpArray;
}


+ (NSArray *) emojiStringArray
{
    
    return [NSArray arrayWithObjects:@"[aini]",@"[aoman]",@"[baiyan]",@"[baobao]",@"[bishi]",@"[bizui]",@"[cahan]",@"[chajing]",@"[ciya]",@"[dabian]",@"[dabing]",@"[daku]",@"[deyi]",@"[fadai]",@"[fanu]",@"[fendou]",@"[ganga]",@"[gouyin]",@"[guzhang]",@"[haixiu]",@"[haha]",@"[haochi]",@"[haqian]",@"[huaixiao]",@"[jingkong]",@"[jingya]",@"[kafei]",@"[keai]",@"[kelian]",@"[ku]",@"[kuaikule]",@"[kulou]",@"[kun]",@"[lanqiu]",@"[lenghan]",@"[liuhan]",@"[liulei]",@"[ma]",@"[nanguo]",@"[no]",@"[ok]",@"[peifu]",@"[pizui]",@"[pingpang]",@"[qiang]",@"[qiaoda]",@"[qinqin]",@"[qioudale]",@"[ruo]",@"[se]",@"[shuai]",@"[shuijiao]",@"[tiaopi]",@"[touxiao]",@"[tu]",@"[wabi]",@"[weiqu]",@"[weixiao]",@"[woquan]",@"[woshou]",@"[xia]",@"[xu]",@"[yeah]",@"[yinxian]",@"[yiwen]",@"[youhengheng]",@"[yueliang]",@"[yun]",@"[zaijian]",@"[zhemo]",@"[zhu]",@"[zhuakuang]",@"[zuohengheng]",nil];
}


+(TYAttributedLabel *)getAllTextAttributeLabel:(NSString *)allStr :(TYAttributedLabel *)attLabel :(NSInteger)font
{
    UIColor *defualtC = attLabel.textColor;
    attLabel.text = [self replaceHtmlLanguageWithSpace:allStr];
    attLabel.backgroundColor = [UIColor clearColor];
    // 属性文本生成器
    TYTextContainer *attStringCreater = [[TYTextContainer alloc]init];
    attStringCreater.text = attLabel.text;
    NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:[self getTyStoreArrs:allStr :font nameColor:nil]];
    // 添加图片信息数组到label
    [attStringCreater addTextStorageArray:tmpArray];
    [attLabel setTextContainer:attStringCreater];
    //TYLabel的属性不能在设置frame之前设置，不然会失效，
    attLabel.linesSpacing = LINESPACE;
    attLabel.characterSpacing = PERSPACE;
    attLabel.font = SYSTEMFONT(font);
    attLabel.lineBreakMode = kCTLineBreakByTruncatingTail;
    attLabel.numberOfLines = 0;
    attLabel.textColor = defualtC;
    return attLabel;
}

+(TYAttributedLabel *)getAllTextAttributeLabel:(NSString *)allStr :(TYAttributedLabel *)attLabel :(NSInteger)font nameColor:(UIColor *)nameColor
{
    UIColor *defualtC = attLabel.textColor;
    
    
    attLabel.text = [self replaceHtmlLanguageWithSpace:allStr];
    attLabel.backgroundColor = [UIColor clearColor];
    // 属性文本生成器
    TYTextContainer *attStringCreater = [[TYTextContainer alloc]init];
    attStringCreater.text = attLabel.text;
    NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:[self getTyStoreArrs:allStr :font nameColor:nameColor]];
    // 添加图片信息数组到label
    [attStringCreater addTextStorageArray:tmpArray];
    [attLabel setTextContainer:attStringCreater];
    //TYLabel的属性不能在设置frame之前设置，不然会失效，
    attLabel.linesSpacing = LINESPACE;
    attLabel.characterSpacing = PERSPACE;
    attLabel.font = SYSTEMFONT(font);
    attLabel.lineBreakMode = kCTLineBreakByTruncatingTail;
    attLabel.numberOfLines = 0;
    attLabel.textColor = defualtC;
    return attLabel;
}

+(NSString *)replaceHuiceAndTab:(NSString *)str
{
    str =  [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    return str;
}



/*
 weibo.app 里面的正则，有兴趣的可以参考下：
 
 HTTP链接 (例如 http://www.weibo.com ):
 ([hH]ttp[s]{0,1})://[a-zA-Z0-9\.\-]+\.([a-zA-Z]{2,4})(:\d+)?(/[a-zA-Z0-9\-~!@#$%^&*+?:_/=<>.',;]*)?
 ([hH]ttp[s]{0,1})://[a-zA-Z0-9\.\-]+\.([a-zA-Z]{2,4})(:\d+)?(/[a-zA-Z0-9\-~!@#$%^&*+?:_/=<>]*)?
 (?i)https?://[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)+([-A-Z0-9a-z_\$\.\+!\*\(\)/,:;@&=\?~#%]*)*
 ^http?://[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+(\/[\w-. \/\?%@&+=\u4e00-\u9fa5]*)?$
 
 链接 (例如 www.baidu.com/s?wd=test ):
 ^[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)+([-A-Z0-9a-z_\$\.\+!\*\(\)/,:;@&=\?~#%]*)*
 
 邮箱 (例如 sjobs@apple.com ):
 \b([a-zA-Z0-9%_.+\-]{1,32})@([a-zA-Z0-9.\-]+?\.[a-zA-Z]{2,6})\b
 \b([a-zA-Z0-9%_.+\-]+)@([a-zA-Z0-9.\-]+?\.[a-zA-Z]{2,6})\b
 ([a-zA-Z0-9%_.+\-]+)@([a-zA-Z0-9.\-]+?\.[a-zA-Z]{2,6})
 
 电话号码 (例如 18612345678):
 ^[1-9][0-9]{4,11}$
 
 At (例如 @王思聪 ):
 @([\x{4e00}-\x{9fa5}A-Za-z0-9_\-]+)
 
 话题 (例如 #奇葩说# ):
 #([^@]+?)#
 
 表情 (例如 [呵呵] ):
 \[([^ \[]*?)]
 
 匹配单个字符 (中英文数字下划线连字符)
 [\x{4e00}-\x{9fa5}A-Za-z0-9_\-]
 
 匹配回复 (例如 回复@王思聪: ):
 \x{56de}\x{590d}@([\x{4e00}-\x{9fa5}A-Za-z0-9_\-]+)(\x{0020}\x{7684}\x{8d5e})?:
 
 */

@end
