//
//  MultiLineGraphView.m
//  dr-charts
//
//  Created by DHIREN THIRANI on 3/29/16.
//  Copyright © 2016 Product. All rights reserved.
//

#import "MultiLineGraphView.h"
#import "LineGraphMarker.h"
#import "DRScrollView.h"
#import "Constants.h"

@interface LineChartDataRenderer : NSObject

@property (nonatomic, strong) NSMutableArray *yAxisArray;
@property (nonatomic, strong) NSMutableArray *xAxisArray;
@property (nonatomic) LineDrawingType lineType;

@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) NSString *graphName;

@property (nonatomic) CGFloat lineWidth;

@property (nonatomic) BOOL drawPoints;
@property (nonatomic) BOOL fillGraph;

@end

@interface MultiLineGraphView()<UIScrollViewDelegate>{
    float stepY;
    float stepX;
    
    NSString *selectedXData;
    NSString *selectedYData;
    CGPoint selectedPoint;
    
    CGFloat widht;
    CGFloat height;
    CGFloat lastScale;
    CGFloat scaleHeight;
}

@property (nonatomic, strong) LineGraphMarker *marker;
@property (nonatomic, strong) CAShapeLayer *xMarker;
@property (nonatomic, strong) CAShapeLayer *yMarker;
@property (nonatomic, strong) UIView *customMarkerView;

@property (nonatomic, strong) LegendView *legendView;
@property (nonatomic, strong) DRScrollView *graphScrollView;
@property (nonatomic, strong) UIView *graphView;

@property (nonatomic, strong) NSMutableArray *xAxisArray;
@property (nonatomic, strong) NSMutableArray *legendArray;
@property (nonatomic, strong) NSMutableArray *lineDataArray;

@end

@implementation MultiLineGraphView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.drawGridY = TRUE;
        self.drawGridX = TRUE;
        
        self.gridLineColor = [UIColor lightGrayColor];
        self.gridLineWidth = 0.3;
        
        self.textFontSize = 11;
        self.textColor = [UIColor blackColor];
        self.textFont = [UIFont systemFontOfSize:self.textFontSize];
        
        self.markerColor = [UIColor orangeColor];
        self.markerTextColor = [UIColor whiteColor];
        self.markerWidth = 0.4;
        
        self.showLegend = TRUE;
        self.legendViewType = LegendTypeVertical;
        
        self.showMarker = TRUE;
        
        self.showCustomMarkerView = FALSE;
        
        scaleHeight = 0;
        lastScale = 1;
    }
    return self;
}

#pragma mark Get Data From Data Source
- (void)getDataFromDataSource{
    self.xAxisArray = [[NSMutableArray alloc] init];
    self.lineDataArray = [[NSMutableArray alloc] init];
    self.legendArray = [[NSMutableArray alloc] init];
    
    for (int i = 0 ; i < [self.dataSource numberOfLinesToBePlotted]; i++) {
        LineChartDataRenderer *lineData = [[LineChartDataRenderer alloc] init];
        [lineData setLineType:[self.dataSource typeOfLineToBeDrawnWithLineNumber:i]];
        [lineData setLineColor:[self.dataSource colorForTheLineWithLineNumber:i]];
        [lineData setLineWidth:[self.dataSource widthForTheLineWithLineNumber:i]];
        [lineData setGraphName:[self.dataSource nameForTheLineWithLineNumber:i]];
        [lineData setFillGraph:[self.dataSource shouldFillGraphWithLineNumber:i]];
        [lineData setDrawPoints:[self.dataSource shouldDrawPointsWithLineNumber:i]];
        [lineData setXAxisArray:[self.dataSource dataForXAxisWithLineNumber:i]];
        [lineData setYAxisArray:[self.dataSource dataForYAxisWithLineNumber:i]];
        
        [self.lineDataArray addObject:lineData];
        
        LegendDataRenderer *data = [[LegendDataRenderer alloc] init];
        [data setLegendText:lineData.graphName];
        [data setLegendColor:lineData.lineColor];
        [self.legendArray addObject:data];
        
        if (self.xAxisArray.count < lineData.xAxisArray.count) {
            [self.xAxisArray removeAllObjects];
            [self.xAxisArray addObjectsFromArray:lineData.xAxisArray];
        }
    }
}

