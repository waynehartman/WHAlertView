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

#import "WHAlertView.h"
#import "WHAlertWindow.h"

@interface WHDefaultAlertViewAnimator : NSObject <WHAlertViewAnimator> @end

@interface WHAlertView()

@property (nonatomic, strong) UIWindow *displayWindow;
@property (nonatomic, strong) UIView *windowDimmerView;
@property (nonatomic, strong) NSArray *buttonItems;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *messageText;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) NSInteger cancelButtonIndex;

@end

#define ALERT_VIEW_WIDTH    276.0
#define ALERT_PADDING       7.0f
#define ALERT_BUTTON_MARGIN 7.0f
#define ALERT_BUTTON_HEIGHT 44.0f

typedef enum {
    WHAlertLayoutModeDefault = 0,
    WHAlertLayoutModeStacked
} WHAlertLayoutMode;

@implementation WHAlertView

#pragma mark - Class Methods

static Class animatorClass = nil;

+ (void)registerAnimationClassForAlertAnimations:(Class)animationClass {
    if (animationClass == nil) {
        animationClass = nil;

        return;
    }

    if ([animationClass instancesRespondToSelector:@selector(showAnimationForAlertView:)] && [animationClass instancesRespondToSelector:@selector(dismissAnimationForAlertView:)]) {
        animatorClass = animationClass;
    } else {
        [NSException raise:@"NSInconsistancyException" format:@"The class registered for animations, %@ ,does not implement the required methods in the WHAlertViewAnimator protocol", animationClass];
    }
}

static Class customizerClass = nil;

+ (void)registerCustomizerClassForAlertUI:(Class<WHAlertViewCustomizer>)customizingClass {
    customizerClass = customizingClass;
}

#pragma mark - Initializers

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<UIAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...   {
    if ((self = [super initWithFrame:CGRectZero])) {
        [self commonInit];
        _title = title;
        _messageText = message;
        NSMutableArray *buttonItems = [[NSMutableArray alloc] initWithCapacity:1];

        NSString *eachItem;
        va_list argumentList;
        if (otherButtonTitles) {
            [buttonItems addObject:otherButtonTitles];
            va_start(argumentList, otherButtonTitles);
            while((eachItem = va_arg(argumentList, NSString *))) {
                [buttonItems addObject: eachItem];
            }

            va_end(argumentList);
        }
        
        if (cancelButtonTitle) {
            if (buttonItems.count > 2) {
                [buttonItems addObject:cancelButtonTitle];
                self.cancelButtonIndex = buttonItems.count - 1;
            } else {
                [buttonItems insertObject:cancelButtonTitle atIndex:0];
                self.cancelButtonIndex = 0;
            }
        } else {
            self.cancelButtonIndex = NSNotFound;
        }

        _buttonItems = buttonItems;
    }

    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonItem:(WHAlertButtonItem *)cancelButtonItem otherButtonItemsArray:(NSArray *)otherButtonItems {
    if ((self = [super initWithFrame:CGRectZero])) {
        [self commonInit];
        _title = title;
        _messageText = message;
        NSMutableArray *buttonItems = [[NSMutableArray alloc] initWithCapacity:1];

        if (otherButtonItems) {
            [buttonItems addObjectsFromArray:otherButtonItems];
        }

        if (cancelButtonItem) {
            if (buttonItems.count >= 2) {
                [buttonItems addObject:cancelButtonItem];
                self.cancelButtonIndex = buttonItems.count - 1;
            } else {
                [buttonItems insertObject:cancelButtonItem atIndex:0];
                self.cancelButtonIndex = 0;
            }
        } else {
            self.cancelButtonIndex = NSNotFound;
        }

        _buttonItems = buttonItems;
    }

    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonItem:(WHAlertButtonItem *)cancelButtonItem otherButtonItems:(WHAlertButtonItem *)otherButtonItems, ...  {
    if ((self = [super initWithFrame:CGRectZero])) {
        [self commonInit];
        _title = title;
        _messageText = message;
        NSMutableArray *buttonItems = [[NSMutableArray alloc] initWithCapacity:1];

        NSString *eachItem;
        va_list argumentList;
        if (otherButtonItems) {
            [buttonItems addObject:otherButtonItems];
            va_start(argumentList, otherButtonItems);

            while((eachItem = va_arg(argumentList, NSString *))) {
                [buttonItems addObject: eachItem];
            }

            va_end(argumentList);
        }

        if (cancelButtonItem) {
            if (buttonItems.count >= 2) {
                [buttonItems addObject:cancelButtonItem];
                self.cancelButtonIndex = buttonItems.count - 1;
            } else {
                [buttonItems insertObject:cancelButtonItem atIndex:0];
                self.cancelButtonIndex = 0;
            }
        } else {
            self.cancelButtonIndex = NSNotFound;
        }

        _buttonItems = buttonItems;
    }

    return self;
}

- (void)commonInit {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnteredBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowDidRotate:)
                                                 name:UIApplicationDidChangeStatusBarFrameNotification
                                               object:nil];
}

