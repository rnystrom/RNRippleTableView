//
//  RNTableView.h
//  TableView
//
//  Created by Ryan Nystrom on 5/18/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RNRippleTableView;

@protocol RNRippleTableViewDataSource <NSObject>
@required
- (NSInteger)numberOfItemsInTableView:(RNRippleTableView *)tableView;
- (UIView *)viewForTableView:(RNRippleTableView *)tableView atIndex:(NSInteger)index withReuseView:(UIView *)reuseView;
@end

@protocol RNRippleTableViewDelegate <NSObject, UIScrollViewDelegate>
@optional
- (CGFloat)heightForViewInTableView:(RNRippleTableView *)tableView atIndex:(NSInteger)index;
- (void)tableView:(RNRippleTableView *)tableView didSelectView:(UIView *)view atIndex:(NSInteger)index;
@end

@interface RNRippleTableView : UIScrollView
@property (nonatomic, weak) id <RNRippleTableViewDataSource> dataSource;
@property (nonatomic, weak) id <RNRippleTableViewDelegate> delegate;

@property (nonatomic, assign) BOOL isAnchoredLeft;
@property (nonatomic, assign) NSInteger rippleOffset;
@property (nonatomic, assign) CGFloat rippleAmplitude;
@property (nonatomic, assign) CGFloat rippleDuration;
@property (nonatomic, assign) BOOL ripplesOnAccelerometer;

- (void)registerContentViewClass:(Class)contentViewClass;
- (void)reloadData;
- (NSArray *)visibleViews;
- (UIView *)viewForIndex:(NSInteger)index;

- (void)bounceView:(UIView *)view;
- (void)bounceView:(UIView *)view amplitude:(CGFloat)amplitude;
- (void)bounceView:(UIView *)view amplitude:(CGFloat)amplitude duration:(CGFloat)duration;

- (void)rippleAtOrigin:(NSInteger)originIndex;
- (void)rippleAtOrigin:(NSInteger)originIndex amplitude:(CGFloat)amplitude;
- (void)rippleAtOrigin:(NSInteger)originIndex amplitude:(CGFloat)amplitude duration:(CGFloat)duration;
@end