#pragma mark Draw Graph
- (void)drawGraph{
    widht = WIDTH(self);

    height = HEIGHT(self) - 2*INNER_PADDING;
    scaleHeight = height;
    
    [self getDataFromDataSource];
    
    if (self.showLegend) {
        height = HEIGHT(self) - [LegendView getLegendHeightWithLegendArray:self.legendArray legendType:self.legendViewType withFont:self.textFont width:WIDTH(self) - 2*SIDE_PADDING] - 2*INNER_PADDING;
        scaleHeight = height;
    }
    
    self.graphScrollView = [[DRScrollView alloc] initWithFrame:CGRectMake(0, INNER_PADDING, WIDTH(self), height)];
    [self.graphScrollView setScrollEnabled:YES];
    [self.graphScrollView setShowsVerticalScrollIndicator:NO];
    [self.graphScrollView setShowsHorizontalScrollIndicator:NO];
    [self.graphScrollView setDelegate:self];
    [self.graphScrollView setUserInteractionEnabled:YES];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGraphZoom:)];
    [self.graphScrollView addGestureRecognizer:pinchGesture];
    
    self.graphView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widht, height)];
    [self.graphView setUserInteractionEnabled:YES];
    
    [self createYAxisLine];
    [self createXAxisLine];
    [self createGraph];
    
    if (self.showMarker) {
        [self createMarker];
    }
    
    if (self.showLegend) {
        [self createLegend];
    }
    
    [self.graphView setNeedsDisplay];
    
    [self.graphScrollView addSubview:self.graphView];
    
    [self.graphScrollView setNeedsDisplay];
    [self addSubview:self.graphScrollView];
    [self.graphScrollView setContentSize:CGSizeMake(WIDTH(self.graphScrollView), scaleHeight)];
    
    [self setNeedsDisplay];

}