#pragma mark - Custom Getters/Setters

- (id<WHAlertViewAnimator>)animator {
    if (_animator == nil) {
        if (animatorClass == nil) {
            _animator = [[WHDefaultAlertViewAnimator alloc] init];
        } else {
            _animator = [[animatorClass alloc] init];
        }
    }

    return _animator;
}

- (id<WHAlertViewCustomizer>)customizer {
    if (_customizer == nil) {
        if (customizerClass == nil) {
            _customizer = [[WHDefaultAlertViewCustomizer alloc] init];
        } else {
            _customizer = [[customizerClass alloc] init];
        }
    }

    return _customizer;
}

#pragma mark - Show/Dismiss

- (void)show {
    //  Build our window first...
    UIWindow *window = [[WHAlertWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.windowLevel = UIWindowLevelStatusBar;
    self.displayWindow = window;
    self.displayWindow.backgroundColor = [UIColor clearColor];
    self.displayWindow.hidden = NO;

    //  Then, build the dimmer view for our window...
    UIImageView *dimmerView = [[UIImageView alloc] initWithFrame:self.displayWindow.bounds];
    dimmerView.image = [self windowDimmerImage];

    self.windowDimmerView = dimmerView;
    self.windowDimmerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
//    self.windowDimmerView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    [self.displayWindow addSubview:dimmerView];

    //  Setup the background color for our alert view
    UIColor *backgroundColor = nil;

    if ([self.customizer respondsToSelector:@selector(backgroundColorForAlertView:)]) {
        backgroundColor = [self.customizer backgroundColorForAlertView:self];
    }

    self.backgroundColor = backgroundColor;
    self.layer.masksToBounds = NO; //   Needed in most cases to let shadows appear, etc.

    //  Next, add the alert to the window
    [self.displayWindow addSubview:self];

    //  Build the entire layout for the UI
    [self constructUI];

    //  Center the view in the window and display it!
    self.center = self.window.center;
    [self.displayWindow makeKeyAndVisible];

    //  Get the show animation from the animator
    void (^animation)(void) = [self.animator showAnimationForAlertView:self];

    float duration = 0.33f;

    if ([self.animator respondsToSelector:@selector(showAnimationDuration)]) {
        duration = [self.animator showAnimationDuration];
    }

    self.windowDimmerView.alpha = 0.0f;

    //  This is for our delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(willPresentAlertView:)]) {
        [self.delegate willPresentAlertView:self];
    }

    //  We're no ready to show it...
    [UIView animateWithDuration:duration
                     animations:^{
                         self.windowDimmerView.alpha = 1.0f;
                         animation();
                     }
                     completion:^(BOOL finished) {
                         if ([self.animator respondsToSelector:@selector(showCompletionForAlertView:)]) {
                             void (^completion)(BOOL finished) = [self.animator showCompletionForAlertView:self];

                             if (completion) {
                                 completion(finished);
                             }
                         }

                         if (self.delegate && [self.delegate respondsToSelector:@selector(didPresentAlertView:)]) {
                             [self.delegate didPresentAlertView:self];
                         }
                     }];
}

- (void)dismiss {
    void (^animation)(void) = [self.animator dismissAnimationForAlertView:self];

    float duration = 0.33f;

    if ([self.animator respondsToSelector:@selector(dismissAnimationDuration)]) {
        duration = [self.animator dismissAnimationDuration];
    }

    [UIView animateWithDuration:duration
                     animations:^{
                         self.windowDimmerView.alpha = 0.0f;
                         animation();
                     }
                     completion:^(BOOL finished) {
                         if ([self.animator respondsToSelector:@selector(dismissCompletionForAlertView:)]) {
                             void (^completion)(BOOL finished) = [self.animator dismissCompletionForAlertView:self];
                             
                             if (completion) {
                                 completion(finished);
                             }
                         }

                         if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
                             [self.delegate alertView:self didDismissWithButtonIndex:self.selectedIndex];
                         }

                         self.windowDimmerView = nil;
                         [self.displayWindow setHidden:YES];
                         self.displayWindow = nil;
                     }];
}

