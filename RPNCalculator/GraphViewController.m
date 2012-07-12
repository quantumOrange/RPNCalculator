//
//  GraphViewController.m
//  Calculator
//
//  Created by David Crooks on 22/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"
#import "CalculatorBrain.h"

@interface GraphViewController() <GraphViewDataSource>
@property (nonatomic, weak) IBOutlet GraphView *graphView;
@property (weak, nonatomic) IBOutlet UILabel *displayFunction;

@end

@implementation GraphViewController
@synthesize graphView=_graphView;
@synthesize displayFunction = _displayFunction;
@synthesize program=_program;


-(void)setGraphView:(GraphView *)graphView
{
    _graphView=graphView;
    self.graphView.dataSource = self;
    
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(moveOrigin:)]];
    [self.graphView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tapOrigin:)]];
}

- (float) functionOfx:(GraphView *) sender evaluatedAt: (float) x
{
    NSDictionary *valueOfX =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:x], @"x",nil];
    
    id result = [CalculatorBrain runProgram:self.program usingVariableValues:valueOfX];
    if ([result isKindOfClass:[NSNumber class]]) {
        return [result doubleValue];
    }
    else {
        return 0.0;
    }
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
           }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.displayFunction.text = [CalculatorBrain descriptionOfProgram:self.program];

	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setDisplayFunction:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

@end