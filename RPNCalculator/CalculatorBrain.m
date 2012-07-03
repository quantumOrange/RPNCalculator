//
//  CalculatorBrain.m
//  RPNCalculator
//
//  Created by David Crooks on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *operandStack;
@end

@implementation CalculatorBrain
@synthesize operandStack=_operandStack;

-(NSMutableArray *) operandStack
{
    if (!_operandStack) 
    {
        _operandStack =[[NSMutableArray alloc] init];
    }
    return _operandStack;
}

- (void) pushOperand: (double)operand
{
    [self.operandStack addObject:[NSNumber numberWithDouble:operand]];
}

- (double) performOperation: (NSString *) operation
{
    double result=0;
    
    if ([operation isEqualToString:@"+"])
    {
        result =  [self popOperand] + [self popOperand];
    } 
    else if ([operation isEqualToString:@"*"]) 
    {
        result =  [self popOperand] * [self popOperand];
    }
    else if ([operation isEqualToString:@"/"]) 
    {
        double numerator=[self popOperand];
        double denominator=[self popOperand];
        if (denominator) 
        {
            result =  numerator / denominator;
        }
        else 
        {
            result = 0;   
        }    
    }
    else if ([operation isEqualToString:@"-"]) 
    {
        double secondArgument=[self popOperand];
        result =  [self popOperand] - secondArgument;
    }
    else if ([operation isEqualToString:@"sin"]) 
    {
        result =  sin([self popOperand]);
    }
    else if ([operation isEqualToString:@"cos"]) 
    {
        result =  cos([self popOperand]);
    }
    else if ([operation isEqualToString:@"√"]) 
    {
        result =  sqrt([self popOperand]);
    }
    else if ([operation isEqualToString:@"π"]) 
    {
        result =  M_PI;
    }
    else 
    {
        result =0;
    }
    
    [self pushOperand:result];
    return result;
}

- (double) popOperand
{
    NSNumber *operandObject = [self.operandStack lastObject];
    if (operandObject) [self.operandStack removeLastObject];
    double result= [operandObject doubleValue];
    return result;
}


-(void) clearAll
{
   [self.operandStack removeAllObjects];
}
@end