#pragma Draw Shape Layer
- (void)createYAxisLine{
    float minY = 0.0;
    float maxY = 0.0;
    
    for (LineChartDataRenderer *lineData in self.lineDataArray) {
        
        NSMutableArray *values = lineData.yAxisArray;
        
        for (int j = 0; j < [values count]; j++) {
            if ([[values objectAtIndex:j] isKindOfClass:[NSNull class]]) {
                continue;
            }
            
            if ([[values objectAtIndex:j] floatValue] > maxY) {
                maxY = [[values objectAtIndex:j] floatValue];
            }
            
            if ([[values objectAtIndex:j] floatValue] < minY) {
                minY = [[values objectAtIndex:j] floatValue];
            }
        }
    }
    
    int gridYCount = 5;
    
    if (scaleHeight > height) {
        gridYCount = ceil(gridYCount * lastScale);
    }
    
    float step = (maxY - minY) / gridYCount;

    stepY = (HEIGHT(self.graphView) - (OFFSET_Y * 2)) / (maxY - minY);
    
    for (int i = 0; i <= gridYCount; i++) {
        int y = (i * step) * stepY;
        float value = i * step + minY;
        
        CGPoint startPoint = CGPointMake(OFFSET_X, HEIGHT(self.graphView) - (y + OFFSET_Y));
        CGPoint endPoint = CGPointMake(WIDTH(self.graphView) - OFFSET_X, HEIGHT(self.graphView) - (y + OFFSET_Y));
        
        NSString *numberString = [NSString stringWithFormat:@"%.1f",value];
        
        BOOL drawGrid = TRUE;
        if (self.drawGridY) {
            drawGrid = TRUE;
        }
        else{
            if(i == 0 || i == gridYCount){
                drawGrid = TRUE;
            }
            else{
                drawGrid = FALSE;
            }
        }
        NSAttributedString *attrString = [LegendView getAttributedString:numberString withFont:self.textFont];
        CGSize size = [attrString boundingRectWithSize:CGSizeMake(OFFSET_X, MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size;

        [self drawLineForGridWithStartPoint:startPoint endPoint:endPoint text:numberString textFrame:CGRectMake(1, HEIGHT(self.graphView) - (y + OFFSET_Y + size.height/2), OFFSET_X - 1, size.height) drawGrid:drawGrid];
    }
}

- (void)createXAxisLine{
    float step = 0;
    NSInteger maxStep = [self.xAxisArray count];

    if ([self.xAxisArray count] > 5) {
        int stepCount = 5;
        
        if (widht > WIDTH(self)) {
            stepCount = ceil(stepCount * lastScale);
        }
    
        NSInteger count = [self.xAxisArray count] - 1;
        
        for (int i = 4; i < 8; i++) {
            if (count % i == 0) {
                stepCount = i;
                break;
            }
        }
        
        step = [self.xAxisArray count] / stepCount;
        maxStep = stepCount;
    } else {
        step = 1;
    }

    stepX = (WIDTH(self.graphView) - (OFFSET_X * 2)) / (self.xAxisArray.count - 1);
    
    for (int i = 0; i <= maxStep; i++) {
        int x = (i * step) * stepX;
        
        if (x > WIDTH(self.graphView) - (OFFSET_X * 2)) {
            x = WIDTH(self.graphView) - (OFFSET_X * 2);
        }

        NSInteger index = i * step;
        if (index >= self.xAxisArray.count){
            index = self.xAxisArray.count - 1;
        }
        
        CGPoint startPoint = CGPointMake(x + OFFSET_X, OFFSET_Y);
        CGPoint endPoint = CGPointMake(x + OFFSET_X, HEIGHT(self.graphView) - OFFSET_Y);

        BOOL drawGrid = TRUE;

        if (self.drawGridX) {
            drawGrid = TRUE;
        }
        else{
            if(i == 0 || i == maxStep){
                drawGrid = TRUE;
            }
            else{
                drawGrid = FALSE;
            }
        }
        NSAttributedString *attrString = [LegendView getAttributedString:[self.xAxisArray objectAtIndex:index] withFont:self.textFont];
        CGSize size = [attrString boundingRectWithSize:CGSizeMake(WIDTH(self) - LEGEND_VIEW, MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size;

        [self drawLineForGridWithStartPoint:startPoint endPoint:endPoint text:[self.xAxisArray objectAtIndex:index] textFrame:CGRectMake(x + size.width/2, HEIGHT(self.graphView) - (size.height + INNER_PADDING), size.width, size.height) drawGrid:drawGrid];
    }
}

- (void)createGraph{
    for (LineChartDataRenderer *lineData in self.lineDataArray) {
        switch (lineData.lineType) {
            case LineDefault:
                {
                    int x = 0;
                    int y = 0;
                    
                    NSInteger itemIndex = [self.xAxisArray indexOfObject:[lineData.xAxisArray objectAtIndex:0]];
                    
                    x = itemIndex * stepX;
                    y = [[lineData.yAxisArray objectAtIndex:0] floatValue] * stepY;
                    
                    CGPoint startPoint = CGPointMake(x + OFFSET_X, HEIGHT(self.graphView) - (OFFSET_Y + y));
                    CGPoint firstPoint = startPoint;
                    if (lineData.drawPoints) {
                        [self drawPointsOnLine:startPoint withColor:lineData.lineColor];
                    }
                    
                    UIBezierPath *path = [UIBezierPath bezierPath];
                    UIBezierPath *fillPath = [UIBezierPath bezierPath];
                    [fillPath moveToPoint:startPoint];
                    
                    CGPoint endPoint;
                    for (int i = 1; i < lineData.yAxisArray.count; i++){
                        NSInteger xIndex = [self.xAxisArray indexOfObject:[lineData.xAxisArray objectAtIndex:i]];
                        x = xIndex * stepX;
                        y = [[lineData.yAxisArray objectAtIndex:i] floatValue] * stepY;
                        
                        endPoint = CGPointMake(x + OFFSET_X, HEIGHT(self.graphView) - ( y + OFFSET_Y));
                        
                        [path appendPath:[self drawPathWithStartPoint:startPoint endPoint:endPoint]];

                        [fillPath addLineToPoint:endPoint];
                        
                        startPoint = endPoint;
                        if (lineData.drawPoints) {
                            [self drawPointsOnLine:startPoint withColor:lineData.lineColor];
                        }
                    }
                    
                    [path closePath];
                    [path stroke];
                    
                    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
                    [shapeLayer setPath:[path CGPath]];
                    [shapeLayer setStrokeColor:lineData.lineColor.CGColor];
                    [shapeLayer setLineWidth:lineData.lineWidth];
                    [shapeLayer setShouldRasterize:YES];
                    [shapeLayer setRasterizationScale:[[UIScreen mainScreen] scale]];
                    [shapeLayer setContentsScale:[[UIScreen mainScreen] scale]];
                    
                    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
                    [pathAnimation setDuration:ANIMATION_DURATION];
                    [pathAnimation setFromValue:[NSNumber numberWithFloat:0.0f]];
                    [pathAnimation setToValue:[NSNumber numberWithFloat:1.0f]];
                    [shapeLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
                    
                    [self.graphView.layer addSublayer:shapeLayer];
                    
                    if (lineData.fillGraph) {
                        [fillPath addLineToPoint:CGPointMake(startPoint.x, HEIGHT(self.graphView) - OFFSET_Y)];
                        [fillPath addLineToPoint:CGPointMake(firstPoint.x, HEIGHT(self.graphView) - OFFSET_Y)];
                        [fillPath addLineToPoint:firstPoint];
                        [fillPath closePath];
                        [fillPath stroke];
                        
                        [self fillGraphBackgroundWithPath:fillPath color:lineData.lineColor];
                    }
                }
                break;
            case LineParallelXAxis:
                {
                    int y = 0;
                    
                    for (int i = 0; i < lineData.yAxisArray.count; i++){
                        y = [[lineData.yAxisArray objectAtIndex:i] floatValue] * stepY;

                        CGPoint startPoint = CGPointMake(OFFSET_X, HEIGHT(self.graphView) - (OFFSET_Y + y));
                        CGPoint endPoint = CGPointMake(WIDTH(self.graphView) - OFFSET_X, HEIGHT(self.graphView) - (OFFSET_Y + y));
                        
                        CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
                        [shapeLayer setPath:[[self drawPathWithStartPoint:startPoint endPoint:endPoint] CGPath]];
                        [shapeLayer setStrokeColor:lineData.lineColor.CGColor];
                        [shapeLayer setLineWidth:lineData.lineWidth];
                        [shapeLayer setShouldRasterize:YES];
                        [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInteger:6], nil]];
                        [shapeLayer setRasterizationScale:[[UIScreen mainScreen] scale]];
                        [shapeLayer setContentsScale:[[UIScreen mainScreen] scale]];
                        [self.graphView.layer addSublayer:shapeLayer];
                    }
                    
                    if (lineData.fillGraph) {
                        
                        y = [[lineData.yAxisArray firstObject] floatValue] * stepY;
                        CGPoint point1 = CGPointMake(OFFSET_X, HEIGHT(self.graphView) - (OFFSET_Y + y));
                        
                        y = [[lineData.yAxisArray lastObject] floatValue] * stepY;
                        CGPoint point2 = CGPointMake(WIDTH(self.graphView) - OFFSET_X, HEIGHT(self.graphView) - (OFFSET_Y + y));
                        
                        UIBezierPath *fillPath = [UIBezierPath bezierPath];
                        [fillPath moveToPoint:point1];
                        [fillPath addLineToPoint:CGPointMake(point1.x, point2.y)];
                        [fillPath addLineToPoint:point2];
                        [fillPath addLineToPoint:CGPointMake(point2.x, point1.y)];
                        
                        [fillPath closePath];
                        [fillPath stroke];
                        
                        [self fillGraphBackgroundWithPath:fillPath color:lineData.lineColor];
                    }
                }
                break;
            case LineParallelYAxis:
                {
                    int x = 0;
                    
                    for (int i = 0; i < lineData.xAxisArray.count; i++){
                        NSInteger itemIndex = [self.xAxisArray indexOfObject:[lineData.xAxisArray objectAtIndex:i]];
                        x = itemIndex * stepX;
                        
                        CGPoint startPoint = CGPointMake(OFFSET_X + x, OFFSET_Y);
                        CGPoint endPoint = CGPointMake(OFFSET_X + x, HEIGHT(self.graphView) - OFFSET_Y);
                        
                        CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
                        [shapeLayer setPath:[[self drawPathWithStartPoint:startPoint endPoint:endPoint] CGPath]];
                        [shapeLayer setStrokeColor:lineData.lineColor.CGColor];
                        [shapeLayer setLineWidth:lineData.lineWidth];
                        [shapeLayer setShouldRasterize:YES];
                        [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInteger:6], nil]];
                        [shapeLayer setRasterizationScale:[[UIScreen mainScreen] scale]];
                        [shapeLayer setContentsScale:[[UIScreen mainScreen] scale]];
                        [self.graphView.layer addSublayer:shapeLayer];
                    }
                    
                    if (lineData.fillGraph) {
                        
                        NSInteger itemIndex = [self.xAxisArray indexOfObject:[lineData.xAxisArray firstObject]];
                        x = itemIndex * stepX;
                        CGPoint point1 = CGPointMake(OFFSET_X + x, OFFSET_Y);
    
                        itemIndex = [self.xAxisArray indexOfObject:[lineData.xAxisArray lastObject]];
                        x = itemIndex * stepX;
                        CGPoint point2 = CGPointMake(OFFSET_X + x, HEIGHT(self.graphView) - OFFSET_Y);
                        
                        UIBezierPath *fillPath = [UIBezierPath bezierPath];
                        [fillPath moveToPoint:point1];
                        [fillPath addLineToPoint:CGPointMake(point1.x, point2.y)];
                        [fillPath addLineToPoint:point2];
                        [fillPath addLineToPoint:CGPointMake(point2.x, point1.y)];
                        
                        [fillPath closePath];
                        [fillPath stroke];
                        
                        [self fillGraphBackgroundWithPath:fillPath color:lineData.lineColor];                    }
                }
                break;
            default:
                break;
        }
    }
}

#pragma mark Create Marker
- (void)createMarker{
    self.marker = [[LineGraphMarker alloc] init];
    [self.marker setHidden:YES];
    [self.marker setFrame:CGRectZero];
    [self.marker setBgColor:self.markerColor];
    [self.marker setTextColor:self.markerTextColor];
    [self.marker setTextFont:self.textFont];
    [self.graphScrollView addSubview:self.marker];
    
    self.xMarker = [[CAShapeLayer alloc] init];
    [self.xMarker setStrokeColor:self.markerColor.CGColor];
    [self.xMarker setLineWidth:self.markerWidth];
    [self.xMarker setName:@"x_marker_layer"];
    [self.xMarker setHidden:YES];
    [self.graphScrollView.layer addSublayer:self.xMarker];
    
    self.yMarker = [[CAShapeLayer alloc] init];
    [self.yMarker setStrokeColor:self.markerColor.CGColor];
    [self.yMarker setLineWidth:self.markerWidth];
    [self.yMarker setName:@"y_marker_layer"];
    [self.yMarker setHidden:YES];
    [self.graphScrollView.layer addSublayer:self.yMarker];
}

- (void) createLegend{
    self.legendView = [[LegendView alloc] initWithFrame:CGRectMake(SIDE_PADDING, BOTTOM(self.graphView), WIDTH(self) - 2*SIDE_PADDING, 0)];
    [self.legendView setLegendArray:self.legendArray];
    [self.legendView setFont:self.textFont];
    [self.legendView setTextColor:self.textColor];
    [self.legendView setLegendViewType:self.legendViewType];
    [self.legendView createLegend];
    [self addSubview:self.legendView];
}

#pragma mark Touch Event on Graph
- (void)handleGraphZoom:(UIPinchGestureRecognizer *)gesture{
    
    CGFloat pinchscale = [gesture scale];

    if (gesture.state == UIGestureRecognizerStateEnded)  {
        CGFloat pastScale = lastScale;
        
        widht = pinchscale * widht;
        scaleHeight = height;
        
        lastScale = pinchscale;
        
        if (widht <= WIDTH(self)) {
            widht = WIDTH(self);
            scaleHeight = height;
            lastScale = 1;
        }
        
        if (pastScale != lastScale) {
            [self zoomGraph];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.showMarker || self.showCustomMarkerView) {
        UITouch *touch = [touches anyObject];
        CGPoint pointTouched = [touch locationInView:self.graphView];
        
        CGRect graphFrame = CGRectMake(OFFSET_X, OFFSET_Y, WIDTH(self.graphView) - 2*OFFSET_X, HEIGHT(self.graphView) - 2*OFFSET_Y);
        if (CGRectContainsPoint(graphFrame, pointTouched)) {
            [self hideMarker];
            NSLog(@"%f, %f",pointTouched.x, pointTouched.y);
            [self findValueForTouch:touch];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(didBeganTouchOnGraph)]) {
        [self.delegate didBeganTouchOnGraph];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.showMarker || self.showCustomMarkerView) {
        UITouch *touch = [touches anyObject];
        CGPoint pointTouched = [touch locationInView:self];
        
        [self hideMarker];
        
        CGRect graphFrame = CGRectMake(OFFSET_X, OFFSET_Y, WIDTH(self.graphView) - 2*OFFSET_X, HEIGHT(self.graphView) - 2*OFFSET_Y);
        if (CGRectContainsPoint(graphFrame, pointTouched)) {
            NSLog(@"%f, %f",pointTouched.x, pointTouched.y);
            [self findValueForTouch:touch];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(didBeganTouchOnGraph)]) {
        [self.delegate didBeganTouchOnGraph];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.showMarker || self.showCustomMarkerView) {
        [self hideMarker];
    }
    
    if ([self.delegate respondsToSelector:@selector(didEndTouchOnGraph)]) {
        [self.delegate didEndTouchOnGraph];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.showMarker || self.showCustomMarkerView) {
        [self hideMarker];
    }
    
    if ([self.delegate respondsToSelector:@selector(didEndTouchOnGraph)]) {
        [self.delegate didEndTouchOnGraph];
    }
}

- (void)zoomGraph{
    [self.graphView removeFromSuperview];
    
    self.graphView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widht, scaleHeight)];
    [self.graphView setUserInteractionEnabled:YES];
    
    [self createYAxisLine];
    [self createXAxisLine];
    [self createGraph];
    
    [self.graphView setNeedsDisplay];
    
    [self.graphScrollView addSubview:self.graphView];
    
    [self.graphScrollView setNeedsDisplay];
    
    [self addSubview:self.graphScrollView];
    [self.graphScrollView setContentSize:CGSizeMake(widht, scaleHeight)];
    
    [self setNeedsDisplay];
}

