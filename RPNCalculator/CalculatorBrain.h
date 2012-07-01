//
//  CalculatorBrain.h
//  RPNCalculator
//
//  Created by David Crooks on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject
- (void) pushOperand: (double)operand;
- (double)performOperation: (NSString *) operation;
- (void) clearAll;
@end