#pragma mark - Creating the UI

- (void)constructUI {
    BOOL shouldIncludeShineEffect = YES;

    if ([self.customizer respondsToSelector:@selector(shouldIncludeShineEffectForAlertView:)]) {
        shouldIncludeShineEffect = [self.customizer shouldIncludeShineEffectForAlertView:self];
    }

    if (shouldIncludeShineEffect) {
        UIImageView *glossView = [[UIImageView alloc] initWithImage:[self shineImage]];

        [self insertSubview:glossView atIndex:0];
    }

    NSArray *uiButtons = [self buildButtons];

    UIView *buttonContainer = nil;
    if (uiButtons.count == 0) {
        // DO NOTHING
    } else if (uiButtons.count > 2) {
        buttonContainer = [self buildStackedViewForButtons:uiButtons];
    } else {
        buttonContainer = [self buildDefaultViewForButtons:uiButtons];
    }

    UIView *titleView = [self titleViewForString:self.title];
    UIView *messageView = [self messageViewForString:self.messageText];

    [self addSubview:titleView];
    [self addSubview:messageView];
    [self addSubview:buttonContainer];

    float margin = 10.0f;

    float totalHeight = ALERT_PADDING + margin + titleView.frame.size.height + margin + messageView.frame.size.height + margin + buttonContainer.frame.size.height + ALERT_PADDING;

    self.frame = CGRectMake(0.0f, 0.0f, ALERT_VIEW_WIDTH, totalHeight);

    float messageViewTopMargin = ALERT_PADDING + margin + titleView.frame.size.height + margin + (messageView.frame.size.height * 0.5f);
    messageView.center = CGPointMake(messageView.center.x, floorf(messageViewTopMargin));

    float buttonContainerTopMargin = ALERT_PADDING + margin + titleView.frame.size.height + margin + messageView.frame.size.height + margin + (buttonContainer.frame.size.height * 0.5);
    buttonContainer.center = CGPointMake(buttonContainer.center.x, floorf(buttonContainerTopMargin));

    if (self.customizer && [self.customizer respondsToSelector:@selector(customizeUIForAlertView:)]) {
        [self.customizer customizeUIForAlertView:self];
    }
}