#pragma mark Touch Action on a touch in a graph
- (void)findValueForTouch:(UITouch *)touch{
    CGPoint pointTouched = [touch locationInView:self.graphView];

    NSString *xData;
    NSString *yData;
    CGPoint closestPoint = CGPointZero;
    CGFloat minDistance = HEIGHT(self.graphView);

    for (LineChartDataRenderer *lineData in self.lineDataArray) {
        if (lineData.lineType == LineDefault) {
            int x = 0;
            int y = 0;

            for (int i = 0; i < lineData.yAxisArray.count; i++){
                NSInteger xIndex = [self.xAxisArray indexOfObject:[lineData.xAxisArray objectAtIndex:i]];
                x = xIndex * stepX;
                y = [[lineData.yAxisArray objectAtIndex:i] floatValue] * stepY;
                
                CGPoint point = CGPointMake(x + OFFSET_X, HEIGHT(self.graphView) - ( y + OFFSET_Y));
                
                CGFloat distance = fabs([self distanceBetweenPoint:pointTouched andPoint:point]);
                
                if (distance < minDistance) {
                    xData = [lineData.xAxisArray objectAtIndex:i];
                    yData = [lineData.yAxisArray objectAtIndex:i];
                    minDistance = distance;
                    closestPoint = point;
                }
            }
        }
    }
    
    if (!CGPointEqualToPoint(closestPoint, CGPointZero)) {
        NSLog(@"x = %@, y = %@",xData,yData);
        
        selectedXData = xData;
        selectedYData = yData;
        selectedPoint = closestPoint;
        
        [self.xMarker setPath:[[self drawPathWithStartPoint:CGPointMake(closestPoint.x, HEIGHT(self.graphView) - OFFSET_Y) endPoint:CGPointMake(closestPoint.x, OFFSET_Y)] CGPath]];
        [self.xMarker setHidden:NO];
        
        [self.yMarker setPath:[[self drawPathWithStartPoint:CGPointMake(OFFSET_X, closestPoint.y) endPoint:CGPointMake(WIDTH(self.graphView) - OFFSET_X, closestPoint.y)] CGPath]];
        [self.yMarker setHidden:NO];

        if (self.showCustomMarkerView){
            [self.marker setHidden:YES];
            [self.marker removeFromSuperview];
            
            self.customMarkerView = [self.dataSource customViewForLineChartTouchWithXValue:xData andYValue:yData];
            
            if (selectedPoint.x + WIDTH(self.customMarkerView) > self.graphScrollView.contentSize.width) {
                selectedPoint.x -= WIDTH(self.customMarkerView);
            }
            
            if (self.customMarkerView != nil) {
                
                [self.customMarkerView setFrame:CGRectMake(selectedPoint.x, 0, WIDTH(self.customMarkerView), HEIGHT(self.customMarkerView))];
                [self.graphView addSubview:self.customMarkerView];
                [self.graphView bringSubviewToFront:self.customMarkerView];
            }
        }
        else if (self.showMarker) {
            [self.marker setXString:selectedXData];
            [self.marker setYString:selectedYData];
            [self.marker drawAtPoint:CGPointMake(selectedPoint.x, OFFSET_Y)];
            [self.marker setHidden:NO];
        }
        
        [self setNeedsDisplay];
        
        if ([self.delegate respondsToSelector:@selector(didTapWithValuesAtX:valuesAtY:)]) {
            [self.delegate didTapWithValuesAtX:selectedXData valuesAtY:selectedYData];
        }
    }
}

