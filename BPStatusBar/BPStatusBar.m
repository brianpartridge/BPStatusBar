//
//  BPStatusBar.m
//  BPStatusBar
//
//  Created by Brian Partridge on 4/8/13.
//  Copyright (c) 2013 Brian Partridge. All rights reserved.
//

#import "BPStatusBar.h"

#define ACCESSORY_DIMENSION 14.0
#define HORIZONTAL_PADDING 10.0
#define STATUSBAR_TRANSITION_DURATION 0.3

typedef NS_ENUM(NSInteger, BPStatusBarAccessoryType) {
    BPStatusBarAccessoryTypeNone,
    BPStatusBarAccessoryTypeIndeterminate,
    BPStatusBarAccessoryTypeImage,
};

#pragma mark - Categories

@implementation UIImage (BPStatusBar)

/**
 * Basic image tinting. From: https://github.com/thoughtbot/ios-sample-blender
 */
- (UIImage *)bpsb_tintedImageWithColor:(UIColor *)tintColor {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];

    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return tintedImage;
}

@end

#pragma mark - BPStatusBar

@interface BPStatusBar ()

@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) NSTimer *autoDismissalTimer;

@property (nonatomic, assign) BPStatusBarAccessoryType accessoryType;

@end

@implementation BPStatusBar

static UIStatusBarAnimation _transitionStyle;

+ (void)initialize {
    _transitionStyle = UIStatusBarAnimationFade;
}

#pragma mark - Class Property

+ (UIStatusBarAnimation)transitionStyle {
    return _transitionStyle;
}

+ (void)setTransitionStyle:(UIStatusBarAnimation)transitionStyle {
    _transitionStyle = transitionStyle;
}

#pragma mark - Singleton

+ (BPStatusBar *)sharedView {
    static BPStatusBar *sharedView;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        UIApplication *app = [UIApplication sharedApplication];
        sharedView = [[BPStatusBar alloc] initWithFrame:CGRectMake(0, 0, app.statusBarFrame.size.width, app.statusBarFrame.size.height)];
    });
    return sharedView;
}

#pragma mark - Show Methods

+ (void)showStatus:(NSString*)status {
    [[self sharedView] showStatus:status transitionStyle:[self transitionStyle]];
}

+ (void)showActivityWithStatus:(NSString*)status {
    [[self sharedView] showActivityWithStatus:status transitionStyle:[self transitionStyle]];
}

#pragma mark - Show Then Dismiss Methods

+ (void)showSuccessWithStatus:(NSString*)status {
    [self showImage:[UIImage imageNamed:@"BPStatusBar.bundle/success.png"] status:status];
}

+ (void)showErrorWithStatus:(NSString *)status {
    [self showImage:[UIImage imageNamed:@"BPStatusBar.bundle/error.png"] status:status];
}

+ (void)showImage:(UIImage*)image status:(NSString*)status {
    [[self sharedView] showImage:image status:status transitionStyle:[self transitionStyle]];
}

#pragma mark - Visibility Methods

+ (void)dismiss {
    [[self sharedView] dismiss:[self transitionStyle]];
}

+ (BOOL)isVisible {
    return ([UIApplication sharedApplication].statusBarHidden &&
            [self sharedView].superview != nil);
}

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (!self) {
        return nil;
	}

    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor blackColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

	return self;
}

- (void)layoutSubviews {
    if (self.accessoryType == BPStatusBarAccessoryTypeNone) {
        self.statusLabel.frame = CGRectInset(self.bounds, HORIZONTAL_PADDING, 0);
    } else {
        [self layoutWithAccessory];
    }
}

- (void)layoutWithAccessory {
    CGRect availableBounds = CGRectInset(self.bounds, HORIZONTAL_PADDING, 0);
    availableBounds.size.width -= (ACCESSORY_DIMENSION + HORIZONTAL_PADDING);

    CGSize labelSize = [self.statusLabel sizeThatFits:availableBounds.size];
    if (availableBounds.size.width < labelSize.width) {
        labelSize = availableBounds.size;
    }

    CGFloat totalContentWidth = ACCESSORY_DIMENSION + HORIZONTAL_PADDING + labelSize.width;
    CGFloat hOffset = floorf((self.bounds.size.width - totalContentWidth) / 2);
    CGRect accessoryFrame = CGRectMake(hOffset,
                                       floorf((self.bounds.size.height - ACCESSORY_DIMENSION) / 2),
                                       ACCESSORY_DIMENSION,
                                       ACCESSORY_DIMENSION);
    self.imageView.frame = self.spinner.frame = accessoryFrame;

    self.statusLabel.frame = CGRectMake(CGRectGetMaxX(accessoryFrame) + HORIZONTAL_PADDING,
                                        floorf((self.bounds.size.height - labelSize.height) / 2),
                                        labelSize.width,
                                        labelSize.height);
}