- (UIView *)buildDefaultViewForButtons:(NSArray *)buttons {
    if (self.buttonItems.count == 0) {
        return nil;
    }

    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(ALERT_PADDING,
                                                                     0.0f,
                                                                     ALERT_VIEW_WIDTH - (ALERT_PADDING * 2.0f),
                                                                     44.0f)];
    containerView.backgroundColor = [UIColor clearColor];

    float buttonWidth = (ALERT_VIEW_WIDTH - ALERT_PADDING * 2.0f);

    UIButton *button1 = buttons[0];
    [containerView addSubview:button1];

    float multibuttonWidth = (buttonWidth - ALERT_BUTTON_MARGIN) / 2.0f;

    UIImage *cancelImage = nil;

    if ([self.customizer respondsToSelector:@selector(stretchableImageForCancelButtonInAlertView:)]) {
        cancelImage = [self.customizer stretchableImageForCancelButtonInAlertView:self];
    }

    UIImage *pressedCancelImage = nil;

    if ([self.customizer respondsToSelector:@selector(stretchablePressedImageForCancelButtonInAlertView:)]) {
        pressedCancelImage = [self.customizer stretchablePressedImageForCancelButtonInAlertView:self];
    }

    [button1 setBackgroundImage:cancelImage forState:UIControlStateNormal];
    [button1 setBackgroundImage:pressedCancelImage forState:UIControlStateHighlighted];

    if (buttons.count == 1) {
        button1.frame = CGRectMake(0.0f, 0.0f, buttonWidth, ALERT_BUTTON_HEIGHT);
    } else {
        button1.frame = CGRectMake(0.0, 0.0f, multibuttonWidth, ALERT_BUTTON_HEIGHT);

        UIImage *otherImage = nil;
        
        if ([self.customizer respondsToSelector:@selector(stretchableImageForOtherButtonsInAlertView:)]) {
            otherImage = [self.customizer stretchableImageForOtherButtonsInAlertView:self];
        }

        UIImage *pressedOtherImage = nil;

        if ([self.customizer respondsToSelector:@selector(stretchablePressedImageForOtherButtonsInAlertView:)]) {
            pressedOtherImage = [self.customizer stretchablePressedImageForOtherButtonsInAlertView:self];
        }

        UIButton *button2 = buttons[1];
        [containerView addSubview:button2];
        [button2 setBackgroundImage:otherImage forState:UIControlStateNormal];
        [button2 setBackgroundImage:pressedOtherImage forState:UIControlStateHighlighted];

        button2.frame = CGRectMake(multibuttonWidth + ALERT_BUTTON_MARGIN, button2.frame.origin.y, multibuttonWidth, ALERT_BUTTON_HEIGHT);
    }

    return containerView;
}

- (UIView *)buildStackedViewForButtons:(NSArray *)buttons {
    if (buttons.count == 0) {
        return nil;
    }

    float cancelMargin = self.cancelButtonIndex != NSNotFound ? ALERT_BUTTON_MARGIN + 6.0 : 0.0f;

    float buttonWidth = ALERT_VIEW_WIDTH - (ALERT_PADDING * 2.0f);
    float containerHeight = (buttons.count * ALERT_BUTTON_HEIGHT) + ((buttons.count - 1) * ALERT_BUTTON_MARGIN) + cancelMargin;

    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(ALERT_PADDING, 0.0f, buttonWidth, containerHeight)];

    
    
    for (int i = 0; i < buttons.count; i++) {
        float additionalMargin = i == self.cancelButtonIndex ? cancelMargin : 0.0f;

        UIButton *button = buttons[i];
        CGRect buttonRect = CGRectMake(0.0f,
                                       (i * (ALERT_BUTTON_HEIGHT + ALERT_BUTTON_MARGIN)) + additionalMargin,
                                       buttonWidth,
                                       ALERT_BUTTON_HEIGHT);
        button.frame = buttonRect;

        if (i == self.cancelButtonIndex) {
            if ([self.customizer respondsToSelector:@selector(stretchableImageForCancelButtonInAlertView:)]) {
                UIImage *backgroundImage = [self.customizer stretchableImageForCancelButtonInAlertView:self];
                [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
            }

            if ([self.customizer respondsToSelector:@selector(stretchablePressedImageForCancelButtonInAlertView:)]) {
                UIImage *image = [self.customizer stretchablePressedImageForCancelButtonInAlertView:self];
                [button setBackgroundImage:image forState:UIControlStateHighlighted];
            }
        } else {
            if ([self.customizer respondsToSelector:@selector(stretchableImageForOtherButtonsInAlertView:)]) {
                UIImage *backgroundImage = [self.customizer stretchableImageForOtherButtonsInAlertView:self];
                [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
            }

            if ([self.customizer respondsToSelector:@selector(stretchablePressedImageForOtherButtonsInAlertView:)]) {
                UIImage *image = [self.customizer stretchablePressedImageForOtherButtonsInAlertView:self];
                [button setBackgroundImage:image forState:UIControlStateHighlighted];
            }
        }

        [containerView addSubview:button];
    }

    return containerView;
}

- (UIView *)messageViewForString:(NSString *)message {
    UIFont *font = nil;
    
    if ([self.customizer respondsToSelector:@selector(messageFontForAlertView:)]) {
        font = [self.customizer messageFontForAlertView:self];
    }

    UIColor *shadowColor = nil;

    if (self.customizer && [self.customizer respondsToSelector:@selector(messageTextShadowColorForAlertView:)]) {
        shadowColor = [self.customizer messageTextShadowColorForAlertView:self];
    } else {
        shadowColor = [UIColor blackColor];
    }

    CGSize expectedSize = [message sizeWithFont:font
                             constrainedToSize:CGSizeMake(ALERT_VIEW_WIDTH - ALERT_PADDING, 1000.0f)
                                 lineBreakMode:NSLineBreakByWordWrapping];

    UIColor *textColor = nil;

    if (self.customizer && [self.customizer respondsToSelector:@selector(messageTextColorForAlertView:)]) {
        textColor = [self.customizer messageTextColorForAlertView:self];
    } else {
        textColor = [UIColor whiteColor];
    }

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(ALERT_PADDING,
                                                               0.0f,
                                                               ALERT_VIEW_WIDTH - (ALERT_PADDING * 2.0f),
                                                               expectedSize.height)];
    label.font = font;
    label.textColor = textColor;
    label.backgroundColor = [UIColor clearColor];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    label.text = message;
    label.shadowColor = shadowColor;
    label.shadowOffset = CGSizeMake(0.0f, -1.0f);
    label.textAlignment = NSTextAlignmentCenter;

    return label;
}

