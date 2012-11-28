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

#import "WHSpinAlertViewAnimator.h"

@implementation WHSpinAlertViewAnimator

- (void (^)(void))showAnimationForAlertView:(WHAlertView *)alertView {
    CATransform3D fromMatrix = CATransform3DMakeRotation(M_PI_2, 0.0f, 1.0f, 0.0f);
    fromMatrix.m34 = -1.0 / 500.0f;

    CATransform3D toMatrix = CATransform3DMakeRotation(-M_PI, 0.0f, 1.0f, 0.0f);
    
    alertView.layer.transform = fromMatrix;
    alertView.layer.zPosition = 100.0f;

    return ^ {
        alertView.layer.transform = toMatrix;
    };
}

- (void (^)(BOOL finished))showCompletionForAlertView:(WHAlertView *)alertView {
    return ^(BOOL finished){
        [UIView animateWithDuration:0.3f
                         animations:^{
                             alertView.layer.transform = CATransform3DIdentity;
                         } completion:^(BOOL finished) {
                             alertView.layer.zPosition = 0.0f;
                         }];
    };
}

 - (void (^)(void))dismissAnimationForAlertView:(WHAlertView *)alertView {
     CATransform3D toMatrix = CATransform3DMakeRotation(M_PI_2, 0.0f, 1.0f, 0.0f);
     toMatrix.m34 = 1.0 / 500.0f;
     alertView.layer.zPosition = 100.0f;

     return ^{
         [UIView animateWithDuration:0.15f
                          animations:^{
                              alertView.layer.transform = toMatrix;
                          }];
     };
 }

#pragma mark - Optional Methods

- (CGFloat)showAnimationDuration {
    return 0.33;
}

- (CGFloat)dismissAnimationDuration {
    return 0.33;
}

- (void (^)(BOOL finished))dismissCompletionForAlertView:(WHAlertView *)alertView {
    return ^(BOOL finished){
        CATransform3D toMatrix = CATransform3DMakeRotation(M_PI_2, 0.0f, 1.0f, 0.0f);
        toMatrix.m34 = 1.0 / 500.0f;

        [UIView animateWithDuration:0.15f
                         animations:^{
                             alertView.layer.transform = toMatrix;
                         }];
    };
}

@end
