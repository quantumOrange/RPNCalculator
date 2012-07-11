//
//  CalculatorBrain.m
//  RPNCalculator
//
//  Created by David Crooks on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@end

@implementation CalculatorBrain
@synthesize programStack=_programStack;

-(NSMutableArray *) programStack
{
    if (!_programStack) 
    {
        _programStack =[[NSMutableArray alloc] init];
    }
    return _programStack;
}

- (void) pushOperand: (double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}


- (void) removeLastObjectFromProgram
{
    if([self.programStack lastObject]) [self.programStack removeLastObject];
}


- (void) pushOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
}

+ (NSSet *)operators
{
    return [NSSet setWithObjects:@"+",@"-",@"*",@"/",nil];
}

+ (NSSet *) functions
{
    return [NSSet setWithObjects:@"√",@"sin",@"cos",nil];
}

+ (NSSet *) operatorsAndFunctions
{
    return [NSSet setWithObjects:@"√",@"sin",@"cos",@"+",@"-",@"*",@"/",@"π",nil];
}


- (id)program
{
    return [self.programStack copy];
}

+ (NSString *) descriptionOfProgram:(id)program
{
    NSMutableArray *stack;
    if([program isKindOfClass:[NSArray class]])
    {
        stack = [program mutableCopy];
    }
    NSString *result;
    while ([stack count]) 
    {
        NSArray *resultAndStack  = [self popDescriptionOffStack:stack];
        if (result) 
        {
            result = [NSString stringWithFormat:@"%@,%@",[resultAndStack objectAtIndex:0],result];
        }
        else 
        {
            result=[resultAndStack objectAtIndex:0];
        }
        stack=[resultAndStack objectAtIndex:1];
    }  
    return result;
}

+ (NSArray *) popDescriptionOffStack:(NSMutableArray *) stack
{
    NSString *description = @"";
    BOOL isCompound = NO;
    id topOfStack = [stack lastObject];
    if(topOfStack) [stack removeLastObject];
    
    if([topOfStack isKindOfClass:[NSNumber class]])
    {
        description =[NSString stringWithFormat:@"%@", topOfStack ];
        
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        if ([[self operators] member:topOfStack] ) 
        {
            //operator take two arguments
            
            //get the first argument and return whats left of the stack
            NSArray *arrayForFirstArgument=[self popDescriptionOffStack:stack];
            NSString *firstArgument=[arrayForFirstArgument objectAtIndex:0];
            //if we get back something compound we'll need to add brackets
            isCompound=[[arrayForFirstArgument objectAtIndex:2] boolValue];
            if (isCompound) firstArgument=[NSString stringWithFormat:@"(%@)",firstArgument];
            
            //feed back in the remains of the stack to get the second argument
            NSArray *arrayForSecondArgument=[self popDescriptionOffStack:[arrayForFirstArgument objectAtIndex:1]];
            NSString *secondArgument=[arrayForSecondArgument objectAtIndex:0];
            if([secondArgument isEqualToString:@""]) 
            {
                secondArgument=@"0";
            }
            //Again,if we get back something compound we'll need to add brackets
            isCompound=[[arrayForSecondArgument objectAtIndex:2] boolValue];
            if (isCompound) secondArgument=[NSString stringWithFormat:@"(%@)",secondArgument];
            //the firstArgument taken from the stack is the secong argument entered, so it goes on the right
            //and the secondArgument is really the first, so it goes on the left 
            description = [NSString stringWithFormat:@"%@ %@ %@",secondArgument ,topOfStack,firstArgument];
            stack=[arrayForSecondArgument objectAtIndex:1];
            
            //the result is compound so if it gets fed into something else, it'll need brackets
            isCompound = YES;
        }
        else if ([[self functions] member:topOfStack]) 
        {
            //functions only take one argument
            NSArray *arrayForArgument=[self popDescriptionOffStack:stack];
            NSString *argument =[arrayForArgument objectAtIndex:0];
            //If we get back an empty string, then there was nothing on the stack. popOperand uses zero in this cas, so we should do the same here.
            if([argument isEqualToString:@""]) 
            {
                argument=@"0";
            }
            //we always want to add brackets here.
            description = [NSString stringWithFormat:@"%@(%@)",topOfStack,argument];
            stack = [arrayForArgument objectAtIndex:1];
        }
        else 
        {
           description=topOfStack;
            //description=@"0";
        }
    }
    return [NSArray arrayWithObjects:description, stack,[NSNumber numberWithBool:isCompound], nil];
}




 

