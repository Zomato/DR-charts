//
//  PageViewController.h
//  dr-charts
//
//  Created by DHIREN THIRANI on 3/29/16.
//  Copyright © 2016 Product. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PageViewController;

typedef enum{
    ChartTypeLine = 0,
    ChartTypeHorizontalStack,
    ChartTypePie,
    ChartTypeBar,
    ChartTypeCircular
}ChartType;

@interface PageViewController : UIViewController

@property (nonatomic) ChartType chartType;

- (instancetype)initWithChartType:(ChartType) type;

@end
