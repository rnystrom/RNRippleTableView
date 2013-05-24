RNRippleTableView
===

A custom table view with highly detailed ripple animations.

## Level of Detail ##

I created this control from a [post on Dribbble]() by [Boris SOMETHING]() out of pure curiosity. I really wanted to nail the shadow animations as well as a bounce effect that followed diminishing return rules on amplitude as well as plausible timing. Take a look at some screens and animations.

<p align="center"><img src=""/></p>

To enable [Anti-Aliasing]() you'll need to set the <code>[UIViewEdgeAntialiasing](http://developer.apple.com/library/ios/#documentation/general/Reference/InfoPlistKeyReference/Articles/iPhoneOSKeys.html)</code> key to YES in your Info.plist.

## Installation ##

The preferred method of installation is through [CocoaPods](http://cocoapods.org/). Just add the following to your Podfile:

```
pod 'RNRippleTableView', '~> 0.0.1'
```

Or if you want to install manually, drag both <code>RNRippleTableView</code>'s .h and .m into your project. You'll need to ensure that the <code>QuartzCore</code> framework is included. Optionally, you'll need to include the MOTION FRAMEWORK if you'd like to use the accelerometer options.

## Usage ##

To use <code>RNRippleTableView</code>, simply add to your controller and lay it out just as you would any other view. Connect a datasource and delegate in a similar fashion to <code>[UITableView]()</code>. You must also register the class that will be used as the table cells. This class should be a class or subclass of UIView.

```objc
self.rippleView = [[RNRippleTableView alloc] init];
[self.rippleView registerContentViewClass:[RNSampleCell class]];
self.rippleView.delegate = self;
self.rippleView.dataSource = self;
```

Setup your cells just like you would with <code>[UITableView]()</code> except without any of the identifier and checking for nil parts, that is handled for you. 

```objc
- (UIView *)viewForTableView:(RNRippleTableView *)tableView atIndex:(NSInteger)index withReuseView:(RNSampleCell *)reuseView {
    reuseView.backgroundColor = [UIColor colorWithRed:117/255.f green:184/255.f blue:174/255.f alpha:1];
    reuseView.titleLabel.text = [NSString stringWithFormat:@"Cell %i",index];
    reuseView.titleLabel.textColor = [UIColor whiteColor];
    return reuseView;
}
```

## Customization

<code>RNRippleTableView</code> comes with a small set of options to customize the appearance and animations. 

```objc
@property (nonatomic, assign) BOOL isAnchoredLeft;          // default YES
```

Determines the anchor point for cells. Also determines which side of the view is animated as well as the direction that the shadow is drawn.

```objc
@property (nonatomic, assign) NSInteger rippleOffset;       // default 3
```

The number of adjacent cells that are rippled.

```objc
@property (nonatomic, assign) CGFloat rippleAmplitude;      // default 20 (degrees)
```

The angle at which the epicenter of the ripple animates its rotation to in degrees.

```objc
@property (nonatomic, assign) CGFloat rippleDuration;       // default 0.75 seconds
```

The time for a single bounce animation to complete in seconds.

```objc
@property (nonatomic, assign) BOOL ripplesOnAccelerometer;  // default NO
```

Optionally you can animate small ripples on significant motion events with the device. This was a fun feature I added just because.

## Acknowledgments

I created a parent project called <code>[RNTableView]()</code> simply as a bear-minimum project for starting highly customized UITableView-esque classes. That project was entirely insprired by Mike Ash's [Let's Build UITableView]() blog post.

[Boris]() was the creator behind this idea on [Dribbble](). All credit for originality goes to him.

## Contact

* [@nystrorm](https://twitter.com/nystrorm) on Twitter
* [@rnystrom](https://github.com/rnystrom) on Github
* <a href="mailTo:rnystrom@whoisryannystrom.com">rnystrom [at] whoisryannystrom [dot] com</a>

## License

See [LICENSE]().