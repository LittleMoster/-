//
//  CommForwardCell.m
//  ZWMFrameWork
//
//  Created by ZhouWeiMing on 14/8/18.
//  Copyright (c) 2014年 zhishi. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "RegexKitLite.h"
#import "UIImageView+WebCache.h"

@implementation CommentTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		// Initialization code
		[self makeView];
	}
	return self;
}

-(void)attributedLabel:(TYAttributedLabel *)attributedLabel textStorageClicked:(id<TYTextStorageProtocol>)textStorage atPoint:(CGPoint)point
{
    //非文本/比如表情什么的
    if (![textStorage isKindOfClass:[TYLinkTextStorage class]]) {
        return;
    }
    TouchType type = ((TYLinkTextStorage *)textStorage).type;
    id linkContain = ((TYLinkTextStorage *)textStorage).linkData;
    [self touchAttribute:type data:linkContain];
}

-(void)touchAttribute:(TouchType)type data:(id)data
{
    switch (type) {
        case NAMETOUCH:
        {
            UserHomePageVC *userVC = [[UserHomePageVC alloc]init];
            userVC.uname = data;
            [_vc.navigationController pushViewController:userVC animated:YES];
        }
            break;
        case WebUrlTOUCH:
        {
            BrowserViewController *browserVC = [[BrowserViewController alloc]initWithUrl:[NSURL URLWithString:data]];
            [_vc presentViewController:browserVC animated:YES completion:^{
                
            }];
        }
            break;
        case HuatiTouch:
        {
            HomeListVC *homV = [HomeListVC new];
            homV.pindaoName = data;
            homV.weiboType = WeiboListTopic;
            [_vc.navigationController pushViewController:homV animated:YES];
        }
            break;
        default:
            break;
    }
    
}


-(void)faceClick{
	if ([self.delegate respondsToSelector:@selector(showUserProfileByName:)])
	{
		[self.delegate showUserProfileByName:nameLabel.text];
	}
}

+(CGFloat)heightForWeibo:(NSDictionary *)weibo{
	NSString *html = [weibo objectForKey:@"content"];
	NSString *_commentHtml = [[html
                               stringByReplacingOccurrencesOfRegex:@"<([^>]*)>" withString:@""] stringByReplacingOccurrencesOfRegex:@"\\*|\t|\r|\n" withString:@""];
	return [DtCaculateTool getLabelHight:MainScreenWidth -74 :_commentHtml :15]+67+2;
}

-(void)updateCellWithWeibo:(NSDictionary *)weibo andIndex:(int)index{
	
	index1 = index;
	
	feedWeibo = weibo;
	
	zanLabel.text = SWToStr([weibo objectForKey:@"digg_count"]);
	if ([[weibo objectForKey:@"is_digg"] intValue]) {
		[zanBtn setImage:[UIImage imageNamed:@"pinglunyizan"] forState:0];
	}else{
		[zanBtn setImage:[UIImage imageNamed:@"pinglunzan"] forState:0];
	}
	
	[faceImageView sd_setImageWithURL:[NSURL URLWithString:[[[weibo objectForKey:@"user_info"] objectForKey:@"avatar"] objectForKey:@"avatar_middle"]] placeholderImage:SMALL_USER];
	nameLabel.text = [[weibo objectForKey:@"user_info"]  objectForKey:@"uname"];
    
    NSString* remark = [[weibo objectForKey:@"user_info"]  objectForKey:@"remark"];
    if (remark.length) {
        
        nameLabel.text = remark;
    }
    
	NSString *ctime = [weibo objectForKey:@"ctime"];
	NSDate *showDate = DateFromString(ctime);
	if (showDate == nil)
	{
		showDate = [NSDate dateWithTimeIntervalSince1970:[ctime longLongValue]];
	}
	timeLabel.text = [DtCaculateTool formateTime:ctime];
	NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:13],NSFontAttributeName,nil];
	CGSize timeSize = [timeLabel.text boundingRectWithSize:CGSizeMake(MainScreenWidth, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
	timeLabel.frame = CGRectMake(62, 39, timeSize.width+5, 15);
	comeLabel.frame = CGRectMake(72+timeSize.width, 39, MainScreenWidth -120, 15);
	
	NSString *allStr = [weibo objectForKey:@"content"];
    NSRange hfRang = [allStr rangeOfString:@"回复@"];
    NSString *tName;
    NSString *tUid;
    if (hfRang.length) {
        //谁回复了谁
        //这里有个坑，如果后面的评论里面有没空格的中文冒号，会自动截取N长的名字，等待后台出解决方案吧~~
        NSRange tempRang = [allStr rangeOfString:@"："];
        if (tempRang.length>0) {
            NSString *unameStr = [allStr substringWithRange:NSMakeRange(hfRang.location+hfRang.length,tempRang.location-(hfRang.location+hfRang.length))];
            //替换文本中的回复为空，我自己拼接
            allStr = [allStr stringByReplacingCharactersInRange:hfRang withString:@""];
            //no cry
            NSString *tempReplaceStr = [NSString stringWithFormat:@"%@：",unameStr];
            if ([allStr rangeOfString:tempReplaceStr].length) {
                allStr = [allStr stringByReplacingOccurrencesOfRegex:tempReplaceStr withString:@""];
            }
            //组合
            tName = unameStr;
            tUid = unameStr;
        }else{
            NSLog(@"转回复失败，表打我");
        }
        
    }
    if (SWNOTEmptyStr(tName)){
        allStr = [NSString stringWithFormat:@"回复<a myRegularId=%@>%@%@</a>：%@",tName,ReplaceH5String,tName,allStr];
    }
    weiBoView.frame = CGRectMake(62, 57, MainScreenWidth -24-50,0);
    weiBoView = [DtCaculateTool getAllTextAttributeLabel:allStr :weiBoView :15 nameColor:ComentsUserNameColor];
    [weiBoView sizeToFit];
	[self addSubview:weiBoView];
	
	lineView.frame = CGRectMake(12, CGRectGetMaxY(weiBoView.frame)+10+0.5, MainScreenWidth-24, 0.5);
}



-(void)makeView{
	//头像
	faceImageView = [[UIImageView alloc]initWithFrame:CGRectMake(12, 15, 40, 40)];
	faceImageView.backgroundColor = [UIColor clearColor];
	faceImageView.layer.masksToBounds = YES;
	faceImageView.layer.cornerRadius = 20;
	faceImageView.userInteractionEnabled = YES;
	[self addSubview:faceImageView];
	
	UITapGestureRecognizer *faceTgr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(faceClick)];
	[faceImageView addGestureRecognizer:faceTgr];
	
	//名字
	nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(62, 15, 200, 18)];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.textColor = RGBA(12, 12, 12);
	nameLabel.font = [UIFont systemFontOfSize:16.0];
	[self addSubview:nameLabel];
	
	zanLabel = [[UILabel alloc]initWithFrame:CGRectMake(MainScreenWidth-120, 12, 80, 18)];
	zanLabel.backgroundColor = [UIColor clearColor];
	zanLabel.textColor = RGBA(102, 102, 102);
	zanLabel.font = [UIFont systemFontOfSize:12.0];
	zanLabel.textAlignment = NSTextAlignmentRight;
