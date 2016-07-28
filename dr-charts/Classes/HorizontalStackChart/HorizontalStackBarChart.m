//
//  HorizontalStackBarChart.m
//  dr-charts
//
//  Created by DHIREN THIRANI on 3/10/16.
//  Copyright © 2016 Product. All rights reserved.
//

#import "HorizontalStackBarChart.h"
#import "Constants.h"

@interface HorizontalStackBarData : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) UIColor *color;

@end

@interface HorizontalStackBarChart(){
    double totalCount;
    CGFloat x;
    CGFloat height;
    
    CAShapeLayer *touchedLayer;
    CAShapeLayer *dataShapeLayer;
}

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *legendArray;

@property (nonatomic, strong) UIView *barView;
@property (nonatomic, strong) LegendView *legendView;
@property (nonatomic, strong) UIView *customMarkerView;

@end

@implementation HorizontalStackBarChart

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.textFontSize = 12;
        self.textFont = [UIFont systemFontOfSize:self.textFontSize];
        self.textColor = [UIColor blackColor];
        
        self.legendViewType = LegendTypeVertical;
        self.showLegend = TRUE;
        
        self.showValueOnBarSlice = TRUE;
        
        self.showMarker = TRUE;
        
        self.showCustomMarkerView = TRUE;
    }
    return self;
}

#pragma mark Get Data From Data Source
- (void)getDataFromDataSource{
    self.dataArray = [[NSMutableArray alloc] init];
    self.legendArray = [[NSMutableArray alloc] init];
    
    for (int i=0; i<[self.dataSource numberOfValuesForStackChart]; i++) {
        HorizontalStackBarData *chartData = [[HorizontalStackBarData alloc] init];
        [chartData setColor:[self.dataSource colorForValueInStackChartWithIndex:i]];
        [chartData setName:[self.dataSource titleForValueInStackChartWithIndex:i]];
        [chartData setCount:[self.dataSource valueInStackChartWithIndex:i]];
        
        totalCount += chartData.count.doubleValue;
        [self.dataArray addObject:chartData];
        
        LegendDataRenderer *data = [[LegendDataRenderer alloc] init];
        [data setLegendText:chartData.name];
        [data setLegendColor:chartData.color];
        [self.legendArray addObject:data];
    }
}

#pragma mark Draw Graph
- (void) drawStackChart{
    [self getDataFromDataSource];
    
    height = HEIGHT(self) - 2*INNER_PADDING;
    
    if (self.showLegend) {
        height = HEIGHT(self) - [LegendView getLegendHeightWithLegendArray:self.legendArray legendType:self.legendViewType withFont:self.textFont width:WIDTH(self) - 2*SIDE_PADDING] - 2*INNER_PADDING;
    }
    
    [self createStackChart];
    if (self.showLegend) {
        [self createLegend];
    }
}

