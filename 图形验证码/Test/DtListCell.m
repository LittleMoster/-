//
//  DtListCell.m
//  ThinkSNS（探索版）
//
//  Created by SamWu on 16/2/19.
//  Copyright © 2016年 zhishi. All rights reserved.
//

#import "DtListCell.h"


#pragma mark<顶部用户名、头像栏>
@implementation SWStatusProfileView

- (instancetype)initWithFrame:(CGRect)frame superCell:(DtListCell *)cell{
    self = [super initWithFrame:frame];
    if (self) {
        self.exclusiveTouch = YES;//禁止多点触碰
        _cell = cell;
        _avatarView = [UIImageView new];
        _avatarView.userInteractionEnabled = YES;
        _avatarView.frame = CGRectMake(FACEULeft, FACEULeft, FACEHEIGHT, FACEHEIGHT);
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarView.clipsToBounds = YES;
        _avatarView.layer.cornerRadius = WIDTH(_avatarView)/2.0;
        _avatarView.backgroundColor = [UIColor lightGrayColor];
        _avatarBadgeView = [UIImageView new];
        _avatarBadgeView.hidden = YES;//默认隐藏
        _avatarBadgeView.size = CGSizeMake(GroupLogoWidth, GroupLogoWidth);
        _avatarBadgeView.center = CGPointMake(_avatarView.right - 6, _avatarView.bottom - 6);
        _avatarBadgeView.contentMode = UIViewContentModeScaleAspectFit;
        
        _nameLabel = [UILabel new];
        _nameLabel.frame = CGRectMake(_avatarView.right + DistanceFaceRight, Y(_avatarView), _cell.contentWidth, NICKNAMEHEIGHT);
        _nameLabel.font = SYSTEMFONT(NAMEFONTSIZE);
        _nameLabel.userInteractionEnabled = YES;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_nameLabel];
        
        _sourceLabel = [TYAttributedLabel new];
        _sourceLabel.delegate = self;
        _sourceLabel.frame = CGRectMake(X(_nameLabel), MaxY(_nameLabel)+5, WIDTH(_nameLabel), HEIGHT(_nameLabel)-5);
        _sourceLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_sourceLabel];
        
        _careButton = [[UIButton alloc]initWithFrame:CGRectMake(MainScreenWidth -60, 14, 48, 22)];
        [_careButton setTitleColor:RGBA(255, 158, 0) forState:UIControlStateNormal];
        [_careButton setTitle:@"+关注" forState:UIControlStateNormal];
        _careButton.titleLabel.font =[UIFont systemFontOfSize:10];
        [_careButton.layer setBorderColor:RGBA(255, 158, 0).CGColor];
        [_careButton.layer setBorderWidth:0.5];
        [_careButton.layer setMasksToBounds:YES];
        _careButton.layer.cornerRadius =3;
        _careButton.clipsToBounds =YES;
        [_careButton addTarget:self action:@selector(addCareTouch) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_careButton];
        
        //点咯👤
        [_avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSome:)]];
        
        //点咯名字
        [_nameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSome:)]];
        if (_cell.dtType == SWWeiboListType) {
            //微博列表
            [self addSubview:_avatarView];
            [self addSubview:_avatarBadgeView];
        }else{
            _nameLabel.frame = CGRectMake(FACEULeft, Y(_avatarView), _cell.contentWidth, NICKNAMEHEIGHT);
            _sourceLabel.frame = CGRectMake(MaxX(_nameLabel),Y(_nameLabel)+5, WIDTH(_nameLabel), HEIGHT(_nameLabel)-5);
        }
    }
    return self;
}

-(void)addCareTouch
{
    _careButton.hidden = YES;
    NSString *addUrl = API_URL_USER_Follow;
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:_swlayout.weibo.user_info.uid,@"user_id", nil];
    [Api requestWithMethod:@"get" withPath:addUrl withParams:param withSuccess:^(id responseObject) {
        if ([[responseObject objectForKey:@"status"] intValue]) {
            [_cell.vc showHudInView:_cell.vc.view showHint:@"加关注成功"];
            _swlayout.weibo.user_info.following = 1;
            [_cell touchAttribute:UpdateTouch data:_swlayout.weibo];
        }else{
            [_cell.vc showHudInView:_cell.vc.view showHint:@"加关注失败"];
        }
    } withError:^(NSError *error) {
        [_cell.vc showHudInView:_cell.vc.view showHint:@"加关注失败"];
    }];
}


-(void)tapSome:(UITapGestureRecognizer *)gesture
{
    if (_swlayout.weibo.user_info.space_privacy == YES) {
        // 不可以进入
        ShowInViewMiss(SpacePrivacy_TXT);
        return;
    }
    [_cell touchAttribute:NAMETOUCH data:_swlayout.weibo.user_info.uname];
}


-(void)setSwlayout:(SWCellLayout *)swlayout
{
    _swlayout = swlayout;
    [_avatarView sd_setImageWithURL:[NSURL URLWithString:_swlayout.weibo.user_info.avatar_middle] placeholderImage:ImageNamed(@"user_default")];
    _avatarBadgeView.hidden = YES;
    if (SWNOTEmptyArr(_swlayout.weibo.user_info.user_group)) {
        _avatarBadgeView.hidden = NO;
        [_avatarBadgeView sd_setImageWithURL:[NSURL URLWithString:swlayout.weibo.user_info.user_group[0]] placeholderImage:Prestrain_SmallFangXingImage];
    }
    _careButton.hidden = YES;
    if (_swlayout.weibo.user_info.following==0&&![_swlayout.weibo.user_info.uid isEqualToString:SWUID]) {
        _careButton.hidden = NO;
    }
    //这里、、、、为了即时更新新的用户名
    if ([_swlayout.weibo.user_info.uid isEqual:SWUID]) {
        _nameLabel.text = SWUNAME;
    }else{
        _nameLabel.text = _swlayout.weibo.user_info.uname;
        
        if (_swlayout.weibo.user_info.remark.length) {
            
            _nameLabel.text = _swlayout.weibo.user_info.remark;
        }
    }
    //分享详情
    CGSize  companyAndJobSize = [_nameLabel.text boundingRectWithSize:CGSizeMake(1000,HEIGHT(_nameLabel)) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:NAMEFONTSIZE]} context:nil].size;
    if (_cell.dtType == SWWeiboDetailType) {
        _nameLabel.frame = CGRectMake(FACEULeft, Y(_avatarView),companyAndJobSize.width, NICKNAMEHEIGHT);
        _sourceLabel.frame = CGRectMake(MaxX(_nameLabel)+10,Y(_nameLabel)+1, _cell.contentWidth-WIDTH(_nameLabel)-10, HEIGHT(_nameLabel)-5);
    }else{
        _nameLabel.width = companyAndJobSize.width;
    }
    NSString *sourceStr  = [NSString stringWithFormat:@"%@  %@",[DtCaculateTool formateTime:_swlayout.weibo.publish_time],_swlayout.weibo.from];
    _sourceLabel = [DtCaculateTool getAllTextAttributeLabel:sourceStr :_sourceLabel :NAMEFONTSIZE-3];
    [_sourceLabel sizeToFit];
    _sourceLabel.textColor = [UIColor lightGrayColor];
    //点咯👤
    UITapGestureRecognizer *tapFace = [UITapGestureRecognizer new];
    [tapFace addActionBlock:^(id sender) {
        
        if (_swlayout.weibo.user_info.space_privacy == YES) {
            // 不可以进入
            ShowInViewMiss(SpacePrivacy_TXT);
            return;
        }
        [_cell touchAttribute:NAMETOUCH data:_swlayout.weibo.user_info.uname];
    }];
    [_avatarView addGestureRecognizer:tapFace];
    
    //点咯名字
    UITapGestureRecognizer *tapName = [UITapGestureRecognizer new];
    [tapName addActionBlock:^(id sender) {
        if (_swlayout.weibo.user_info.space_privacy == YES) {
            // 不可以进入
            ShowInViewMiss(SpacePrivacy_TXT);
            return;
        }

        [_cell touchAttribute:NAMETOUCH data:_swlayout.weibo.user_info.uname];
    }];
    [_nameLabel addGestureRecognizer:tapName];
     
}

-(void)attributedLabel:(TYAttributedLabel *)attributedLabel textStorageClicked:(id<TYTextStorageProtocol>)textStorage atPoint:(CGPoint)point
{
    //非文本/比如表情什么的
    if (![textStorage isKindOfClass:[TYLinkTextStorage class]]) {
        return;
    }
    TouchType type = ((TYLinkTextStorage *)textStorage).type;
    id linkContain = ((TYLinkTextStorage *)textStorage).linkData;
    [_cell touchAttribute:type data:linkContain];
}