- (void)setStatus:(NSString *)status {
    self.statusLabel.text = status;
    [self setNeedsLayout];
}

#pragma mark - Properties

- (void)setAccessoryType:(BPStatusBarAccessoryType)accessoryType {
    _accessoryType = accessoryType;

    switch (accessoryType) {
        case BPStatusBarAccessoryTypeNone:
            self.imageView.image = nil;
            self.imageView.hidden = YES;
            [self.spinner stopAnimating];
            break;
        case BPStatusBarAccessoryTypeIndeterminate:
            self.imageView.image = nil;
            self.imageView.hidden = YES;
            [self.spinner startAnimating];
            break;
        case BPStatusBarAccessoryTypeImage:
            self.imageView.hidden = NO;
            [self.spinner stopAnimating];
            break;
        default:
            break;
    }
}

#pragma mark - Show and Dismiss

- (void)showStatus:(NSString *)status transitionStyle:(UIStatusBarAnimation)transitionStyle {
    [self.autoDismissalTimer invalidate];

    self.accessoryType = BPStatusBarAccessoryTypeNone;
    self.statusLabel.text = status;

    if (![UIApplication sharedApplication].statusBarHidden) {
        self.frame = [UIApplication sharedApplication].statusBarFrame;
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:transitionStyle];
    }
    [self setNeedsLayout];
}

- (void)showActivityWithStatus:(NSString *)status transitionStyle:(UIStatusBarAnimation)transitionStyle {
    [self.autoDismissalTimer invalidate];

    self.accessoryType = BPStatusBarAccessoryTypeIndeterminate;
    self.statusLabel.text = status;

    if (![UIApplication sharedApplication].statusBarHidden) {
        self.frame = [UIApplication sharedApplication].statusBarFrame;
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:transitionStyle];
    }
    [self setNeedsLayout];
}

- (void)showImage:(UIImage *)image status:(NSString *)status transitionStyle:(UIStatusBarAnimation)transitionStyle {
    [self.autoDismissalTimer invalidate];

    self.accessoryType = BPStatusBarAccessoryTypeImage;
    self.imageView.image = [image bpsb_tintedImageWithColor:self.foregroundColor];
    self.statusLabel.text = status;

    if (![UIApplication sharedApplication].statusBarHidden) {
        self.frame = [UIApplication sharedApplication].statusBarFrame;
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:transitionStyle];
    }
    [self setNeedsLayout];

    self.autoDismissalTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissFromTimer:) userInfo:nil repeats:NO];
}

- (void)dismiss:(UIStatusBarAnimation)transitionStyle {
    if (![UIApplication sharedApplication].statusBarHidden) {
        return;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:transitionStyle];

    // TODO: This is a timing hack, it would be nice if we could get notified when the system status bar fully appears, but we can't currently.
    double delayInSeconds = STATUSBAR_TRANSITION_DURATION;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self removeFromSuperview];
    });
}

- (void)dismissFromTimer:(NSTimer *)timer {
    [self dismiss:[[self class]transitionStyle]];
}

#pragma mark - Subviews

- (UILabel *)statusLabel {
    if (_statusLabel == nil) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.adjustsFontSizeToFitWidth = NO;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
        _statusLabel.textAlignment = UITextAlignmentCenter;
#else
        _statusLabel.textAlignment = NSTextAlignmentCenter;
#endif
		_statusLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;

        // UIAppearance is used when iOS >= 5.0
		_statusLabel.textColor = self.foregroundColor;
		_statusLabel.font = self.font;
    }

    if (_statusLabel.superview == nil) {
        [self addSubview:_statusLabel];
    }

    return _statusLabel;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ACCESSORY_DIMENSION, ACCESSORY_DIMENSION)];
    }

    if(_imageView.superview == nil) {
        [self addSubview:_imageView];
    }

    return _imageView;
}

- (UIActivityIndicatorView *)spinner {
    if (_spinner == nil) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		_spinner.hidesWhenStopped = YES;

        CGFloat scale = ACCESSORY_DIMENSION / _spinner.bounds.size.width;
        _spinner.transform = CGAffineTransformMakeScale(scale, scale);

        // UIAppearance is used when iOS >= 5.0
        _spinner.color = self.foregroundColor;
    }

    if(_spinner.superview == nil) {
        [self addSubview:_spinner];
    }

    return _spinner;
}

#pragma mark - UIAppearance Getters

- (UIColor *)foregroundColor {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000
    if (_foregroundColor == nil) {
        _foregroundColor = [[[self class] appearance] foregroundColor];
    }

    if (_foregroundColor != nil) {
        return _foregroundColor;
    }
#endif

    return [UIColor colorWithWhite:186.0/255.0 alpha:1.0];
}

- (UIFont *)font {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000
    if (_font == nil) {
        _font = [[[self class] appearance] font];
    }

    if (_font != nil) {
        return _font;
    }
#endif

    return [UIFont boldSystemFontOfSize:14];
}

@end