- (void) createStackChart{
    self.barView = [[UIView alloc] initWithFrame:CGRectMake(SIDE_PADDING, INNER_PADDING, WIDTH(self) - 2*SIDE_PADDING, height)];
    
    x = 0;
    for (HorizontalStackBarData *chartData in self.dataArray) {
        [self drawPathWithValue:chartData.count.doubleValue color:chartData.color];
    }
    [self addSubview:self.barView];
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
    
    NSString *text = [NSString stringWithFormat:@"%0.2f%%",(value/totalCount)*100];
    CGRect layerRect = CGPathGetBoundingBox(shapeLayer.path);
    NSAttributedString *attrString = [LegendView getAttributedString:text withFont:self.textFont];
    CGSize size = [attrString boundingRectWithSize:CGSizeMake(WIDTH(self), MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    if (size.height < layerRect.size.height && size.width < layerRect.size.width && self.showValueOnBarSlice) {
        CATextLayer *textLayer = [[CATextLayer alloc] init];
        [textLayer setFont:CFBridgingRetain(self.textFont.fontName)];
        [textLayer setFontSize:self.textFontSize];
        [textLayer setFrame:CGRectMake(layerRect.origin.x + layerRect.size.width/2 - size.width/2, layerRect.origin.y + layerRect.size.height/2 - size.height/2, size.width, size.height)];
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
    
    [self.barView.layer addSublayer:shapeLayer];
}

- (UIBezierPath *)drawArcWithValue:(CGFloat)value{
    CGFloat width = (value/totalCount) * WIDTH(self.barView);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(x, 0)];
    [path addLineToPoint:CGPointMake(x, HEIGHT(self.barView))];
    [path addLineToPoint:CGPointMake(x + width, HEIGHT(self.barView))];
    [path addLineToPoint:CGPointMake(x + width, 0)];

    [path closePath];
    [path stroke];

    x += width;
    
    return path;
}

#pragma mark Touch Action On Graph
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.showMarker || self.showCustomMarkerView) {
        CGPoint touchPoint = [[touches anyObject] locationInView:self.barView];
        
        if(CGRectContainsPoint(self.barView.frame, touchPoint)){
            CALayer *layer = [self.barView.layer hitTest:touchPoint];
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
                    else if (self.showMarker){
                        [self showMarkerWithData:data withTouchedPoint:touchPoint];
                    }
                    
                    if ([self.delegate respondsToSelector:@selector(didTapOnHorizontalStackBarChartWithValue:)]) {
                        [self.delegate didTapOnHorizontalStackBarChartWithValue:data];
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
    self.customMarkerView = [self.dataSource customViewForStackChartTouchWithValue:[NSNumber numberWithFloat:data.floatValue]];
    
    if (self.customMarkerView != nil) {
        CGRect rect = CGPathGetBoundingBox(touchedLayer.path);

        CGFloat viewX = 0;
        if (point.x <= self.barView.center.x) {
            viewX = self.barView.center.x;
        }
        else{
            viewX = self.barView.center.x - WIDTH(self.customMarkerView);
        }
        
        [self.customMarkerView setFrame:CGRectMake(viewX, rect.origin.y, WIDTH(self.customMarkerView), HEIGHT(self.customMarkerView))];
        [self.barView addSubview:self.customMarkerView];
    }
}

#pragma mark Show Marker
- (void)showMarkerWithData:(NSString *)text withTouchedPoint:(CGPoint)point{
    CGRect rect = CGPathGetBoundingBox(touchedLayer.path);
    
    NSAttributedString *attrString = [LegendView getAttributedString:text withFont:self.textFont];
    CGSize size = [attrString boundingRectWithSize:CGSizeMake(WIDTH(self), MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size;

    CGFloat viewX = 0;
    if (point.x <= self.barView.center.x) {
        viewX = self.barView.center.x;
    }
    else{
        viewX = self.barView.center.x - size.width + 2*INNER_PADDING;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(viewX, rect.origin.y, size.width + 2*INNER_PADDING, size.height) cornerRadius:3];
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
    
    [self.barView.layer addSublayer:dataShapeLayer];
}

#pragma mark Create Legend
- (void) createLegend{
    self.legendView = [[LegendView alloc] initWithFrame:CGRectMake(SIDE_PADDING, BOTTOM(self.barView), WIDTH(self) - 2*SIDE_PADDING, 0)];
    [self.legendView setLegendArray:self.legendArray];
    [self.legendView setFont:self.textFont];
    [self.legendView setTextColor:self.textColor];
    [self.legendView setLegendViewType:self.legendViewType];
    [self.legendView createLegend];
    [self addSubview:self.legendView];
}

#pragma mark Reload Graph
- (void)reloadHorizontalStackGraph{
    [self.barView removeFromSuperview];
    [self.legendView removeFromSuperview];
    
    [self drawStackChart];
}

@end

@implementation HorizontalStackBarData

- (instancetype)init{
    self = [super init];
    if (self) {
        self.count = @0;
        self.name = @"";
        self.color = [UIColor blackColor];
    }
    return self;
}

@end