- (CGFloat)distanceBetweenPoint:(CGPoint)a andPoint:(CGPoint)b{
    CGFloat a2 = powf(a.x-b.x, 2.f);
    CGFloat b2 = powf(a.y-b.y, 2.f);
    return sqrtf(a2 + b2);
}

- (void)hideMarker{
    if (self.showCustomMarkerView){
        [self.customMarkerView removeFromSuperview];
    }
    else if (self.showMarker) {
        [self.marker setHidden:YES];
        [self.marker setFrame:CGRectZero];
    }
    
    [self.xMarker setHidden:YES];
    [self.yMarker setHidden:YES];
    
    [self setNeedsDisplay];
}

#pragma mark Fill Graph
- (void)fillGraphBackgroundWithPath:(UIBezierPath *)path color:(UIColor *)color{
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    [shapeLayer setPath:path.CGPath];
    [shapeLayer setFillColor:color.CGColor];
    [shapeLayer setOpacity:0.1];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"fill"];
    [pathAnimation setDuration:ANIMATION_DURATION];
    [pathAnimation setFillMode:kCAFillModeForwards];
    [pathAnimation setFromValue:(id)[[UIColor clearColor] CGColor]];
    [pathAnimation setToValue:(id)[color CGColor]];
    [pathAnimation setBeginTime:CACurrentMediaTime()];
    [pathAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];

    [shapeLayer addAnimation:pathAnimation forKey:@"fill"];
    
    [self.graphView.layer addSublayer:shapeLayer];
}

