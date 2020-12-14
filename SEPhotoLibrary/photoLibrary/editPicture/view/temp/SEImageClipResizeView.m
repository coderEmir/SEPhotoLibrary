//
//  SEImageClipResizeView.m
//  SEPhotoLibrary
//
//  Created by xKing on 2020/12/12.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import "SEImageClipResizeView.h"
#define SEScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define SEScreenHeight  [[UIScreen mainScreen] bounds].size.height
static CGFloat const normalLineWidth = 0.5;
static CGFloat const cornerLineWidth = 2.5;
static CGFloat const cornerLineLength = 20;
static CGFloat const borderLineWidth = 1;
static CGFloat const handlePanScopeWH = 50;
static CGFloat const minImageWH = 70;

@interface SEImageClipResizeView ()

@property (nonatomic, strong) CAShapeLayer *bgLayer;

@property (nonatomic, strong) CAShapeLayer *clipLayer;

@property (nonatomic, strong) CAShapeLayer *leftTopLayer;

@property (nonatomic, strong) CAShapeLayer *rightTopLayer;

@property (nonatomic, strong) CAShapeLayer *leftBottomLayer;

@property (nonatomic, strong) CAShapeLayer *rightBottomLayer;

@property (nonatomic, strong) CAShapeLayer *hTopLineLayer;

@property (nonatomic, strong) CAShapeLayer *hBottomLineLayer;

@property (nonatomic, strong) CAShapeLayer *vLeftLineLayer;

@property (nonatomic, strong) CAShapeLayer *vRightLineLayer;

@property (nonatomic, assign) CGSize contentSize;

@property (nonatomic , assign) CGFloat margin;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic , assign) CGFloat baseImageW;

@property (nonatomic , assign) CGFloat baseImageH;

@property (nonatomic , assign) CGRect bgPathFrame;

@property (nonatomic , assign) CGRect originFrame;

@property (nonatomic , assign) CGRect maxResizeFrame;

@property (nonatomic , assign) CGRect resizeFrame;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic , assign) BOOL isPrepareToScale;

// 处理手势
@property (nonatomic , assign) SEImageClipResizeCornerType cornerType;
@property (nonatomic , assign) CGPoint diagonalPoint;
@property (nonatomic , assign) CGFloat startResizeW;
@property (nonatomic , assign) CGFloat startResizeH;

@end

@implementation SEImageClipResizeView

- (instancetype)initWithFrame:(CGRect)frame contentSize:(CGSize)contentSize margin:(CGFloat)margin imageView:(UIImageView *)imageView scrollView:(UIScrollView *)scrollView
{
    self = [super initWithFrame:frame];
    self.backgroundColor = UIColor.clearColor;
    self.contentSize = contentSize;
    self.margin = margin;
    self.scrollView = scrollView;
    self.imageView = imageView;
    [self setUpData];
    [self calculateResizeFrames];
    [self addSubLayers];
    [self addGsetures];
    [self updateResizeFrame:self.originFrame animated:NO];
    return self;
}

- (void)setUpData
{
    self.bgPathFrame = CGRectMake(-800, -800,SEScreenWidth + 1600, SEScreenHeight + 1600);
    if (self.prepareToScaleClosure) self.prepareToScaleClosure(self.isPrepareToScale);
    if (self.prepareToScaleClosure) self.prepareToScaleClosure(self.isCanRecovery);
}

- (void)addSubLayers
{
    [self.layer addSublayer:self.bgLayer];
    [self.layer addSublayer:self.clipLayer];
    [self.layer addSublayer:self.leftTopLayer];
    [self.layer addSublayer:self.leftBottomLayer];
    [self.layer addSublayer:self.rightTopLayer];
    [self.layer addSublayer:self.rightBottomLayer];
    [self.layer addSublayer:self.vLeftLineLayer];
    [self.layer addSublayer:self.vRightLineLayer];
    [self.layer addSublayer:self.hTopLineLayer];
    [self.layer addSublayer:self.hBottomLineLayer];
}

- (void)addGsetures
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [self addGestureRecognizer:panGesture];
}

