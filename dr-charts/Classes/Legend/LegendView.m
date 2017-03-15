//
//  LegendView.m
//  dr-charts
//
//  Created by DHIREN THIRANI on 4/1/16.
//  Copyright © 2016 Product. All rights reserved.
//

#import "LegendView.h"
#import "Constants.h"

@implementation LegendView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.legendArray = [[NSMutableArray alloc] init];
        self.font = [UIFont systemFontOfSize:12];
    }
    return self;
}

- (void)createLegend{
    CGFloat height = INNER_PADDING;
    if (self.legendViewType == LegendTypeVertical) {
        for (LegendDataRenderer *legendData in self.legendArray) {
            if (legendData.legendText.length) {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, height, LEGEND_VIEW, LEGEND_VIEW)];
                [view setBackgroundColor:legendData.legendColor];
                [self addSubview:view];
                
                NSAttributedString *attrString = [LegendView getAttributedString:legendData.legendText withFont:self.font];
                CGSize size = [attrString boundingRectWithSize:CGSizeMake(WIDTH(self) - WIDTH(view), MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size;
                
                UILabel *label = [[UILabel alloc] init];
                [label setNumberOfLines:0];
                [label setTextColor:self.textColor];
                [label setAttributedText:attrString];
                [label setFrame:CGRectMake(AFTER(view) + OFFSET_PADDING, height, WIDTH(self) - WIDTH(view), size.height)];
                [self addSubview:label];
                
                if (size.height > LEGEND_VIEW) {
                    height = height + size.height + INNER_PADDING;
                    
                }
                else{
                    height = height + LEGEND_VIEW + INNER_PADDING;
                }
            }
        }
        
        CGRect frame = self.frame;
        frame.size.height = height;
        [self setFrame:frame];
    }
    else if (self.legendViewType == LegendTypeHorizontal){
        CGFloat width = 0;
        CGFloat x = 0;
        
        for (LegendDataRenderer *legendData in self.legendArray) {
            if (legendData.legendText.length) {
                NSAttributedString *attrString = [LegendView getAttributedString:legendData.legendText withFont:self.font];
                CGSize size = [attrString boundingRectWithSize:CGSizeMake(WIDTH(self) - LEGEND_VIEW, MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size;
                
                width += LEGEND_VIEW + size.width + INNER_PADDING + OFFSET_PADDING;
                
                if (width >= WIDTH(self)) {
                    height += LEGEND_VIEW + INNER_PADDING;
                    width = LEGEND_VIEW + size.width + INNER_PADDING + OFFSET_PADDING;
                    x = 0;
                }
                
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x, height, LEGEND_VIEW, LEGEND_VIEW)];
                [view setBackgroundColor:legendData.legendColor];
                [self addSubview:view];
                
                UILabel *label = [[UILabel alloc] init];
                [label setNumberOfLines:0];
                [label setTextColor:self.textColor];
                [label setAttributedText:attrString];
                [label setFrame:CGRectMake(AFTER(view) + OFFSET_PADDING, height, size.width, size.height)];
                [self addSubview:label];
                
                x = width;
            }
        }
        height += LEGEND_VIEW + INNER_PADDING;

        CGRect frame = self.frame;
        frame.size.height = height;
        [self setFrame:frame];
    }
    
}

+ (NSMutableAttributedString *)getAttributedString:(NSString *)tinyText withFont:(UIFont *)font {
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:tinyText];
    
    [attrString addAttributes:@{NSFontAttributeName:font}
                        range:NSMakeRange(0, tinyText.length)];
    
    return  attrString;
}

+ (CGFloat)getLegendHeightWithLegendArray:(NSMutableArray *)legendArray legendType:(LegendType)type withFont:(UIFont *)font width:(CGFloat)viewWidth{
    CGFloat height = 0;
    height += INNER_PADDING;
    
    if (type == LegendTypeVertical) {
        for (LegendDataRenderer *legendData in legendArray){
            NSAttributedString *attrString = [LegendView getAttributedString:legendData.legendText withFont:font];
            CGSize size = [attrString boundingRectWithSize:CGSizeMake(viewWidth - LEGEND_VIEW, MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size;

            if (size.height > LEGEND_VIEW) {
                height = height + size.height + INNER_PADDING;

            }
            else{
                height = height + LEGEND_VIEW + INNER_PADDING;
            }
        }
    }
    else if (type == LegendTypeHorizontal){
        CGFloat width = 0;
        CGFloat x = 0;
        
        for (LegendDataRenderer *legendData in legendArray){
            NSAttributedString *attrString = [LegendView getAttributedString:legendData.legendText withFont:font];
            CGSize size = [attrString boundingRectWithSize:CGSizeMake(viewWidth - LEGEND_VIEW, MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
            x = width;
            width += LEGEND_VIEW + size.width + INNER_PADDING + OFFSET_PADDING;
            
            if (width >= viewWidth) {
                height = height + LEGEND_VIEW + INNER_PADDING;
                width = LEGEND_VIEW + size.width + INNER_PADDING + OFFSET_PADDING;
                x = 0;
            }
        }
        height += LEGEND_VIEW + INNER_PADDING;
    }
    return height;
}

@end

@implementation LegendDataRenderer

@end
