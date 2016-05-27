//
//  DRScrollView.m
//  dr-charts
//
//  Created by DHIREN THIRANI on 5/18/16.
//  Copyright © 2016 Product. All rights reserved.
//

#import "DRScrollView.h"

@implementation DRScrollView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view{
    return NO;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    // If not dragging, send event to next responder
    if (!self.dragging){
        [self.nextResponder touchesBegan: touches withEvent:event];
    }
    else{
        [super touchesBegan: touches withEvent: event];
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    // If not dragging, send event to next responder
    if (!self.dragging){
        [self.nextResponder touchesMoved: touches withEvent:event];
    }
    else{
        [super touchesMoved: touches withEvent: event];
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    // If not dragging, send event to next responder
    if (!self.dragging){
        [self.nextResponder touchesEnded: touches withEvent:event];
    }
    else{
        [super touchesEnded: touches withEvent: event];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    // If not dragging, send event to next responder
    if (!self.dragging){
        [self.nextResponder touchesCancelled: touches withEvent:event];
    }
    else{
        [super touchesCancelled: touches withEvent: event];
    }
}

@end
