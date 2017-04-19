//
//  Constants.h
//  dr-charts
//
//  Created by DHIREN THIRANI on 5/23/16.
//  Copyright © 2016 Product. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define HEIGHT(v)                                       v.frame.size.height
#define WIDTH(v)                                        v.frame.size.width
#define BOTTOM(v)                                       (v.frame.origin.y + v.frame.size.height)
#define AFTER(v)                                        (v.frame.origin.x + v.frame.size.width)
#define PH                                              [[UIScreen mainScreen].bounds.size.height]
#define PW                                              [[UIScreen mainScreen].bounds.size.width]

#define INNER_PADDING 10
#define SIDE_PADDING 15
#define LEGEND_VIEW 15
#define OFFSET_X 30
#define OFFSET_Y 30
#define OFFSET_PADDING 5

#define DEG2RAD(angle) angle*M_PI/180.0

#define ANIMATION_DURATION 1.5f

#endif /* Constants_h */
