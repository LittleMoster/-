//
//  Act_CommentCell.m
//  ThinkSNS_activity
//
//  Created by SamWu on 15/12/18.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "Act_CommentCell.h"
#import "DtCaculateTool.h"

@implementation Act_CommentCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self makeCellView];
    }
    return self;
}

-(void)makeCellView {
    _avartaImg = [UIImageView new];
    _nameLabel = [UILabel new];
    _timeLabel = [UILabel new];
    _content = [TYAttributedLabel new];
    _lineLabel  =[UILabel new];
    [self addSubview:_lineLabel];
    [self addSubview:_avartaImg];
    [self addSubview:_nameLabel];
    [self addSubview:_timeLabel];
    [self addSubview:_content];
    
    _avartaImg.frame = CGRectMake(8, 8, 36, 36);
    _avartaImg.layer.cornerRadius = WIDTH(_avartaImg)/2.0;
    _avartaImg.clipsToBounds = YES;
    _avartaImg.userInteractionEnabled = YES;
    UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avartaImageTap)];
    [_avartaImg addGestureRecognizer:tap];
    
    _nameLabel.frame = CGRectMake(MaxX(_avartaImg)+10, Y(_avartaImg)+2, 100, 14);
    _timeLabel.frame = CGRectMake(MaxX(_nameLabel), Y(_nameLabel),MainScreenWidth-MaxX(_nameLabel)-20, 14);
    _timeLabel.textAlignment = NSTextAlignmentRight;
    _nameLabel.font = SYSTEMFONT(14);
    _timeLabel.font = SYSTEMFONT(13);
    _timeLabel.textColor = TimeGRAY;
    _content.font = SYSTEMFONT(14);//LIGHTFONT(14);
    _content.backgroundColor = [UIColor clearColor];
    _lineLabel.backgroundColor = CELLRGB;
    _lineLabel.hidden = NO;
    self.backgroundColor = [UIColor whiteColor];

}

-(void)setComment:(ActivityNoticeModel *)comment {
    _comment = comment;
    [_avartaImg sd_setImageWithURL:[NSURL URLWithString:comment.avatar] placeholderImage:SMALL_USER];
    _nameLabel.text = comment.uname;
    _timeLabel.text = [UserSingleCenter formateZxTime:comment.ctime];
    _content = [DtCaculateTool getAllTextAttributeLabel:_comment.content :_content :CONTENTFONT-1 nameColor:[UIColor blackColor]];
    [_content sizeToFit] ;
//    _content.text = comment.content;
    [_content setFrameWithOrign:CGPointMake(X(_nameLabel), MaxY(_nameLabel)+5) Width:(MainScreenWidth-X(_nameLabel)-10)];
}

+(CGFloat)cellHeight:(NSString *)content {
    TYAttributedLabel *ty = [TYAttributedLabel new];
    ty.text = content;
    ty.font = SYSTEMFONT(14);
    [ty setFrameWithOrign:CGPointZero Width:(MainScreenWidth-8-36-17-10)];
//    return HEIGHT(ty)+8+16+2+10;
    return [DtCaculateTool getLabelHight:MainScreenWidth-8-36-10 :content :14] + 8 + 16 + 2 + 10;
}

- (void)avartaImageTap {
    if (_delegate && [_delegate respondsToSelector:@selector(goToUserPageWithUserName:)]) {
        [_delegate goToUserPageWithUserName:_comment.uname];
    }
}
@end
