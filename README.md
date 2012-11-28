#WHAlertView: Have your alerts and eat them too.

##What is it
Alert views that can have their own custom animations and skinned UI.

##Why I made it
Because I wanted cool alert views like TweetBot.  I wanted to be able to have custom animations for presenting and dismissing alerts, as well as be able to customize the UI. **This is really rough code that still needs a lot of work.  I wanted to get it out so people could get their hands on it to spark their imaginations on how alerts can be done differently on iOS.**

##How to use it
WHAlertView has three different ways to instantiate an alert:

###An API similar to UIAlertView:
    - (id)initWithTitle:(NSString *)title 
                message:(NSString *)message
               delegate:(id<WHAlertViewDelegate>)delegate
      cancelButtonTitle:(NSString *)cancelButtonTitle 
      otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

Or:

###An API similar to [UIAlertView+Blocks](https://github.com/jivadevoe/UIAlertView-Blocks)*:
    - (id)initWithTitle:(NSString *)title
                message:(NSString *)message
       cancelButtonItem:(WHAlertButtonItem *)cancelButtonItem 
       otherButtonItems:(WHAlertButtonItem *)otherButtonItems, ... NS_REQUIRES_NIL_TERMINATION;

Or:

      - (id)initWithTitle:(NSString *)title
                  message:(NSString *)message
         cancelButtonItem:(WHAlertButtonItem *)cancelButtonItem
    otherButtonItemsArray:(NSArray *)otherButtonItems;

I'm pretty partial to block-based APIs:

    WHAlertButtonItem *cancel = [WHAlertButtonItem alertButtonItemWithTitle:@"Cancel"];
    WHAlertButtonItem *ok = [WHAlertButtonItem alertButtonItemWithTitle:@"OK"
                                                                 action:^{
                                                                     NSLog(@"Pressed OK!");
                                                                 }];

    WHAlertView *alert = [[WHAlertView alloc] initWithTitle:@"Hello!"
                                                    message:@"This is an alert"
                                           cancelButtonItem:cancel
                                           otherButtonItems:ok, nil];
    [alert show];

It's that easy!

###But how do I customize the animations or UI?
In addition to a delegate protocol, `WHAlertView` defines two other protocols that your custom classes need to implement: `WHAlertViewAnimator` and `WHAlertViewCustomizer`.  You can assign an instance of `WHAlertView` with implementors of those protocols, ***or*** use the following API to register a class that implements those protocols:

    [WHAlertView registerAnimationClassForAlertAnimations:[WHTweetBotAlertViewAnimator class]];

Or:

    [WHAlertView registerCustomizerClassForAlertUI:[WHFlatCustomizer class]];

Registering a class saves you the trouble of having to instantiate and assign instances of those classes every time you need to pop up an alert: Your *custom* alerts should be *consistent* throughout your app.  The override is in place for instances where you may have a special kind of animation or custom alert that only needs to be shown in certain situations:

    WHAlertView *alert = [[WHAlertView alloc] initWithTitle:@"Hello!"
                                                    message:@"This is an alert"
                                           cancelButtonItem:cancel
                                           otherButtonItems:ok, nil];
    alert.animator = [[WHPinWheelAlertViewAnimator alloc] init]
    [alert show];

Here's an example implementation of an animator:

    #import "WHDropAlertViewAnimator.h"

    @interface WHDropAlertViewAnimator()

    @property (nonatomic, assign) CGPoint originalCenter;

    @end

    @implementation WHDropAlertViewAnimator

    - (void (^)(void))showAnimationForAlertView:(WHAlertView *)alertView {
        CGPoint center = alertView.center;
        alertView.center = CGPointMake(alertView.center.x, -alertView.window.bounds.size.height);
        self.originalCenter = center;
        alertView.alpha = 0.0f;

        return ^ {
            alertView.center = CGPointMake(center.x, center.y + 25.0f);
            alertView.alpha = 1.0f;
        };
    }

    - (void (^)(BOOL finished))showCompletionForAlertView:(WHAlertView *)alertView {
        return ^(BOOL finished){
            [UIView animateWithDuration:0.2
                             animations:^{
                                 alertView.center = self.originalCenter;
                             }];
        };
    }

    - (void (^)(void))dismissAnimationForAlertView:(WHAlertView *)alertView {
        return ^{
            alertView.center = CGPointMake(alertView.center.x, alertView.bounds.size.height + alertView.window.bounds.size.height);
        };
    }

    @end
    
##Requirements

- Tested on iOS 5+  
- Uses ARC  
- Uses modern Objective-C syntax, so you'll need Xcode 4.4+

##Known Issues

- The `layoutSubviews` needs a little bit of cleanup
- Accessory view is not yet implemented (but will be implemented when `layoutSubviews` is fixed
- Window rotation code needs some refactoring


##License

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

##Recognition

*Hat tip to [jivadevoe](https://github.com/jivadevoe) for inspiring a great blocks-based API for UIAlertView.