#pragma mark Draw Grid Lines
- (void)drawLineForGridWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint text:(NSString *)text textFrame:(CGRect)frame drawGrid:(BOOL)draw{
    
    if (draw) {
        CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
        [shapeLayer setPath:[[self drawPathWithStartPoint:startPoint endPoint:endPoint] CGPath]];
        [shapeLayer setStrokeColor:self.gridLineColor.CGColor];
        [shapeLayer setLineWidth:self.gridLineWidth];
        [self.graphView.layer addSublayer:shapeLayer];
    }
    
    CATextLayer *textLayer = [[CATextLayer alloc] init];
    [textLayer setFont:(__bridge CFTypeRef _Nullable)self.textFont];
    [textLayer setFontSize:self.textFontSize];
    [textLayer setFrame:frame];
    [textLayer setString:text];
    [textLayer setAlignmentMode:kCAAlignmentCenter];
    [textLayer setForegroundColor:self.textColor.CGColor];
    [textLayer setShouldRasterize:YES];
    [textLayer setRasterizationScale:[[UIScreen mainScreen] scale]];
    [textLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [textLayer setWrapped:YES];
    [self.graphView.layer addSublayer:textLayer];
}

#pragma mark Create a Path Between 2 points
- (UIBezierPath *)drawPathWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    
    [path closePath];
    [path stroke];
    
    return path;
}

