//
//  BarChart.m
//  dr-charts
//
//  Created by DHIREN THIRANI on 5/20/16.
//  Copyright © 2016 Product. All rights reserved.
//

#import "BarChart.h"
#import "DRScrollView.h"
#import "Constants.h"

@interface BarChartDataRenderer : NSObject

@property (nonatomic, strong) NSMutableArray *yAxisArray;
@property (nonatomic, strong) UIColor *barColor;
@property (nonatomic, strong) NSString *graphName;
@property (nonatomic) CGFloat barWidth;

@end

@interface BarChart()<UIScrollViewDelegate>{
    float stepY;
    float stepX;
    
    CGFloat widht;
    CGFloat height;
    
    CAShapeLayer *touchedLayer;
    CAShapeLayer *dataShapeLayer;
}

@property (nonatomic, strong) LegendView *legendView;
@property (nonatomic, strong) DRScrollView *graphScrollView;
@property (nonatomic, strong) UIView *graphView;
@property (nonatomic, strong) UIView *customMarkerView;

@property (nonatomic, strong) NSMutableArray *xAxisArray;
@property (nonatomic, strong) NSMutableArray *legendArray;
@property (nonatomic, strong) NSMutableArray *barDataArray;

@end

@implementation BarChart

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.drawGridY = TRUE;
        self.drawGridX = TRUE;
        
        self.gridLineColor = [UIColor lightGrayColor];
        self.gridLineWidth = 0.3;
        
        self.textFontSize = 12;
        self.textColor = [UIColor blackColor];
        self.textFont = [UIFont systemFontOfSize:self.textFontSize];
        
        self.showLegend = TRUE;
        self.legendViewType = LegendTypeVertical;
        
        self.showMarker = TRUE;
        
        self.showCustomMarkerView = FALSE;
    }
    return self;
}

#pragma mark Get Data From Data Source
- (void)getDataFromDataSource{
    self.xAxisArray = [[NSMutableArray alloc] init];
    self.barDataArray = [[NSMutableArray alloc] init];
    self.legendArray = [[NSMutableArray alloc] init];
    
    stepX = 0;
    
    self.xAxisArray= [self.dataSource xDataForBarChart];
    for (int i = 0 ; i < [self.dataSource numberOfBarsToBePlotted]; i++) {
        BarChartDataRenderer *barData = [[BarChartDataRenderer alloc] init];
        [barData setBarColor:[self.dataSource colorForTheBarWithBarNumber:i]];
        [barData setBarWidth:[self.dataSource widthForTheBarWithBarNumber:i]];
        [barData setGraphName:[self.dataSource nameForTheBarWithBarNumber:i]];
        [barData setYAxisArray:[self.dataSource yDataForBarWithBarNumber:i]];
        
        [self.barDataArray addObject:barData];
        
        stepX += barData.barWidth;
        
        LegendDataRenderer *data = [[LegendDataRenderer alloc] init];
        [data setLegendText:barData.graphName];
        [data setLegendColor:barData.barColor];
        [self.legendArray addObject:data];
    }
    
    stepX += 20;
}

#pragma mark Draw Graph
- (void)drawBarGraph{
    widht = WIDTH(self);
    height = HEIGHT(self) - 2*INNER_PADDING;
    
    [self getDataFromDataSource];
    
    widht = (stepX * self.xAxisArray.count) + (OFFSET_X * 2);
    
    if (widht < WIDTH(self) && stepX < WIDTH(self)/self.xAxisArray.count) {
        widht = WIDTH(self);
        
        stepX = WIDTH(self)/self.xAxisArray.count;
    }
    
    if (self.showLegend) {
        height = HEIGHT(self) - [LegendView getLegendHeightWithLegendArray:self.legendArray legendType:self.legendViewType withFont:self.textFont width:WIDTH(self) - 2*SIDE_PADDING] - 2*INNER_PADDING;
    }
    
    self.graphScrollView = [[DRScrollView alloc] initWithFrame:CGRectMake(0, INNER_PADDING, WIDTH(self), height)];
    [self.graphScrollView setScrollEnabled:YES];
    [self.graphScrollView setShowsVerticalScrollIndicator:NO];
    [self.graphScrollView setShowsHorizontalScrollIndicator:NO];
    [self.graphScrollView setDelegate:self];
    [self.graphScrollView setUserInteractionEnabled:YES];
    
    self.graphView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widht, height)];
    [self.graphView setUserInteractionEnabled:YES];
    
    [self createYAxisLine];
    [self createXAxisLine];
    [self createGraph];
    
    if (self.showLegend) {
        [self createLegend];
    }
    
    [self.graphView setNeedsDisplay];

    [self addSubview:self.graphView];
    
    [self.graphScrollView addSubview:self.graphView];
    
    [self.graphScrollView setNeedsDisplay];
    [self addSubview:self.graphScrollView];
    [self.graphScrollView setContentSize:CGSizeMake(widht, height)];
    
    [self setNeedsDisplay];
}