- (void)calculateResizeFrames
{
    if (self.imageView == nil) return;
    self.baseImageW = self.imageView.bounds.size.width;
    self.baseImageH = self.imageView.bounds.size.height;
    
    CGFloat viewW = self.bounds.size.width;
    CGFloat viewH = self.bounds.size.height;
    
    CGFloat x = (viewW - _baseImageW) * 0.5;
    CGFloat y = (viewH - _baseImageH) * 0.5;
    
    self.originFrame = CGRectMake(x, y, _baseImageW, _baseImageH);
    
    CGFloat diffHalfWith = (viewW - self.contentSize.width) * 0.5;
    
    CGFloat maxX = diffHalfWith + _margin;
    CGFloat maxW = diffHalfWith - 2 * maxX;
    CGFloat maxH = viewH - 2 * _margin;
    
    self.maxResizeFrame = CGRectMake(maxX, _margin, maxW, maxH);
}

- (UIEdgeInsets)contentInsetWithNewResizeFrame:(CGRect)newResizeFrame
{
    CGFloat viewW = self.bounds.size.width;
    CGFloat viewH = self.bounds.size.height;
    CGFloat top = CGRectGetMinY(newResizeFrame);
    CGFloat bottom = viewH - CGRectGetMaxY(newResizeFrame);
    CGFloat left = CGRectGetMinX(newResizeFrame);
    CGFloat right = viewW - CGRectGetMaxX(newResizeFrame);
    
    return UIEdgeInsetsMake(top, left, bottom, right);
}

- (CGFloat)minZoomScaleWIthResizeSize:(CGSize)resizeSize
{
    CGFloat minZoomScale = 1;
    if (resizeSize.width >= resizeSize.height) {
        minZoomScale = resizeSize.width / _baseImageW;
        CGFloat imageH = _baseImageH * minZoomScale;
        if (imageH < resizeSize.height) {
            minZoomScale *= (resizeSize.height / imageH);
        }
        else
        {
            minZoomScale = resizeSize.height / _baseImageH;
            CGFloat imageW = _baseImageW * minZoomScale;
            if (imageW < resizeSize.width) {
                minZoomScale *= (resizeSize.width / imageW);
            }
        }
    }
    return minZoomScale;
}

- (void)updateResizeFrame:(CGRect)resizeFrame animated:(BOOL)animated
{
    self.resizeFrame = resizeFrame;
    CGFloat resizeFrameMinX = CGRectGetMinX(resizeFrame);
    CGFloat resizeFrameMinY = CGRectGetMinY(resizeFrame);
    CGFloat resizeFrameMaxY = CGRectGetMaxY(resizeFrame);
    CGFloat resizeFrameMaxX = CGRectGetMaxX(resizeFrame);
    UIBezierPath *leftTopPath = [self cornerPathWithPosition:CGPointMake(resizeFrameMinX, resizeFrameMinY) cornerType:SEImageClipResizeCornerLeftTop];
    UIBezierPath *leftBottomPath = [self cornerPathWithPosition:CGPointMake(resizeFrameMinX, resizeFrameMaxY) cornerType:SEImageClipResizeCornerLeftBottom];
    UIBezierPath *rightTopPath = [self cornerPathWithPosition:CGPointMake(resizeFrameMaxX, resizeFrameMinY) cornerType:SEImageClipResizeCornerRightTop];
    UIBezierPath *rightBottomPath = [self cornerPathWithPosition:CGPointMake(resizeFrameMaxX, resizeFrameMaxY) cornerType:SEImageClipResizeCornerRightBottom];
    
    UIBezierPath *hTopLinePath = [self linePathWithPosition:CGPointMake(resizeFrameMinX, resizeFrameMinY + resizeFrame.size.height / 3) length:resizeFrame.size.width linePosition:SEImageClipResizeLineHorizontalTop];
    UIBezierPath *hBottomLinePath = [self linePathWithPosition:CGPointMake(resizeFrameMinX, resizeFrameMinY + resizeFrame.size.height / 3 * 2) length:resizeFrame.size.width linePosition:SEImageClipResizeLineHorizontalBottom];
    UIBezierPath *vLeftLinePath = [self linePathWithPosition:CGPointMake(resizeFrameMinX + resizeFrame.size.width / 3, resizeFrameMinY) length:resizeFrame.size.height linePosition:SEImageClipResizeLineVerticalLeft];
    UIBezierPath *vRightLinePath = [self linePathWithPosition:CGPointMake(resizeFrameMinX + resizeFrame.size.width / 3 * 2, resizeFrameMinY) length:resizeFrame.size.height linePosition:SEImageClipResizeLineVerticalRight];
    
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRect:resizeFrame];
    UIBezierPath *bgPath = [UIBezierPath bezierPathWithRect:self.bgPathFrame];
    
    [bgPath appendPath:[clipPath bezierPathByReversingPath]];
    
    if (animated) {
        [self animateLayer:self.leftTopLayer path:leftTopPath];
        [self animateLayer:self.rightTopLayer path:rightTopPath];
        [self animateLayer:self.leftBottomLayer path:leftBottomPath];
        [self animateLayer:self.rightBottomLayer path:rightBottomPath];
        [self animateLayer:self.vLeftLineLayer path:vLeftLinePath];
        [self animateLayer:self.vRightLineLayer path:vRightLinePath];
        [self animateLayer:self.hTopLineLayer path:hTopLinePath];
        [self animateLayer:self.hBottomLineLayer path:hBottomLinePath];
        [self animateLayer:self.bgLayer path:bgPath];
        [self animateLayer:self.clipLayer path:clipPath];
    }
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    self.leftTopLayer.path = leftTopPath.CGPath;
    self.rightTopLayer.path = rightTopPath.CGPath;
    self.leftBottomLayer.path = leftBottomPath.CGPath;
    self.rightBottomLayer.path = rightBottomPath.CGPath;
    self.vLeftLineLayer.path = vLeftLinePath.CGPath;
    self.vRightLineLayer.path = vRightLinePath.CGPath;
    self.hTopLineLayer.path = hTopLinePath.CGPath;
    self.hBottomLineLayer.path = hBottomLinePath.CGPath;
    self.bgLayer.path = bgPath.CGPath;
    self.clipLayer.path = clipPath.CGPath;
    
    [CATransaction commit];
}