@end


#pragma mark<工具栏>
@implementation SWStatusToolbarView
- (instancetype)initWithFrame:(CGRect)frame superCell:(DtListCell *)cell {
    self = [super initWithFrame:frame];
    if (self) {
        self.exclusiveTouch = YES;
        _cell = cell;
        _repostButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _repostButton.exclusiveTouch = YES;
        _repostButton.frame = CGRectMake(MainScreenWidth -128+ZanTouchWidth*2, 0, ZanTouchWidth, self.height);
        
        _addressView = [[UIView alloc]initWithFrame:CGRectMake(DistanceFaceRight+FACEULeft+FACEHEIGHT,0,AddressViewWidth,AddressHeight+4)];
        _addressView.hidden = YES;
        _addressView.backgroundColor = [UIColor clearColor];
        [self addSubview:_addressView];

        
        _addressBtn = [[UIButton alloc]initWithFrame:CGRectMake(18,0,AddressLabelWidth,AddressHeight+4)];
        [_addressBtn setBackgroundImage:ImageNamed(@"dt_touch_hightLight") forState:UIControlStateHighlighted];
        _addressBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _addressBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _addressBtn.titleLabel.font = SYSTEMFONT(AddressHeight-1);
        [_addressBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_addressBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [_addressView addSubview:_addressBtn];
        [_addressBtn addTarget:self action:@selector(pressAddress) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *addressImg = [[UIImageView alloc]initWithFrame:CGRectMake(2,2, AddressHeight,AddressHeight)];
        addressImg.image = ImageNamed(@"dingwei_3");
        addressImg.contentMode = UIViewContentModeScaleAspectFit;
        [_addressView addSubview:addressImg];
        
        
        _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _commentButton.exclusiveTouch = YES;
        _commentButton.frame = CGRectMake(MainScreenWidth -128+ZanTouchWidth, 0, ZanTouchWidth, self.height);
        
        _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _likeButton.exclusiveTouch = YES;
        _likeButton.frame = CGRectMake(MainScreenWidth -128, 0, ZanTouchWidth, self.height);
        
        _repostImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ZanImageHeight, ZanImageHeight)];
        _repostImageView.contentMode = UIViewContentModeScaleAspectFit;
        _repostImageView.image = ImageNamed(@"icon_more_gery");
        [_repostButton addSubview:_repostImageView];
        
        _commentImageView = [[UIImageView alloc] initWithFrame:_repostImageView.bounds];
        _likeImageView.contentMode = UIViewContentModeScaleAspectFit;
        _commentImageView.image = ImageNamed(@"icon_comment_grey");
        [_commentButton addSubview:_commentImageView];
        
        _likeImageView = [[UIImageView alloc] initWithFrame:_repostImageView.bounds];
        _likeImageView.contentMode = UIViewContentModeScaleAspectFit;
        _likeImageView.image = ImageNamed(@"icon_like_grey");
        [_likeButton addSubview:_likeImageView];
        
        
        _commentLabel = [[UILabel alloc]initWithFrame:CGRectMake(MaxX(_commentImageView), 0, WIDTH(_commentButton)-MaxX(_commentImageView), HEIGHT(_commentImageView))];
        [_commentButton addSubview:_commentLabel];
        _commentLabel.textAlignment = NSTextAlignmentCenter;
        
        _likeLabel = [[UILabel alloc]initWithFrame:_commentLabel.frame];
        [_likeButton addSubview:_likeLabel];
        _likeLabel.textAlignment = NSTextAlignmentCenter;
        
        _likeLabel.font = SYSTEMFONT(12);
        _commentLabel.font = SYSTEMFONT(12);
        
        _likeLabel.textColor = [UIColor lightGrayColor];
        _commentLabel.textColor = [UIColor lightGrayColor];
        
        
        if (cell.dtType == SWWeiboListType) {
            //微博列表
            [self addSubview:_repostButton];
            [self addSubview:_commentButton];
            [self addSubview:_likeButton];
        }else{
            _addressView.frame = CGRectMake(FACEULeft,0,WIDTH(_addressView),AddressHeight+4);

        }
        @weakify(self);
        [_repostButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {
            [weak_self moreClick];
        }];
        
        [_commentButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {
            [weak_self commentClick];
        }];
        
        [_likeButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {
            [weak_self zanClick];
        }];
    

    }
    return self;
}

-(void)pressAddress
{
    [_cell touchAttribute:AddressTouch data:nil];

}


//点击了点赞按钮
-(void)zanClick
{
    if (!SWNOTEmptyStr(SWUNAME)) {
        return;
    }
    BOOL isZan = _swlayout.weibo.is_digg;
    //赞的动画效果
    if (isZan) {
        _zanUrl = API_URL_DEL_zan;
        _likeImageView.image = ImageNamed(@"icon_like_grey");
    }else{
        _zanUrl = API_URL_ADD_zan;
        _likeImageView.image = ImageNamed(@"icon_like_blue");
    }
    CAKeyframeAnimation *k = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    k.values = @[@(0.1),@(1.5),@(1.8),@(2.0)];
    k.keyTimes = @[@(0.0),@(0.5),@(0.8),@(1.0)];
    k.calculationMode = kCAAnimationLinear;
    k.removedOnCompletion= YES;
    k.delegate = self;
    [_likeImageView.layer addAnimation:k forKey:@"SHOW"];
    _likeButton.userInteractionEnabled = NO;//防止频繁操作
}

-(void)makeDiger:(BOOL)isZan
{
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:_swlayout.weibo.digg_users];
    if (isZan) {
        //取消
        for (DtDigUser *digUser in _swlayout.weibo.digg_users) {
            if ([digUser.uid isEqualToString:SWUID]) {
                [tempArr removeObject:digUser];
            }
        }
        _swlayout.weibo.digg_count -=1;
        _swlayout.weibo.digg_users = tempArr;
    }else{
        //点赞
        DtDigUser *digUser =[DtDigUser new];
        digUser.uid = SWUID;
        digUser.uname = SWUNAME;
        digUser.avatar = SWAVATAR;
        [tempArr addObject:digUser];
        _swlayout.weibo.digg_count +=1;
        _swlayout.weibo.digg_users = tempArr;
    }
}


//延迟刷新列表，避免用户多次操作，和误操作
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        //网络请求
        _likeButton.userInteractionEnabled = YES;
        if (NOTNULL(_swlayout.weibo.feed_id)) {
            [Api requestWithMethod:@"get" withPath:_zanUrl withParams:@{@"feed_id":_swlayout.weibo.feed_id} withSuccess:^(id responseObject) {
                if ([responseObject[@"status"]integerValue]==1) {
                    [self makeDiger:_swlayout.weibo.is_digg];//本地插数据
                    _swlayout.weibo.is_digg = !_swlayout.weibo.is_digg;//置反
                    if (_swlayout.weibo.is_digg) {
                        _likeImageView.image = ImageNamed(@"icon_like_blue");
                    }else{
                        _likeImageView.image = ImageNamed(@"icon_like_grey");
                    }
                    [_cell touchAttribute:UpdateTouch data:_swlayout.weibo];
                }else{
                    if (_swlayout.weibo.is_digg) {
                        _likeImageView.image = ImageNamed(@"icon_like_blue");
                    }else{
                        _likeImageView.image = ImageNamed(@"icon_like_grey");
                    }
                    [_cell.vc showHudInView:_cell.vc.view showHint:@"点赞失败"];
                }
            } withError:^(NSError *error) {
                if (_swlayout.weibo.is_digg) {
                    _likeImageView.image = ImageNamed(@"icon_like_blue");
                }else{
                    _likeImageView.image = ImageNamed(@"icon_like_grey");
                }
                [_cell.vc showHudInView:_cell.vc.view showHint:@"点赞失败"];
            }];
        }else{
            if (_swlayout.weibo.is_digg) {
                _likeImageView.image = ImageNamed(@"icon_like_blue");
            }else{
                _likeImageView.image = ImageNamed(@"icon_like_grey");
            }
            [_cell.vc showHudInView:_cell.vc.view showHint:@"点赞失败"];
        }
    }
}

//评论按钮
-(void)commentClick
{
    if (_swlayout.weibo.can_comment) {
        //评论框
        SWCommentView *comV=[[SWCommentView alloc]initShowWithUrl:_cell.commentUrl passParam:_cell.comentParam contentKey:_cell.comentKey showId:_swlayout.weibo.feed_id placeHolder:nil replyName:nil];
        //评论成功
        comV.successBlock = ^(NSDictionary *backDic){
            [_cell dealComment:backDic];
        };
    }else{
        [_cell.vc showHudInView:_cell.vc.view showHint:@"您没有权限评论TA的分享"];
    }
}

