//
//  UIView+EdgeAnimation.m
//  EdgeAnimationDemo
//
//  Created by lizq on 16/8/17.
//  Copyright © 2016年 zqLee. All rights reserved.
//

#import "UIView+EdgeAnimation.h"
#import <objc/message.h>

#define SCREENWIDTH     [UIScreen mainScreen].bounds.size.width
#define SCREENWHEIGHT   [UIScreen mainScreen].bounds.size.height

static NSString *const LQDDirectionKey  = @"directionKey";
static NSString *const LQEdgeLayerKey   = @"edgelayerKey";
static NSString *const LQEndPointKey    = @"endpointKey";
static NSString *const LQEdgeColorKey   = @"edgecolorKey";
static NSString *const LQPanGestureKey   = @"panGestureKey";



typedef NS_ENUM(NSInteger, EdgeAnimationDirection) {
    EdgeAnimationFromRight = 0,
    EdgeAnimationFromLeft,
    EdgeAnimationFromTop,
    EdgeAnimationFromBottom
};

@interface UIView ()

@property (nonatomic, strong) CAShapeLayer *edgeLayer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) EdgeAnimationDirection direction;
@property (nonatomic, assign) CGPoint endPoint;


@end
@implementation UIView (EdgeAnimation)


- (void)addEdgeEffect {
    UIPanGestureRecognizer *panGesture = objc_getAssociatedObject(self, (__bridge const void *)(LQPanGestureKey));
    if (!panGesture) {
        panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        objc_setAssociatedObject(self, (__bridge const void *)(LQPanGestureKey), panGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        Method mothod1 = class_getInstanceMethod([self class], NSSelectorFromString(@"addGestureRecognizer:"));
        Method mothod2 = class_getInstanceMethod([self class], NSSelectorFromString(@"LQaddGestureRecognizer:"));
        method_exchangeImplementations(mothod1, mothod2);
    }
    [self addGestureRecognizer:panGesture];
}
#pragma mark 手势处理

- (void)panGesture:(UIPanGestureRecognizer *)gesture {

    CGPoint point = [gesture translationInView:self];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (point.x > 0 &&point.x >= ABS(point.y)) {
            self.direction = EdgeAnimationFromRight;
        }else if (point.x < 0 && ABS(point.x) >= ABS(point.y)) {
            self.direction = EdgeAnimationFromLeft;
        }else if (point.y > 0 && point.y >= ABS(point.x)) {
            self.direction = EdgeAnimationFromTop;
        }else if(point.y < 0 && ABS(point.y) >= ABS(point.x)) {
            self.direction = EdgeAnimationFromBottom;
        }
    }else if (gesture.state == UIGestureRecognizerStateChanged) {
        [self changeEdgeLayerAtPoint:point];

        CGFloat offect;
        if (self.direction == EdgeAnimationFromRight ||self.direction == EdgeAnimationFromLeft)
            offect = ABS(self.endPoint.x);
        else
            offect = ABS(self.endPoint.y);
        self.edgeLayer.opacity = [self fillColorAtOffect:offect];

    }else if (gesture.state == UIGestureRecognizerStateCancelled||
              gesture.state == UIGestureRecognizerStateEnded ||
              gesture.state == UIGestureRecognizerStateFailed) {
        [self removeGesture];
        [self removeEdgeLayerFromPoint:self.endPoint];
    }
}