- (void)animateLayer:(CAShapeLayer *)layer path:(UIBezierPath *)path
{
    CABasicAnimation *animate = [CABasicAnimation animationWithKeyPath:@"path"];
    animate.fillMode = kCAFillModeBackwards;
    animate.fromValue = (__bridge id _Nullable)(layer.path);
    animate.toValue = path;
    animate.duration = animateDuration;
    animate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [layer addAnimation:animate forKey:@"path"];
}

- (UIBezierPath *)cornerPathWithPosition:(CGPoint)position cornerType:(SEImageClipResizeCornerType)cornerType
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    CGFloat halfCornerLineWidth = cornerLineWidth / 2;
    CGPoint point1 = CGPointZero;
    CGPoint point2 = CGPointZero;
    CGPoint point3 = CGPointZero;
    
    switch (cornerType) {
    case SEImageClipResizeCornerLeftTop:
            point2 = CGPointMake(position.x - halfCornerLineWidth, position.y - halfCornerLineWidth);
            point1 = CGPointMake(point2.x, point2.y + cornerLineLength);
            point3 = CGPointMake(point2.x + cornerLineLength, point2.y);
    case SEImageClipResizeCornerLeftBottom:
            point2 = CGPointMake(position.x - halfCornerLineWidth, position.y + halfCornerLineWidth);
            point1 = CGPointMake(point2.x, point2.y - cornerLineLength);
            point3 = CGPointMake(point2.x + cornerLineLength, point2.y);
    case SEImageClipResizeCornerRightTop:
            point2 = CGPointMake(position.x + halfCornerLineWidth,position.y - halfCornerLineWidth);
            point1 = CGPointMake(point2.x - cornerLineLength, point2.y);
            point3 = CGPointMake(point2.x, point2.y + cornerLineLength);
    case SEImageClipResizeCornerRightBottom:
            point2 = CGPointMake(position.x + halfCornerLineWidth, position.y + halfCornerLineWidth);
            point1 = CGPointMake(point2.x - cornerLineLength, point2.y);
            point3 = CGPointMake(point2.x, point2.y - cornerLineLength);
    default:
            point1 = position;
            point2 = position;
            point3 = position;
    }
    [path moveToPoint:point1];
    [path addLineToPoint:point2];
    [path addLineToPoint:point3];
    
    return path;
}

- (UIBezierPath *)linePathWithPosition:(CGPoint)position length:(CGFloat)length linePosition:(SEImageClipResizeLinePosition)linePosition
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    CGPoint point = CGPointZero;
    switch (linePosition) {
        case SEImageClipResizeLineHorizontalBottom:
        case SEImageClipResizeLineHorizontalTop:
            point = CGPointMake(position.x + length,position.y);
            break;
        case SEImageClipResizeLineVerticalLeft:
        case SEImageClipResizeLineVerticalRight:
            point = CGPointMake(position.x + length,position.y);
            break;
    }
    [path moveToPoint:position];
    [path addLineToPoint:point];
    return path;
}

