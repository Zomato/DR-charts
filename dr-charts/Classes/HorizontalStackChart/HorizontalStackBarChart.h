//
//  HorizontalStackBarChart.h
//  dr-charts
//
//  Created by DHIREN THIRANI on 3/10/16.
//  Copyright © 2016 Product. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LegendView.h"

@protocol HorizontalStackBarChartDelegate <NSObject>

- (void)didTapOnHorizontalStackBarChartWithValue:(NSString *)value;

@end

@protocol HorizontalStackBarChartDataSource  <NSObject>

- (NSInteger)numberOfValuesForStackChart;
//Set number of items to be shown on the Stack Chart

- (UIColor *)colorForValueInStackChartWithIndex:(NSInteger)index;
//Set Color for each item in a Stack Chart
//Default Color is Black

- (NSString *)titleForValueInStackChartWithIndex:(NSInteger)index;
//Set Title for each item in a Stack Chart
//Default Title is Empty String

- (NSNumber *)valueInStackChartWithIndex:(NSInteger)index;
//Set Value for each item in a Stack Chart

@optional
- (UIView *)customViewForStackChartTouchWithValue:(NSNumber *)value;
//Set Custom View for touch on each item in a Stack Chart

@end

@interface HorizontalStackBarChart : UIView

@property (nonatomic, strong) id<HorizontalStackBarChartDataSource> dataSource;
@property (nonatomic, strong) id<HorizontalStackBarChartDelegate> delegate;

//set FONT property for the graph
@property (nonatomic, strong) UIFont *textFont; //Default is [UIFont systemFontOfSize:textFontSize];
@property (nonatomic, strong) UIColor *textColor; //Default is [UIColor blackColor]
@property (nonatomic) CGFloat textFontSize; //Default is 12

//show LEGEND with the graph
@property (nonatomic) BOOL showLegend; //Default is TRUE
//Set LEGEND TYPE Horizontal or Vertical
@property (nonatomic) LegendType legendViewType; //Default is LegendTypeVertical i.e. VERTICAL

//show Value on Bar Slice with the graph
@property (nonatomic) BOOL showValueOnBarSlice; //Default is TRUE

//show MARKER when interacting with graph
@property (nonatomic) BOOL showMarker; //Default is TRUE

//show CUSTOM MARKER when interacting with graph.
//If Both MARKER and CUSTOM MARKER view are True then CUSTOM MARKER View Priorties over MARKER View.
@property (nonatomic) BOOL showCustomMarkerView; //Default is FALSE

//To draw the graph
- (void)drawStackChart;

//To reload data on the graph
- (void)reloadHorizontalStackGraph;

@end

