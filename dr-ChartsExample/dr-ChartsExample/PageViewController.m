//
//  PageViewController.m
//  dr-charts
//
//  Created by DHIREN THIRANI on 3/29/16.
//  Copyright © 2016 Product. All rights reserved.
//

#import "PageViewController.h"
#import "DrGraphs.h"

#define header_height 65

@interface PageViewController ()<MultiLineGraphViewDataSource, MultiLineGraphViewDelegate, PieChartDataSource, PieChartDelegate, HorizontalStackBarChartDataSource, HorizontalStackBarChartDelegate, BarChartDataSource, BarChartDelegate, CircularChartDataSource, CircularChartDelegate>

@end

@implementation PageViewController

- (instancetype)initWithChartType:(ChartType) type{
    self = [super init];
    if (self) {
        self.chartType = type;
        [self createView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)createView{
    [self createHeader];
    [self createGraph];
}

- (void)createHeader{
    [self.navigationItem setTitle:@"Charts"];
}

#pragma mark - Action Methods
- (void)leftButtonTapped{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) createGraph{
    switch (self.chartType) {
        case ChartTypeLine:
            [self createLineGraph];
            break;
        case ChartTypeHorizontalStack:
            [self createHorizontalStackChart];
            break;
        case ChartTypePie:
            [self createPieChart];
            break;
        case ChartTypeBar:
            [self createBarChart];
            break;
        case ChartTypeCircular:
            [self createCircularChart];
            break;
        default:
            break;
    }
}

#pragma Mark CreateLineGraph
- (void)createLineGraph{
    MultiLineGraphView *graph = [[MultiLineGraphView alloc] initWithFrame:CGRectMake(0, header_height, WIDTH(self.view), HEIGHT(self.view) - header_height)];
    [graph setDelegate:self];
    [graph setDataSource:self];
    [graph setLegendViewType:LegendTypeHorizontal];
    [graph drawGraph];
    [self.view addSubview:graph];
}

#pragma mark MultiLineGraphViewDataSource
- (NSMutableArray *)xDataForLineToBePlotted{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 30; i++) {
        [array addObject:[NSString stringWithFormat:@"%d june", i]];
    }
    return array;
}

- (NSInteger)numberOfLinesToBePlotted{
    return 4;
}

- (LineDrawingType)typeOfLineToBeDrawnWithLineNumber:(NSInteger)lineNumber{
    switch (lineNumber) {
        case 0:
            return LineDefault;
            break;
        case 1:
            return LineDefault;
            break;
        case 2:
            return LineParallelXAxis;
            break;
        case 3:
            return LineParallelYAxis;
            break;
        default:
            break;
    }
    return LineDefault;
}

- (UIColor *)colorForTheLineWithLineNumber:(NSInteger)lineNumber{
    NSInteger aRedValue = arc4random()%255;
    NSInteger aGreenValue = arc4random()%255;
    NSInteger aBlueValue = arc4random()%255;
    UIColor *randColor = [UIColor colorWithRed:aRedValue/255.0f green:aGreenValue/255.0f blue:aBlueValue/255.0f alpha:1.0f];
    return randColor;
}

- (CGFloat)widthForTheLineWithLineNumber:(NSInteger)lineNumber{
    return 1;
}

- (NSString *)nameForTheLineWithLineNumber:(NSInteger)lineNumber{
    return [NSString stringWithFormat:@"data %ld",(long)lineNumber];
}

- (BOOL)shouldFillGraphWithLineNumber:(NSInteger)lineNumber{
    switch (lineNumber) {
        case 0:
            return false;
            break;
        case 1:
            return true;
            break;
        case 2:
            return false;
            break;
        case 3:
            return true;
            break;
        default:
            break;
    }
    return false;
}

- (BOOL)shouldDrawPointsWithLineNumber:(NSInteger)lineNumber{
    switch (lineNumber) {
        case 0:
            return true;
            break;
        case 1:
            return false;
            break;
        case 2:
            return false;
            break;
        case 3:
            return false;
            break;
        default:
            break;
    }
    return false;
}

- (NSMutableArray *)dataForLineWithLineNumber:(NSInteger)lineNumber{
    switch (lineNumber) {
        case 0:
            {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                for (int i = 0; i < 30; i++) {
                    [array addObject:[NSNumber numberWithLong:random() % 100]];
                }
                return array;
            }
            break;
        case 1:
            {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                for (int i = 0; i < 30; i++) {
                    [array addObject:[NSNumber numberWithLong:random() % 50]];
                }
                return array;
            }
            break;
        case 2:
            {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                [array addObject:[NSNumber numberWithLong:random() % 100]];
                [array addObject:[NSNumber numberWithLong:random() % 100]];

                return array;
            }
            break;
        case 3:
            {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                [array addObject:[NSString stringWithFormat:@"%d", (int)(1000 + random() % 100)]];
                [array addObject:[NSString stringWithFormat:@"%d", (int)(1000 + random() % 100)]];
                return array;
            }
            break;
        default:
            break;
    }
    return [[NSMutableArray alloc] init];
}

#pragma mark MultiLineGraphViewDelegate
- (void)didTapWithValuesAtX:(NSString *)xValue valuesAtY:(NSString *)yValue{
    NSLog(@"Line Chart: Value-X:%@, Value-Y:%@",xValue, yValue);
}

#pragma Mark CreatePieChart
- (void)createPieChart{
    PieChart *chart = [[PieChart alloc] initWithFrame:CGRectMake(0, header_height, WIDTH(self.view), (HEIGHT(self.view) - header_height)/2)];
    [chart setDataSource:self];
    [chart setDelegate:self];
    [chart setLegendViewType:LegendTypeHorizontal];
    [chart drawPieChart];
    [self.view addSubview:chart];
}

#pragma mark PieChartDataSource
- (NSInteger)numberOfValuesForPieChart{
    return 15;
}

- (UIColor *)colorForValueInPieChartWithIndex:(NSInteger)lineNumber{
    NSInteger aRedValue = arc4random()%255;
    NSInteger aGreenValue = arc4random()%255;
    NSInteger aBlueValue = arc4random()%255;
    UIColor *randColor = [UIColor colorWithRed:aRedValue/255.0f green:aGreenValue/255.0f blue:aBlueValue/255.0f alpha:1.0f];
    return randColor;
}

- (NSString *)titleForValueInPieChartWithIndex:(NSInteger)index{
    return [NSString stringWithFormat:@"data %ld",(long)index];
}

- (NSNumber *)valueInPieChartWithIndex:(NSInteger)index{
    return [NSNumber numberWithLong:random() % 100];
}

#pragma mark PieChartDelegate
- (void)didTapOnPieChartWithValue:(NSString *)value{
    NSLog(@"Pie Chart: %@",value);
}

#pragma Mark CreateHorizontalChart
- (void)createHorizontalStackChart{
    HorizontalStackBarChart *chartView = [[HorizontalStackBarChart alloc] initWithFrame:CGRectMake(0, header_height, WIDTH(self.view), 150)];
    [chartView setDataSource:self];
    [chartView setDelegate:self];
    [chartView setLegendViewType:LegendTypeHorizontal];
    [chartView drawStackChart];
    [self.view addSubview:chartView];
}

#pragma mark HorizontalStackBarChartDataSource
- (NSInteger)numberOfValuesForStackChart{
    return 5;
}

- (UIColor *)colorForValueInStackChartWithIndex:(NSInteger)index{
    NSInteger aRedValue = arc4random()%255;
    NSInteger aGreenValue = arc4random()%255;
    NSInteger aBlueValue = arc4random()%255;
    UIColor *randColor = [UIColor colorWithRed:aRedValue/255.0f green:aGreenValue/255.0f blue:aBlueValue/255.0f alpha:1.0f];
    return randColor;
}

- (NSString *)titleForValueInStackChartWithIndex:(NSInteger)index{
    return [NSString stringWithFormat:@"data %ld",(long)index];
}

- (NSNumber *)valueInStackChartWithIndex:(NSInteger)index{
    return [NSNumber numberWithLong:random() % 100];
}

#pragma mark HorizontalStackBarChartDelegate
- (void)didTapOnHorizontalStackBarChartWithValue:(NSString *)value{
    NSLog(@"Horizontal Stack Chart: %@",value);
}

#pragma Mark CreateHorizontalChart
- (void)createBarChart{
    BarChart *barChartView = [[BarChart alloc] initWithFrame:CGRectMake(0, header_height, WIDTH(self.view), HEIGHT(self.view) - header_height)];
    [barChartView setDataSource:self];
    [barChartView setDelegate:self];
    [barChartView setLegendViewType:LegendTypeHorizontal];
    [barChartView drawBarGraph];

    [self.view addSubview:barChartView];
}

#pragma mark BarChartDataSource
- (NSMutableArray *)xDataForBarChart{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 20; i++) {
        [array addObject:[NSString stringWithFormat:@"%d", 2000 + i]];
    }
    return  array;
}