- (void)addTimer
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(handleTimer) userInfo:nil repeats:false];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}

- (void)removeTimer
{
    if (self.timer == nil) return;
    [self.timer invalidate];
    self.timer = nil;
}

- (void)handleTimer
{
    [self removeTimer];
    [self updateResizeFrameWithAnimate:YES];
}

- (void)updateResizeFrameWithAnimate:(BOOL)animated
{
    if (self.scrollView == nil) return;
    CGRect adjustResizeFrame = self.calculateAdjustResizeFrame;
    UIEdgeInsets contentInset = [self contentInsetWithNewResizeFrame:adjustResizeFrame];
    CGPoint contentOffset = CGPointZero;
    CGPoint convertPoint = [self convertPoint:self.resizeFrame.origin toView:self.imageView];
    contentOffset.x = -contentInset.left + convertPoint.x * self.scrollView.zoomScale;
    contentOffset.y = -contentInset.top + convertPoint.y * self.scrollView.zoomScale;
    self.scrollView.minimumZoomScale = [self minZoomScaleWIthResizeSize:adjustResizeFrame.size];
    
    CGFloat convertScale = self.resizeFrame.size.width / adjustResizeFrame.size.width;
    CGFloat diffXSpace = CGRectGetMinX(adjustResizeFrame) * convertScale;
    CGFloat diffYSpace = CGRectGetMinY(adjustResizeFrame) * convertScale;
    CGFloat convertW = self.resizeFrame.size.width + 2 * diffXSpace;
    CGFloat convertH = self.resizeFrame.size.height + 2 * diffYSpace;
    CGFloat convertX = CGRectGetMinX(adjustResizeFrame) - diffXSpace;
    CGFloat convertY = CGRectGetMinY(adjustResizeFrame) - diffYSpace;
    
    CGRect zoomFrame = [self convertRect:CGRectMake(convertX, convertY, convertW, convertH) toView:self.imageView];
    __weak typeof(self) weakSelf = self;
    void (^zoomClosure)(void) = ^{
        weakSelf.scrollView.contentInset = contentInset;
        [weakSelf.scrollView setContentOffset:contentOffset animated:false];
        [weakSelf.scrollView zoomToRect:zoomFrame animated:false];
    };
    void (^completeClosure)(BOOL finished) = ^(BOOL finished) {
        self.isPrepareToScale = NO;
        [self checkIsCanRecovery];
        self.superview.userInteractionEnabled = YES;
    };
    self.superview.userInteractionEnabled = NO;
    [self updateResizeFrame:adjustResizeFrame animated:animated];
    if (animated) {
        [UIView animateWithDuration:animateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:zoomClosure completion:completeClosure];
    }
    else
    {
        zoomClosure();
        completeClosure(YES);
    }
}

- (void)checkIsCanRecovery
{
    CGPoint convertCenter = [self convertPoint:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)) toView:self.imageView];
    CGPoint imageViewCenter = CGPointMake(CGRectGetMinX(self.imageView.bounds), CGRectGetMinY(self.imageView.bounds));
    BOOL isSameCenter = (labs((NSInteger)(convertCenter.x - imageViewCenter.x)) <= 1 && labs((NSInteger)(convertCenter.y - imageViewCenter.y)) <= 1);
    BOOL isOriginFrame = labs((NSInteger)(self.resizeFrame.size.width - self.imageView.bounds.size.width)) <= 1 && labs((NSInteger)(self.resizeFrame.size.height - self.imageView.bounds.size.height)) <= 1;
    
    self.isCanRecovery = !isOriginFrame || !isSameCenter;
}

- (CGRect)calculateAdjustResizeFrame
{
    CGFloat resizeWHScale = self.resizeFrame.size.width / self.resizeFrame.size.height;
    CGFloat adjustResizeW = 0;
    CGFloat adjustResizeH = 0;
    CGFloat maxResizeFrameH = self.maxResizeFrame.size.height;
    CGFloat maxResizeFrameW = self.maxResizeFrame.size.width;
    if (resizeWHScale >= 1) {
        adjustResizeW = self.maxResizeFrame.size.width;
        adjustResizeH = adjustResizeW / resizeWHScale;
        if (adjustResizeH > maxResizeFrameH) {
            adjustResizeH = maxResizeFrameH;
            adjustResizeW = adjustResizeH * resizeWHScale;
        }
    } else {
        adjustResizeH = maxResizeFrameH;
        adjustResizeW = adjustResizeH * resizeWHScale;
        if (adjustResizeW > maxResizeFrameW) {
            adjustResizeW = maxResizeFrameW;
            adjustResizeH = adjustResizeW / resizeWHScale;
        }
    }
    CGFloat adjustResizeX = CGRectGetMinX(self.maxResizeFrame) + (maxResizeFrameW - adjustResizeW) / 2;
    CGFloat adjustResizeY = CGRectGetMinY(self.maxResizeFrame) + (maxResizeFrameH - adjustResizeH) / 2;
    return CGRectMake(adjustResizeX, adjustResizeY, adjustResizeW, adjustResizeH);
}