//	[self addSubview:zanLabel];
	
	UIButton *zanBtnBg = [UIButton buttonWithType:UIButtonTypeCustom];
	zanBtnBg.frame = CGRectMake(MainScreenWidth-40, 12, 40, 40);
	[zanBtnBg addTarget:self action:@selector(zanBtn:) forControlEvents:UIControlEventTouchUpInside];
//	[self addSubview:zanBtnBg];
	
	zanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	zanBtn.frame = CGRectMake(10, 3, 15, 13);
	zanBtnBg.tag = zanBtn.tag;
	[zanBtn addTarget:self action:@selector(zanBtn:) forControlEvents:UIControlEventTouchUpInside];
//	[zanBtnBg addSubview:zanBtn];
	
	//时间
	timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 30, MainScreenWidth -120, 20)];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textColor = RGBA(138, 138, 138);
	timeLabel.font = [UIFont systemFontOfSize:12.0];
	[self addSubview:timeLabel];
	
	//来自客户端
	comeLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 300, MainScreenWidth -120, 20)];
	comeLabel.backgroundColor = [UIColor clearColor];
	comeLabel.textColor = RGBA(138, 138, 138);
	comeLabel.font = [UIFont systemFontOfSize:12.0];
	[self addSubview:comeLabel];
	
	//原微博内容
	weiBoView  = [[TYAttributedLabel alloc] initWithFrame:CGRectZero];
	weiBoView.opaque = YES;
	weiBoView.backgroundColor = [UIColor clearColor];
	weiBoView.font = [UIFont systemFontOfSize:15];
	[weiBoView setTextColor:[UIColor lightGrayColor]];
	[weiBoView setBackgroundColor:[UIColor clearColor]];
    weiBoView.delegate = self;
    
	lineView = [[UIView alloc]init];
	lineView.backgroundColor = LINERGBA;
	[self addSubview:lineView];
	
	
}

-(void)zanBtn:(UIButton *)sender{
	
	if ([ThinkSNSUtil isExistenceNetwork]) {
		BOOL isZan = [[feedWeibo objectForKey:@"is_digg"] boolValue];
		//赞的动画效果
		if (isZan) {
			index2 = 0;
		}else{
			index2 = 1;
		}
		//14年11月3刘鹏注释,在过多处对其进行了设置
		//		[zanBtn setImage:[UIImage imageNamed:(index2%2==0?@"pinglunzan":@"pinglunyizan")] forState:0];
		//		zanBtn.layer.contents = (id)[UIImage imageNamed:(index2%2==0?@"pinglunzan":@"pinglunyizan")].CGImage;
		CAKeyframeAnimation *k = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
		k.values = @[@(0.1),@(1.5),@(1.5)];
		k.keyTimes = @[@(0.0),@(0.5),@(0.8),@(1.0)];
		k.calculationMode = kCAAnimationLinear;
		[zanBtn.layer addAnimation:k forKey:@"SHOW"];
		[zanBtn.layer addAnimation:k forKey:@"SHOW"];
		
		//		if (isZan) {
		//			zanLabel.text = [NSString stringWithFormat:@"%d",[[feedWeibo objectForKey:@"digg_count"] intValue]-1];
		//		}else{
		//			zanLabel.text = [NSString stringWithFormat:@"%d",[[feedWeibo objectForKey:@"digg_count"] intValue]+1];
		//		}
		
		if (self.delegate&&[self.delegate respondsToSelector:@selector(zanClick_:)]) {
			[self.delegate zanClick_:index1];
		}
	}else{
		[self showHint:@"请检查网络设置"];
	}
	
}

- (void)awakeFromNib
{
	// Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}

@end
