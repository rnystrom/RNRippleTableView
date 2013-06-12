//
//  RNTableView.m
//  TableView
//
//  Created by Ryan Nystrom on 5/18/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import "RNRippleTableView.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define DEGREES(rads) rads * M_PI / 180.f

CGFloat const kRNRippleViewCellDefaultHeight = 40;

static const void *kRNRippleTableViewParentShadowKey = &kRNRippleTableViewParentShadowKey;
static const void *kRNRippleTableViewShadingLayerKey = &kRNRippleTableViewShadingLayerKey;

@interface UIView (RNRippleView)
@property (nonatomic, strong) CAShapeLayer *parentShadowLayer;
@property (nonatomic, strong) CALayer *shadingLayer;
@end

@implementation UIView (RNRippleView)
- (CAShapeLayer *)parentShadowLayer {
    return objc_getAssociatedObject(self, kRNRippleTableViewParentShadowKey);
}
- (void)setParentShadowLayer:(CAShapeLayer *)parentShadowLayer {
    objc_setAssociatedObject(self, kRNRippleTableViewParentShadowKey, parentShadowLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CALayer *)shadingLayer {
    return objc_getAssociatedObject(self, kRNRippleTableViewShadingLayerKey);
}
- (void)setShadingLayer:(CALayer *)shadingLayer {
    objc_setAssociatedObject(self, kRNRippleTableViewShadingLayerKey, shadingLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

@interface RNRowObject : NSObject
@property (nonatomic, strong) UIView *cachedView;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) CGFloat startY;
@property (nonatomic, assign) CGFloat height;
@end
@implementation RNRowObject
@end

@interface RNRippleTableView ()
@property (nonatomic, strong) NSMutableArray *reusePool;
@property (nonatomic, strong) NSMutableArray *rowObjects;
@property (nonatomic, copy) Class contentViewClass;
@property (nonatomic, strong) NSMutableIndexSet* visibleRows;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@end

@implementation RNRippleTableView

#pragma mark - UIView

static void tableInit(RNRippleTableView *self) {
    self->_tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:self->_tapGesture];
    
    self->_reusePool = [NSMutableArray array];
    self->_visibleRows = [NSMutableIndexSet indexSet];
    self->_isAnchoredLeft = YES;
    self->_rippleAmplitude = 20;
    self->_rippleDuration = 0.75f;
    self->_rippleOffset = 3;
    self->_rippleDelay = 0.1f;
    self->_rippleEnabled = YES;
    self->_rippleHasParentShading = YES;
    self->_rippleHasShading = YES;
    
    self.bounces = YES;
    self.alwaysBounceHorizontal = NO;
    self.alwaysBounceVertical = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = YES;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        tableInit(self);
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        tableInit(self);
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        tableInit(self);
    }
    return self;
}

- (BOOL)canBecomeFirstResponder {
    return self.ripplesOnShake;
}

#pragma mark - Table view

- (UIView *)dequeReusableView {
    UIView *view = [self.reusePool lastObject];
    if (! view) {
        view = [[self.contentViewClass alloc] init];
        
        view.shadingLayer = [CALayer layer];
        view.shadingLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.13f].CGColor;
        view.shadingLayer.opacity = 0;
        [view.layer addSublayer:view.shadingLayer];
        
        view.parentShadowLayer = [CAShapeLayer layer];
        view.parentShadowLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.5f].CGColor;
        view.parentShadowLayer.fillRule = kCAFillRuleNonZero;
        view.parentShadowLayer.opacity = 1;
        [view.layer addSublayer:view.parentShadowLayer];
    }
    else {
        [self.reusePool removeObject:view];
    }
    return view;
}

- (void)generateHeightAndOffsetData {
    BOOL checkForHeightEachRow = [self.delegate respondsToSelector:@selector(heightForViewInTableView:atIndex:)];
    NSInteger numberOfRow = [self.dataSource numberOfItemsInTableView:self];
    CGFloat startY = 0;
    self.rowObjects = [NSMutableArray array];
    @autoreleasepool {
        for (NSInteger i = 0; i < numberOfRow; i++) {
            RNRowObject *rowObject = [[RNRowObject alloc] init];
            rowObject.index = i;
            rowObject.height = checkForHeightEachRow ? [self.delegate heightForViewInTableView:self atIndex:i] : kRNRippleViewCellDefaultHeight;
            rowObject.startY = startY;
            startY += rowObject.height;
            [self.rowObjects addObject:rowObject];
        }
    }
    self.contentSize = CGSizeMake(self.bounds.size.width, startY);
}

