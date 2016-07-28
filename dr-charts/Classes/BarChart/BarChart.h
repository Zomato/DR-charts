//
//  BarChart.h
//  dr-charts
//
//  Created by DHIREN THIRANI on 5/20/16.
//  Copyright © 2016 Product. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LegendView.h"

@protocol BarChartDelegate <NSObject>

- (void)didTapOnBarChartWithValue:(NSString *)value;

@end

@protocol BarChartDataSource <NSObject>

- (NSMutableArray *)xDataForBarChart;
//Set data for x-Axis for the Line Graph

- (NSInteger)numberOfBarsToBePlotted;
//Set number of items to be shown on the Bar Chart

- (UIColor *)colorForTheBarWithBarNumber:(NSInteger)barNumber;
//Set Color for each item in a Bar Chart
//Default Color is Black

- (CGFloat)widthForTheBarWithBarNumber:(NSInteger)barNumber;
//Set Width for each item in a Bar Chart
//Default Width 40.0F

- (NSString *)nameForTheBarWithBarNumber:(NSInteger)barNumber;
//Set Name for each item in a Bar Chart
//Default Name is Empty String

- (NSMutableArray *)yDataForBarWithBarNumber:(NSInteger)barNumber;
//Set y-Axis data for each item in a Bar Chart

@optional
- (UIView *)customViewForBarChartTouchWithValue:(NSNumber *)value;
//Set Custom View for touch on each item in a Bar Chart

@end

@interface BarChart : UIView

@property (nonatomic, strong) id<BarChartDataSource> dataSource;
@property (nonatomic, strong) id<BarChartDelegate> delegate;

//set FONT property for the graph
@property (nonatomic, strong) UIFont *textFont; //Default is [UIFont systemFontOfSize:12];
@property (nonatomic, strong) UIColor *textColor; //Default is [UIColor blackColor]
@property (nonatomic) CGFloat textFontSize; //Default is 12

//show GRID with the graph
@property (nonatomic) BOOL drawGridX; //Default is TRUE
@property (nonatomic) BOOL drawGridY; //Default is TRUE
//set property for the GRID
@property (nonatomic, strong) UIColor *gridLineColor; //Default is [UIColor lightGrayColor]
@property (nonatomic) CGFloat gridLineWidth; //Default is 0.3F

//show LEGEND with the graph
@property (nonatomic) BOOL showLegend; //Default is TRUE
//Set type of legend Horizontal or Vertical, default value is Vertical
@property (nonatomic) LegendType legendViewType; //Default is LegendTypeVertical

//show MARKER when interacting with graph
@property (nonatomic) BOOL showMarker; //Default is TRUE

//show CUSTOM MARKER when interacting with graph.
//If Both MARKER and CUSTOM MARKER view are True then CUSTOM MARKER View Priorties over MARKER View.
@property (nonatomic) BOOL showCustomMarkerView; //Default is FALSE

//To draw the graph
- (void)drawBarGraph;

//To reload data on the graph
- (void)reloadBarGraph;

@end