- (void)panGesture:(UIPanGestureRecognizer *)panGesture
{
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint point = [panGesture locationInView:self];
            [self beginPanWithPoint:point];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [panGesture translationInView:self];
            [panGesture setTranslation:CGPointZero inView:self];
            [self changePanWithTranslation:translation];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            [self endIamgeResize];
        }
            break;
        
            
        default:
            break;
    }
}

- (void)beginPanWithPoint:(CGPoint)point
{
    [self startImageResize];
    CGFloat halfHandlePanScopeWH = handlePanScopeWH / 2;
    CGFloat x = CGRectGetMinX(self.resizeFrame);
    CGFloat y = CGRectGetMinY(self.resizeFrame);
    CGFloat w = self.resizeFrame.size.width;
    CGFloat h = self.resizeFrame.size.height;
    CGFloat midX = CGRectGetMidX(self.resizeFrame);
    CGFloat midY = CGRectGetMidY(self.resizeFrame);
    CGFloat maxX = CGRectGetMaxX(self.resizeFrame);
    CGFloat maxY = CGRectGetMaxY(self.resizeFrame);
    CGRect leftTopRect = CGRectMake(x - halfHandlePanScopeWH, y - halfHandlePanScopeWH, handlePanScopeWH, handlePanScopeWH);
    CGRect leftBottomRect = CGRectMake(x - halfHandlePanScopeWH, maxY - halfHandlePanScopeWH, handlePanScopeWH, handlePanScopeWH);
    CGRect rightTopRect = CGRectMake(maxX - halfHandlePanScopeWH, y, handlePanScopeWH, handlePanScopeWH);
    CGRect rightBottomRect = CGRectMake(maxX - halfHandlePanScopeWH, maxY - halfHandlePanScopeWH, handlePanScopeWH, handlePanScopeWH);
    CGRect leftMidRect = CGRectMake(x - halfHandlePanScopeWH, y + halfHandlePanScopeWH, handlePanScopeWH, h - handlePanScopeWH);
    CGRect rightMidRect = CGRectMake(maxX - halfHandlePanScopeWH, y + halfHandlePanScopeWH, handlePanScopeWH, h - handlePanScopeWH);
    CGRect topMidRect = CGRectMake(x + halfHandlePanScopeWH, y - halfHandlePanScopeWH, w - handlePanScopeWH, handlePanScopeWH);
    CGRect bottomMidRect = CGRectMake(x + halfHandlePanScopeWH, maxY - halfHandlePanScopeWH, w - handlePanScopeWH, handlePanScopeWH);
    
    if (CGRectContainsPoint(leftTopRect, point)) {
        self.cornerType =  SEImageClipResizeCornerLeftTop;
        self.diagonalPoint = CGPointMake(maxX, maxY);
    } else if (CGRectContainsPoint(leftBottomRect, point)) {
        self.cornerType =  SEImageClipResizeCornerLeftBottom;
        self.diagonalPoint = CGPointMake(maxX, y);
    } else if (CGRectContainsPoint(rightTopRect, point)) {
        self.cornerType = SEImageClipResizeCornerRightTop;
        self.diagonalPoint = CGPointMake(x, maxY);
    } else if (CGRectContainsPoint(rightBottomRect, point)) {
        self.cornerType = SEImageClipResizeCornerRightBottom;
        self.diagonalPoint = CGPointMake(x, y);
    } else if (CGRectContainsPoint(leftMidRect, point)) {
        self.cornerType = SEImageClipResizeCornerLeftMiddle;
        self.diagonalPoint = CGPointMake(maxX, midY);
    } else if (CGRectContainsPoint(rightMidRect, point)) {
        self.cornerType = SEImageClipResizeCornerRightMiddle;
        self.diagonalPoint = CGPointMake(x, midY);
    } else if (CGRectContainsPoint(topMidRect, point)) {
        self.cornerType = SEImageClipResizeCornerTopMiddle;
        self.diagonalPoint = CGPointMake(midX, maxY);
    } else if (CGRectContainsPoint(bottomMidRect, point)) {
        self.cornerType = SEImageClipResizeCornerBottomMiddle;
        self.diagonalPoint = CGPointMake(midX, y);
    }
    self.startResizeW = w;
    self.startResizeH = h;
}