- (UIView *)titleViewForString:(NSString *)title {
    UIFont *font = nil;

    if ([self.customizer respondsToSelector:@selector(titleFontForAlertView:)]) {
        font = [self.customizer titleFontForAlertView:self];
    }

    UIColor *textColor = nil;

    if ([self.customizer respondsToSelector:@selector(titleTextColorForAlertView:)]) {
        textColor = [self.customizer titleTextColorForAlertView:self];
    } else {
        textColor = [UIColor whiteColor];
    }

    UIColor *shadowColor = nil;

    if (self.customizer && [self.customizer respondsToSelector:@selector(titleTextShadowColorForAlertView:)]) {
        shadowColor = [self.customizer titleTextShadowColorForAlertView:self];
    } else {
        shadowColor = [UIColor blackColor];
    }

    CGSize expectedSize = [title sizeWithFont:font
                              constrainedToSize:CGSizeMake(ALERT_VIEW_WIDTH - ALERT_PADDING, 200.0f)
                                  lineBreakMode:NSLineBreakByWordWrapping];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(ALERT_PADDING,
                                                               ALERT_PADDING + 5.0f,
                                                               ALERT_VIEW_WIDTH - (ALERT_PADDING * 2.0f),
                                                               expectedSize.height)];
    label.font = font;
    label.textColor = textColor;
    label.backgroundColor = [UIColor clearColor];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    label.shadowColor = shadowColor;
    label.shadowOffset = CGSizeMake(0.0f, -1.0f);

    return label;
}

- (NSArray *)buildButtons {
    NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:self.buttonItems.count];

    UIFont *buttonFont = nil;

    if ([self.customizer respondsToSelector:@selector(buttonTitlesFontForAlertView:)]) {
        buttonFont = [self.customizer buttonTitlesFontForAlertView:self];
    }
    
    UIColor *textColor = nil;
    
    if (self.customizer && [self.customizer respondsToSelector:@selector(buttonTextColorForAlertView:)]) {
        textColor = [self.customizer buttonTextColorForAlertView:self];
    } else {
        textColor = [UIColor whiteColor];
    }
    
    UIColor *shadowColor = nil;

    if (self.customizer && [self.customizer respondsToSelector:@selector(buttonTextShadowColorForAlertView:)]) {
        shadowColor = [self.customizer buttonTextShadowColorForAlertView:self];
    } else {
        shadowColor = [UIColor blackColor];
    }

    for (int i = 0; i < self.buttonItems.count; i++) {
        NSString *title = nil;

        id item  = self.buttonItems[i];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTag:i];
        [button addTarget:self action:@selector(didSelectButton:) forControlEvents:UIControlEventTouchUpInside];

        if ([item isKindOfClass:[NSString class]]) {
            title = item;
        } else {
            WHAlertButtonItem *buttonItem = item;
            title = buttonItem.title;
        }

        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleShadowColor:shadowColor forState:UIControlStateNormal];
        button.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
        [button.titleLabel setFont:buttonFont];
        [button setTitleColor:textColor forState:UIControlStateNormal];

        [buttons addObject:button];
    }

    return buttons;
}

