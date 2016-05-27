//
//  LineGraphMarker.h
//  dr-charts
//
//  Created by DHIREN THIRANI on 4/1/16.
//  Copyright © 2016 Product. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LineGraphMarker : UIView

@property (nonatomic, strong) NSString *xString;
@property (nonatomic, strong) NSString *yString;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *textFont;

- (void)drawAtPoint:(CGPoint)point;

@end