//更多按钮,所有的数据处理和逻辑全在moreView里面
-(void)moreClick
{
    SWWeibo *weibo = _swlayout.weibo;
    _moreView = [[SWMoreView alloc ]initShowMoreView:weibo];
    __weak typeof(_cell) tCell = _cell;
    __weak typeof(_swlayout) tswLayout = _swlayout;
    @weakify(self);
    _moreView.moreViewBlock = ^(MoreBtnType type){
        switch (type) {
            case MoreZhuanfa:
                //转发
            {
                PostViewController *postVC = [[PostViewController alloc]initWithOperationType:ForwardWeiboOperation];
                postVC.weiboDic = [weibo mj_keyValues];
                [tCell.vc presentViewController:postVC animated:YES completion:NULL];
            }
                break;
            case MoreColleted:
            {
                [weak_self updateCollectionToState:YES];
            }
                break;
            case MoreUnColleted:
            {
                [weak_self updateCollectionToState:NO];
            }
                break;
            case MoreDelete:
            {
                tswLayout.weibo.isDeleted = YES;
                [tCell touchAttribute:DeleteTouch data:nil];
            }
                break;
            case MoreJuBao:
            {
                tswLayout.weibo.isJubao = YES;
                [tCell touchAttribute:UpdateTouch data:tswLayout.weibo];
                //举报，暂时没啥子处理~
            }
                break;
            default:
                break;
        }
    };
}

-(void)updateCollectionToState:(BOOL)collected
{
    //收藏
    collected = !collected;
    NSString *zanUrl = collected?API_URL_UNFAVORITE_weibo:API_URL_FAVORITE_weibo;
    [Api requestWithMethod:@"get" withPath:zanUrl withParams:@{@"feed_id":_swlayout.weibo.feed_id} withSuccess:^(id responseObject) {
        if ([[responseObject objectForKey:@"status"] intValue]) {
            //修改
            _swlayout.weibo.is_favorite = !_swlayout.weibo.is_favorite;
            //刷新moreview
            [_moreView updateData:_swlayout.weibo];
            //本地更新
            [_cell touchAttribute:UpdateTouch data:_swlayout.weibo];
        }else{
            [_cell.vc showHudInView:_cell.vc.view showHint:[responseObject objectForKey:@"msg"]];
        }
    } withError:^(NSError *error) {
        [_cell.vc showHudInView:_cell.vc.view showHint:@"连接超时，请稍后重试"];
    }];
}

-(void)setSwlayout:(SWCellLayout *)swlayout
{
    _swlayout = swlayout;
    _likeLabel.text = @"0";
    _commentLabel.text = @"0";
    if (swlayout.weibo.is_digg ) {
        _likeImageView.image = ImageNamed(@"icon_like_blue");
    }else{
        _likeImageView.image = ImageNamed(@"icon_like_grey");
    }
    if ([swlayout.weibo.comment_info count]>0) {
        _commentLabel.text = [NSString stringWithFormat:@"%@",@(swlayout.weibo.comment_count)];
    }
    
    if ([swlayout.weibo.digg_users count]) {
        _likeLabel.text = [NSString stringWithFormat:@"%@",@(swlayout.weibo.digg_count)];
    }
    
    _addressView.hidden = YES;
    //地址
    if (SWNOTEmptyStr(swlayout.weibo.address)) {
        if (_cell.dtType == SWWeiboListType) {
            _addressView.hidden = NO;
            CGSize addressSize = [swlayout.weibo.address boundingRectWithSize:CGSizeMake(AddressLabelWidth,AddressHeight-1) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:AddressHeight-1]} context:nil].size;
            if (addressSize.width>AddressLabelWidth) {
                _addressBtn.width = AddressLabelWidth;
            }
            [_addressBtn setTitle:swlayout.weibo.address forState:UIControlStateNormal];
        }else{
            _addressView.hidden = NO;
            CGSize addressSize = [swlayout.weibo.address boundingRectWithSize:CGSizeMake(MainScreenWidth - FACEULeft*2-18,AddressHeight-1) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:AddressHeight-1]} context:nil].size;
            _addressView.frame = CGRectMake(FACEULeft,0,MainScreenWidth - 2*FACEULeft,AddressHeight+4);
            _addressBtn.width = addressSize.width;
            [_addressBtn setTitle:swlayout.weibo.address forState:UIControlStateNormal];
        }
    }
    
}

@end

#pragma mark<转发>
@implementation SWStatusCardView

