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


typedef enum :NSInteger {
    
    kCameraMoveDirectionNone,
    
    kCameraMoveDirectionUp,
    
    kCameraMoveDirectionDown,
    
    kCameraMoveDirectionRight,
    
    kCameraMoveDirectionLeft
    
} CameraMoveDirection;

@interface ZHPieView ()
{
    CGPoint panNormalizedVector;
    PieElement* panPieElem;
    float panStartCenterOffsetElem;
    float panStartDotProduct;
        CameraMoveDirection direction;
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
    
//    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
//    pan.maximumNumberOfTouches = 1;
//    [self addGestureRecognizer:pan];
    
//    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
//    recognizer.maximumNumberOfTouches = 1;
//    [self addGestureRecognizer:recognizer];
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

//- (void)handlePan:(UIPanGestureRecognizer*)pan
//{
//    CGPoint pos = [pan locationInView:pan.view];
//    CGPoint center = CGPointMake(pan.view.frame.size.width / 2, pan.view.frame.size.height / 2);
//    if(pan.state == UIGestureRecognizerStateBegan){
//        panPieElem = [self.layer pieElemInPoint:pos];
//        panStartCenterOffsetElem = panPieElem.centrOffset;
//        
//        CGPoint vec = CGPointMake(pos.x - center.x, pos.y - center.y);
//        float distance = sqrtf(pow(vec.x, 2.0) + pow(vec.y, 2.0));
//        panNormalizedVector = CGPointMake(vec.x / distance, vec.y / distance);
//        panStartDotProduct = distance;
//    } else if(pan.state == UIGestureRecognizerStateChanged){
//        CGPoint currPoint = CGPointMake(pos.x - center.x, pos.y - center.y);
//        float dotProduct = currPoint.x * panNormalizedVector.x + currPoint.y * panNormalizedVector.y;
//        panPieElem.centrOffset = MAX(0.0, dotProduct - panStartDotProduct + panStartCenterOffsetElem);
//    } else if(pan.state == UIGestureRecognizerStateEnded){
//        panPieElem = nil;
//    }
//}


// This is my gesture recognizer handler, which detects movement in a particular

// direction, conceptually tells a camera to start moving in that direction

// and when the user lifts their finger off the screen, tells the camera to stop.

- (void)handleSwipe:(UIPanGestureRecognizer *)gesture

{
    
    CGPoint translation = [gesture translationInView:gesture.view];
    
    if (gesture.state ==UIGestureRecognizerStateBegan)
        
    {
        
        direction = kCameraMoveDirectionNone;
        
    }
    
    else if (gesture.state == UIGestureRecognizerStateChanged && direction == kCameraMoveDirectionNone)
        
    {
        
        direction = [self determineCameraDirectionIfNeeded:translation];
        
        
        // ok, now initiate movement in the direction indicated by the user's gesture
        
        switch (direction) {
                
            case kCameraMoveDirectionDown:
                
                NSLog(@"Start moving down");
                
                break;
                
            case kCameraMoveDirectionUp:
                
                NSLog(@"Start moving up");
                
                break;
                
            case kCameraMoveDirectionRight:
                
                NSLog(@"Start moving right");
                
                break;
                
            case kCameraMoveDirectionLeft:
                
                NSLog(@"Start moving left");
                
                break;
                
            default:
                
                break;
        }
    }
    
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        // now tell the camera to stop
        NSLog(@"Stop");
    }
}

// This method will determine whether the direction of the user's swipe

- (CameraMoveDirection)determineCameraDirectionIfNeeded:(CGPoint)translation
{
    if (direction != kCameraMoveDirectionNone)
        
        return direction;
    
    // determine if horizontal swipe only if you meet some minimum velocity
    
    if (fabs(translation.x) > gestureMinimumTranslation)
    {
        BOOL gestureHorizontal = NO;
        
        if (translation.y ==0.0)
            gestureHorizontal = YES;
        else
            gestureHorizontal = (fabs(translation.x / translation.y) >5.0);
        
        if (gestureHorizontal)
            
        {
            if (translation.x >0.0)
                return kCameraMoveDirectionRight;
            else
                return kCameraMoveDirectionLeft;
        }
    }
    // determine if vertical swipe only if you meet some minimum velocity
    
    else if (fabs(translation.y) > gestureMinimumTranslation)
        
    {
        
        BOOL gestureVertical = NO;
        
        if (translation.x ==0.0)
            
            gestureVertical = YES;
        
        else
            
            gestureVertical = (fabs(translation.y / translation.x) >5.0);
        
        if (gestureVertical)
            
        {
            
            if (translation.y >0.0)
                
                return kCameraMoveDirectionDown;
            
            else
                
                return kCameraMoveDirectionUp;
            
        }
        
    }
    
    return direction;
    
}

@end
