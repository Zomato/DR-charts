//
//  PieChart.m
//  dr-charts
//
//  Created by DHIREN THIRANI on 4/5/16.
//  Copyright © 2016 Product. All rights reserved.
//

#import "PieChart.h"
#import "Constants.h"

@interface PieChartDataRenderer : NSObject

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *value;

@end

@interface PieChart(){
    CGFloat startAngle;
    CGFloat radius;
    CGPoint center;
    CGFloat height;
    
    CAShapeLayer *touchedLayer;
    CAShapeLayer *dataShapeLayer;
}

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *legendArray;
@property (nonatomic, strong) NSNumber *totalCount;
@property (nonatomic, strong) LegendView *legendView;
@property (nonatomic, strong) UIView *pieView;
@property (nonatomic, strong) UIView *customMarkerView;

@end

@implementation PieChart

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.dataArray = [[NSMutableArray alloc] init];
        self.legendArray = [[NSMutableArray alloc] init];
        
        self.textFontSize = 12;
        self.textFont = [UIFont systemFontOfSize:self.textFontSize];
        self.textColor = [UIColor blackColor];
        
        self.legendViewType = LegendTypeVertical;
        self.showLegend = TRUE;
        
        self.showValueOnPieSlice = TRUE;
        
        self.showMarker = TRUE;
        
        self.showCustomMarkerView = FALSE;
    }
    return self;
}

#pragma mark Get Data From Data Source
- (void)getDataFromDataSource{
    for(int i = 0; i <[self.dataSource numberOfValuesForPieChart] ; i++){
        PieChartDataRenderer *data = [[PieChartDataRenderer alloc] init];
        [data setColor:[self.dataSource colorForValueInPieChartWithIndex:i]];
        [data setTitle:[self.dataSource titleForValueInPieChartWithIndex:i]];
        [data setValue:[self.dataSource valueInPieChartWithIndex:i]];
        
        [self.dataArray addObject:data];
        
        self.totalCount = [NSNumber numberWithFloat:(self.totalCount.floatValue + data.value.floatValue)];
        
        LegendDataRenderer *legendData = [[LegendDataRenderer alloc] init];
        [legendData setLegendText:data.title];
        [legendData setLegendColor:data.color];
        [self.legendArray addObject:legendData];
    }
}

#pragma mark Draw Graph
- (void)drawPieChart{
    [self getDataFromDataSource];
    
    height = HEIGHT(self) - 2*INNER_PADDING;
    
    if (self.showLegend) {
        height = HEIGHT(self) - [LegendView getLegendHeightWithLegendArray:self.legendArray legendType:self.legendViewType withFont:self.textFont width:WIDTH(self) - 2*SIDE_PADDING] - 2*INNER_PADDING;
    }
    
    radius = (WIDTH(self) - 2*INNER_PADDING)/2;
    if (radius > (height - 2*INNER_PADDING)/2) {
        radius = (height - 2*INNER_PADDING)/2;
    }
    
    self.pieView = [[UIView alloc] initWithFrame:CGRectMake(0, INNER_PADDING, WIDTH(self), height)];
    
    center = self.pieView.center;
    
    startAngle = 0;

    for (PieChartDataRenderer *data in self.dataArray) {
        [self drawPathWithValue:data.value.floatValue color:data.color];
    }
    [self addSubview:self.pieView];
    
    if (self.showLegend) {
        [self createLegend];
    }
}