- (void)changePanWithTranslation:(CGPoint)translation
{
    if (_scrollView == nil) return;
    CGFloat x = CGRectGetMinX(self.resizeFrame);
    CGFloat y = CGRectGetMinY(self.resizeFrame);
    
    CGFloat w = self.resizeFrame.size.width;
    CGFloat h = self.resizeFrame.size.height;
    CGFloat maxResizeX = CGRectGetMinX(self.maxResizeFrame);
    CGFloat maxResizeY = CGRectGetMinY(self.maxResizeFrame);
    CGFloat maxResizeMaxX = CGRectGetMaxX(self.maxResizeFrame);
    CGFloat maxResizeMaxY = CGRectGetMaxY(self.maxResizeFrame);
    switch (self.cornerType) {
    case SEImageClipResizeCornerLeftTop:
            x += translation.x;
            y += translation.y;
        if (x < maxResizeX) {
            x = maxResizeX;
        }
        if (y < maxResizeY) {
            y = maxResizeY;
        }
            w = self.diagonalPoint.x - x;
            h = self.diagonalPoint.y - y;
        if (w < minImageWH) {
            w = minImageWH;
            x = self.diagonalPoint.x - w;
        }
        if (h < minImageWH) {
            h = minImageWH;
            y = self.diagonalPoint.y - h;
        }
        break;
    case SEImageClipResizeCornerLeftBottom:
            x += translation.x;
            h += translation.y;
        if (x < maxResizeX) {
            x = maxResizeX;
        }
        if (y + h > maxResizeMaxY) {
            h = maxResizeMaxY - self.diagonalPoint.y;
        }
            w = self.diagonalPoint.x - x;
        if (w < minImageWH) {
            w = minImageWH;
            x = self.diagonalPoint.x - w;
        }
        if (h < minImageWH) {
            h = minImageWH;
        }
        break;
    case SEImageClipResizeCornerRightTop:
            y += translation.y;
            w += translation.x;
        if (y < maxResizeY) {
            y = maxResizeY;
        }
        if (x + w > maxResizeMaxX) {
            w = maxResizeMaxX - self.diagonalPoint.x;
        }
            h = self.diagonalPoint.y - y;
        if (w < minImageWH) {
            w = minImageWH;
        }
        if (h < minImageWH) {
            h = minImageWH;
            y = self.diagonalPoint.y - h;
        }
        break;
    case SEImageClipResizeCornerRightBottom:
            w += translation.x;
            h += translation.y;
        if (x + w > maxResizeMaxX) {
            w = maxResizeMaxX - self.diagonalPoint.x;
        }
        if (y + h > maxResizeMaxY) {
            h = maxResizeMaxY - self.diagonalPoint.y;
        }
        if (w < minImageWH) {
            w = minImageWH;
        }
        if (h < minImageWH) {
            h = minImageWH;
        }
        break;
    case SEImageClipResizeCornerLeftMiddle:
            x += translation.x;
        if (x < maxResizeX) {
            x = maxResizeX;
        }
            w = self.diagonalPoint.x - x;
        if (w < minImageWH) {
            w = minImageWH;
            x = self.diagonalPoint.x - w;
        }
        break;
    case SEImageClipResizeCornerRightMiddle:
            w += translation.x;
        if (x + w > maxResizeMaxX) {
            w = maxResizeMaxX - self.diagonalPoint.x;
        }
        if (w < minImageWH) {
            w = minImageWH;
        }
        break;
    case SEImageClipResizeCornerTopMiddle:
            y += translation.y;
        if (y < maxResizeY) {
            y = maxResizeY;
        }
            h = self.diagonalPoint.y - y;
        if (h < minImageWH) {
            h = minImageWH;
            y = self.diagonalPoint.y - h;
        }
        break;
    case SEImageClipResizeCornerBottomMiddle:
            h += translation.y;
        if (y + h > maxResizeMaxY) {
            h = maxResizeMaxY - self.diagonalPoint.y;
        }
        if (h < minImageWH) {
            h = minImageWH;
        }
        break;
    default:
        break;
    }
    CGRect newResizeFrame = CGRectMake(x, y, w, h);
    [self updateResizeFrame:newResizeFrame animated:NO];

    CGRect zoomFrame = [self convertRect:newResizeFrame toView:self.imageView];
    CGPoint contentOffset = self.scrollView.contentOffset;
    CGFloat zoomFrameMinX = CGRectGetMinX(zoomFrame);
    CGFloat zoomFrameMaxX = CGRectGetMaxX(zoomFrame);
    CGFloat zoomFrameMinY = CGRectGetMinY(zoomFrame);
    CGFloat zoomFrameMaxY = CGRectGetMaxY(zoomFrame);
    if (zoomFrameMinX < 0) {
        contentOffset.x -= zoomFrameMinX;
    } else if (zoomFrameMaxX > _baseImageW) {
        contentOffset.x -= zoomFrameMaxX - _baseImageW;
    }
    if (zoomFrameMinY < 0) {
        contentOffset.y -= zoomFrameMinY;
    } else if (zoomFrameMaxY > _baseImageH) {
        contentOffset.y -= zoomFrameMaxY - _baseImageH;
    }
    [self.scrollView setContentOffset:contentOffset animated:NO];
    CGFloat wZoomScale = 0;
    CGFloat hZoomScale = 0;
    if (w > _startResizeW) {
        wZoomScale = w / _baseImageW;
    }
    if (h > _startResizeH) {
        hZoomScale = h / _baseImageH;
    }
    CGFloat zoomScale = MAX(wZoomScale, hZoomScale);
    if (zoomScale > self.scrollView.zoomScale) {
        [self.scrollView setZoomScale:zoomScale animated:false];
    }
}

