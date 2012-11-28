/*
 
 Copyright (c) 2012, Wayne Hartman
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of Wayne Hartman nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL WAYNE HARTMAN BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "WHAlertButtonItem.h"

@protocol WHAlertViewAnimator;
@protocol WHAlertViewCustomizer;
@protocol WHAlertViewDelegate;

@class WHDefaultAlertViewCustomizer;

@interface WHAlertView : UIView

/*!
 *  @discussion The accessorView of an alert can be any type of UIView.  Use this to set progress bars, text fields, or other custom elements.  These
 *  elements should have a resize mask that have a flexible width and left/right margins.
 *
 *  @warning Alerts should respond quickly to interaction.  Avoid adding views that are expensive or take a while to load.
 */
@property (nonatomic, strong) UIView *accessoryView;

/*!
 *  @discussion override point for setting an instance of a class that implements the WHAlertViewAnimator.  Genereally speaking, alerts should be conistent 
 *  throughout the application.  However, there may instances where a specific animation for an AlertView may need to be set.  This property should be set 
 *  after an instance is created, but *before* it is sent a /show/ message.
 */
@property (nonatomic, strong) id<WHAlertViewAnimator> animator;

/*!
 *  @discussion override point for setting an instance of a class that implements the WHAlertViewCustomizer.  Genereally speaking, alerts should be conistent
 *  throughout the application.  However, there may instances where a specific UI presentation for an AlertView may need to be created.  This property should be set
 *  after an instance is created, but *before* it is sent a /show/ message.
 */
@property (nonatomic, strong) id<WHAlertViewCustomizer> customizer;

/*!
 *  @discussion This API mirrors that of UIAlertViewDelegate.  It exists for backwards compatibility
 *  @warning WHAlertView does not implement the style types that were introduced into iOS 5, like the text fields.  For this there is a more generic accessoryView 
 *  property where a text field, or other view can be added.
 */
@property (nonatomic, assign) id<WHAlertViewDelegate> delegate;

/*!
 *  @method registerAnimationClassForAlertAnimations
 *  @param animationClass a class that implements the <WHAlertViewAnimator> protocol
 *  @discussion Since alerts in an application should generally behave the same throughout an app, this class method can be 
 *  used to specify the class that should be used throughout the application life.  If no class is registered, WHAlertView will use a default implementation.
 *
 *  @warning Classes that implement the WHALertViewAnimator MUST implement all the required methods or an NSInconsistancy exception will be thrown at runtime
 *  when attempting to register the class for use.
 */
+ (void)registerAnimationClassForAlertAnimations:(Class<WHAlertViewAnimator>)animationClass;

/*!
 *  @method registerCustomizerClassForAlertUI
 *  @param customizerClass a class that implements the <WHAlertViewCustomizer> protocol
 *  @discussion Since alerts in an application should generally look the same throughout an app, this class method can be
 *  used to specify the class that should be used throughout the application life.  If no class is registered, WHAlertView will use a default implementation.
 */
+ (void)registerCustomizerClassForAlertUI:(Class<WHAlertViewCustomizer>)customizerClass;

/*!
 *  @param title the title of the alertView
 *  @param message the message to show the user
 *  @param delegate WHAlertViewDelegate to recieve callbacks during the lifetime of the alertView
 *  @param cancelButtonTitle NSString title of the cancel button
 *  @param otherButtonTitles nil terminated vararg list of NSString titles for the buttons
 *  @return an initialized instance of a WHAlertView
 */
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<WHAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

/*!
 *  @param title the title of the alertView
 *  @param message the message to show the user
 *  @param cancelButtonItem WHAlertButtonItem for the cancel button
 *  @param otherButtonItems NSArray of ordered WHAlertButtonItem instances for the other buttons
 *  @return an initialized instance of a WHAlertView
 */
- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonItem:(WHAlertButtonItem *)cancelButtonItem otherButtonItemsArray:(NSArray *)otherButtonItems;

/*!
 *  @param title the title of the alertView
 *  @param message the message to show the user
 *  @param cancelButtonItem WHAlertButtonItem for the cancel button
 *  @param otherButtonItems nil terminated vararg list of WHButtonItems instances for the buttons
 *  @return an initialized instance of a WHAlertView
 */
- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonItem:(WHAlertButtonItem *)cancelButtonItem otherButtonItems:(WHAlertButtonItem *)otherButtonItems, ... NS_REQUIRES_NIL_TERMINATION;

/*!
 *  @method show Shows the custom alert view
 */
- (void)show;

@end

#pragma mark - WHAlertViewAnimator -