#pragma mark Draw Shape Layer
- (void)drawPathWithValue:(CGFloat)value color:(UIColor *)color{
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    [shapeLayer setPath:[[self drawArcWithValue:value] CGPath]];
    [shapeLayer setStrokeColor:color.CGColor];
    [shapeLayer setFillColor:color.CGColor];
    [shapeLayer setOpacity:0.7f];
    [shapeLayer setLineWidth:1.0f];
    [shapeLayer setValue:[NSString stringWithFormat:@"%0.2f",value] forKey:@"data"];

    [CATransaction begin];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    [pathAnimation setFromValue:[NSNumber numberWithFloat:0.0f]];
    [pathAnimation setToValue:[NSNumber numberWithFloat:1.0f]];
    
    CABasicAnimation *fillColorAnimation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
    [fillColorAnimation setFromValue:(id)[[UIColor clearColor] CGColor]];
    [fillColorAnimation setToValue:(id)[color CGColor]];
    
    CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
    [group setAnimations:[NSArray arrayWithObjects:pathAnimation,fillColorAnimation, nil]];
    [group setDuration:ANIMATION_DURATION];
    [group setFillMode:kCAFillModeBoth];
    [group setRemovedOnCompletion:FALSE];
    [group setBeginTime:CACurrentMediaTime()];
    [group setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    NSString *text = [NSString stringWithFormat:@"%0.2f%%",(value/self.totalCount.floatValue)*100];
    CGRect layerRect = CGPathGetBoundingBox(shapeLayer.path);
    NSAttributedString *attrString = [LegendView getAttributedString:text withFont:self.textFont];
    CGSize size = [attrString boundingRectWithSize:CGSizeMake(WIDTH(self), MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size;

    if (size.height < layerRect.size.height/2 && size.width < layerRect.size.width/2 && self.showValueOnPieSlice) {
        CGRect frame = CGRectMake(layerRect.origin.x + layerRect.size.width/2 - size.width/2, layerRect.origin.y + layerRect.size.height/2 - size.height/2, size.width, size.height);
        
        CATextLayer *textLayer = [[CATextLayer alloc] init];
        [textLayer setFont:CFBridgingRetain(self.textFont.fontName)];
        [textLayer setFontSize:self.textFontSize];
        [textLayer setFrame:frame];
        [textLayer setString:[NSString stringWithFormat:@"%@",text]];
        [textLayer setAlignmentMode:kCAAlignmentCenter];
        [textLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
        [textLayer setForegroundColor:[[UIColor whiteColor] CGColor]];
        [textLayer setShouldRasterize:YES];
        [textLayer setRasterizationScale:[[UIScreen mainScreen] scale]];
        [textLayer setContentsScale:[[UIScreen mainScreen] scale]];
        [shapeLayer addSublayer:textLayer];
    }
    
    [shapeLayer addAnimation:group forKey:@"animate"];
    
    [CATransaction commit];
    
    [self.pieView.layer addSublayer:shapeLayer];
}

- (UIBezierPath *)drawArcWithValue:(CGFloat)value{
    CGFloat endAngle = startAngle + (value/self.totalCount.floatValue)*360;

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:center];
    [path addLineToPoint:CGPointMake(center.x + radius * cosf(DEG2RAD(startAngle)), center.y + radius *sinf(DEG2RAD(startAngle)))];
    [path addArcWithCenter:center radius:radius startAngle:DEG2RAD(startAngle) endAngle:DEG2RAD(endAngle) clockwise:YES];
    [path addLineToPoint:center];
    
    startAngle = endAngle;
    return path;
}

#pragma mark Touch Action in a graph
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.showMarker || self.showCustomMarkerView) {
        CGPoint touchPoint = [[touches anyObject] locationInView:self.pieView];
        
        if(CGRectContainsPoint(self.pieView.frame, touchPoint)){
            CALayer *layer = [self.pieView.layer hitTest:touchPoint];
            for(CAShapeLayer *shapeLayer in layer.sublayers){
                if (CGPathContainsPoint(shapeLayer.path, 0, touchPoint, YES)) {
                    [shapeLayer setOpacity:1.0f];
                    [shapeLayer setShadowRadius:10.0f];
                    [shapeLayer setShadowColor:[[UIColor blackColor] CGColor]];
                    [shapeLayer setShadowOpacity:1.0f];
                    
                    touchedLayer = shapeLayer;
                    
                    NSString *data = [shapeLayer valueForKey:@"data"];
                    if (self.showCustomMarkerView) {
                        [self showCustomMarkerViewWithData:data withTouchedPoint:touchPoint];
                    }
                    else if(self.showMarker){
                        [self showMarkerWithData:data withTouchedPoint:touchPoint];
                    }
                    
                    if ([self.delegate respondsToSelector:@selector(didTapOnPieChartWithValue:)]) {
                        [self.delegate didTapOnPieChartWithValue:data];
                    }
                    
                    break;
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
- (void)showCustomMarkerViewWithData:(NSString *)data withTouchedPoint:(CGPoint)point{
    self.customMarkerView = [self.dataSource customViewForPieChartTouchWithValue:[NSNumber numberWithFloat:data.floatValue]];
    
    if (self.customMarkerView != nil) {
        CGFloat viewX = 0;
        if (point.x <= self.pieView.center.x) {
            viewX = self.pieView.center.x;
        }
        else{
            viewX = self.pieView.center.x - WIDTH(self.customMarkerView);
        }
        
        [self.customMarkerView setFrame:CGRectMake(viewX, self.pieView.center.y, WIDTH(self.customMarkerView), HEIGHT(self.customMarkerView))];
        [self.pieView addSubview:self.customMarkerView];
    }
}

#pragma mark Show Marker
- (void)showMarkerWithData:(NSString *)text withTouchedPoint:(CGPoint)point{
    NSAttributedString *attrString = [LegendView getAttributedString:text withFont:self.textFont];
    CGSize size = [attrString boundingRectWithSize:CGSizeMake(WIDTH(self), MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    CGFloat viewX = 0;
    if (point.x <= self.pieView.center.x) {
        viewX = self.pieView.center.x;
    }
    else{
        viewX = self.pieView.center.x - (size.width + 2*SIDE_PADDING);
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(viewX, self.pieView.center.y, size.width + 2*SIDE_PADDING, size.height) cornerRadius:3];
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
    
    [self.pieView.layer addSublayer:dataShapeLayer];
}

#pragma mark Create Legend
- (void) createLegend{
    self.legendView = [[LegendView alloc] initWithFrame:CGRectMake(SIDE_PADDING, BOTTOM(self.pieView), WIDTH(self) - 2*SIDE_PADDING, 0)];
    [self.legendView setLegendArray:self.legendArray];
    [self.legendView setFont:self.textFont];
    [self.legendView setTextColor:self.textColor];
    [self.legendView setLegendViewType:self.legendViewType];
    [self.legendView createLegend];
    [self addSubview:self.legendView];
}

#pragma mark Reload Chart
- (void)reloadPieChart{
    [self.pieView removeFromSuperview];
    [self.legendView removeFromSuperview];
    
    [self drawPieChart];
}

@end

@implementation PieChartDataRenderer

- (instancetype)init{
    self = [super init];
    if (self) {
        self.value = @0;
        self.title = @"";
        self.color = [UIColor blackColor];
    }
    return self;
}

@end