- (NSInteger)numberOfBarsToBePlotted{
    return 2;
}

- (UIColor *)colorForTheBarWithBarNumber:(NSInteger)barNumber{
    NSInteger aRedValue = arc4random()%255;
    NSInteger aGreenValue = arc4random()%255;
    NSInteger aBlueValue = arc4random()%255;
    UIColor *randColor = [UIColor colorWithRed:aRedValue/255.0f green:aGreenValue/255.0f blue:aBlueValue/255.0f alpha:1.0f];
    return randColor;
}

- (CGFloat)widthForTheBarWithBarNumber:(NSInteger)barNumber{
    return 40;
}

- (NSString *)nameForTheBarWithBarNumber:(NSInteger)barNumber{
    return [NSString stringWithFormat:@"Data %d",(int)barNumber];
}

- (NSMutableArray *)yDataForBarWithBarNumber:(NSInteger)barNumber{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 20; i++) {
        [array addObject:[NSNumber numberWithLong:random() % 100]];
    }
    return array;
}

#pragma mark BarChartDelegate
- (void)didTapOnBarChartWithValue:(NSString *)value{
    NSLog(@"Bar Chart: %@",value);
}

#pragma Mark CreatePieChart
- (void)createCircularChart{
    CircularChart *chart = [[CircularChart alloc] initWithFrame:CGRectMake(0, header_height, WIDTH(self.view), (HEIGHT(self.view) - header_height)/2)];
    [chart setDataSource:self];
    [chart setDelegate:self];
    [chart setLegendViewType:LegendTypeHorizontal];
    [chart drawPieChart];
    [self.view addSubview:chart];
}

#pragma mark CircularChartDataSource
- (CGFloat)strokeWidthForCircularChart{
    return 50;
}

- (NSInteger)numberOfValuesForCircularChart{
    return 2;
}

- (UIColor *)colorForValueInCircularChartWithIndex:(NSInteger)lineNumber{
    NSInteger aRedValue = arc4random()%255;
    NSInteger aGreenValue = arc4random()%255;
    NSInteger aBlueValue = arc4random()%255;
    UIColor *randColor = [UIColor colorWithRed:aRedValue/255.0f green:aGreenValue/255.0f blue:aBlueValue/255.0f alpha:1.0f];
    return randColor;
}

- (NSString *)titleForValueInCircularChartWithIndex:(NSInteger)index{
    return [NSString stringWithFormat:@"data %ld",(long)index];
}

- (NSNumber *)valueInCircularChartWithIndex:(NSInteger)index{
    return [NSNumber numberWithLong:random() % 100];
}

#pragma mark CircularChartDelegate
- (void)didTapOnCircularChartWithValue:(NSString *)value{
    NSLog(@"Circular Chart: %@",value);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end