+ (id) popOperandOffStack:(NSMutableArray *)stack
{
    double result;
    id topOfStack = [stack lastObject];
    if(topOfStack) [stack removeLastObject];
    
    if([topOfStack isKindOfClass:[NSNumber class]])
    {
        return topOfStack;
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
      NSString *operation = topOfStack;
        if ([[self operators] member:topOfStack] ) 
        {
            //operators need two arguments
            id popOne=[self popOperandOffStack:stack];
            id popTwo=[self popOperandOffStack:stack];
            
            if ([popOne isKindOfClass:[NSNumber class]] && [popTwo isKindOfClass:[NSNumber class]] ) 
            {
                double argOne = [popOne doubleValue];
                double argTwo = [popTwo doubleValue];
               
                if ([operation isEqualToString:@"+"])
                {
                    result =  argTwo + argOne;
                } 
                else if ([operation isEqualToString:@"*"]) 
                {
                    result =  argTwo * argOne;
                }
                
                else if ([operation isEqualToString:@"/"]) 
                {
                    if (argOne) 
                    {
                        result =  argTwo/ argOne;
                    }
                    else 
                    {
                        return @"Infinity!";   
                    }    
                }
                else if ([operation isEqualToString:@"-"]) 
                {
                    result =  argTwo  - argOne;
                }
            }
            else 
            {
                //One of the pops must be an error
                if ([popOne isKindOfClass:[NSString class]]) 
                {
                    return popOne;
                }
                else if ([popTwo isKindOfClass:[NSString class]]) 
                {
                    return popTwo;
                }
                else
                {
                    //Or else I don't know whats going on...
                    return @"Unknown Error!";
                }
            }
        }
        else if ([[self functions] member:topOfStack]) 
        {
            //these functions need only one argument
            id pop=[self popOperandOffStack:stack];
            if ([pop isKindOfClass:[NSNumber class]])
            {
                double arg = [pop doubleValue];  
                
                if ([operation isEqualToString:@"sin"]) 
                {
                    result =  sin(arg);
                }
                else if ([operation isEqualToString:@"cos"]) 
                {
                    result =  cos(arg);
                }
                else if ([operation isEqualToString:@"√"]) 
                {
                    if (arg>=0) 
                    {
                        result =  sqrt(arg);
                    }
                    else
                    {
                        return @"Complex!";
                    }
                }

            }
            else
            {
                // pop must be an error message
                return pop;
            }
            
        }
        else if ([operation isEqualToString:@"π"]) {
            result = M_PI;
        }
        else 
        {
            return @"Unknown Error!";
        }
    }
    return [NSNumber numberWithFloat:result];
}

+ (id)runProgram: (id) program 
{
    NSMutableArray *stack;
    if([program isKindOfClass:[NSArray class]])
    {
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack];
}

+ (id)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
{
    NSMutableArray *stack;
    if([program isKindOfClass:[NSArray class]])
    {
        stack = [program mutableCopy];
    }
    for (int i=0; i<stack.count; i++) 
    {
        NSNumber *argument=[variableValues objectForKey:[stack objectAtIndex:i]];
        if (argument) 
        {
            [stack replaceObjectAtIndex:i withObject:argument];
        }    
    }
    return [self popOperandOffStack:stack];
}


-(id) lastOnStack
{
    id stack = [self programStack];
    if([stack count]>0)
    {
        id topOfStack= [stack lastObject];
        return [self stackObjectAsString:topOfStack];
        
    }
    else
    {
        return 0;
    }
}

-(id) secondTolastOnStack
{
    id stack = [self programStack];
    if([self.programStack count]>1)
    {
        int indexOfSecondToLastObject = [stack count]-2;
        id secondOnStack = [stack objectAtIndex:indexOfSecondToLastObject];
        return [self stackObjectAsString:secondOnStack];
    }
    else 
    {
        return 0;
    }
}

-(NSString *) stackObjectAsString:(id)stackObject
{
    if ([stackObject isKindOfClass:[NSString class]]) {
        return stackObject;
    }
    else if ([stackObject isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%g", [stackObject doubleValue] ];
    }
    else {
        return 0;
    }
}



-(NSString *) description
{
    return [NSString stringWithFormat:@"stack =%@",self.programStack];
}




/*
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
    NSNumber *operandObject = [self.programStack lastObject];
    if (operandObject) [self.programStack removeLastObject];
    double result= [operandObject doubleValue];
    return result;
}
*/



-(void) clearAll
{
   [self.programStack removeAllObjects];
}


+ (NSSet *)variablesUsedInProgram:(id)program
{
    NSMutableArray *variables = [[NSMutableArray alloc] init];  
    if([program isKindOfClass:[NSArray class]])
    {
        for( id operand in program)
        {
            if ([operand isKindOfClass:[NSString class]] && ![[self operatorsAndFunctions] member:operand]) 
            {
                [variables addObject:operand];
            } 
        }
    }
    
    if ([variables count]) 
    {
        return [NSSet setWithArray:variables];
    }
    else 
    {
        return nil;
    }
}



+ (NSDictionary *) testVariableValues:(NSString *) test  
{
    if ([test isEqualToString:@"Test 1"]) {
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.46], @"x", [NSNumber numberWithFloat:23.8], @"y", [NSNumber numberWithFloat:2.18], @"z",nil];
    }
    else if(  [test isEqualToString:@"Test 2"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:100000000000000000000.98869], @"x", [NSNumber numberWithFloat:0.0008], @"y", [NSNumber numberWithFloat:5.789], @"z",nil];
    }
    else if(  [test isEqualToString:@"Test 3"])
    {
        NSDictionary *dict;
        return  dict;
    }
    else if(  [test isEqualToString:@"Test 4"])
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.16], @"x", [NSNumber numberWithFloat:203.8], @"y", [NSNumber numberWithFloat:0.85], @"z", nil];
    }
    else
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:0.0], @"x", [NSNumber numberWithFloat:0.0], @"y", [NSNumber numberWithFloat:0.0], @"z", nil];
    }
}

@end