- (void)layoutTableView {
    CGFloat startY = self.contentOffset.y;
    CGFloat endY = startY + self.frame.size.height;
    NSInteger rowToDisplay = [self findRowForOffsetY:startY inRange:NSMakeRange(0, [self.rowObjects count])];
    NSMutableIndexSet *newVisibleRows = [NSMutableIndexSet indexSet];
    CGFloat yOrigin;
    CGFloat rowHeight;
    while (yOrigin + rowHeight < endY && rowToDisplay < [self.rowObjects count]) {
        [newVisibleRows addIndex:rowToDisplay];
        yOrigin = [self startPositionYForIndex:rowToDisplay];
        rowHeight = [self heightForIndex:rowToDisplay];
        UIView *view = [self cachedViewForIndex:rowToDisplay];
        if (! view) {
            UIView *view = [self.dataSource viewForTableView:self atIndex:rowToDisplay withReuseView:[self dequeReusableView]];
            [self setCachedView:view forIndex:rowToDisplay];
            view.layer.anchorPoint = CGPointMake(_isAnchoredLeft ? 0 : 1, 0.5f);
            view.frame = CGRectMake(0, yOrigin, self.bounds.size.width, rowHeight);
            view.shadingLayer.frame = view.bounds;
            [self insertSubview:view atIndex:0];
        }
        rowToDisplay++;
    }
    [self returnNonVisibleRowsToThePool:newVisibleRows];
}

- (NSInteger)findRowForOffsetY: (CGFloat) yPosition inRange: (NSRange) range {
    if ([self.rowObjects count] == 0) return 0;
    
    RNRowObject *rowObject = [[RNRowObject alloc] init];
    rowObject.startY = yPosition;
    
    NSInteger index = [self.rowObjects indexOfObject:rowObject inSortedRange:NSMakeRange(0, [self.rowObjects count]) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult (RNRowObject *r1, RNRowObject *r2) {
        if (r1.startY < r2.startY) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    return MAX(0, index - 1);
}

- (void)reloadData {
    if (self.dataSource) {
        [self returnNonVisibleRowsToThePool:nil];
        [self generateHeightAndOffsetData];
    }
}

- (void)returnNonVisibleRowsToThePool:(NSMutableIndexSet*)currentVisibleRows {
    [self.visibleRows removeIndexes:currentVisibleRows];
    [self.visibleRows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        UIView *view = [self cachedViewForIndex:idx];
        if (view) {
            [self.reusePool addObject:view];
            [view removeFromSuperview];
            [self setCachedView:nil forIndex:idx];
        }
    }];
    self.visibleRows = currentVisibleRows;
}

#pragma mark - Setters

- (void)setCachedView:(UIView *)view forIndex:(NSInteger)index {
    RNRowObject *rowObject = self.rowObjects[index];
    rowObject.cachedView = view;
}

- (void)setContentOffset:(CGPoint)contentOffset {
    [super setContentOffset:contentOffset];
    [self layoutTableView];
}

- (void)registerContentViewClass:(Class)contentViewClass {
    NSAssert([contentViewClass isSubclassOfClass:[UIView class]], @"Cannot register a class that does not inherit from UIView.");
    self.contentViewClass = contentViewClass;
}

- (void)setDataSource:(id<RNRippleTableViewDataSource>)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}

- (void)setIsAnchoredLeft:(BOOL)isAnchoredLeft {
    if (isAnchoredLeft != _isAnchoredLeft) {
        _isAnchoredLeft = isAnchoredLeft;
        [self reloadData];
    }
}

#pragma mark - Getters

- (UIView *)cachedViewForIndex:(NSInteger)index {
    return [(RNRowObject *)self.rowObjects[index] cachedView];
}

- (CGFloat)heightForIndex:(NSInteger)index {
    return [(RNRowObject *)self.rowObjects[index] height];
}

- (CGFloat)startPositionYForIndex:(NSInteger)index {
    return [(RNRowObject *)self.rowObjects[index] startY];
}

- (NSArray *)visibleViews {
    if ([self.rowObjects count] > 0) {
        return [[self.rowObjects objectsAtIndexes:self.visibleRows] valueForKeyPath:@"cachedView"];
    }
    return nil;
}

- (UIView *)viewAtPoint:(CGPoint)point {
    for (UIView *view in [self visibleViews]) {
        if (CGRectContainsPoint(view.frame, point)) return view;
    }
    return nil;
}

- (UIView *)viewForIndex:(NSInteger)index {
    return [[self.rowObjects objectAtIndex:index] cachedView];
}

- (CGPathRef)parentShadowPathForView:(UIView *)view withModifier:(CGFloat)modifier {
    CGFloat maxHeight = 0.25f * view.bounds.size.height;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    [path addLineToPoint:CGPointMake(self.bounds.size.width, 0)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width * (1 - view.layer.anchorPoint.x), maxHeight * modifier)];
    return CGPathRetain(path.CGPath);
}

#pragma mark - Gestures

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer {
    if (recognizer == self.tapGesture && [self.delegate respondsToSelector:@selector(tableView:didSelectView:atIndex:)]) {
        UIView *view = [self viewAtPoint:[recognizer locationInView:self]];
        if (view) {
            NSArray *rowObjects = [self.rowObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"cachedView = %@",view]];
            RNRowObject *rowObject = [rowObjects lastObject];
            if (rowObject) {
                if (self.rippleEnabled) {
                    [self rippleAtOrigin:rowObject.index];
                }
                
                [self.delegate tableView:self didSelectView:view atIndex:rowObject.index];
            }
        }
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [super motionEnded:motion withEvent:event];
    
    if (event.subtype == UIEventSubtypeMotionShake && self.ripplesOnShake) {
        [self rippleAtOrigin:[[self visibleRows] firstIndex] amplitude:5 duration:0.05f];
    }
}

