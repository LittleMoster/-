//
//  WeiboCommentCell.m
//  ThinkSNS（探索版）
//
//  Created by SamWu on 16/2/25.
//  Copyright © 2016年 zhishi. All rights reserved.
//

#import "WeiboCommentCell.h"
#import "TYAttributedLabel.h"
#import "DtCaculateTool.h"
@interface WeiboCommentCell()<TYAttributedLabelDelegate>
{
    UIImageView *faceImageView;
    UILabel *nameLabel;
    UILabel *timeLabel;
    UIView *lineView;

}
@property (nonatomic, strong) UIImageView *avatarBadgeView; ///< 徽章

@property(nonatomic,retain)TYAttributedLabel *contentLabel;

@end


@implementation WeiboCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self makeView];
    }
    return self;
}

-(void)makeView
{
    //头像
    faceImageView = [[UIImageView alloc]initWithFrame:CGRectMake(12, 13, 34, 34)];
    faceImageView.backgroundColor = [UIColor clearColor];
    faceImageView.layer.masksToBounds = YES;
    faceImageView.layer.cornerRadius = 17;
    faceImageView.userInteractionEnabled = YES;
    [self addSubview:faceImageView];
    
    UITapGestureRecognizer *faceTgr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(faceClick)];
    [faceImageView addGestureRecognizer:faceTgr];
    
    _avatarBadgeView = [UIImageView new];
    _avatarBadgeView.hidden = YES;//默认隐藏
    _avatarBadgeView.size = CGSizeMake(GroupLogoWidth, GroupLogoWidth);
    _avatarBadgeView.center = CGPointMake(faceImageView.right - 6, faceImageView.bottom - 6);
    _avatarBadgeView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_avatarBadgeView];

    
    //名字
    nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(62, 13, 200, 16)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = RGBA(12, 12, 12);
    nameLabel.font = [UIFont systemFontOfSize:14.0];
    [self addSubview:nameLabel];
    nameLabel.userInteractionEnabled = YES;
    [nameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(faceClick)]];

    //时间
    timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(MainScreenWidth-200, 26, 200, 20)];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.textColor = RGBA(138, 138, 138);
    timeLabel.font = [UIFont systemFontOfSize:11.0];
    [self addSubview:timeLabel];
    
    _contentLabel = [TYAttributedLabel new];
    _contentLabel.textColor = RGBA(1, 1, 1);
    _contentLabel.font = SYSTEMFONT(14);
    _contentLabel.delegate = self;
    [_contentLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_contentLabel];
    
    lineView = [[UIView alloc]init];
    lineView.backgroundColor = LINERGBA;
    [self addSubview:lineView];

}


+(CGFloat)getCommentHeight:(DtComment *)comment
{
    NSString *allStr = comment.content;
    NSString* remark = comment.to_uid_info.remark;
    
    if (remark.length == 0) {
        remark = comment.to_uid_info.uname;
    }
    if (SWNOTEmptyStr(remark)) {
        allStr = [NSString stringWithFormat:@"回复<a myRegularId=%@>%@%@</a>：%@",remark,ReplaceH5String,remark,comment.content];
    }
    return 50+[DtCaculateTool getLabelHight:MainScreenWidth -24-50 :allStr :14];
}

-(void)faceClick
{
    if (_coment.user_info.space_privacy) {
        ShowInViewMiss(SpacePrivacy_TXT);
        return;
    }
    [self touchAttribute:NAMETOUCH data:_coment.user_info.uname];
}

-(void)setComent:(DtComment *)coment
{
    _coment = coment;
    [faceImageView sd_setImageWithURL:[NSURL URLWithString:coment.user_info.avatar_middle] placeholderImage:nil];
    _avatarBadgeView.hidden = YES;
    if (SWNOTEmptyArr(coment.user_info.user_group)) {
        _avatarBadgeView.hidden = NO;
        [_avatarBadgeView sd_setImageWithURL:[NSURL URLWithString:coment.user_info.user_group[0]]];
    }
    nameLabel.text = coment.user_info.uname;
    
    if (coment.user_info.remark.length) {
        nameLabel.text = coment.user_info.remark;
    }
    
    timeLabel.text = [DtCaculateTool formateTime:coment.ctime];
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:13],NSFontAttributeName,nil];
    NSDictionary * dic2 = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:14],NSFontAttributeName,nil];
    CGSize nameSize = [nameLabel.text boundingRectWithSize:CGSizeMake(MainScreenWidth, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic2 context:nil].size;
    nameLabel.size = nameSize;
    
    CGSize timeSize = [timeLabel.text boundingRectWithSize:CGSizeMake(MainScreenWidth, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    timeLabel.frame = CGRectMake(MainScreenWidth -(timeSize.width+5+8), 14, timeSize.width+5, 15);

    _contentLabel.frame = CGRectMake(62, 40, MainScreenWidth -24-50,0);
    NSString *allStr = _coment.content;
    NSRange hfRang = [_coment.content rangeOfString:@"回复@"];
    if (hfRang.length) {
        //谁回复了谁
        //这里有个坑，如果后面的评论里面有没空格的中文冒号，会自动截取N长的名字，等待后台出解决方案吧~~
        NSRange tempRang = [_coment.content rangeOfString:@"："];
        if (tempRang.length>0) {
            NSString *unameStr = [_coment.content substringWithRange:NSMakeRange(hfRang.location+hfRang.length,tempRang.location-(hfRang.location+hfRang.length))];
            //替换文本中的回复为空，我自己拼接
            _coment.content = [_coment.content stringByReplacingCharactersInRange:hfRang withString:@""];
            //no cry
            NSString *tempReplaceStr = [NSString stringWithFormat:@"%@：",unameStr];
            if ([_coment.content rangeOfString:tempReplaceStr].length) {
                _coment.content = [_coment.content stringByReplacingOccurrencesOfRegex:tempReplaceStr withString:@""];
            }
            //组合
            DtUser* toComUser = [DtUser new];
            toComUser.uname = unameStr;
            toComUser.uid = unameStr;
            _coment.to_uid_info = toComUser;
        }else{
            NSLog(@"转回复失败，表打我");
        }
        
    }
    if (SWNOTEmptyStr(_coment.to_uid_info.uname)) {
        allStr = [NSString stringWithFormat:@"回复<a myRegularId=%@>%@%@</a>：%@",_coment.to_uid_info.uname,ReplaceH5String,_coment.to_uid_info.uname,_coment.content];
    }
    _contentLabel.textColor = CommentsColor;
    _contentLabel = [DtCaculateTool getAllTextAttributeLabel:allStr :_contentLabel :14 nameColor:ComentsUserNameColor];
    [_contentLabel sizeToFit];
    
    lineView.frame = CGRectMake(12,MaxY(_contentLabel)+9+0.5, MainScreenWidth-24,0.5);
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
        case CONTENTTOUCH:
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


@end
