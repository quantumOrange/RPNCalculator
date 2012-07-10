//
//  CalculatorBrain.h
//  RPNCalculator
//
//  Created by David Crooks on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject
@property (readonly) id program;

- (void) clearAll;
+ (NSSet *) operators;
+ (NSSet *) functions;
+ (NSSet *) operatorsAndFunctions;
+ (NSSet *) variablesUsedInProgram:(id)program;
+ (NSDictionary *) testVariableValues:(NSString *) test;
+ (id) runProgram:(id)program;
+ (id) runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (NSString *)descriptionOfProgram:(id)program;
- (void) pushOperand: (double)operand;
- (void) pushOperation:(NSString *)operation;
- (void) removeLastObjectFromProgram;
- (void) clearAll;
- (NSString *) stackObjectAsString:(id)stackObject;
- (id) lastOnStack;
- (id) secondTolastOnStack;
@end
