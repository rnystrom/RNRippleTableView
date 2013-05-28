//
//  RNViewController.m
//  RNRipplingTableView
//
//  Created by Ryan Nystrom on 5/20/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import "RNViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RNSampleCell.h"

@interface RNViewController ()
@property (weak, nonatomic) IBOutlet RNRippleTableView *rippleView;
@end

@implementation RNViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:117/255.f green:184/255.f blue:174/255.f alpha:1];
    self.rippleView.ripplesOnShake = YES;
    [self.rippleView registerContentViewClass:[RNSampleCell class]];
    self.rippleView.delegate = self;
    self.rippleView.dataSource = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.rippleView becomeFirstResponder];
}

#pragma mark - Tableview datasource

- (NSInteger)numberOfItemsInTableView:(RNRippleTableView *)tableView {
    return 10;
}

- (UIView *)viewForTableView:(RNRippleTableView *)tableView atIndex:(NSInteger)index withReuseView:(RNSampleCell *)reuseView {
    reuseView.backgroundColor = [UIColor colorWithRed:117/255.f green:184/255.f blue:174/255.f alpha:1];
    reuseView.titleLabel.text = [NSString stringWithFormat:@"Cell %i",index+1];
    reuseView.titleLabel.textColor = [UIColor whiteColor];
    reuseView.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    reuseView.titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.1f];
    reuseView.titleLabel.shadowOffset = CGSizeMake(0, -1);
    reuseView.dividerLayer.backgroundColor = [UIColor whiteColor].CGColor;
    return reuseView;
}

#pragma mark - Tableview delegate

- (CGFloat)heightForViewInTableView:(RNRippleTableView *)tableView atIndex:(NSInteger)index {
    return 55;
}

- (void)tableView:(RNRippleTableView *)tableView didSelectView:(UIView *)view atIndex:(NSInteger)index {
    NSLog(@"Row %i tapped",index);
}

@end