- (instancetype)initWithFrame:(CGRect)frame superCell:(DtListCell *)cell {
    self = [super initWithFrame:frame];
    if (self) {
        self.exclusiveTouch = YES;
        _cell = cell;
        _placeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0,cell.contentWidth, 0)];
        [self addSubview:_placeBtn];
        [_placeBtn setImage:ImageNamed(@"dt_touch_hightLight") forState:UIControlStateHighlighted];
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(ZhuanfaContentDistance, ZhuanfaContentDistance, ZhuanfaViewHeight-2*ZhuanfaContentDistance, ZhuanfaViewHeight-2*ZhuanfaContentDistance)];
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = LINERGBA;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        _contentLabel = [TYAttributedLabel new];
        _contentLabel.delegate = self;
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textAlignment = NSTextAlignmentLeft;

        _titleLabel = [UILabel new];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        
        _resourceLabel = [UILabel new];
        _resourceLabel.backgroundColor = [UIColor clearColor];
        _resourceLabel.textAlignment = NSTextAlignmentLeft;
        
        [_placeBtn addSubview:_resourceLabel];
        [_placeBtn addSubview:_titleLabel];
        [_placeBtn addSubview:_contentLabel];
        [_placeBtn addSubview:_imageView];
        _placeBtn.clipsToBounds  = YES;
        _placeBtn.layer.borderWidth = CGFloatFromPixel(1);
        _placeBtn.layer.borderColor = [UIColor colorWithWhite:0.000 alpha:0.070].CGColor;
        _placeBtn.backgroundColor = RGBA(243, 243, 243);
        [_placeBtn addTarget:self action:@selector(tapPlaceBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)tapPlaceBtn
{
    SWWeibo *status = _swlayout.weibo;
    if (status.source_info.is_del == 1) {
        [_cell touchAttribute:DeletedContentTouch data:nil];
    }else{
        if ([status.type isEqualToString:@"repost"]) {
            [_cell touchAttribute:FenxianTouch data:status.source_info.feed_id];
        }else{
            [_cell touchAttribute:TieziTouch data:status.sid];
        }
    }
}


-(void)setSwlayout:(SWCellLayout *)swlayout
{
    _swlayout = swlayout;
    SWWeibo *status = swlayout.weibo;
    _placeBtn.height = swlayout.retweetContentHeight;
    _resourceLabel.font = SYSTEMFONT(ZhuanfaFONT-2);
    _titleLabel.font = SYSTEMFONT(ZhuanfaFONT);
    _contentLabel.font = SYSTEMFONT(ZhuanfaFONT-1);
    _resourceLabel.hidden = YES;
    _titleLabel.hidden = YES;
    _contentLabel.hidden = YES;
    _imageView.hidden = YES;
    _titleLabel.userInteractionEnabled = NO;//点击标题不会有响应
    _resourceLabel.textColor = [UIColor lightGrayColor];
    _titleLabel.textColor = [UIColor darkGrayColor];
    _contentLabel.textColor = [UIColor grayColor];
    _contentLabel.numberOfLines = 0;
    for (UIView *view in _imageView.subviews) {
        [view removeFromSuperview];
    }
    //转发
    if (status.source_info.is_del == 1) {
        //被删除
        _titleLabel.hidden = NO;
        _titleLabel.frame = CGRectMake(ZhuanfaContentDistance,(ReportDeleteHeight-ZhuanfaFONT)/2.0-2,_cell.contentWidth-30, ZhuanfaFONT);
        _titleLabel.textColor = [UIColor grayColor];
        _titleLabel.text = @"内容已经被删除";
        _titleLabel.font = SYSTEMFONT(ZhuanfaFONT);
        [_titleLabel sizeToFit];
        _imageView.hidden = YES;
    }
    else
    {//未删除
        _resourceLabel.hidden = NO;
        _titleLabel.hidden = NO;
        _contentLabel.hidden = NO;
        if ([status.type isEqualToString:@"repost"]){
            //转发图片或视屏
            CGFloat titleX = ZhuanfaContentDistance;
            if ([status.source_info.type isEqualToString:@"postimage"]) {
                if (SWNOTEmptyArr(status.source_info.attach_info)) {
                    _imageView.hidden = NO;
                    DtPhonto *photo = status.source_info.attach_info[0];
                    [_imageView sd_setImageWithURL:[NSURL URLWithString:photo.attach_small] placeholderImage:Prestrain_SmallFangXingImage];
                    titleX = ZhuanfaViewHeight+ZhuanfaContentDistance;
                }
            }else if ([status.source_info.type isEqualToString:@"postvideo"]){
                if (SWNOTEmptyArr(status.source_info.attach_info)) {
                    _imageView.hidden = NO;
                    DtPhonto *photo = status.source_info.attach_info[0];
                    [_imageView sd_setImageWithURL:[NSURL URLWithString:photo.flashimg] placeholderImage:Prestrain_WeiBoCellImage];
                    titleX = ZhuanfaViewHeight+ZhuanfaContentDistance;
                }
                UIImageView *bofangImg =[[UIImageView alloc]initWithFrame:CGRectMake((WIDTH(_imageView)-30)/2.0,(HEIGHT(_imageView)-30)/2.0,30,30)];
                bofangImg.image =[UIImage imageNamed:@"xiaobofang"];
                bofangImg.userInteractionEnabled =YES;
                UIView*placeV = [[UIView alloc]initWithFrame:_imageView.bounds];
                placeV.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.4];
                [_imageView addSubview:placeV];
                [_imageView addSubview:bofangImg];
            }
            CGSize sizeT =[status.source_info.user_info.uname sizeWithAttributes:@{NSFontAttributeName:SYSTEMFONT(ZhuanfaFONT)}];
            _titleLabel.frame = CGRectMake(titleX, ZhuanfaContentDistance,sizeT.width+10, ZhuanfaFONT);
            _titleLabel.text = status.source_info.user_info.uname;
            
            //点咯名字
            UITapGestureRecognizer *tapName = [UITapGestureRecognizer new];
            [tapName addActionBlock:^(id sender) {
                if (_swlayout.weibo.user_info.space_privacy == YES) {
                    // 不可以进入
                    ShowInViewMiss(SpacePrivacy_TXT);
                    return;
                }
                [_cell touchAttribute:NAMETOUCH data:status.source_info.user_info.uname];
            }];
            [_titleLabel addGestureRecognizer:tapName];
            
            
            _resourceLabel.frame = CGRectMake(MaxX(_titleLabel), Y(_titleLabel),200,ZhuanfaFONT);
            _resourceLabel.text = [DtCaculateTool formateTime:status.source_info.publish_time];
            _resourceLabel.backgroundColor = [UIColor clearColor];
            
            if (titleX == ZhuanfaContentDistance) {
                //纯文字，自适应
                _contentLabel.frame = CGRectMake(X(_titleLabel), MaxY(_titleLabel)+ZhuanfaShangxiaJianju, _cell.contentWidth -2*ZhuanfaContentDistance, swlayout.retweetContentHeight-(ZhuanfaFONT+2*ZhuanfaContentDistance));
                _contentLabel = [DtCaculateTool getAllTextAttributeLabel:status.source_info.content :_contentLabel :ZhuanfaFONT-1];
                [_contentLabel sizeToFit];
            }else{
                //有图片
                _contentLabel.frame = CGRectMake(X(_titleLabel), MaxY(_titleLabel)+ZhuanfaShangxiaJianju-3, _cell.contentWidth -ZhuanfaContentDistance-titleX, swlayout.retweetContentHeight-(ZhuanfaFONT+2*ZhuanfaContentDistance)-5);
                _contentLabel = [DtCaculateTool getAllTextAttributeLabel:status.source_info.content :_contentLabel :ZhuanfaFONT-1];
                [_contentLabel sizeToFit];
                _contentLabel.numberOfLines = 2;
            }
        }
        else
        {
            NSString *fromStr = @"";
            //转发帖子
            if ([status.type isEqualToString:@"weiba_repost"]) {
                //转发到动态再转
                _titleLabel.frame = CGRectMake(ZhuanfaContentDistance, ZhuanfaContentDistance, _cell.contentWidth-2*ZhuanfaContentDistance, ZhuanfaFONT);
                _titleLabel.text = status.source_info.title;
                
                _contentLabel.frame = CGRectMake(X(_titleLabel), MaxY(_titleLabel)+ZhuanfaShangxiaJianju, _cell.contentWidth -2*ZhuanfaContentDistance,ZhuanfaFONT+5);
                if (SWNOTEmptyStr(status.source_info.content)) {
                    _contentLabel.text = status.source_info.content;
                }else{
                    _contentLabel.text = @"图片帖子";
                }
                _contentLabel.frame = CGRectMake(X(_titleLabel), MaxY(_titleLabel)+ZhuanfaShangxiaJianju, _cell.contentWidth -2*ZhuanfaContentDistance,ZhuanfaFONT+5);
                _contentLabel = [DtCaculateTool getAllTextAttributeLabel:_contentLabel.text :_contentLabel :ZhuanfaFONT-1];
                [_contentLabel sizeToFit];
                _contentLabel.numberOfLines = 1;
                _resourceLabel.frame = CGRectMake(X(_titleLabel), MaxY(_titleLabel)+ZhuanfaShangxiaJianju+ZhuanfaShangxiaJianju+ZhuanfaFONT+5,WIDTH(_titleLabel),ZhuanfaFONT-2);
                fromStr = status.source_info.source_name;
                _resourceLabel.text = [NSString stringWithFormat:@"来自%@",fromStr];
            }else{
                //直接由帖子转发出
                _titleLabel.frame = CGRectMake(ZhuanfaContentDistance, ZhuanfaContentDistance, _cell.contentWidth-2*ZhuanfaContentDistance, ZhuanfaFONT);
                _titleLabel.text = status.title;
                _contentLabel.frame = CGRectMake(X(_titleLabel), MaxY(_titleLabel)+ZhuanfaShangxiaJianju, _cell.contentWidth -2*ZhuanfaContentDistance,ZhuanfaFONT+5);
                if (SWNOTEmptyStr(status.content)) {
                    _contentLabel.text = status.content;
                }else{
                    _contentLabel.text = @"图片帖子";
                }
                _contentLabel.frame = CGRectMake(X(_titleLabel), MaxY(_titleLabel)+ZhuanfaShangxiaJianju, _cell.contentWidth -2*ZhuanfaContentDistance,ZhuanfaFONT+5);
                _contentLabel = [DtCaculateTool getAllTextAttributeLabel:_contentLabel.text :_contentLabel :ZhuanfaFONT-1];
                [_contentLabel sizeToFit];
                _contentLabel.numberOfLines = 1;
                _resourceLabel.frame = CGRectMake(X(_titleLabel), MaxY(_titleLabel)+ZhuanfaShangxiaJianju+ZhuanfaShangxiaJianju+ZhuanfaFONT+5,WIDTH(_titleLabel),ZhuanfaFONT-2);
                fromStr = status.source_name;
                _resourceLabel.text = [NSString stringWithFormat:@"来自%@",fromStr];
            }
        }

    }
}

-(void)attributedLabel:(TYAttributedLabel *)attributedLabel textStorageClicked:(id<TYTextStorageProtocol>)textStorage atPoint:(CGPoint)point
{
    //非文本/比如表情什么的
    if (![textStorage isKindOfClass:[TYLinkTextStorage class]]) {
        return;
    }
    TouchType type = ((TYLinkTextStorage *)textStorage).type;
    id linkContain = ((TYLinkTextStorage *)textStorage).linkData;
    [_cell touchAttribute:type data:linkContain];
}



@end

#pragma mark<评论、点赞内容区域>
@implementation SWCommentsView

- (instancetype)initWithFrame:(CGRect)frame superCell:(DtListCell *)cell
{
    self = [super initWithFrame:frame];
    if (self) {
        _cell = cell;
        _backView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, cell.contentWidth, 0)];
        _backView.backgroundColor = [UIColor clearColor];
        _backView.userInteractionEnabled = YES;
        _backView.clipsToBounds = YES;
        _backView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
        [self addSubview:_backView];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(cell.contentWidth-63,-6.5, 13, 7.5)];
        imageView.image = ImageNamed(@"jiaobiaori");
        [self addSubview:imageView];
        
        _zanList = [TYAttributedLabel new];
        [self addSubview:_zanList];
        _comView = [UIView new];
        [self addSubview:_comView];
        
    }
    return self;
}

