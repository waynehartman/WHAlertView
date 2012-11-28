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

#import "WHTweetBotAlertViewAnimator.h"

@implementation WHTweetBotAlertViewAnimator

#pragma mark - WHAlertViewAnimator

- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view {
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y);

    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);

    CGPoint position = view.layer.position;

    position.x -= oldPoint.x;
    position.x += newPoint.x;

    position.y -= oldPoint.y;
    position.y += newPoint.y;

    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

- (void (^)(void))showAnimationForAlertView:(WHAlertView *)alertView {
    alertView.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
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

- (void (^)(void))dismissAnimationForAlertView:(WHAlertView *)alertView {
    [self setAnchorPoint:CGPointMake(1.0f, 1.0f) forView:alertView];

    return ^{
        alertView.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
        alertView.center  = CGPointMake(alertView.center.x, alertView.center.y + alertView.superview.bounds.size.height * 0.5);
    };
}

- (CGFloat)showAnimationDuration {
    return 0.25;
}

- (CGFloat)dismissAnimationDuration {
    return 0.5f;
}

@end
