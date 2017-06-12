//
//  Act_CommentCell.h
//  ThinkSNS_activity
//
//  Created by SamWu on 15/12/18.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYAttributedLabel.h"
#import "Constants.h"
#import "UIImageView+WebCache.h"
#import "ActComment.h"
#import "ActivityNoticeModel.h"

@protocol Act_CommentCellDelegate <NSObject>

- (void)goToUserPageWithUserName:(NSString *)userName;

@end

@interface Act_CommentCell : UITableViewCell

@property (assign, nonatomic) id<Act_CommentCellDelegate> delegate;

@property(nonatomic,retain)UIImageView *avartaImg;

@property (nonatomic,retain) UILabel *nameLabel;

@property (nonatomic,retain) UILabel *timeLabel;

@property (nonatomic,retain) TYAttributedLabel *content;

@property (nonatomic,retain) UILabel *lineLabel;

@property(nonatomic,retain)ActivityNoticeModel *comment;

+(CGFloat)cellHeight:(NSString *)content;



@end
