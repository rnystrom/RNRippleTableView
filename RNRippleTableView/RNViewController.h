//
//  RNViewController.h
//  RNRipplingTableView
//
//  Created by Ryan Nystrom on 5/20/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNRippleTableView.h"

@interface RNViewController : UIViewController
<RNRippleTableViewDataSource, RNRippleTableViewDelegate>

@end
