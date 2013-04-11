//
//  BPStatusBar.h
//  BPStatusBar
//
//  Created by Brian Partridge on 4/8/13.
//  Copyright (c) 2013 Brian Partridge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AvailabilityMacros.h>

@interface BPStatusBar : UIView

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000
@property (readwrite, nonatomic, retain) UIColor *foregroundColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (readwrite, nonatomic, retain) UIFont *font NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
#endif

/**
 * Access the animation used to transition to/from the system status bar.
 * @default UIStatusBarAnimationFade
 */
+ (UIStatusBarAnimation)transitionStyle;

/**
 * Set the animation used to transition to/from the system status bar.
 */
+ (void)setTransitionStyle:(UIStatusBarAnimation)transitionStyle;

/**
 * Show a status string.
 */
+ (void)showStatus:(NSString*)status;

/**
 * Show spinner with status string.
 */
+ (void)showActivityWithStatus:(NSString*)status;

/**
 * Stops the activity indicator, shows a glyph and status, and dismisses 1 second later.
 */
+ (void)showSuccessWithStatus:(NSString*)status;

/**
 * Stops the activity indicator, shows a glyph and status, and dismisses 1 second later.
 */
+ (void)showErrorWithStatus:(NSString *)status;

/**
 * Stops the activity indicator, shows a glyph and status, and dismisses 1 second later.
 * @param image Image to display. Should be a 14x14 white png.
 */
+ (void)showImage:(UIImage*)image status:(NSString*)status;

/**
 * Dismiss the BPStatusBar and restore the system status bar.
 */
+ (void)dismiss;

/**
 * Indicates whether the BPStatusBar is visible.
 */
+ (BOOL)isVisible;

@end