static UIImage *dimmerImage;

- (UIImage *)windowDimmerImage {    
    if (dimmerImage == nil) {   //  If our static image isn't created, do so.
        float largestSize = self.displayWindow.bounds.size.width > self.displayWindow.bounds.size.height ? self.displayWindow.bounds.size.width : self.displayWindow.bounds.size.height;
        
        CGRect drawRect = CGRectMake(0.0f, 0.0f, largestSize, largestSize);
        CGPoint center = CGPointMake(0.5f * largestSize, 0.5f * largestSize);  // Center of gradient

        CGFloat colors[12] = {
            0.0f, 0.0f, 0.0f, 0.05f,
//            0.0f, 0.0f, 0.0f, 0.20f,
            0.0f, 0.0f, 0.0f, 0.50f,
            0.0f, 0.0f, 0.0f, 0.70f
        };

        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, nil, 3);

        // Starting image and drawing gradient into it
        UIGraphicsBeginImageContextWithOptions(drawRect.size, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawRadialGradient(context,
                                    gradient,
                                    center,
                                    0.0f,
                                    center,
                                    largestSize,
                                    0);  // Drawing gradient
        dimmerImage = UIGraphicsGetImageFromCurrentImageContext();  // Retrieving image from context
        UIGraphicsEndImageContext();  // Ending process
        
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);
    }

    return dimmerImage;
}

static UIImage *shineImage = nil;

/*
 *  Produces the shine on the top area of the alert
 *  The Core Graphics code was lifted form CustomAlertView.h
 */
- (UIImage *)shineImage {
    if (!shineImage) {
        float height = 30.0f;

        CGRect rect = CGRectMake(0.0f, 0.0f, ALERT_VIEW_WIDTH, 100.0f);

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(ALERT_VIEW_WIDTH, height), NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();

        CGContextSetAllowsAntialiasing(context, true);
        CGContextSetShouldAntialias(context, true);

        CGFloat lineWidth = 2.0;
        CGFloat shadowOffsetY = 5.0;
        CGFloat shadowBlur = 3.0;
        CGFloat cornerRadius = 8.0;
        CGFloat shadowHeight = shadowOffsetY + shadowBlur;

        CGRect viewRect = CGRectMake(rect.origin.x + lineWidth, rect.origin.y + lineWidth, rect.size.width - lineWidth*2, rect.size.height - lineWidth*2 - shadowHeight);

        CGMutablePathRef roundedRectPath = CGPathCreateMutable();
        CGPathMoveToPoint(roundedRectPath, NULL, viewRect.origin.x + cornerRadius, viewRect.origin.y);
        CGPathAddArc(roundedRectPath, NULL, CGRectGetMaxX(viewRect) - cornerRadius, CGRectGetMinY(viewRect) + cornerRadius,	cornerRadius, -M_PI/2, 0, NO);
        CGPathAddArc(roundedRectPath, NULL, CGRectGetMaxX(viewRect) - cornerRadius, CGRectGetMaxY(viewRect) - cornerRadius,	cornerRadius, 0, M_PI/2, NO);
        CGPathAddArc(roundedRectPath, NULL, CGRectGetMinX(viewRect) + cornerRadius, CGRectGetMaxY(viewRect) - cornerRadius,	cornerRadius, M_PI/2, M_PI, NO);
        CGPathAddArc(roundedRectPath, NULL, CGRectGetMinX(viewRect) + cornerRadius, CGRectGetMinY(viewRect) + cornerRadius, cornerRadius, M_PI, 3*M_PI/2, NO);
        CGPathCloseSubpath(roundedRectPath);

        // Clip to rounded rect
        CGContextSaveGState(context);
        CGContextAddPath(context, roundedRectPath);
        CGContextClip(context);

        // Gradient
        CGFloat components[8] = {
            1.0, 1.0, 1.0, 0.6,
            1.0, 1.0, 1.0, 0.12
        };

        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, NULL, 2);

        CGRect clip = CGRectMake(-rect.size.width * 0.3/2, -30, rect.size.width * 1.3, 30 * 2);
        CGContextAddEllipseInRect(context, clip);
        CGContextClip(context);

        CGContextDrawLinearGradient(context, gradient, rect.origin, CGPointMake(rect.origin.x, 30), 0);
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorspace);

        shineImage = UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext();
    }

    return shineImage;
}