-(void)setSwlayout:(SWCellLayout *)swlayout
{
    _swlayout = swlayout;
    _backView.frame = CGRectMake(X(_backView), Y(_backView),_cell.contentWidth,swlayout.commentViewHeight);
    if (_comView.superview) {
        for (UIView *view in _comView.subviews) {
            [view removeFromSuperview];
        }
        [_comView removeFromSuperview];
    }
    if (_zanList.superview) {
        [_zanList removeFromSuperview];
    }
    
    if ([swlayout.weibo.digg_users count]) {
        [self configDigView:swlayout];
        [self addSubview:_zanList];
    }
    if ([swlayout.weibo.comment_info count]) {
        [self configCommentView:swlayout];
        [self addSubview:_comView];
    }
}


/**
 *  @author SamWu
 *
 *  @brief  配置点赞的富文本
 *
 *  @param entity entity
 */
-(void)configDigView:(SWCellLayout *)lay
{
    SWWeibo *entity = lay.weibo;
    NSArray *dataArray = entity.digg_users;
    NSMutableArray *zanNameArr = [NSMutableArray new];//存生成的对象
    NSMutableArray *zanNameArr2 = [NSMutableArray new];//纯名字
    
    NSString *allNameStr;//拼接文字
    int countZan = 0;
    for (DtUser *nDic in dataArray) {
        if (countZan == 0) {
            //第一个不加逗号,空格多少可以设置和赞图标的距离
            if (nDic.remark.length) {
                allNameStr = [NSString stringWithFormat:@"  %@",nDic.remark];
            }
            else{
                allNameStr = [NSString stringWithFormat:@"  %@",nDic.uname];
            }
            
        }else{
            
            if (nDic.remark.length) {
                
                allNameStr = [NSString stringWithFormat:@"%@, %@",allNameStr,nDic.remark];
            }
            else{
                allNameStr = [NSString stringWithFormat:@"%@, %@",allNameStr,nDic.uname];
            }
        }
        
        if (nDic.remark.length) {
            
            [zanNameArr2 addObject:nDic.remark];
        }
        else{
            [zanNameArr2 addObject:nDic.uname];

        }
        
        countZan++;
    }
    //点赞最多返回5个，但是个数不一定是5
    if (entity.digg_count>ZansMaxNum) {
        allNameStr = [NSString stringWithFormat:@"%@ 等%@人觉得很赞",allNameStr,@(entity.digg_count)];
    }
    
    int tempInde = 0;
    
    
    NSString *replaceStr = allNameStr;
    for (NSString *subText in zanNameArr2) {
        TYLinkTextStorage *linkTextStorage = [[TYLinkTextStorage alloc]init];
        linkTextStorage.underLineStyle = kCTUnderlineStyleNone;
        linkTextStorage.type = NAMETOUCH;
        linkTextStorage.range = [replaceStr rangeOfString:subText];
        replaceStr = [replaceStr stringByReplacingCharactersInRange:linkTextStorage.range withString:[self makeArmStr:linkTextStorage.range.length]];
        linkTextStorage.font = SYSTEMFONT(ZanAndComentFont);
        linkTextStorage.textColor = [UIColor blackColor];
        linkTextStorage.linkData = ((DtUser *)dataArray[tempInde]).uname;
        [zanNameArr addObject:linkTextStorage];
        tempInde++;
    }
    _zanList.delegate = self;
    _zanList.font = SYSTEMFONT(ZanAndComentFont);
    _zanList.highlightedLinkColor = [UIColor grayColor];
    _zanList.backgroundColor = [UIColor clearColor];
    _zanList.text = allNameStr;
    _zanList.textColor = [UIColor lightGrayColor];
    [_zanList addTextStorageArray:zanNameArr];
    _zanList.linesSpacing = LINESPACE;
    _zanList.characterSpacing = PERSPACE;
    [_zanList addImageWithName:@"icon_like_blue" range:NSMakeRange(0,0) size:CGSizeMake(ZanAndComentFont+2, ZanAndComentFont+2) alignment:TYDrawAlignmentTop];
    [_zanList setFrameWithOrign:CGPointMake(ComentDistance,CommentTopDistance+3) Width:(_cell.contentWidth-ComentDistance*2)];
}

//替换已经识别的，防止名字包含的关系
-(NSString *)makeArmStr:(NSInteger)len
{
    NSString *plarceStr = @"";
    for (int i = 0; i<len; i++) {
        plarceStr = [NSString stringWithFormat:@"%@%@",plarceStr,@(arc4random()%9)];
    }
    return plarceStr;
}

/**
 *  @author SamWu
 *
 *  @brief  配置动态的评论富文本
 *
 *  @param entity entity
 */
-(void)configCommentView:(SWCellLayout *)lay
{
    SWWeibo *entity = lay.weibo;
    NSArray *dataArray = entity.comment_info;
    _comView.frame = CGRectMake(0,CommentTopDistance, _cell.contentWidth, lay.commentHeight);
    CGFloat comTotalHight = CommentTopDistance+1;//加上分割线和稍微向下的偏移
    if (entity.digg_count) {
        _comView.frame = CGRectMake(0,CommentTopDistance*2+lay.zanHeight, _cell.contentWidth, lay.commentHeight);
        //分割线
        UILabel *lineL = [[UILabel alloc]initWithFrame:CGRectMake(0, 0,_cell.contentWidth, SINGLE_LINE_ADJUST_OFFSET)];
        lineL.backgroundColor = RGBA(205, 205,205);
        [_comView addSubview:lineL];
    }
    for (int i = 0 ; i < dataArray.count; i++) {
        if (i == CommentMaxNum) {
            //最多三条评论
            UILabel *moreCommentL = [[UILabel alloc]initWithFrame:CGRectMake(0, comTotalHight,_cell.contentWidth-ComentDistance-5, ComentsMoreHeight)];
            moreCommentL.font = SYSTEMFONT(12);
            moreCommentL.textAlignment = NSTextAlignmentRight;
            moreCommentL.textColor = [UIColor lightGrayColor];
            moreCommentL.text = [NSString stringWithFormat:@"全部%@条评论",@(entity.comment_count)];
            [_comView addSubview:moreCommentL];
            break;
        }
        DtComment *dtComment = dataArray[i];
        //我是临时工，表打我😄
        //DtUser *toComUser = dtComment.to_uid_info;//这东西肯定是没有的，伪造一个,如果伪造成功了就不再伪造，因为TS数据库没设计😄,具体伪造过程请看layout
        //这里的设计是为了后面开发可能需要把用户名对应的传递数据变为uid而不是这个文字本身而留下的一个后手
        DtUser *toComUser = dtComment.to_uid_info;;
        DtUser *commentUser = dtComment.user_info;
        NSString *allStr = dtComment.content;
        if (dtComment.to_uid_info.uid) {
            allStr = [NSString stringWithFormat:@"<a myRegularId=%@>%@%@</a>回复<a myRegularId=%@>%@%@</a>：%@",commentUser.uname,ReplaceH5String,commentUser.uname,toComUser.uname,ReplaceH5String,toComUser.uname,dtComment.content];
        }else{
            allStr = [NSString stringWithFormat:@"<a myRegularId=%@>%@%@</a>：%@",commentUser.uname,ReplaceH5String,commentUser.uname,dtComment.content];
        }
        
        
        if (dtComment.to_uid_info.uid) {
            
            NSString* commenName;
            NSString* toName;
            
            if (commentUser.remark.length) {
                commenName = commentUser.remark;
            }
            else{
                commenName = commentUser.uname;
            }
            
            if (toComUser.remark.length) {
                toName = toComUser.remark;
            }
            else{
                toName = toComUser.uname;
            }
            
            allStr = [NSString stringWithFormat:@"<a myRegularId=%@>%@%@</a>回复<a myRegularId=%@>%@%@</a>：%@",commenName,ReplaceH5String,commenName,toName,ReplaceH5String,toName,dtComment.content];
            
        }else{
            
            
            NSString* commenName;

            if (commentUser.remark.length) {
            
                commenName = commentUser.remark;
           
            }
            else{
            
                commenName = commentUser.uname;
            }
            
            allStr = [NSString stringWithFormat:@"<a myRegularId=%@>%@%@</a>：%@",commenName,ReplaceH5String,commenName,dtComment.content];
        }
        
        
        TYAttributedLabel *tyNameLabel = [TYAttributedLabel new];
        tyNameLabel.textColor = CommentsColor;
        tyNameLabel = [DtCaculateTool getAllTextAttributeLabel:allStr :tyNameLabel :ZanAndComentFont nameColor:ComentsUserNameColor];
        tyNameLabel.font  = SYSTEMFONT(ZanAndComentFont);
        tyNameLabel.delegate = self;
        tyNameLabel.backgroundColor = [UIColor clearColor];
        //回复按钮，点击非名字，交给按钮响应
        UIButton *replyComentBtn = [UIButton new];
        [_comView addSubview:replyComentBtn];
        [replyComentBtn addTarget:self action:@selector(touchComment:) forControlEvents:UIControlEventTouchUpInside];
        [replyComentBtn setImage:ImageNamed(@"dt_touch_hightLight") forState:UIControlStateHighlighted];
        replyComentBtn.contentMode = UIViewContentModeScaleToFill;
        //用按钮来传递信息
        replyComentBtn.tag = i+7000;
        //只减了单倍行距是因为，字体的宽度可能容不下，导致提前换行，后没比较空
        [tyNameLabel setFrameWithOrign:CGPointMake(ComentDistance,CommentDistanceBtn) Width:(_cell.contentWidth-ComentDistance*2+2)];
        replyComentBtn.frame = CGRectMake(0, comTotalHight, _cell.contentWidth, HEIGHT(tyNameLabel)+CommentDistanceBtn);
        comTotalHight += HEIGHT(replyComentBtn)+ComentAndComentDistance;
        [replyComentBtn addSubview:tyNameLabel];
    }
}



