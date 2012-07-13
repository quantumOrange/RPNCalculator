//
//  GraphView.h
//  Calculator
//
//  Created by David Crooks on 22/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GraphView;

@protocol GraphViewDataSource <NSObject>
- (float) functionOfx:(GraphView *) sender evaluatedAt: (float) x;
@end



@interface GraphView : UIView
@property (nonatomic) CGFloat scale;
@property (nonatomic) CGFloat axisSize;
@property (nonatomic) CGPoint axisOrigin;

- (void)pinch:(UIPinchGestureRecognizer *)gesture;
- (void)tapOrigin:(UITapGestureRecognizer *) gesture;
@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;
@end



