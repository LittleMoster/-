//
//  DtCaculateTool.h
//  chuangyejia
//
//  Created by SamWu on 15/10/12.
//  Copyright © 2015年 zhishi. All rights reserved.
//

/**
 *  @author SamWu
 *
 *  @brief  这个类是动态的工具类，主要提供cell的高度计算、富文本操作等类方法
 *
 *  @param -74 ..
 *
 *  @return .
 */




#import <Foundation/Foundation.h>
#import "TYLinkTextStorage.h"
#import "TYImageStorage.h"
#import "TYAttributedLabel.h"
#import "RegexKitLite.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "UIActionSheet+Blocks.h"
#import "BrowserViewController.h"
#import "HomeListVC.h"
#import "CircleDetailViewController.h"


#define FACEHEIGHT 40 //头像高度
#define FACEULeft 12 //头像距离屏幕左边的宽度,距离顶部+3
#define FaceDown 5 //头像和内容的下间距

#define DownDistance 12 //下留白高度

#define ZanDistancePC 3 //赞以及评论距离时间的距离偏差，除掉nickdown
#define GroupLogoWidth 15 //管理标示的图片宽高
#define NICKNAMEHEIGHT 18//昵称高度
#define DistanceFaceRight 10//右边距，头像
#define NAMEFONTSIZE 15 //昵称的字体大小
#define CONTENTFONT 15 //微博内容的字体
#define WIDCONTENT (MainScreenWidth-FACEULeft*2-DistanceFaceRight-FACEHEIGHT) //内容的宽度 50+12*2
#define WIDDetailCONTENT (MainScreenWidth-FACEULeft*2) //微博详情，没有头像的排版

#define AddressViewWidth (iPhone4?100:(iPhone5?120:150))//地址的宽度
#define AddressLabelWidth (AddressViewWidth-18)
#define AddressHeight 12 //地址的高度
#define TimeHeight  12 //时间的高度

#define ToolBarHeight 25//点赞行的高度
#define ZanTouchWidth 50//点赞的触碰区域,更多-10
#define ZanImageHeight 16//点赞图标的高度
#define ZanImageDistanceLabel 2//点赞图标和文字的间距

#define ZhuanfaViewHeight 70 //转发带图片的固定高度
#define ZhuanfaTieziHeiht 70 //转发的帖子，固定高度
#define ReportDeleteHeight 32 //转发的被删除
#define ZhuanfaContentDistance 8//转发的左右内间距
#define ZhuanfaShangxiaJianju 6
#define ZhuanfaFONT 13 //转发文本标题的字体大小 内容和来自依次-1



#define ComentDistance 8.0 //评论距离边框的距离
#define ZanTopDistance 2//点赞列表和容器的上下间距
#define CommentTopDistance 2//评论列表和容器的上下间距
#define ZansMaxNum 5 //最大赞数目
#define CommentMaxNum 3//最大评论数目
#define ZanAndComentFont 12 //点赞和评论的字体大小
//#define CommentsColor [UIColor lightGrayColor]//评论的颜色

#define CommentsColor RGBA(140,140,140)//评论的颜色
#define ComentsUserNameColor [UIColor blackColor]//评论人和被回复人的的名字颜色
#define ComentsMoreHeight 20//更多评论高度
#define ZanViewCommViewDistance 1 //评论和点赞之间的距离
#define LINESPACE 0 //行距，不一定生效，可能会自己适配
#define PERSPACE 0.5 //字距
#define ComentAndComentDistance 0 //评论与评论的间距
#define CommentDistanceBtn 0//评论距离所在按钮顶部的距离





#define NAMEBLUE BLUECOLOR


#define ReplaceH5String @"≤¬πø∆œ≈"//用来替换前面的h5代码，做富文本

#define NetWorkConnetString @"访问链接+" //链接的字段(访问链接+)

@interface DtCaculateTool : NSObject



+(NSString *)replaceEmojiForCaculateheight:(NSString *)contentStr;

+(NSString *)replaceH5:(NSString *)contentStr;

+(NSString *)replaceEmoji:(NSString *)contentStr;

+(NSString *)replaceUrl:(NSString *)contentStr;

+(NSString *)replaceHtmlLanguageWithSpace:(NSString *)contentStr;

//获取富文本的高度
+(CGFloat)getLabelHight:(CGFloat)labelWidth :(NSString *)containStr :(NSInteger)font;


+(CGFloat)getWebReplyLabelHight:(CGFloat)labelWidth :(NSString *)containStr :(NSInteger)font;//微吧的回复高度计算


+ (NSString *)formateTime:(NSString *)time;

+(BOOL)isOutToday:(NSString *)time;


+(TYAttributedLabel *)getAllTextAttributeLabel:(NSString *)allStr :(TYAttributedLabel *)attLabel :(NSInteger)font;

//为了评论框内名字为黑色、、什么JJ需求~~
+(TYAttributedLabel *)getAllTextAttributeLabel:(NSString *)allStr :(TYAttributedLabel *)attLabel :(NSInteger)font nameColor:(UIColor *)nameColor;


+(NSString *)replaceHuiceAndTab:(NSString *)str;

+(NSString *)replaceAllStr:(NSString *)allStr;

@end