#pragma mark Draw Shape Layer
- (void)createYAxisLine{
    float minY = 0.0;
    float maxY = 0.0;
    
    for (BarChartDataRenderer *barData in self.barDataArray) {
        
        NSMutableArray *values = barData.yAxisArray;
        
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
    
    float step = (maxY - minY) / gridYCount;
    
    stepY = (HEIGHT(self.graphView) - (OFFSET_Y * 2)) / (maxY - minY);
    
    for (int i = 0; i <= gridYCount; i++) {
        int y = (i * step) * stepY;
        float value = i * step + minY;
        
        CGPoint startPoint = CGPointMake(OFFSET_X, HEIGHT(self.graphView) - (y + OFFSET_Y));
        CGPoint endPoint = CGPointMake(WIDTH(self.graphView) - OFFSET_X, HEIGHT(self.graphView) - (y + OFFSET_Y));
        
        NSString *numberString = [NSString stringWithFormat:@"%d",(int)value];
        
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
        CGSize size = [attrString boundingRectWithSize:CGSizeMake(WIDTH(self) - LEGEND_VIEW, MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size;

        [self drawLineForGridWithStartPoint:startPoint endPoint:endPoint text:numberString textFrame:CGRectMake(INNER_PADDING, HEIGHT(self.graphView) -(y + OFFSET_Y + INNER_PADDING), size.width, size.height) drawGrid:drawGrid];
    }
}

- (void)createXAxisLine{
    NSInteger maxStep = [self.xAxisArray count];
    
    for (int i = 0; i <= maxStep; i++) {
        int x = i * stepX;
        NSInteger index = i;
        
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
        
        NSString *text = @"";
        if (i == maxStep) {
            text = @"";
        }
        else{
            text = [self.xAxisArray objectAtIndex:index];
        }
        
        NSAttributedString *attrString = [LegendView getAttributedString:text withFont:self.textFont];
        CGSize size = [attrString boundingRectWithSize:CGSizeMake(WIDTH(self) - LEGEND_VIEW, MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        [self drawLineForGridWithStartPoint:startPoint endPoint:endPoint text:text textFrame:CGRectMake(x + size.width/2, HEIGHT(self.graphView) - (size.height + INNER_PADDING), size.width, size.height) drawGrid:drawGrid];
    }
}

- (void)createGraph{
    CGFloat barWidth = 0;
    for (BarChartDataRenderer *barData in self.barDataArray) {
        int x = 0;
        int y = 0;
                
        CGPoint startPoint;
        CGPoint endPoint;
        
        for (int i = 0; i < barData.yAxisArray.count; i++){
            x = i * stepX;
            y = [[barData.yAxisArray objectAtIndex:i] floatValue] * stepY;
            
            startPoint = CGPointMake(x+OFFSET_X + barWidth + barData.barWidth, HEIGHT(self.graphView) - (OFFSET_Y + y));
            endPoint = CGPointMake(x+OFFSET_X + barWidth, HEIGHT(self.graphView) - OFFSET_Y);
            
            CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
            [shapeLayer setPath:[[self drawBarPathWithStartPoint:endPoint endPoint:startPoint] CGPath]];
            [shapeLayer setStrokeColor:[barData.barColor CGColor]];
            [shapeLayer setFillColor:[barData.barColor CGColor]];
            [shapeLayer setFillRule:kCAFillRuleEvenOdd];
            [shapeLayer setLineWidth:0.5f];
            [shapeLayer setOpacity:0.7f];
            [shapeLayer setShadowRadius:0.0f];
            [shapeLayer setShadowColor:[[UIColor clearColor] CGColor]];
            [shapeLayer setShadowOpacity:0.0f];
            [shapeLayer setValue:[barData.yAxisArray objectAtIndex:i] forKey:@"data"];
            
            [CATransaction begin];
            
            CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            [pathAnimation setFromValue:[NSNumber numberWithFloat:0.0f]];
            [pathAnimation setToValue:[NSNumber numberWithFloat:1.0f]];
            
            CABasicAnimation *fillColorAnimation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
            [fillColorAnimation setFromValue:(id)[[UIColor clearColor] CGColor]];
            [fillColorAnimation setToValue:(id)[barData.barColor CGColor]];
            
            CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
            [group setAnimations:[NSArray arrayWithObjects:pathAnimation,fillColorAnimation, nil]];
            [group setDuration:ANIMATION_DURATION];
            [group setFillMode:kCAFillModeBoth];
            [group setRemovedOnCompletion:FALSE];
            [group setBeginTime:CACurrentMediaTime()];
            [group setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            
            [shapeLayer addAnimation:group forKey:@"animate"];
            
            [CATransaction commit];
            
            [self.graphView.layer addSublayer:shapeLayer];
        }
        barWidth = barData.barWidth;
    }
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

- (UIBezierPath *)drawBarPathWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(startPoint.x, startPoint.y, endPoint.x - startPoint.x, endPoint.y - startPoint.y)];
  
    [path closePath];
    [path stroke];
    
    return path;
}

#pragma mark Touch Action On Graph
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.showMarker || self.showCustomMarkerView) {
        CGPoint touchPoint = [[touches anyObject] locationInView:self.graphView];
        
        if(CGRectContainsPoint(self.graphView.frame, touchPoint)){
            CALayer *layer = [self.graphView.layer hitTest:touchPoint];
            for(CAShapeLayer *shapeLayer in layer.sublayers){
                if ([shapeLayer isKindOfClass:[CAShapeLayer class]]){
                    if (CGPathContainsPoint(shapeLayer.path, 0, touchPoint, NO)) {
                        [shapeLayer setOpacity:1.0f];
                        [shapeLayer setShadowRadius:10.0f];
                        [shapeLayer setShadowColor:[[UIColor blackColor] CGColor]];
                        [shapeLayer setShadowOpacity:1.0f];
                        
                        touchedLayer = shapeLayer;
                        
                        NSString *data = [shapeLayer valueForKey:@"data"];
                        
                        if (self.showCustomMarkerView) {
                            [self showCustomMarkerViewWithData:data];
                        }
                        else if (self.showMarker){
                            [self showMarkerWithData:data];
                        }
                        
                        if ([self.delegate respondsToSelector:@selector(didTapOnBarChartWithValue:)]) {
                            [self.delegate didTapOnBarChartWithValue:data];
                        }
                        break;
                    }
                }
            }
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.showCustomMarkerView) {
        [touchedLayer setOpacity:0.7f];
        [touchedLayer setShadowRadius:0.0f];
        [touchedLayer setShadowColor:[[UIColor clearColor] CGColor]];
        [touchedLayer setShadowOpacity:0.0f];
        
        [self.customMarkerView removeFromSuperview];
    }
    else if (self.showMarker) {
        [touchedLayer setOpacity:0.7f];
        [touchedLayer setShadowRadius:0.0f];
        [touchedLayer setShadowColor:[[UIColor clearColor] CGColor]];
        [touchedLayer setShadowOpacity:0.0f];
        
        [dataShapeLayer removeFromSuperlayer];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.showCustomMarkerView) {
        [touchedLayer setOpacity:0.7f];
        [touchedLayer setShadowRadius:0.0f];
        [touchedLayer setShadowColor:[[UIColor clearColor] CGColor]];
        [touchedLayer setShadowOpacity:0.0f];
        
        [self.customMarkerView removeFromSuperview];
    }
    else if (self.showMarker) {
        [touchedLayer setOpacity:0.7f];
        [touchedLayer setShadowRadius:0.0f];
        [touchedLayer setShadowColor:[[UIColor clearColor] CGColor]];
        [touchedLayer setShadowOpacity:0.0f];
        
        [dataShapeLayer removeFromSuperlayer];
    }
}

#pragma mark Show Custom Marker
- (void)showCustomMarkerViewWithData:(NSString *)data{
    self.customMarkerView = [self.dataSource customViewForBarChartTouchWithValue:[NSNumber numberWithFloat:data.floatValue]];
    
    if (self.customMarkerView != nil) {
        CGRect rect = CGPathGetBoundingBox(touchedLayer.path);

        [self.customMarkerView setFrame:CGRectMake(rect.origin.x, rect.origin.y - HEIGHT(self.customMarkerView), WIDTH(self.customMarkerView), HEIGHT(self.customMarkerView))];
        [self.graphView addSubview:self.customMarkerView];
    }
}

#pragma mark Show Marker
- (void)showMarkerWithData:(NSString *)text{
    CGRect rect = CGPathGetBoundingBox(touchedLayer.path);
    
    NSAttributedString *attrString = [LegendView getAttributedString:[NSString stringWithFormat:@"%@",text] withFont:self.textFont];
    CGSize size = [attrString boundingRectWithSize:CGSizeMake(WIDTH(self), MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size;

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(rect.origin.x, rect.origin.y - size.height, size.width + 2*INNER_PADDING, size.height) cornerRadius:3];
    [path closePath];
    [path stroke];
    
    dataShapeLayer = [[CAShapeLayer alloc] init];
    [dataShapeLayer setPath:[path CGPath]];
    [dataShapeLayer setBackgroundColor:[[UIColor whiteColor] CGColor]];
    [dataShapeLayer setFillColor:[[UIColor whiteColor] CGColor]];
    [dataShapeLayer setStrokeColor:[[UIColor whiteColor] CGColor]];
    [dataShapeLayer setLineWidth:3.0F];
    [dataShapeLayer setShadowRadius:5.0f];
    [dataShapeLayer setShadowColor:[[UIColor blackColor] CGColor]];
    [dataShapeLayer setShadowOpacity:1.0f];
    
    CATextLayer *textLayer = [[CATextLayer alloc] init];
    [textLayer setFont:CFBridgingRetain(self.textFont.fontName)];
    [textLayer setFontSize:self.textFontSize];
    [textLayer setFrame:CGPathGetBoundingBox(dataShapeLayer.path)];
    [textLayer setString:[NSString stringWithFormat:@"%@",text]];
    [textLayer setAlignmentMode:kCAAlignmentCenter];
    [textLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
    [textLayer setForegroundColor:[self.textColor CGColor]];
    [textLayer setShouldRasterize:YES];
    [textLayer setRasterizationScale:[[UIScreen mainScreen] scale]];
    [textLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [dataShapeLayer addSublayer:textLayer];
    
    [self.graphView.layer addSublayer:dataShapeLayer];
}

#pragma mark Create Legend
- (void) createLegend{
    self.legendView = [[LegendView alloc] initWithFrame:CGRectMake(SIDE_PADDING, BOTTOM(self.graphView), WIDTH(self) - 2*SIDE_PADDING, 0)];
    [self.legendView setLegendArray:self.legendArray];
    [self.legendView setFont:self.textFont];
    [self.legendView setTextColor:self.textColor];
    [self.legendView setLegendViewType:self.legendViewType];
    [self.legendView createLegend];
    [self addSubview:self.legendView];
}

#pragma mark Reload Graph
- (void)reloadBarGraph{
    [self.graphScrollView removeFromSuperview];
    [self.legendView removeFromSuperview];
    
    [self drawBarGraph];
}

@end

@implementation BarChartDataRenderer

- (instancetype)init{
    self = [super init];
    if (self) {
        self.yAxisArray = [[NSMutableArray alloc] init];
        self.barWidth = 40.0f;
        self.barColor = [UIColor blackColor];
        self.graphName = @"";
    }
    return self;
}

@end
