//
//  MultiLineGraphView.h
//  dr-charts
//
//  Created by DHIREN THIRANI on 3/29/16.
//  Copyright © 2016 Product. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LegendView.h"

typedef enum {
    LineParallelXAxis,
    LineParallelYAxis,
    LineDefault
}LineDrawingType;

@protocol MultiLineGraphViewDelegate  <NSObject>

- (void)didTapWithValuesAtX:(NSString *)xValue valuesAtY:(NSString *)yValue;
//Returns, the touched point values

@optional
- (void)didBeganTouchOnGraph;

@optional
- (void)didEndTouchOnGraph;

@end

@protocol MultiLineGraphViewDataSource  <NSObject>

- (NSInteger)numberOfLinesToBePlotted;
//Set number of lines to be plotted on the Line Graph

- (LineDrawingType)typeOfLineToBeDrawnWithLineNumber:(NSInteger)lineNumber;
//Set Line Type for each for Line on the Line Graph
//Default is LineDefault

- (UIColor *)colorForTheLineWithLineNumber:(NSInteger)lineNumber;
//Set Line Color for each for Line on the Line Graph
//Default is Black Color

- (CGFloat)widthForTheLineWithLineNumber:(NSInteger)lineNumber;
//Set Line Width for each for Line on the Line Graph
//Default is 1.0F

- (NSString *)nameForTheLineWithLineNumber:(NSInteger)lineNumber;
//Set Line Name for each for Line on the Line Graph
//Default is Empty String

- (BOOL)shouldFillGraphWithLineNumber:(NSInteger)lineNumber;
//Set Fill Property for each for Line on the Line Graph
//Default is False

- (BOOL)shouldDrawPointsWithLineNumber:(NSInteger)lineNumber;
//Set Draw Points Property for each for Line on the Line Graph
//Default is False

- (NSMutableArray *)dataForYAxisWithLineNumber:(NSInteger)lineNumber;
//Set yData for Line on Line Graph When Line Type is LineDefault & LineParallelXAxis
//If LineType is LineParallelYAxis, Set yData as empty array

- (NSMutableArray *)dataForXAxisWithLineNumber:(NSInteger)lineNumber;
//Set xData for Line on Line Graph for corresponding yData
//If LineType is LineParallelYAxis, Set xData for the Line on Line Graph

@optional
- (UIView *)customViewForLineChartTouchWithXValue:(id)xValue andYValue:(id)yValue;
//Set Custom View for touch on each item in a Line Chart

@end

@interface MultiLineGraphView : UIView

@property (nonatomic, strong) id<MultiLineGraphViewDelegate> delegate;
@property (nonatomic, strong) id<MultiLineGraphViewDataSource> dataSource;

//set FONT property for the graph
@property (nonatomic, strong) UIFont *textFont; //Default is [UIFont systemFontOfSize:textFontSize];
@property (nonatomic, strong) UIColor *textColor; //Default is [UIColor blackColor]
@property (nonatomic) CGFloat textFontSize; //Default is 12

//show Grid with the graph
@property (nonatomic) BOOL drawGridX; //Default is TRUE
@property (nonatomic) BOOL drawGridY; //Default is TRUE
//set property for the grid
@property (nonatomic, strong) UIColor *gridLineColor; //Default is [UIColor lightGrayColor]
@property (nonatomic) CGFloat gridLineWidth; //Default is 0.3F

//show MARKER when interacting with graph
@property (nonatomic) BOOL showMarker; //Default is TRUE

//show CUSTOM MARKER when interacting with graph.
//If Both MARKER and CUSTOM MARKER view are True then CUSTOM MARKER View Priorties over MARKER View.
@property (nonatomic) BOOL showCustomMarkerView; //Default is FALSE

//to set marker property
@property (nonatomic, strong) UIColor *markerColor; //Default is [UIColor orangeColor]
@property (nonatomic, strong) UIColor *markerTextColor; //Default is [UIColor whiteColor]
@property (nonatomic) CGFloat markerWidth; //Default is 0.4F

//show LEGEND with the graph
@property (nonatomic) BOOL showLegend; //Default is TRUE
//Set LEGEND TYPE Horizontal or Vertical
@property (nonatomic) LegendType legendViewType; //Default is LegendTypeVertical i.e. VERTICAL

//To draw the graph
- (void)drawGraph;

//To reload data on the graph
- (void)reloadGraph;

@end