- (void)changeEdgeLayerAtPoint:(CGPoint)point {
    switch (self.direction) {
        case EdgeAnimationFromRight:
        {
            CGPathRef pathRef = [self createRightEdgeLayerAtPoint:point];
            if ([self pointsInLayer:pathRef]){
                point = CGPointMake(self.endPoint.x, point.y);
                self.edgeLayer.path = [self createRightEdgeLayerAtPoint:point];
            }
            else
                self.edgeLayer.path = pathRef;
        }
            break;
        case EdgeAnimationFromLeft:
        {
            CGPathRef pathRef = [self createLeftEdgeLayerAtPoint:point];
            if ([self pointsInLayer:pathRef]){
                point = CGPointMake(self.endPoint.x, point.y);
                self.edgeLayer.path = [self createLeftEdgeLayerAtPoint:point];
            }
            else
                self.edgeLayer.path = pathRef;
        }
            break;
        case EdgeAnimationFromTop:{
            CGPathRef pathRef = [self createTopEdgeLayerAtPoint:point];
            if ([self pointsInLayer:pathRef]){
                point = CGPointMake(point.x, self.endPoint.y);
                self.edgeLayer.path = [self createTopEdgeLayerAtPoint:point];
            }
            else
                self.edgeLayer.path = pathRef;
        }
            break;
        case EdgeAnimationFromBottom:{
            CGPathRef pathRef = [self createBottomEdgeLayerAtPoint:point];
            if ([self pointsInLayer:pathRef]){
                point = CGPointMake(point.x, self.endPoint.y);
                self.edgeLayer.path = [self createBottomEdgeLayerAtPoint:point];
            }
            else
                self.edgeLayer.path = pathRef;
        }
            break;
    }
    self.endPoint = point;

}

#pragma mark create layer path

- (CGPathRef)createRightEdgeLayerAtPoint:(CGPoint)point {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addQuadCurveToPoint:CGPointMake(0, SCREENWHEIGHT)
                 controlPoint:CGPointMake(point.x, SCREENWHEIGHT/2 + point.y)];
    return path.CGPath;
}

- (CGPathRef)createLeftEdgeLayerAtPoint:(CGPoint)point {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(SCREENWIDTH, 0)];
    [path addQuadCurveToPoint:CGPointMake(SCREENWIDTH, SCREENWHEIGHT)
                 controlPoint:CGPointMake(SCREENWIDTH + point.x, SCREENWHEIGHT/2 + point.y)];
    return path.CGPath;
}

- (CGPathRef)createTopEdgeLayerAtPoint:(CGPoint)point {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addQuadCurveToPoint:CGPointMake(SCREENWIDTH, 0)
                 controlPoint:CGPointMake(SCREENWIDTH/2 + point.x, point.y)];
    return path.CGPath;
}

- (CGPathRef)createBottomEdgeLayerAtPoint:(CGPoint)point {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, SCREENWHEIGHT)];
    [path addQuadCurveToPoint:CGPointMake(SCREENWIDTH, SCREENWHEIGHT)
                 controlPoint:CGPointMake(SCREENWIDTH/2 + point.x, SCREENWHEIGHT + point.y)];
    return path.CGPath;
}

#pragma mark other 

- (NSArray *)pathsFromPoint:(CGPoint)point {
    NSMutableArray *pathArray = [NSMutableArray arrayWithCapacity:0];
    switch (self.direction) {
        case EdgeAnimationFromRight:
        {
            pathArray[0] = (id)[self createRightEdgeLayerAtPoint:point];
            pathArray[1] = (id)[self createRightEdgeLayerAtPoint:CGPointMake(0, 0)];
        }
            break;
        case EdgeAnimationFromLeft:
            pathArray[0] = (id)[self createLeftEdgeLayerAtPoint:point];
            pathArray[1] = (id)[self createLeftEdgeLayerAtPoint:CGPointMake(0, 0)];

            break;
        case EdgeAnimationFromTop:
            pathArray[0] = (id)[self createTopEdgeLayerAtPoint:point];
            pathArray[1] = (id)[self createTopEdgeLayerAtPoint:CGPointMake(0, 0)];

            break;
        case EdgeAnimationFromBottom:
            pathArray[0] = (id)[self createBottomEdgeLayerAtPoint:point];
            pathArray[1] = (id)[self createBottomEdgeLayerAtPoint:CGPointMake(0, 0)];

            break;
    }
    return pathArray;
}

