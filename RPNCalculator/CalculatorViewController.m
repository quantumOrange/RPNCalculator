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
@synthesize displayVariables = _displayVariables;
@synthesize userIsInTheMiddleOfEnteringANumber =_userIsInTheMiddleOfEnteringANumber;
@synthesize brain=_brain;

-(CalculatorBrain *) brain
{
    if(!_brain) _brain =[[CalculatorBrain alloc] init];
    return _brain;
}

- (IBAction)runPressed 
{
    if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed]; 
    self.display.text=[NSString stringWithFormat:@"%f",[CalculatorBrain runProgram:self.brain.program]];
    self.displayVariables.text=@"x=0 y=0 z=0";
    //self.logScreen.text= [self.logScreen.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
    NSRange range =[self.logScreen.text rangeOfString:@"="] ;
    if (range.location==NSNotFound) {
        self.logScreen.text = [self.logScreen.text stringByAppendingString:@"="];
    }
    
}
- (IBAction)runTest:(id)sender 
{
    NSDictionary *testVariableValues = [CalculatorBrain testVariableValues:[sender currentTitle]];
    if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed]; 
    self.display.text=[NSString stringWithFormat:@"%f",[CalculatorBrain runProgram:self.brain.program usingVariableValues:testVariableValues]];
    
    
    self.displayVariables.text=@"  ";
    for (NSString *variable in testVariableValues) 
    {
        NSNumber *value=[testVariableValues objectForKey:variable];
        NSString *variableEqualsValue=[variable stringByAppendingString:[NSString stringWithFormat:@"=%@  ",value]];
        self.displayVariables.text=[self.displayVariables.text stringByAppendingString:variableEqualsValue];
    }
    //self.logScreen.text= [self.logScreen.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
    
    NSRange range =[self.logScreen.text rangeOfString:@"="] ;
    if (range.location==NSNotFound) {
        self.logScreen.text = [self.logScreen.text stringByAppendingString:@"="];
    }

}

- (IBAction)Clear 
{
    [self.brain clearAll];
    self.display.text = @"0";
    self.logScreen.text = @"";
    self.displayVariables.text =@"";
    self.userIsInTheMiddleOfEnteringANumber=NO;
}

- (IBAction)backButton 
{
    if (self.userIsInTheMiddleOfEnteringANumber) 
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
    else 
    {
        [self.brain removeLastObjectFromProgram];
        self.logScreen.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
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
    self.logScreen.text= [self.logScreen.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
}

- (IBAction)operationPressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
    [self.brain pushOperation:sender.currentTitle];
    self.logScreen.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    

}

- (IBAction)enterPressed 
{
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.logScreen.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    self.userIsInTheMiddleOfEnteringANumber=NO;
    self.display.text = @"0";

}

- (void)viewDidUnload {
    [self setLogScreen:nil];
    [self setDisplayVariables:nil];
    [super viewDidUnload];
}
@end
