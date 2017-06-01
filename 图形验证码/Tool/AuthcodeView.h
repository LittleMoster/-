//
//  AuthcodeView.h
//  图形验证码
//
//  Created by LK on 2017/5/23.
//  Copyright © 2017年 sqzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthcodeView : UIView
@property (strong, nonatomic) NSArray *dataArray;//字符素材数组

@property (strong, nonatomic) NSMutableString *authCodeStr;//验证码字符串

-(void)ChangAuthcode;
@end