/*!
 *  @protocol WHAlertViewAnimator
 *  @discussion The WHAlertViewAnimator prescribes a set of behaviors for allowing for custom animations for a WHAlertView instance.  
 *  Implementors of this protocol are only required to return blocks for the show and dismiss animations, but further customizations and hooks are available 
 *  for even deeper customization
 */
@protocol WHAlertViewAnimator <NSObject>

#pragma mark - Required Methods

/*!
 *  @param alertView the alertview instance that will be shown.
 *  @return animation block for animating the alertview
 *  @discussion This method will be called immediately before the animation block is executed.  Implementors can use this method to do any setup,
 *  including positioning the alertView, setting alpha, etc.
 */
- (void (^)(void))showAnimationForAlertView:(WHAlertView *)alertView;

/*!
 *  @param alertView the alertview instance that will be shown.
 *  @return animation block for animating the alertview
 *  @discussion This method will be called immediately before the animation block is executed.  Implementors can use this method to do any setup,
 *  including positioning the alertView, setting alpha, etc.
 */
- (void (^)(void))dismissAnimationForAlertView:(WHAlertView *)alertView;

#pragma mark - Optional Methods

@optional
/*!
 *  @return duration of the show animation
 *  @discussion Use this method to customize the duration of the show animation.  If this method is not implemented, then the alert view will use a default value.
 */
- (CGFloat)showAnimationDuration;

/*!
 *  @return duration of the dismiss animation
 *  @discussion Use this method to customize the duration of the dismiss animation.  If this method is not implemented, then the alert view will use a default value.
 */
- (CGFloat)dismissAnimationDuration;

/*!
 *  @param alertView the alertview instance that will be shown.
 *  @return completion block to execute after the show animation completes.
 *  @discussion This method will be called when the show animation completion block has executed.  Implementors can use this method to do any addition teardown
 *  or even implement successive nested animations.
 */
- (void (^)(BOOL finished))showCompletionForAlertView:(WHAlertView *)alertView;

/*!
 *  @param alertView the alertview instance that will be shown.
 *  @return completion block to execute after the dismiss animation completes.
 *  @discussion This method will be called immediately after the dismiss animation block has finished execution.  Implementors can use this method to do any addition teardown
 *  or even implement successive nested animations.
 */
- (void (^)(BOOL finished))dismissCompletionForAlertView:(WHAlertView *)alertView;

@end

#pragma mark - WHAlertViewCustomizer

@protocol WHAlertViewCustomizer <NSObject>

#pragma mark - Optional Methods
@optional
- (UIImage *) stretchableImageForCancelButtonInAlertView:(WHAlertView *)alertView;
- (UIImage *) stretchableImageForOtherButtonsInAlertView:(WHAlertView *)alertView;
- (UIImage *) stretchablePressedImageForCancelButtonInAlertView:(WHAlertView *)alertView;
- (UIImage *) stretchablePressedImageForOtherButtonsInAlertView:(WHAlertView *)alertView;

- (UIColor *) backgroundColorForAlertView:(WHAlertView *)alertView;
- (UIColor *) titleTextColorForAlertView:(WHAlertView *)alertView;
- (UIColor *) messageTextColorForAlertView:(WHAlertView *)alertView;
- (UIColor *) buttonTextColorForAlertView:(WHAlertView *)alertView;

- (UIColor *) titleTextShadowColorForAlertView:(WHAlertView *)alertView;
- (UIColor *) messageTextShadowColorForAlertView:(WHAlertView *)alertView;
- (UIColor *) buttonTextShadowColorForAlertView:(WHAlertView *)alertView;

- (UIFont *) titleFontForAlertView:(WHAlertView *)alertView;
- (UIFont *) messageFontForAlertView:(WHAlertView *)alertView;
- (UIFont *) buttonTitlesFontForAlertView:(WHAlertView *)alertView;

- (BOOL)shouldIncludeShineEffectForAlertView:(WHAlertView *)alertView;
- (void)customizeUIForAlertView:(WHAlertView *)alertView;

@end

#pragma mark - WHAlertViewDelegate

@protocol WHAlertViewDelegate <NSObject>

@optional
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(WHAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(WHAlertView *)alertView;

- (void)willPresentAlertView:(WHAlertView *)alertView;  // before animation and showing view
- (void)didPresentAlertView:(WHAlertView *)alertView;  // after animation

- (void)alertView:(WHAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
- (void)alertView:(WHAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation

@end

#pragma mark - WHDefaultAlertViewCustomizer -

@interface WHDefaultAlertViewCustomizer : NSObject <WHAlertViewCustomizer>

@end