- (void)startImageResize
{
    self.isPrepareToScale = YES;
    [self removeTimer];
}

- (void)endIamgeResize
{
    UIEdgeInsets contentInset = [self contentInsetWithNewResizeFrame:self.resizeFrame];
    self.scrollView.contentInset = contentInset;
    [self addTimer];
}

- (void)willRecovery
{
    super.userInteractionEnabled = false;
    [self removeTimer];
}

- (void)doneRecovery
{
    [self updateResizeFrameWithAnimate:NO];
    super.userInteractionEnabled = YES;
}

- (void)recoveryWIthAnimate:(BOOL)animated
{
    UIEdgeInsets contentInset = [self contentInsetWithNewResizeFrame:self.originFrame];
    CGFloat minZoomScale = [self minZoomScaleWIthResizeSize:self.originFrame.size];
    CGFloat contentOffsetX = -contentInset.left + (self.baseImageW * minZoomScale - self.originFrame.size.width) / 2;
    CGFloat contentOffsetY = -contentInset.top + (self.baseImageH * minZoomScale - self.originFrame.size.height) / 2;
    [self updateResizeFrame:self.originFrame animated:animated];
    
    self.scrollView.minimumZoomScale = minZoomScale;
    self.scrollView.zoomScale = minZoomScale;
    self.scrollView.contentInset = contentInset;
    self.scrollView.contentOffset = CGPointMake(contentOffsetX, contentOffsetY);
}