-(void)attributedLabel:(TYAttributedLabel *)attributedLabel textStorageClicked:(id<TYTextStorageProtocol>)textStorage atPoint:(CGPoint)point
{
    //非文本/比如表情什么的
    if (![textStorage isKindOfClass:[TYLinkTextStorage class]]) {
        return;
    }
    TouchType type = ((TYLinkTextStorage *)textStorage).type;
    id linkContain = ((TYLinkTextStorage *)textStorage).linkData;
    [_cell touchAttribute:type data:linkContain];
}



//点击了某条评论
-(void)touchComment:(UIButton *)sender
{
    [_cell touchComentIndex:sender.tag-7000];
}




@end



#pragma mark<主要cell>


@implementation DtListCell
//👌
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier weiboType:(WeiboType)type {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _dtType = type;
        if (_dtType == SWWeiboListType) {
            //列表
            self.contentWidth = WIDCONTENT;
        }else{
            self.contentWidth = WIDDetailCONTENT;
        }
        [self configCell];
    }
    return self;
}

-(instancetype)initWithWeiboType:(WeiboType)type
{
    self = [super init];
    if (self) {
        _dtType = type;
        if (_dtType == SWWeiboListType) {
            //列表
            self.contentWidth = WIDCONTENT;
        }else{
            self.contentWidth = WIDDetailCONTENT;
        }
        [self configCell];
    }
    return self;
}



-(void)configCell
{
    _contentV = [UIView new];
    _contentV.width = kScreenWidth;
    _contentV.height = 1;
    _contentV.backgroundColor = [UIColor whiteColor];
    _contentV.userInteractionEnabled = YES;
    
    _bottomLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, MainScreenWidth,0.5)];;
    _bottomLine.backgroundColor = LINERGBA;
    [_contentV addSubview:_bottomLine];
    [self addSubview:_contentV];
    
    //头像
    _profileView = [[SWStatusProfileView alloc]initWithFrame:CGRectMake(0, 0, MainScreenWidth, FACEHEIGHT+FACEULeft+3) superCell:self];
    [_contentV addSubview:_profileView];
    
    _txtView = [UIView new];
    _txtView.userInteractionEnabled = YES;
    [_contentV addSubview:_txtView];
    
    //内容
    if (_dtType == SWWeiboDetailType) {
        _contentLabel = [[TYAttributedLabel alloc]initWithFrame:CGRectMake(FACEULeft, MaxY(_profileView)+FaceDown, self.contentWidth, 0)];
    }else
        _contentLabel = [[TYAttributedLabel alloc]initWithFrame:CGRectMake(DistanceFaceRight+FACEHEIGHT+FACEULeft, MaxY(_profileView)+FaceDown, self.contentWidth, 0)];
    _contentLabel.delegate = self;
    [_contentV addSubview:_contentLabel];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(pressCell:)];
    [_txtView addGestureRecognizer:longPress];
    
    _photosView = [[UIView alloc]initWithFrame:CGRectMake(X(_contentLabel), MaxY(_contentLabel)+DownDistance, self.contentWidth, 0)];
    _photosView.hidden = YES;
    [_contentV addSubview:_photosView];
    
    //转发
    _cardView = [[SWStatusCardView alloc]initWithFrame:CGRectMake(X(_contentLabel), MaxY(_contentLabel), self.contentWidth, 0) superCell:self];
    _cardView.hidden = YES;
    [_contentV addSubview:_cardView];
    
    //赞、评论按钮
    _toolbarView = [[SWStatusToolbarView alloc]initWithFrame:CGRectMake(0, 0, MainScreenWidth, ToolBarHeight) superCell:self];
    _toolbarView.cell = self;
    [_contentV addSubview:_toolbarView];
    
    if (_dtType == SWWeiboListType) {
        //赞、评论列表
        _commentsView = [[SWCommentsView alloc]initWithFrame:CGRectMake(X(_contentLabel), MaxY(_toolbarView)+DownDistance, self.contentWidth, 0) superCell:self];
        _commentsView.hidden = YES;
        _commentsView.cell = self;
        _commentsView.userInteractionEnabled = YES;
        [_contentV addSubview:_commentsView];
    }else{
        _contentLabel.textColor = [UIColor darkGrayColor];
    }
}

-(void)setSwlayout:(SWCellLayout *)swlayout
{
    _swlayout = swlayout;
    self.height = swlayout.height;
    _contentV.height = swlayout.height;//找你吗B一下午，为什么整个cell点不动，艹艹艹
    self.contentView.height = swlayout.height;
    _profileView.height = swlayout.txHeight;
    _profileView.swlayout = _swlayout;
    _contentLabel.top = MaxY(_profileView)+FaceDown;    
    _bottomLine.frame = CGRectMake(0, swlayout.height-0.5-SINGLE_LINE_ADJUST_OFFSET, MainScreenWidth,0.5);
    
    //内容布局
    _contentLabel.size = CGSizeMake(WIDTH(_contentLabel), 0);
    if (NOTNULL(_swlayout.weibo.content)) {
        _contentLabel = [DtCaculateTool getAllTextAttributeLabel:_swlayout.weibo.content:_contentLabel :CONTENTFONT];
        _contentLabel.size = CGSizeMake(WIDTH(_contentLabel),_swlayout.textHeight);
    }
    _photosView.frame = CGRectMake(X(_photosView), MaxY(_contentLabel)+DownDistance, WIDTH(_photosView), HEIGHT(_photosView));
    _photosView.hidden = YES;
    _cardView.hidden = YES;
    //转发布局
    if ([_swlayout.weibo.type isEqualToString:@"repost"]||[_swlayout.weibo.type isEqualToString:@"weiba_repost"]||[_swlayout.weibo.type isEqualToString:@"weiba_post"]) {
        _cardView.hidden = NO;
        if (![swlayout.weibo.type isEqualToString:@"weiba_post"]) {
            _cardView.top = MaxY(_contentLabel)+DownDistance;
        }else{
            _cardView.top = MaxY(_contentLabel);
        }
        _cardView.height = swlayout.retweetContentHeight;
        _cardView.swlayout = swlayout;
    }else if ([_swlayout.weibo.type isEqualToString:@"postimage"]){
        //照片
        _photosView.hidden = NO;
        _photosView.height = swlayout.photoHeight;
        for (UIView *view in _photosView.subviews) {
            [view removeFromSuperview];
        }
        [self configImages:swlayout.weibo];
    }else if ([_swlayout.weibo.type isEqualToString:@"postvideo"]){
        //视频
        _photosView.hidden = NO;
        _photosView.height = swlayout.vedioHeight;
        for (UIView *view in _photosView.subviews) {
            [view removeFromSuperview];
        }
        UIImageView *imageV = [[UIImageView alloc]initWithFrame:_photosView.bounds];
        imageV.backgroundColor = LINERGBA;
        imageV.height = swlayout.vedioHeight;
        DtPhonto *photo = swlayout.weibo.attach_info[0];
        [self makeTapGestuerImage:100 :imageV];
        [imageV sd_setImageWithURL:[NSURL URLWithString:photo.flashimg] placeholderImage:Prestrain_WeiBoCellImage];
        [_photosView addSubview:imageV];
        
        //播放按钮
        UIView *placeView = [[UIView alloc]initWithFrame:imageV.bounds];
        placeView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.6];
        [imageV addSubview:placeView];
        UIImageView *bofangImg =[[UIImageView alloc]initWithFrame:CGRectMake(MidX(imageV)-20,MidY(imageV)-20,40,40)];
        bofangImg.image =[UIImage imageNamed:@"xiaobofang"];
        bofangImg.userInteractionEnabled =YES;
        [imageV addSubview:bofangImg];
    }
    
    //工具栏
    _toolbarView.top = _swlayout.toolBarTop;
    _toolbarView.swlayout = swlayout;
    
    if (_dtType==SWWeiboListType) {
        _commentsView.hidden = YES;
        if (_swlayout.weibo.digg_users.count||_swlayout.weibo.comment_info.count) {
            _commentsView.hidden = NO;
            _commentsView.top = MaxY(_toolbarView);
            _commentsView.height = _swlayout.commentViewHeight;
            _commentsView.swlayout = swlayout;
        }
    }
    _txtView.frame = _contentLabel.frame;
}

