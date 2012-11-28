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

#import "WHFlatCustomizer.h"

#define BUTTON_EDGE_INSETS UIEdgeInsetsMake(0.0f, 13.0f, 0.0f, 13.0f)

@implementation WHFlatCustomizer

- (UIImage *) stretchableImageForCancelButtonInAlertView:(WHAlertView *)alertView {
    return [[UIImage imageNamed:@"flatButton.png"] resizableImageWithCapInsets:BUTTON_EDGE_INSETS];
}

- (UIImage *) stretchableImageForOtherButtonsInAlertView:(WHAlertView *)alertView {
    return [[UIImage imageNamed:@"flatButton.png"] resizableImageWithCapInsets:BUTTON_EDGE_INSETS];
}

- (UIImage *) stretchablePressedImageForCancelButtonInAlertView:(WHAlertView *)alertView {
    return [[UIImage imageNamed:@"flatButtonPressed.png"] resizableImageWithCapInsets:BUTTON_EDGE_INSETS];
}

- (UIImage *) stretchablePressedImageForOtherButtonsInAlertView:(WHAlertView *)alertView {
    return [[UIImage imageNamed:@"flatButtonPressed.png.png"] resizableImageWithCapInsets:BUTTON_EDGE_INSETS];
}

- (UIColor *) backgroundColorForAlertView:(WHAlertView *)alertView {
    return [UIColor colorWithWhite:0.95f alpha:1.0];
}

- (UIColor *) titleTextColorForAlertView:(WHAlertView *)alertView {
    return [UIColor colorWithWhite:0.2 alpha:1.0f];
}

- (UIColor *) messageTextColorForAlertView:(WHAlertView *)alertView {
    return [UIColor colorWithWhite:0.2 alpha:1.0f];
}

- (UIColor *) buttonTextColorForAlertView:(WHAlertView *)alertView {
    return [UIColor colorWithWhite:0.2 alpha:1.0f];
}

- (UIColor *) titleTextShadowColorForAlertView:(WHAlertView *)alertView {
    return [UIColor clearColor];
}

- (UIColor *) messageTextShadowColorForAlertView:(WHAlertView *)alertView {
    return [UIColor clearColor];
}

- (UIColor *) buttonTextShadowColorForAlertView:(WHAlertView *)alertView {
    return [UIColor clearColor];
}

- (UIFont *) titleFontForAlertView:(WHAlertView *)alertView {
    return [UIFont fontWithName:@"Courier-Bold" size:16.0f];
}

- (UIFont *) messageFontForAlertView:(WHAlertView *)alertView {
    return [UIFont fontWithName:@"Courier" size:15.0f];
}

- (UIFont *) buttonTitlesFontForAlertView:(WHAlertView *)alertView {
    return [UIFont fontWithName:@"Courier-Bold" size:15.0f];
}

- (BOOL)shouldIncludeShineEffectForAlertView:(WHAlertView *)alertView {
    return NO;
}

- (void)customizeUIForAlertView:(WHAlertView *)alertView {
    alertView.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.9f].CGColor;
    alertView.layer.borderWidth = 2.0f;
    alertView.layer.cornerRadius = 10.0f;
}

@end