#pragma mark - Actions

- (void)didSelectButton:(id)sender {
    UIButton *selectedButton = sender;
    int index = selectedButton.tag;

    self.selectedIndex = index;

    id selectedButtonItem = self.buttonItems[index];

    if ([selectedButtonItem isKindOfClass:[NSString class]]) {
        //  Need a delegate callback
    } else {
        WHAlertButtonItem *item = selectedButtonItem;
        if (item.action) {
            dispatch_async(dispatch_get_main_queue(), item.action);
        }
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)]) {
        [self.delegate alertView:self willDismissWithButtonIndex:index];
    }

    [self dismiss];
}

#pragma mark - Notifications

- (void)applicationEnteredBackground:(NSNotification *)notification {
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertViewCancel:)]) {
        [self.delegate alertViewCancel:self];
    } else {
        self.selectedIndex = 0;
        [self dismiss];
    }
}

- (void)windowDidRotate:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect screenRect = [[UIScreen mainScreen] bounds];

    CGSize newSize = CGSizeZero;

    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            newSize = CGSizeMake(screenRect.size.height, screenRect.size.width);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationPortrait:
            newSize = CGSizeMake(screenRect.size.width, screenRect.size.height);
            break;
    }

    self.center = CGPointMake(newSize.width * 0.5f, newSize.height * 0.5f);
}

#pragma mark - Memory Management

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

#pragma mark - WHDefaultAlertViewAnimator -

@implementation WHDefaultAlertViewAnimator

- (void (^)(void)) showAnimationForAlertView:(WHAlertView *)alertView {
    alertView.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
    alertView.alpha = 0.0f;

    return ^{
        alertView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
        alertView.alpha = 1.0f;
    };
}

- (void (^)(BOOL finished))showCompletionForAlertView:(WHAlertView *)alertView {
    return ^(BOOL finished) {
        static float duration = 0.18f;

        [UIView animateWithDuration:duration * 0.5
                         animations:^{
                             alertView.transform = CGAffineTransformMakeScale(0.95f, 0.95f);
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:duration * 0.5
                                              animations:^{
                                                  alertView.transform = CGAffineTransformIdentity;
                                              }
                                              completion:^(BOOL finished) {
                                              }];
                         }];
    };
}

- (CGFloat)showAnimationDuration {
    return 0.25f;
}

- (CGFloat)dismissAnimationDuration {
    return 0.3f;
}

- (void (^)(void))dismissAnimationForAlertView:(WHAlertView *)alertView {
    return ^{
        alertView.alpha = 0.0f;
    };
}

- (void (^)(BOOL finished))dismissCompletionForAlertView:(WHAlertView *)alertView {
    return NULL;
}

@end

#pragma mark - WHDefaultAlertViewDresser -

@implementation WHDefaultAlertViewCustomizer

#define EDGE_INSETS UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 5.0f)

#pragma mark - Button Images

- (UIImage *) stretchableImageForCancelButtonInAlertView:(WHAlertView *)alertView {
    if (alertView.buttonItems.count == 1) {
        return [[UIImage imageNamed:@"defaultAlertButton.png"] resizableImageWithCapInsets:EDGE_INSETS];
    } else {
        return [[UIImage imageNamed:@"defaultCancelAlertButton.png"] resizableImageWithCapInsets:EDGE_INSETS];
    }
}

- (UIImage *) stretchableImageForOtherButtonsInAlertView:(WHAlertView *)alertView {
    return [[UIImage imageNamed:@"defaultAlertButton.png"] resizableImageWithCapInsets:EDGE_INSETS];
}

