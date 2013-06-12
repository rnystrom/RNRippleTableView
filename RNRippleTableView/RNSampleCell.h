//
//  RNRippleCell.h
//  RNRipplingTableView
//
//  Created by Ryan Nystrom on 5/20/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface RNSampleCell : UIView
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) CALayer *dividerLayer;
@end