-(void)configImages:(SWWeibo *)weibo
{
    NSInteger photoNum = ((NSArray *)weibo.attach_info).count;
    if (photoNum ==1)
    {
        DtPhonto *photo = [DtPhonto mj_objectWithKeyValues:weibo.attach_info[0]];
        UIImageView *imageV = [[UIImageView alloc]initWithFrame:_photosView.bounds];
        imageV.backgroundColor = LINERGBA;
        [imageV sd_setImageWithURL:[NSURL URLWithString:photo.attach_middle] placeholderImage:Prestrain_WeiBoCellImage];
        [self makeTapGestuerImage:photoNum-1 :imageV];
        [_photosView addSubview:imageV];
        
    }
    else if (photoNum ==2)
    {
        for (int i = 0 ; i<2; i++) {
            DtPhonto *photo = [DtPhonto mj_objectWithKeyValues:weibo.attach_info[i]];
            UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake((self.contentWidth-5)/2*i+i*5, 0, (self.contentWidth-5)/2, (self.contentWidth-5)/2)];
            [imageV sd_setImageWithURL:[NSURL URLWithString:photo.attach_small] placeholderImage:Prestrain_FangXingImage];
            imageV.backgroundColor = LINERGBA;
            [self makeTapGestuerImage:i :imageV];
            [_photosView addSubview:imageV];
        }
    }else if (photoNum ==4) {
        for (int i = 0 ; i<4; i++) {
            DtPhonto *photo = [DtPhonto mj_objectWithKeyValues:weibo.attach_info[i]];
            UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake((self.contentWidth-5)/2*(i%2)+5*(i%2),(self.contentWidth-5)/2*(i/2)+5*(i/2), (self.contentWidth-5)/2, (self.contentWidth-5)/2)];
            [imageV sd_setImageWithURL:[NSURL URLWithString:photo.attach_small] placeholderImage:Prestrain_FangXingImage];
            imageV.backgroundColor = LINERGBA;
            [self makeTapGestuerImage:i :imageV];
            [_photosView addSubview:imageV];
        }
    }
    else
    {
        for (int i = 0 ; i<photoNum; i++) {
            DtPhonto *photo = [DtPhonto mj_objectWithKeyValues:weibo.attach_info[i]];
            UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake((self.contentWidth-10)/3*(i%3)+5*(i%3),(self.contentWidth-10)/3*(i/3)+5*(i/3), (self.contentWidth-10)/3, (self.contentWidth-10)/3)];
            [imageV sd_setImageWithURL:[NSURL URLWithString:photo.attach_small] placeholderImage:Prestrain_FangXingImage];
            imageV.backgroundColor = LINERGBA;
            [self makeTapGestuerImage:i :imageV];
            [_photosView addSubview:imageV];
        }
    }
    
}

-(void)makeTapGestuerImage:(NSInteger)tags :(UIImageView *)imageV
{
    imageV.clipsToBounds = YES;
    imageV.contentMode = UIViewContentModeScaleAspectFill;
    imageV.tag = tags;
    imageV.userInteractionEnabled = YES;
    [imageV addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
        _chooseImagePage = tags;
        if (tags==100) {
            //视频
            DtPhonto *photo = _swlayout.weibo.attach_info[0];
            if ([photo.host integerValue]==1) {
                //app录制的
                [self touchAttribute:VedioTouch data:photo.flashvar];
            }else{
                [self touchAttribute:WebUrlTOUCH data:photo.source];
            }
        }else//图片
            [self touchAttribute:ImageTouch data:nil];
    }]];
}

#pragma mark<主要方法，所有的回调以及分支触发的方法都在这里>
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
            NSURL *url =[NSURL URLWithString:[data stringByReplacingOccurrencesOfString:@" " withString:@""]];
            NSString *urlStr =[[NSString stringWithFormat:@"%@",url]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            BrowserViewController *browserVC = [[BrowserViewController alloc]initWithUrl:[NSURL URLWithString:urlStr]];
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
        case DeletedContentTouch:
        {
            [_vc showHudInView:_vc.view showHint:@"内容不存在，或已被删除"];
        }
            break;
        case DeleteTouch:
        {
            //删除
            if ([self.delegate respondsToSelector:@selector(operationCell: weibo:)]) {
                [self.delegate operationCell:self.operationCellIndex weibo:_swlayout.weibo];
            }
        }
            break;
        case TieziTouch:
        {
            CircleDetailViewController *circleDetailVC = [[CircleDetailViewController alloc] initWithNibName:nil bundle:nil andID:data];
            [_vc.navigationController pushViewController:circleDetailVC animated:YES];
        }
            break;
        case FenxianTouch:
        {
            WeiboDetailVC *weiboVC = [[WeiboDetailVC alloc]init];
            weiboVC.feedId = data;
            [_vc.navigationController pushViewController:weiboVC animated:YES];
        }
            break;
        case ImageTouch:
        {
            ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
            pickerBrowser.delegate = self;
            pickerBrowser.dataSource = self;
            // 是否可以删除照片
            pickerBrowser.editing = NO;
            // 当前分页的值
            // pickerBrowser.currentPage = indexPath.row;
            // 传入组
            pickerBrowser.currentIndexPath = [NSIndexPath indexPathForRow:_chooseImagePage inSection:0];
            // 展示控制器
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            [pickerBrowser showPickerVc:window.rootViewController];

        }
            break;
        case VedioTouch:
        {
            if (_dtType == SWWeiboDetailType) {
                if ([self.delegate respondsToSelector:@selector(touchAvplayer:)]) {
                    [self.delegate touchAvplayer:data];
                }
                return;
            }
            NSURL *url =[NSURL URLWithString:[data stringByReplacingOccurrencesOfString:@" " withString:@""]];
            NSString *urlStr =[[NSString stringWithFormat:@"%@",url]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if (!self.videoController) {
                self.videoController = [[KRVideoPlayerController alloc] initWithFrame:[UIScreen mainScreen].bounds];
                __weak typeof(self)weakSelf = self;
                [self.videoController setDimissCompleteBlock:^{
                    weakSelf.videoController = nil;
                }];
                [self.videoController showInWindow];
            }
            self.videoController.contentURL = [NSURL URLWithString:urlStr];
        }
            break;
        case AddressTouch:
        {
            Map1ViewController *mapVC = [[Map1ViewController alloc]init];
            mapVC.lat = [NSString stringWithFormat:@"%f",_swlayout.weibo.latitude];
            mapVC.lon = [NSString stringWithFormat:@"%f",_swlayout.weibo.longitude];
            mapVC.locationAddress = _swlayout.weibo.address;
            mapVC.isChat = YES;
            [_vc.navigationController pushViewController:mapVC animated:YES];
        }
            break;
        case UpdateTouch:
        {
            if ([self.delegate respondsToSelector:@selector(operationCell: weibo:)]) {
                [self.delegate operationCell:self.operationCellIndex weibo:data];
            }
        }
            break;
        default:
            break;
    }
    
}

#pragma mark<touch 事件>
-(void)pressCell:(UIGestureRecognizer *)gesture
{
    [self becomeFirstResponder];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(menuCopyBtnPressed:)];
        menuController.menuItems = @[copyItem];
        [menuController setTargetRect:_contentV.frame inView:_contentLabel];
        [menuController setMenuVisible:YES animated:YES];
        [UIMenuController sharedMenuController].menuItems=nil;
    }
}

