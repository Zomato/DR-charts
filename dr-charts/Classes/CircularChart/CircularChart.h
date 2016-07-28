//
//  CircularChart.h
//  dr-charts
//
//  Created by DHIREN THIRANI on 5/22/16.
//  Copyright © 2016 Product. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LegendView.h"

@protocol CircularChartDelegate <NSObject>

- (void)didTapOnCircularChartWithValue:(NSString *)value;

@end

@protocol CircularChartDataSource <NSObject>

- (CGFloat)strokeWidthForCircularChart;
//Set Width of the stroke for the Circular Chart, i.e. thickness of the Circular Chart
//Default is 20.0F

- (NSInteger)numberOfValuesForCircularChart;
//Set number of items to be shown on the Circular Chart

- (UIColor *)colorForValueInCircularChartWithIndex:(NSInteger)index;
//Set Color for each item in a Circular Chart
//Default Color Black

- (NSString *)titleForValueInCircularChartWithIndex:(NSInteger)index;
//Set Tiltle for each item in a Circular Chart
//Default Title is Empty String

- (NSNumber *)valueInCircularChartWithIndex:(NSInteger)index;
//Set Value for each item in a Circular Chart
//Default value is 0

@optional
- (UIView *)customViewForCircularChartTouchWithValue:(NSNumber *)value;
//Set Custom View for touch on each item in a Circular Chart

@end

@interface CircularChart : UIView

@property (nonatomic, strong) id<CircularChartDataSource> dataSource;
@property (nonatomic, strong) id<CircularChartDelegate> delegate;

//set FONT property for the graph
@property (nonatomic, strong) UIFont *textFont; //Default is [UIFont systemFontOfSize:12];
@property (nonatomic, strong) UIColor *textColor; //Default is [UIColor blackColor]
@property (nonatomic) CGFloat textFontSize; //Default is 12

//show LEGEND with the graph
@property (nonatomic) BOOL showLegend; //Default is TRUE
//Set LEGEND TYPE Horizontal or Vertical
@property (nonatomic) LegendType legendViewType; //Default is LegendTypeVertical i.e. VERTICAL

//show MARKER when interacting with graph
@property (nonatomic) BOOL showMarker; //Default is TRUE

//show CUSTOM MARKER when interacting with graph.
//If Both MARKER and CUSTOM MARKER view are True then CUSTOM MARKER View Priorties over MARKER View.
@property (nonatomic) BOOL showCustomMarkerView; //Default is FALSE

//To draw the graph
- (void)drawCircularChart;

//To reload data on the graph
- (void)reloadCircularChart;

@end