#pragma mark Draw Point On the Line
- (void)drawPointsOnLine:(CGPoint)point withColor:(UIColor *)color{
    UIBezierPath *pointPath = [UIBezierPath bezierPath];
    [pointPath addArcWithCenter:point radius:3 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    [shapeLayer setPath:pointPath.CGPath];
    [shapeLayer setStrokeColor:[UIColor whiteColor].CGColor];
    [shapeLayer setFillColor:color.CGColor];
    [shapeLayer setLineWidth:1.0];
    [shapeLayer setShouldRasterize:YES];
    [shapeLayer setRasterizationScale:[[UIScreen mainScreen] scale]];
    [shapeLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [self.graphView.layer addSublayer:shapeLayer];
}

#pragma Reload Graph
- (void)reloadGraph{
    [self.graphScrollView removeFromSuperview];
    [self.legendView removeFromSuperview];
    
    [self drawGraph];
}

@end

@implementation LineChartDataRenderer

- (instancetype)init{
    self = [super init];
    if (self) {
        self.yAxisArray = [[NSMutableArray alloc] init];
        self.xAxisArray = [[NSMutableArray alloc] init];
        self.lineType = LineDefault;
        self.lineWidth = 1.0f;
        self.lineColor = [UIColor blackColor];
        self.graphName = @"";
        self.drawPoints = FALSE;
        self.fillGraph = FALSE;
    }
    return self;
}

@end
