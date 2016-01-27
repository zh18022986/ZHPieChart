//
//  ZHPieView.h
//  ZHPieChart
//
//  Created by zhouhao on 16/1/15.
//  Copyright © 2016年 zhouhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PieElement.h"
#import "PieLayer.h"

@interface ZHPieView : UIView

@property (nonatomic, copy) void(^elemTapped)(PieElement*);

@end

@interface ZHPieView (ex)

@property(nonatomic,readonly,retain) PieLayer *layer;

@end