- (CGFloat)fillColorAtOffect:(CGFloat)offect {
    CGFloat scale = offect/200.0 < 1? offect/200.0 :1;
    return scale*0.3;
}

- (void)removeGesture {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
            [self removeGestureRecognizer:gesture];
        }
    }
}

- (BOOL)pointsInLayer:(CGPathRef)path {

    CGRect rect = CGPathGetBoundingBox(path);
    if (rect.size.width >= SCREENWIDTH &&CGRectGetHeight(rect) > 150 ) {
        return YES;
    }else if (CGRectGetHeight(rect) >= SCREENWHEIGHT && CGRectGetWidth(rect) > 200) {
        return YES;
    }
    return NO;
}

//防止手势被覆盖
- (void)LQaddGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {

    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = objc_getAssociatedObject(self, (__bridge const void *)(LQPanGestureKey));
        if (pan && pan!= gestureRecognizer) {
            return;
        }
    }
    objc_msgSend(self, NSSelectorFromString(@"LQaddGestureRecognizer:"),gestureRecognizer);
}

#pragma mark animation

- (void)removeEdgeLayerFromPoint:(CGPoint)point {

    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = [NSArray arrayWithObjects:
                        [self edgeLayerAnimationFromPoint:point],
                        [self fillColorAnimationFromPoint:point],
                        nil];

    group.duration = 1;
    group.delegate = self;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    [self.edgeLayer addAnimation:group forKey:@"group"];
}

- (CAKeyframeAnimation *)edgeLayerAnimationFromPoint:(CGPoint)point {

    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    animation.values = [self pathsFromPoint:point];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    return animation;
}

- (CAKeyframeAnimation *)fillColorAnimationFromPoint:(CGPoint)point {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    animation.values = [NSArray arrayWithObjects:@(self.edgeLayer.opacity),@([self fillColorAtOffect:0]), nil];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

    return animation;
}

#pragma mark CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {

    [self.edgeLayer removeFromSuperlayer];
    self.edgeLayer = nil;
    [self addEdgeEffect];
}

#pragma mark getter or setter

- (CAShapeLayer *)edgeLayer {

    CAShapeLayer *layer = objc_getAssociatedObject(self, (__bridge const void *)(LQEdgeLayerKey));
    if (!layer) {
        layer = [CAShapeLayer layer];
        layer.fillColor = self.edgeFillColor.CGColor;
        layer.strokeColor = self.edgeFillColor.CGColor;
        layer.opacity = 0;
        [self setEdgeLayer:layer];
    }
    [self.layer addSublayer:layer];
    return layer;
}

- (void)setEdgeLayer:(CAShapeLayer *)edgeLayer {
    objc_setAssociatedObject(self, (__bridge const void *)(LQEdgeLayerKey), edgeLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (EdgeAnimationDirection)direction {
    NSString *string = objc_getAssociatedObject(self, (__bridge const void *)(LQDDirectionKey));
    return string.intValue;
}

- (void)setDirection:(EdgeAnimationDirection)direction {
    objc_setAssociatedObject(self, (__bridge const void *)(LQDDirectionKey), [NSString stringWithFormat:@"%ld", (long)direction], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGPoint)endPoint {
    NSString *pointString = objc_getAssociatedObject(self, (__bridge const void *)(LQEndPointKey));
    CGPoint point = CGPointFromString(pointString);
    return point;
}

- (void)setEndPoint:(CGPoint)endPoint {
    objc_setAssociatedObject(self, (__bridge const void *)(LQEndPointKey), NSStringFromCGPoint(endPoint), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIColor *)edgeFillColor {
    UIColor *color = objc_getAssociatedObject(self, (__bridge const void *)(LQEdgeColorKey));
    if (!color) {
        color = [UIColor grayColor];
    }
    return color;
}

- (void)setEdgeFillColor:(UIColor *)edgeFillColor {

    objc_setAssociatedObject(self, (__bridge const void *)(LQEdgeColorKey), edgeFillColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