- (UIImage *) stretchablePressedImageForCancelButtonInAlertView:(WHAlertView *)alertView {
    return [[UIImage imageNamed:@"defaultAlertButtonPressed.png"] resizableImageWithCapInsets:EDGE_INSETS];
}

- (UIImage *) stretchablePressedImageForOtherButtonsInAlertView:(WHAlertView *)alertView {
    return [[UIImage imageNamed:@"defaultAlertButtonPressed.png"] resizableImageWithCapInsets:EDGE_INSETS];
}

#pragma mark - Custom Colors

- (UIColor *) backgroundColorForAlertView:(WHAlertView *)alertView {
    //  Rough approximation of the Apple default color of the UIAlertView
    return [UIColor colorWithRed:0.0f/255.0f
                           green:19.0f/255.0f
                            blue:69.0f/255.0f
                           alpha:0.8f];
}

- (UIColor *) titleTextColorForAlertView:(WHAlertView *)alertView {
    return [UIColor whiteColor];
}

- (UIColor *) messageTextColorForAlertView:(WHAlertView *)alertView {
    return [UIColor whiteColor];
}

- (UIColor *) buttonTextColorForAlertView:(WHAlertView *)alertView {
    return [UIColor whiteColor];
}

#pragma mark - Custom Fonts

- (UIFont *) titleFontForAlertView:(WHAlertView *)alertView {
    return [UIFont boldSystemFontOfSize:18.0f];
}

- (UIFont *) messageFontForAlertView:(WHAlertView *)alertView {
    return [UIFont systemFontOfSize:16.0f];
}

- (UIFont *) buttonTitlesFontForAlertView:(WHAlertView *)alertView {
    return [UIFont boldSystemFontOfSize:18.0f];
}

#pragma mark - Other UI Customization

- (void)customizeUIForAlertView:(WHAlertView *)alertView {
    alertView.layer.borderWidth = 2.0f;
    alertView.layer.cornerRadius = 10.0f;
    alertView.layer.borderColor = [UIColor colorWithRed:1.0f
                                                  green:1.0f
                                                   blue:1.0f
                                                  alpha:0.8f].CGColor;

    CALayer *shadowLayer = [self createShadowLayerForAlertView:alertView];
    [alertView.layer insertSublayer:shadowLayer atIndex:0];
}

- (BOOL)shouldIncludeShineEffectForAlertView:(WHAlertView *)alertView {
    return YES;
}

#pragma mark - Other Instance Methods

- (CALayer *)createShadowLayerForAlertView:(WHAlertView *)alertView {
    /*
     *  Not sure how Apple's shadow is implemented, it's very likely that it's drawn on there using CoreGraphics.  Ours is going to create a shadow layer and then mask
     *  out the whole layer except the parts that should be visible around the edges of the alert view itself.
     */
    CGRect shadowRect = CGRectMake(alertView.bounds.origin.x, alertView.bounds.origin.y, alertView.bounds.size.width, alertView.bounds.size.height + 4.0f);
    
    CALayer *shadowLayer = [CALayer layer];
    shadowLayer.masksToBounds = NO;
    shadowLayer.frame = alertView.bounds;
    shadowLayer.backgroundColor = [UIColor clearColor].CGColor;
    shadowLayer.shadowColor = [UIColor blackColor].CGColor;
    shadowLayer.shadowOffset = CGSizeMake(0.0f, 0.f);
    shadowLayer.shadowOpacity = 0.65f;
    shadowLayer.shadowRadius = 2.0f;
    shadowLayer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:shadowRect
                                                   byRoundingCorners:UIRectCornerAllCorners
                                                         cornerRadii:CGSizeMake(alertView.layer.cornerRadius, alertView.layer.cornerRadius)].CGPath;
    
    CALayer *mask = [CALayer layer];
    mask.frame = CGRectMake(-10, -10, shadowRect.size.width + 20, shadowRect.size.height + 15.0f);
    mask.masksToBounds = NO;
    mask.borderColor = [UIColor whiteColor].CGColor;
    mask.borderWidth = 10.0f;
    mask.cornerRadius = 20.0f;
    
    shadowLayer.mask = mask;

    return shadowLayer;
}

@end
