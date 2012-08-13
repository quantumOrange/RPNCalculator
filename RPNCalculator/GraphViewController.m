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
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@end

@implementation GraphViewController
@synthesize graphView=_graphView;
@synthesize displayFunction = _displayFunction;
@synthesize program=_program;
@synthesize splitViewBarButtonItem=_splitViewBarButtonItem;
@synthesize toolbar=_toolbar;

- (void) setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolbar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

- (IBAction)drawLines:(UISwitch *)sender 
{
    if(sender.on)
    {
        self.graphView.drawLines=YES;
        NSLog(@"Line");
    }
    else 
    {
        self.graphView.drawLines=NO;
        NSLog(@"Pixels");
    }
    [self.graphView setNeedsDisplay];
}

- (void) setProgram:(id)program
{
    _program =program;
    [self.graphView setNeedsDisplay];
    self.displayFunction.text = [CalculatorBrain descriptionOfProgram:self.program];
}

-(void)setGraphView:(GraphView *)graphView
{
    _graphView=graphView;
    self.graphView.dataSource = self;
    self.graphView.scale=[[NSUserDefaults standardUserDefaults] floatForKey:@"scale"];
    
    CGPoint axisOrigin;
    axisOrigin.x=[[NSUserDefaults standardUserDefaults] floatForKey:@"originX"];
    axisOrigin.y=[[NSUserDefaults standardUserDefaults] floatForKey:@"originY"];
    self.graphView.axisOrigin=axisOrigin;
    
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(moveOrigin:)]];
    UITapGestureRecognizer  *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tapOrigin:)];
    tapGesture.numberOfTapsRequired = 3;
    [self.graphView addGestureRecognizer:tapGesture];
}

- (float) functionOfx:(GraphView *) sender evaluatedAt: (float) x
{
    NSDictionary *valueOfX =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:x], @"x",nil];
    
    id result = [CalculatorBrain runProgram:self.program usingVariableValues:valueOfX];
    if ([result isKindOfClass:[NSNumber class]]) {
        return [result doubleValue];
    }
    else 
    {
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
    self.graphView.drawLines=YES;
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
