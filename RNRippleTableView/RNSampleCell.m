//
//  RNRippleCell.m
//  RNRipplingTableView
//
//  Created by Ryan Nystrom on 5/20/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import "RNSampleCell.h"

@implementation RNSampleCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _init];
    }
    return self;
}

- (void)_init {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
    
    _dividerLayer = [CALayer layer];
    _dividerLayer.backgroundColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:_dividerLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = self.bounds;
    CGFloat dividerWidth = self.bounds.size.width / 2;
    self.dividerLayer.frame = CGRectMake(dividerWidth / 2, 0, dividerWidth, 1);
}

@end