#pragma mark - Cell animation

- (void)bounceView:(UIView *)view {
    [self bounceView:view amplitude:self.rippleAmplitude];
}

- (void)bounceView:(UIView *)view amplitude:(CGFloat)amplitude {
    [self bounceView:view amplitude:amplitude duration:self.rippleDuration];
}

- (void)bounceView:(UIView *)view amplitude:(CGFloat)amplitude duration:(CGFloat)duration {    
    CGFloat m34 = 1 / 300.f * (view.layer.anchorPoint.x == 0 ? -1 : 1);
    CGFloat bounceAngleModifiers[] = {1, 0.33f, 0.13f};
    NSInteger bouncesCount = sizeof(bounceAngleModifiers) / sizeof(CGFloat);
    bouncesCount = bouncesCount * 2 + 1;
    
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = m34;
    view.layer.transform = transform;
    
    CAKeyframeAnimation *bounceKeyframe = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.y"];
    bounceKeyframe.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    bounceKeyframe.duration = duration;
    
    NSMutableArray *bounceValues = [NSMutableArray array];
    for (NSInteger i = 0; i < bouncesCount; i++) {
        CGFloat angle = 0;
        if (i % 2 > 0) {
            angle = bounceAngleModifiers[i / 2] * amplitude;
        }
        [bounceValues addObject:@(DEGREES(angle))];
    }
    bounceKeyframe.values = bounceValues;
    
    view.parentShadowLayer.path = [self parentShadowPathForView:view withModifier:0];
    [view.layer setValue:@(0) forKeyPath:bounceKeyframe.keyPath];
    [view.layer addAnimation:bounceKeyframe forKey:nil];
    
    CAKeyframeAnimation *shadowKeyframe = [bounceKeyframe copy];
    shadowKeyframe.keyPath = @"opacity";
    
    if (self.rippleHasShading) {
        [view.shadingLayer addAnimation:shadowKeyframe forKey:nil];
    }
    
    if (self.rippleHasParentShading) {
        [view.parentShadowLayer addAnimation:shadowKeyframe forKey:nil];
        
        CAKeyframeAnimation *shadowPathKeyframe = [bounceKeyframe copy];
        shadowPathKeyframe.keyPath = @"path";
        
        NSMutableArray *pathValues = [NSMutableArray array];
        CGPathRef initialPath = view.parentShadowLayer.path;
        for (NSInteger i = 0; i < bouncesCount; i++) {
            CGPathRef path = initialPath;
            if (i % 2 > 0) {
                CGFloat modifier = bounceAngleModifiers[i / 2];
                path = [self parentShadowPathForView:view withModifier:modifier];
            }
            [pathValues addObject:(__bridge id)path];
        }
        shadowPathKeyframe.values = pathValues;
        [view.parentShadowLayer addAnimation:shadowPathKeyframe forKey:nil];
    }
}

#pragma mark - Table animation

- (void)rippleAtOrigin:(NSInteger)originIndex {
    [self rippleAtOrigin:originIndex amplitude:self.rippleAmplitude];
}

- (void)rippleAtOrigin:(NSInteger)originIndex amplitude:(CGFloat)amplitude {
    [self rippleAtOrigin:originIndex amplitude:amplitude duration:self.rippleDuration];
}

- (void)rippleAtOrigin:(NSInteger)originIndex amplitude:(CGFloat)amplitude duration:(CGFloat)duration {
    UIView *originView = [self viewForIndex:originIndex];
    
    [self bounceView:originView amplitude:amplitude];
    
    CGFloat delay = self.rippleDelay;
    NSMutableArray *viewGroups = [NSMutableArray array];
    NSArray *visibleViews = [self visibleViews];
    
    for (NSInteger i = 1; i <= self.rippleOffset; i++) {
        NSMutableArray *viewGroup = [NSMutableArray array];
        if (originIndex - i > -1) {
            UIView *view = [self viewForIndex:originIndex - i];
            if (view && [visibleViews containsObject:view]) {
                [viewGroup addObject:view];
            }
        }
        if (originIndex + i < [self.dataSource numberOfItemsInTableView:self]) {
            UIView *view = [self viewForIndex:originIndex + i];
            if (view && [visibleViews containsObject:view]) {
                [viewGroup addObject:view];
            }
        }
        if ([viewGroup count] > 0) {
            [viewGroups addObject:viewGroup];
        }
    }
    
    [viewGroups enumerateObjectsUsingBlock:^(NSArray *viewGroup, NSUInteger idx, BOOL *stop) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * (idx + 1) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            CGFloat modifier = 1 / (1.f * idx + 1);
            modifier = powf(modifier, idx);
            CGFloat subAmplitude = amplitude * modifier;
            for (UIView *view in viewGroup) {
                [self bounceView:view amplitude:subAmplitude];
            }
        });
    }];
}

@end