- (void)clipImageWithReferenceWidth:(CGFloat)referenceWidth isOriginImageSize:(BOOL)isOriginImageSize completion:(void(^)(UIImage *image))completion
{
    UIImage *image = self.imageView.image;
    CGImageRef imageRef = image.CGImage;
    if (imageRef == nil) {
        completion(nil);
        return;
    }
    CGFloat imageScale = image.scale;
    CGFloat imageWidth = image.size.width * imageScale;
    CGFloat imageHeight = image.size.height * imageScale;
    CGFloat scale = imageWidth / self.imageView.bounds.size.width;
    CGFloat deviceScale = UIScreen.mainScreen.scale;
    CGRect cropFrame = _isCanRecovery ? [self convertRect:self.resizeFrame toView:self.imageView] : self.imageView.bounds;
    CGFloat newRefW = referenceWidth;
    if (newRefW > 0) {
        CGFloat maxWidth = MAX(imageWidth, self.imageView.bounds.size.width);
        CGFloat minWidth = MIN(imageWidth, self.imageView.bounds.size.width);
        if (newRefW > maxWidth) {
            newRefW = maxWidth;
        }
        if (newRefW < minWidth) {
            newRefW = minWidth;
        }
    } else {
        newRefW = self.imageView.bounds.size.width;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CGFloat x = CGRectGetMinX(cropFrame) * scale;
        CGFloat y = CGRectGetMinY(cropFrame) * scale;
        CGFloat w = cropFrame.size.width * scale;
        CGFloat h = cropFrame.size.height * scale;
        if (x < 0) {
            w -= x;
            x = 0;
        }
        if (y < 0) {
            h -= y;
            y = 0;
        }
        if (w + x > imageWidth) {
            w -= (w + x - imageWidth);
        }
        if (h + y > imageHeight) {
            h -= (h + y - imageHeight);
        }
        CGRect cropRect = CGRectMake(x, y, w, h);
        CGImageRef cropImageRef = CGImageCreateWithImageInRect(imageRef, cropRect);
        if (cropImageRef == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
            return;
        }
        UIImage *cropImage = [UIImage imageWithCGImage:cropImageRef];
        if (isOriginImageSize) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(cropImage);
            });
            return;
        }
        CGFloat cropScale = imageWidth / newRefW;
        CGSize cropSize = CGSizeMake(floor(cropImage.size.width / cropScale), floor(cropImage.size.height / cropScale));
        UIGraphicsBeginImageContextWithOptions(cropSize, false, deviceScale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, cropSize.height);
        CGContextScaleCTM(context, 1, -1);
        CGContextDrawImage(context, CGRectMake(0, 0, cropSize.width, cropSize.height), cropImageRef);
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(newImage);
        });
    });
}

#pragma mark - lazyLoad
- (CAShapeLayer *)bgLayer
{
    if (!_bgLayer) {
        _bgLayer = [self generateSublayerWithLineWidth:0];
        _bgLayer.fillColor = [UIColor.blackColor colorWithAlphaComponent:0.6].CGColor;
        _bgLayer.fillRule = kCAFillRuleEvenOdd;
    }
    return _bgLayer;
}

- (CAShapeLayer *)clipLayer
{
    if (!_clipLayer) {
        _clipLayer = [self generateSublayerWithLineWidth:borderLineWidth];
    }
    return _clipLayer;
}


- (CAShapeLayer *)leftTopLayer
{
    if (!_leftTopLayer) {
        _leftTopLayer = [self generateSublayerWithLineWidth:cornerLineWidth];
    }
    return _leftTopLayer;
}


- (CAShapeLayer *)rightTopLayer
{
    if (!_rightTopLayer) {
        _rightTopLayer = [self generateSublayerWithLineWidth:cornerLineWidth];
    }
    return _rightTopLayer;
}


- (CAShapeLayer *)leftBottomLayer
{
    if (!_leftBottomLayer) {
        _leftBottomLayer = [self generateSublayerWithLineWidth:cornerLineWidth];
    }
    return _leftBottomLayer;
}


- (CAShapeLayer *)rightBottomLayer
{
    if (!_rightBottomLayer) {
        _rightBottomLayer = [self generateSublayerWithLineWidth:cornerLineWidth];
    }
    return _rightBottomLayer;
}

- (CAShapeLayer *)hTopLineLayer
{
    if (!_hTopLineLayer) {
        _hTopLineLayer = [self generateSublayerWithLineWidth:normalLineWidth];
    }
    return _hTopLineLayer;
}


- (CAShapeLayer *)hBottomLineLayer
{
    if (!_hBottomLineLayer) {
        _hBottomLineLayer = [self generateSublayerWithLineWidth:normalLineWidth];
    }
    return _hBottomLineLayer;
}

- (CAShapeLayer *)vLeftLineLayer
{
    if (!_vLeftLineLayer) {
        _vLeftLineLayer = [self generateSublayerWithLineWidth:normalLineWidth];
    }
    return _vLeftLineLayer;
}

- (CAShapeLayer *)vRightLineLayer
{
    if (!_vRightLineLayer) {
        _vRightLineLayer = [self generateSublayerWithLineWidth:normalLineWidth];
    }
    return _vRightLineLayer;
}

- (CAShapeLayer *)generateSublayerWithLineWidth:(CGFloat)lineWidth
{
    CAShapeLayer *cornerLayer = [[CAShapeLayer alloc] init];
    cornerLayer.frame = self.bounds;
    cornerLayer.strokeColor = UIColor.whiteColor.CGColor;
    cornerLayer.fillColor = UIColor.clearColor.CGColor;
    cornerLayer.lineWidth = lineWidth;
    return cornerLayer;
}

@end
