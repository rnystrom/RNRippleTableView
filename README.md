RNRippleTableView
===

A custom table view with highly detailed ripple animations.

## Level of Detail ##

I created this control from a [couple](http://dribbble.com/shots/1072843-Filp-Menu?list=users) [posts](http://dribbble.com/shots/1072843-Filp-Menu/attachments/132747) on [Dribbble](http://dribbble.com/) by [Boris Valusek](http://dribbble.com/BorisValusek) out of pure curiosity. I really wanted to nail the shadow animations as well as a bounce effect that followed diminishing return rules on amplitude as well as plausible timing. Take a look at some screens and animations.

<p align="center"><img src="https://raw.github.com/rnystrom/RNRippleTableView/master/images/animated.gif"/></p>

To enable [Anti-Aliasing](http://en.wikipedia.org/wiki/Spatial_anti-aliasing) you'll need to set the <code>[UIViewEdgeAntialiasing](http://developer.apple.com/library/ios/#documentation/general/Reference/InfoPlistKeyReference/Articles/iPhoneOSKeys.html)</code> key to YES in your Info.plist. Doing so will impact performance, but if you're an optimizer you'll end up with good performance and sweet, sweet line edges like this:

<p align="center"><img src="https://raw.github.com/rnystrom/RNRippleTableView/master/images/still.png"/></p>

## Installation ##

The preferred method of installation is through [CocoaPods](http://cocoapods.org/). Just add the following to your Podfile:

```
pod 'RNRippleTableView', '~> 0.1.4'
```

Or if you want to install manually, drag both <code>RNRippleTableView</code>'s .h and .m into your project. You'll need to ensure that the <code>QuartzCore</code> framework is included. 

Optionally, you'll need to add the following code to any view controllers using <code>RNRippleTableView</code> to have ripple animations on shake gestures.

```objc
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.rippleView becomeFirstResponder];
}
```

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
@property (nonatomic, assign) BOOL rippleEnabled; // default YES
```

Toggle rippling on and off.

```objc
@property (nonatomic, assign) BOOL isAnchoredLeft; // default YES
```

Determines the anchor point for cells. Also determines which side of the view is animated as well as the direction that the shadow is drawn.

```objc
@property (nonatomic, assign) NSInteger rippleOffset; // default 3
```

The number of adjacent cells that are rippled.

```objc
@property (nonatomic, assign) CGFloat rippleAmplitude; // default 20 (degrees)
```

The angle at which the epicenter of the ripple animates its rotation to in degrees.

```objc
@property (nonatomic, assign) CGFloat rippleDuration; // default 0.75 seconds
```

The time for a single bounce animation to complete in seconds.

```objc
@property (nonatomic, assign) CGFloat rippleDelay; // default 0.1f
```

The timing delay between bounce animations in seconds that gives the entire ripple animation its delay effect. Faster looks more like a burst while slower looks like water.

```objc
@property (nonatomic, assign) BOOL rippleHasParentShading; // default YES
```

Determines if the previous view casts a shadow on the animated view.

```objc
@property (nonatomic, assign) BOOL rippleHasShading; // default YES
```

Determines if the entire view is shaded as it bounces.

```objc
@property (nonatomic, assign) BOOL ripplesOnShake; // default NO
```

Optionally you can animate small ripples on shake gestures with the device. This was a fun feature I added just because.

## Credits

I created a parent project called <code>[RNTableView](https://github.com/rnystrom/RNTableView)</code> simply as a bare-minimum project for starting highly customized UITableView-esque classes. That project was entirely insprired by Mike Ash's [Let's Build UITableView](http://www.mikeash.com/pyblog/friday-qa-2013-02-22-lets-build-uitableview.html) blog post.

[Boris Valusek](http://dribbble.com/BorisValusek) was the creator behind this idea on [Dribbble](http://dribbble.com/). All credit for originality goes to him.

## Apps

If you've used this project in a live app, please <a href="mailTo:rnystrom@whoisryannystrom.com">let me know</a>! Nothing makes me happier than seeing someone else take my work and go wild with it. 
## Contact

* [@nystrorm](https://twitter.com/_ryannystrom) on Twitter
* [@rnystrom](https://github.com/rnystrom) on Github
* <a href="mailTo:rnystrom@whoisryannystrom.com">rnystrom [at] whoisryannystrom [dot] com</a>

## License

See [LICENSE](https://github.com/rnystrom/RNRippleTableView/blob/master/LICENSE).
