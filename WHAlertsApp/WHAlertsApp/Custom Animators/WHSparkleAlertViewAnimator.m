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

#import "WHSparkleAlertViewAnimator.h"

@implementation WHSparkleAlertViewAnimator

- (void (^)(void))showAnimationForAlertView:(WHAlertView *)alertView {
    CAEmitterCell *stars = [CAEmitterCell emitterCell];
    stars.contents = (id)[UIImage imageNamed:@"tspark.png"].CGImage;
    stars.birthRate = 30;
    stars.scale = 0.6;
    stars.velocity = 100;
    stars.lifetime = 5;
    stars.alphaRange = -0.2f;
    stars.alphaSpeed = -0.2f;
    stars.duration = 1.0f;
    stars.emissionRange = 2 * M_PI;
    stars.scaleSpeed = -0.1;
    stars.spin = 2;

    CAEmitterLayer* emitter = [CAEmitterLayer layer];
    emitter.renderMode = kCAEmitterLayerAdditive;
    emitter.emitterCells = @[stars];
    emitter.position = CGPointMake(alertView.frame.size.width * 0.5f, alertView.frame.size.height * 0.5f);
    emitter.backgroundColor = [UIColor redColor].CGColor;
    emitter.opacity = 0.5f;

    [alertView.layer insertSublayer:emitter atIndex:0];

    CGAffineTransform transform = CGAffineTransformMakeScale(0.01f, 0.01f);
    alertView.transform = transform;
    alertView.alpha = 0.0f;

    return ^ {
        alertView.transform = CGAffineTransformIdentity;
        alertView.alpha = 1.0f;
    };
}

- (void (^)(void))dismissAnimationForAlertView:(WHAlertView *)alertView {
    CGAffineTransform transform = CGAffineTransformMakeScale(0.01f, 0.01f);

    return ^(){
        [UIView animateWithDuration:0.2
                         animations:^{
                             alertView.transform = transform;
                             alertView.alpha = 0.0f;
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
        
    };
}

@end
