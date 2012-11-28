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

#import "WHFlyInAlertViewAnimator.h"

@implementation WHFlyInAlertViewAnimator

- (void (^)(void))showAnimationForAlertView:(WHAlertView *)alertView {
    CATransform3D fromMatrix = CATransform3DMakeRotation(M_PI_2, 1.0, 0.0f, 0.0f);
    fromMatrix = CATransform3DScale(fromMatrix, 2.3f, .3f, 0.3f);
    fromMatrix.m34 = -1.0f / 500.0f;
    alertView.alpha = 0.0f;

    [self setAnchorPoint:CGPointMake(0.5f, 1.0f) forView:alertView];

    CGPoint center = alertView.center;
    alertView.center = CGPointMake(center.x, center.y + alertView.bounds.size.height);

    alertView.layer.transform = fromMatrix;
    alertView.layer.zPosition = 100.0f;
    return ^ {
        alertView.alpha = 1.0f;
        alertView.center = center;
        alertView.layer.transform = CATransform3DIdentity;
    };
}

- (void (^)(BOOL finished))showCompletionForAlertView:(WHAlertView *)alertView {
    CATransform3D toMatrix = CATransform3DMakeRotation(-M_PI_4 + 0.50f, 1.0, 0.0f, 0.0f);

    float duration = 0.20f;
    
    return ^(BOOL finished){
        [UIView animateWithDuration:duration * 0.5f
                         animations:^{
                             alertView.layer.transform = toMatrix;
                         } completion:^(BOOL finished) {
                             [UIView animateWithDuration:duration * 0.5f
                                              animations:^{
                                                  alertView.layer.transform = CATransform3DIdentity;
                                              }];
                         }];
    };
}

- (void (^)(void))dismissAnimationForAlertView:(WHAlertView *)alertView {
    CATransform3D fromMatrix = CATransform3DMakeRotation(-M_PI_2 + 0.50, 1.0, 0.0f, 0.0f);
    fromMatrix = CATransform3DScale(fromMatrix, 0.6f, 0.6f, 0.6f);
    fromMatrix.m34 = -1.0f / 500.0f;

    [self setAnchorPoint:CGPointMake(0.5f, 1.0f) forView:alertView];

    CGPoint center = alertView.center;
    alertView.layer.zPosition = 100.0f;
    return ^{
        alertView.layer.transform = fromMatrix;
        alertView.center = CGPointMake(center.x, center.y + (alertView.bounds.size.height * 0.1));
        alertView.alpha = 0.0f;
    };
}

#pragma mark - Optional Methods

- (CGFloat)showAnimationDuration {
    return 0.33;
}

- (CGFloat)dismissAnimationDuration {
    return 0.33;
}

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

@end
