//
//  CalculatorViewController.m
//  RPNCalculator
//
//  Created by David Crooks on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@end

@implementation CalculatorViewController
@synthesize display;
@synthesize logScreen = _logScreen;
@synthesize userIsInTheMiddleOfEnteringANumber =_userIsInTheMiddleOfEnteringANumber;
@synthesize brain=_brain;

-(CalculatorBrain *) brain
{
    if(!_brain) _brain =[[CalculatorBrain alloc] init];
    return _brain;
}


- (IBAction)Clear 
{
    [self.brain clearAll];
    self.display.text = @"0";
    self.logScreen.text = @"";
    self.userIsInTheMiddleOfEnteringANumber=NO;
}

- (IBAction)backButton 
{
    if(self.display.text.length>1)
    {
        //if there is more than one digit in the display screen we just want remove the last digit
        self.display.text= [self.display.text substringToIndex:(self.display.text.length -1)];
    }        
    else 
    {
        // if there is only one digit, we want to put a zero in the display screen
        self.display.text=@"0";
        self.userIsInTheMiddleOfEnteringANumber=NO;
    }
}

- (IBAction)plusMinus 
{
    
        if ([self.display.text hasPrefix:@"-"]) 
        { 
            self.display.text=[self.display.text substringFromIndex:1];
        }
        else 
        {
            self.display.text=[@"-" stringByAppendingString:self.display.text];
        }
}



- (IBAction)didgitPressed:(UIButton *)sender 
{
    NSString *digit = [sender currentTitle];
   
    if (self.userIsInTheMiddleOfEnteringANumber)
    {
        //Check if user is entering a decimal point
        if ([digit isEqualToString:@"."])
        {
            NSRange range = [self.display.text rangeOfString:@"."];
            //Check to see if the number in the display already contains a decimal point. If nothing is found, add the point. Else, do nothing.  
            if (range.location == NSNotFound) 
            {  
                self.display.text =[self.display.text stringByAppendingString:digit];
            }
        }
        else
        {
            self.display.text =[self.display.text stringByAppendingString:digit];
        }
    }
    else 
    {
        //We're just starting a number. Check if user is entering a decimal point
        if ([digit isEqualToString:@"."])
        {
            //so if the user starts a number with a point, we want to keep the leading zero
            self.display.text=@"0.";
        }
        else 
        {
            //otherwise we discard it
            self.display.text=digit;
        }
        self.userIsInTheMiddleOfEnteringANumber=YES;
    }
}

- (IBAction)operationPressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
    NSString *operation = [sender currentTitle];
    double result = [self.brain performOperation:operation];
    self.logScreen.text= [self.logScreen.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
    operation=[[@" " stringByAppendingString:operation] stringByAppendingString:@"="];
    self.logScreen.text = [self.logScreen.text stringByAppendingString:operation];
    self.display.text = [NSString stringWithFormat:@"%g",result];
}

- (IBAction)enterPressed 
{
    NSString *numberDisplayed = self.display.text;
    [self.brain pushOperand:[numberDisplayed doubleValue]];
    numberDisplayed=[@" " stringByAppendingString:numberDisplayed];
    //we need to remove the equals sign if there is one.
    self.logScreen.text= [self.logScreen.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
    self.logScreen.text = [self.logScreen.text stringByAppendingString:numberDisplayed];
    self.userIsInTheMiddleOfEnteringANumber=NO;
}

- (void)viewDidUnload {
    [self setLogScreen:nil];
    [super viewDidUnload];
}
@end
