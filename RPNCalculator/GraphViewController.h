//
//  GraphViewController.h
//  Calculator
//
//  Created by David Crooks on 22/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"
@interface GraphViewController : UIViewController <SplitViewBarButtonItemPresenter>

@property (nonatomic) id program;

@end
