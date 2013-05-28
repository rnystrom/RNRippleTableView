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

@property (nonatomic, assign) BOOL rippleEnabled;           // default YES
@property (nonatomic, assign) BOOL isAnchoredLeft;          // default YES
@property (nonatomic, assign) NSInteger rippleOffset;       // default 3
@property (nonatomic, assign) CGFloat rippleAmplitude;      // default 20 (degrees)
@property (nonatomic, assign) CGFloat rippleDuration;       // default 0.75 seconds
@property (nonatomic, assign) BOOL ripplesOnShake;          // default NO
@property (nonatomic, assign) CGFloat rippleDelay;          // default 0.1f
@property (nonatomic, assign) BOOL rippleHasParentShading;  // default YES
@property (nonatomic, assign) BOOL rippleHasShading;        // default YES

- (void)registerContentViewClass:(Class)contentViewClass;
- (void)reloadData;
- (NSArray *)visibleViews;
- (UIView *)viewForIndex:(NSInteger)index;

// animate individual cells
- (void)bounceView:(UIView *)view;
- (void)bounceView:(UIView *)view amplitude:(CGFloat)amplitude;
- (void)bounceView:(UIView *)view amplitude:(CGFloat)amplitude duration:(CGFloat)duration;

// animate ripple effect
- (void)rippleAtOrigin:(NSInteger)originIndex;
- (void)rippleAtOrigin:(NSInteger)originIndex amplitude:(CGFloat)amplitude;
- (void)rippleAtOrigin:(NSInteger)originIndex amplitude:(CGFloat)amplitude duration:(CGFloat)duration;
@end
