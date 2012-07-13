//
//  CalculatorViewController.h
//  RPNCalculator
//
//  Created by David Crooks on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorViewController : UIViewController <UISplitViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *logScreen;
@property (weak, nonatomic) IBOutlet UILabel *displayVariables;

@end