-(void)menuCopyBtnPressed:(UIMenuItem *)menuItem
{
    [UIPasteboard generalPasteboard].string = _contentLabel.text;
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(menuCopyBtnPressed:)) {
        return YES;
    }
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint p = [touch locationInView:_contentLabel];
    CGPoint pz = [touch locationInView:_commentsView];

    BOOL insideRetweet = CGRectContainsPoint(_contentLabel.bounds, p);
    BOOL inCommentsView = CGRectContainsPoint(_commentsView.bounds, pz);
    if (!insideRetweet&&!inCommentsView) {
        [(_contentV) performSelector:@selector(setBackgroundColor:) withObject:LINERGBA afterDelay:0.15];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesRestoreBackgroundColor];
    if ([self.delegate respondsToSelector:@selector(cellDidClick:index:)]) {
        [self.delegate cellDidClick:self index:_operationCellIndex];
    }
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesRestoreBackgroundColor];
}

- (void)touchesRestoreBackgroundColor {
    [NSObject cancelPreviousPerformRequestsWithTarget:_contentV selector:@selector(setBackgroundColor:) object:LINERGBA];
    _contentV.backgroundColor = [UIColor whiteColor];
}
#pragma mark<自己实现的方法>
//点击了某条评论,留给外部调用的接口方法
//  微博列表评论
-(void)touchComentIndex:(NSInteger)index
{
    DtComment *dtComent;
    if (index<[_swlayout.weibo.comment_info count]) {
        dtComent = _swlayout.weibo.comment_info[index];
        if ([dtComent.user_info.uid isEqualToString:SWUID]) {
            //自己的评论
            [UIActionSheet showInView:self.vc.view withTitle:@"提示" cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除评论" otherButtonTitles:@[@"复制"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    [self.vc showHudInView:self.vc.view hint:@"删除中..."];
                    if (_swlayout.weibo.comment_count == 0) {
                        _swlayout.weibo.comment_count = 0;
                    }else
                        _swlayout.weibo.comment_count-=1;
                    [self deleteComment:dtComent index:index];
                }else if (buttonIndex == 1){
                    [UIPasteboard generalPasteboard].string = dtComent.content;
                    [self.vc showHudInView:self.vc.view showHint:@"复制成功"];
                }
            }];
        }else{
            //别人的评论
            [UIActionSheet showInView:self.vc.view withTitle:@"提示" cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"评论",@"复制"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    //评论
                    //技术问题，actionsheet消失的时候回全屏结束编辑。所以延迟0.5秒
                    [self performSelector:@selector(showCommentView:) withObject:@(index) afterDelay:0.5];
                }else if (buttonIndex == 1){
                    [UIPasteboard generalPasteboard].string = dtComent.content;
                    [self.vc showHudInView:self.vc.view showHint:@"复制成功"];
                }
            }];
        }
    }else{
        [self.vc showHudInView:self.vc.view showHint:@"无法评论，请稍后重试"];
    }
}



//点击了某条评论 新方法
// herman 微博详情页评论
// 当微博详情页 有新的评论时，点击之前的评论会导致评论失败
-(void)touchComentIndex:(NSInteger)index commentInfo:(NSArray *)commentInfo{
    if (commentInfo) {
        _swlayout.weibo.comment_info = commentInfo;
    }
    DtComment *dtComent;
    if (index<[_swlayout.weibo.comment_info count]) {
        dtComent = _swlayout.weibo.comment_info[index];
        if ([dtComent.user_info.uid isEqualToString:SWUID]) {
            //自己的评论
            [UIActionSheet showInView:self.vc.view withTitle:@"提示" cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除评论" otherButtonTitles:@[@"复制"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    [self.vc showHudInView:self.vc.view hint:@"删除中..."];
                    if (_swlayout.weibo.comment_count == 0) {
                        _swlayout.weibo.comment_count = 0;
                    }else
                        _swlayout.weibo.comment_count-=1;
                    [self deleteComment:dtComent index:index];
                }else if (buttonIndex == 1){
                    [UIPasteboard generalPasteboard].string = dtComent.content;
                    [self.vc showHudInView:self.vc.view showHint:@"复制成功"];
                }
            }];
        }else{
            //别人的评论
            [UIActionSheet showInView:self.vc.view withTitle:@"提示" cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"评论",@"复制"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    //评论
                    //技术问题，actionsheet消失的时候回全屏结束编辑。所以延迟0.5秒
                    [self performSelector:@selector(showCommentView:) withObject:@(index) afterDelay:0.5];
                }else if (buttonIndex == 1){
                    [UIPasteboard generalPasteboard].string = dtComent.content;
                    [self.vc showHudInView:self.vc.view showHint:@"复制成功"];
                }
            }];
        }
    }else{
        [self.vc showHudInView:self.vc.view showHint:@"无法评论，请稍后重试"];
    }
}


-(void)showCommentView:(NSNumber *)indexNum
{
    NSInteger index = [indexNum integerValue];
    DtComment *dtComent = _swlayout.weibo.comment_info[index];
    NSMutableDictionary *passPar = [NSMutableDictionary dictionaryWithDictionary:self.comentParam];
    [passPar setObject:dtComent.comment_id forKey:@"to_comment_id"];
    SWCommentView *comV=[[SWCommentView alloc]initShowWithUrl:self.commentUrl passParam:passPar contentKey:self.comentKey showId:dtComent.comment_id placeHolder:[NSString stringWithFormat:@"回复%@:",dtComent.user_info.uname] replyName:dtComent.user_info.uname];
    //评论成功
    comV.successBlock = ^(NSDictionary *backDic){
        [self dealComment:backDic];
    };
}



-(void)deleteComment:(DtComment *)deletComment index:(NSInteger)deleteIndex
{
    NSDictionary *dic =[NSDictionary dictionaryWithObject:deletComment.comment_id forKey:@"commentid"];
    [Api requestWithMethod:@"get" withPath:API_URL_DELETECOMMENT withParams:dic withSuccess:^(id responseObject)
     {
         [self.vc hideHud];
         if ([[responseObject objectForKey:@"status"]integerValue]==1)
         {
             NSMutableArray *tempArr = [NSMutableArray arrayWithArray:_swlayout.weibo.comment_info];
             if (deleteIndex<[tempArr count]) {
                 [tempArr removeObjectAtIndex:deleteIndex];
             }
             _swlayout.weibo.comment_info = tempArr;
             [self touchAttribute:UpdateTouch data:_swlayout.weibo];
         }
         else
         {
             [self.vc showHudInView:self.vc.view showHint:@"删除失败，请稍后重试"];
         }
     } withError:^(NSError *error) {
         [self.vc hideHud];
         [self.vc showHudInView:self.vc.view showHint:@"连接超时，请稍后重试"];
     }];
    
}


//评论成功后的本地处理
-(void)dealComment:(NSDictionary *)backDic
{
    DtComment *dtCommentNew = [DtComment new];
    dtCommentNew.content = backDic[@"content"];
    dtCommentNew.comment_id = backDic[@"comment_id"];
    dtCommentNew.ctime = [NSString stringWithFormat:@"%@",@([[NSDate date] timeIntervalSince1970])];
    //组装自己的信息
    DtUser *tempUser = [DtUser new];
    tempUser.uname = SWUNAME;
    tempUser.uid = SWUID;
    tempUser.avatar_middle = SWAVATAR;
    dtCommentNew.user_info = tempUser;
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:_swlayout.weibo.comment_info];
    _swlayout.weibo.comment_count+=1;
    if ([tempArr count]) {
        [tempArr insertObject:dtCommentNew atIndex:0];
    }else
        [tempArr addObject:dtCommentNew];
    _swlayout.weibo.comment_info = tempArr;
    [self touchAttribute:UpdateTouch data:_swlayout.weibo];
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

#pragma mark - <ZLPhotoPickerBrowserViewControllerDataSource>
- (NSInteger)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section{
    return [_swlayout.weibo.attach_info count];
}

- (ZLPhotoPickerBrowserPhoto *)photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath{
    DtPhonto *dtPhoto = _swlayout.weibo.attach_info[indexPath.item];
    ZLPhotoPickerBrowserPhoto *photo = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:[NSURL URLWithString:dtPhoto.attach_origin]];
    // 保存的图
    if (!_noShowPhotoAnimation) {
        pickerBrowser.homeImg = NO;
    }else{
        pickerBrowser.homeImg = YES;
    }
    photo.toView = _photosView.subviews[indexPath.item];
    photo.thumbImage = ((UIImageView *)_photosView.subviews[indexPath.item]).image;
    return photo;
}





@end
