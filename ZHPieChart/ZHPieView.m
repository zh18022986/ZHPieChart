//
//  ZHPieView.m
//  ZHPieChart
//
//  Created by zhouhao on 16/1/15.
//  Copyright © 2016年 zhouhao. All rights reserved.
//

#import "ZHPieView.h"
#import "MagicPieLayer.h"
CGFloat const gestureMinimumTranslation = 20.0;

@interface ZHPieView ()
{
    CGPoint panNormalizedVector;
    PieElement* panPieElem;
    float panStartCenterOffsetElem;
    float panStartDotProduct;
}
@end

@implementation ZHPieView

+ (Class)layerClass
{
    return [PieLayer class];
}

- (id)init
{
    self = [super init];
    if(self){
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.layer.maxRadius = 120;
    self.layer.minRadius = 80;
    self.layer.animationDuration = 0.6;
    self.layer.showTitles = ShowTitlesNever;
    if ([self.layer.self respondsToSelector:@selector(setContentsScale:)])
    {
        self.layer.contentsScale = [[UIScreen mainScreen] scale];
    }
    
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tap];
}

//点击向外移动20
- (void)handleTap:(UITapGestureRecognizer*)tap
{
    if(tap.state != UIGestureRecognizerStateEnded)
        return;
    
    CGPoint pos = [tap locationInView:tap.view];
    PieElement* tappedElem = [self.layer pieElemInPoint:pos];
    if(!tappedElem)
        return;
    
    if(tappedElem.centrOffset > 0)
        tappedElem = nil;
    [PieElement animateChanges:^{
        for(PieElement* elem in self.layer.values){
            elem.centrOffset = tappedElem==elem? 20 : 0;
        }
    }];
}
@end
