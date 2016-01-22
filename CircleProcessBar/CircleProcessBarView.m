//
//  CircleProcessBarView.m
//  CircleProcessBar
//
//  Created by dl on 16/1/21.
//  Copyright © 2016年 dl. All rights reserved.
//

#import "CircleProcessBarView.h"

#define UIColorFromRGBA(rgbValue, alphaValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
                blue:((float)(rgbValue & 0x0000FF))/255.0 \
                alpha:alphaValue]

#define UI_COLOR_RED_CG         (__bridge id)UIColorFromRGBA(0xEC1161, 1).CGColor
#define UI_COLOR_RED_CG_A(x)    (__bridge id)UIColorFromRGBA(0xEC1161, x).CGColor

#define GradientLayerCount      4

@implementation CircleProcessBarView

{
    NSMutableArray<CAGradientLayer *> *layers;
    CAShapeLayer * oval;
    BOOL autoAnimate;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        layers = [NSMutableArray array];
        
        CGRect rect = self.bounds;
        self.layer.cornerRadius = CGRectGetWidth(rect)/2.f;
        
        CGFloat halfWidth = CGRectGetWidth(rect)/2.f;
        CGRect layerFrame = CGRectMake(CGRectGetMinX(rect), 0, CGRectGetWidth(rect), halfWidth);
        
        for (int i=0; i<GradientLayerCount; i++) {
            
            CGFloat centerDegrees = -90.f/180.f*M_PI;
            CGFloat offsetDegrees = 1.f/GradientLayerCount*M_PI;
            CGFloat xOffsetPoint = sin(offsetDegrees)/2.f;
            
            CAGradientLayer *layer = [CAGradientLayer layer];
            layer.startPoint = CGPointMake(0.5-xOffsetPoint, 0);
            layer.endPoint = CGPointMake(0.5+xOffsetPoint, 0);
            layer.locations = @[@(-i), @0.f];
            layer.colors = @[UI_COLOR_RED_CG_A(0), UI_COLOR_RED_CG];
            layer.frame = layerFrame;
            
            CAShapeLayer *sectorLayer = [CAShapeLayer layer];
            sectorLayer.frame = CGRectMake(0, 0, halfWidth, halfWidth);
            CGPoint centerPoint = CGPointMake(CGRectGetWidth(layerFrame)/2.f, CGRectGetHeight(layerFrame));
            
            UIBezierPath* ovalPath = [UIBezierPath bezierPathWithArcCenter:centerPoint
                                                                    radius:CGRectGetHeight(layerFrame)
                                                                startAngle:(centerDegrees-offsetDegrees)
                                                                  endAngle:(centerDegrees+offsetDegrees)
                                                                 clockwise:YES];
            [ovalPath addLineToPoint:centerPoint];
            [ovalPath closePath];
            sectorLayer.path = ovalPath.CGPath;
            layer.mask = sectorLayer;
            
            layer.anchorPoint = CGPointMake(0.5f, 1);
            CATransform3D transform = CATransform3DMakeTranslation(0, halfWidth/2.f, 0);
            transform = CATransform3DRotate(transform, offsetDegrees+i*(2*M_PI/GradientLayerCount), 0, 0, 1);
            layer.transform = transform;
            
            [self.layer addSublayer:layer];
            [layers addObject:layer];
        }
        
        oval = [CAShapeLayer layer];
        oval.frame = CGRectMake(10, 10, 2*halfWidth-20, 2*halfWidth-20);
        oval.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 220, 220)].CGPath;
        [self.layer addSublayer:oval];
        
        [oval setValue:@(-90 * M_PI/180) forKeyPath:@"transform.rotation"];
        oval.fillColor   = [UIColor whiteColor].CGColor;
        oval.strokeColor = [UIColor whiteColor].CGColor;
        oval.lineWidth   = 40;
    }
    return self;
}

- (void) animate
{
    self.layer.speed = 1;
    [self resetAnimationWithAutoAni:YES];
}

- (void) setPercentage:(CGFloat)percentage
{
    if (_percentage != percentage) {
        _percentage = percentage;
        
        self.layer.speed = 0;
        [self resetAnimationWithAutoAni:NO];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.layer.timeOffset = GradientLayerCount*percentage;
        });
    }
}

- (void) resetAnimationWithAutoAni:(BOOL)autoAni
{
    if (autoAni || autoAnimate != autoAni) {
        for (int i=0; i<GradientLayerCount; i++) {
            CABasicAnimation *loc_ani = [CABasicAnimation animationWithKeyPath:@"locations"];
            loc_ani.toValue = @[@(-i), @(GradientLayerCount-i)];
            loc_ani.duration = GradientLayerCount-i;
            loc_ani.beginTime = autoAni?(CACurrentMediaTime()+1.f*i):(1.f*i);
            loc_ani.fillMode = kCAFillModeForwards;
            loc_ani.removedOnCompletion = NO;
            
            if (!autoAnimate || autoAni) {
                [layers[i] removeAnimationForKey:@"groupAnimation"];
            }
            [layers[i] addAnimation:loc_ani forKey:@"groupAnimation"];
        }
        
        CAKeyframeAnimation * ovalStrokeEndAnim = [CAKeyframeAnimation animationWithKeyPath:@"strokeStart"];
        ovalStrokeEndAnim.values   = @[@0, @1];
        ovalStrokeEndAnim.keyTimes = @[@0, @1];
        ovalStrokeEndAnim.duration = GradientLayerCount;
        ovalStrokeEndAnim.fillMode = kCAFillModeForwards;
        ovalStrokeEndAnim.removedOnCompletion = NO;
        
        if (!autoAnimate || autoAni) {
            [oval removeAnimationForKey:@"ovalStrokeEndAnim"];
        }
        [oval addAnimation:ovalStrokeEndAnim forKey:@"ovalStrokeEndAnim"];
        
        autoAnimate = autoAni;
    }
}

@end
