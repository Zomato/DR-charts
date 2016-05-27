//
//  LineGraphMarker.m
//  dr-charts
//
//  Created by DHIREN THIRANI on 4/1/16.
//  Copyright © 2016 Product. All rights reserved.
//

#import "LineGraphMarker.h"
#import "Constants.h"

@interface LineGraphMarker()

@property (nonatomic, strong) UILabel *markerLabel;

@end

@implementation LineGraphMarker

- (instancetype)init{
    self = [super init];
    if (self) {
        self.markerLabel = [[UILabel alloc] init];
        [self addSubview:self.markerLabel];
    }
    return self;
}

- (void)drawAtPoint:(CGPoint)point{
    [self setBackgroundColor:self.bgColor];

    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    NSString *string = [NSString stringWithFormat:@"%@, %@ ", self.yString, self.xString];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    
    [attrString addAttributes:@{NSFontAttributeName:self.textFont , NSKernAttributeName : @(0.5), NSParagraphStyleAttributeName:paragraphStyle}
                        range:NSMakeRange(0, string.length)];
    
    [self.markerLabel setAttributedText:attrString];
    [self.markerLabel setTextColor:self.textColor];
    
    CGFloat height = MAXFLOAT;
    CGFloat width = MAXFLOAT;
    
    CGSize size = [attrString boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    [self.markerLabel setFrame:CGRectMake(5, 5, size.width, size.height)];
    
    CGFloat x = point.x - (WIDTH(self.markerLabel) + 10)/2;
//    if (x < 0) {
//        x = point.x;
//    }
//    else if(x + (WIDTH(self.markerLabel) + 10) > [UIScreen mainScreen].bounds.size.width){
//        x = point.x - (WIDTH(self.markerLabel) + 10);
//    }
    
    [self setFrame:CGRectMake(x, point.y - (HEIGHT(self.markerLabel) + 10), WIDTH(self.markerLabel) + 10, HEIGHT(self.markerLabel) + 10)];
}

@end