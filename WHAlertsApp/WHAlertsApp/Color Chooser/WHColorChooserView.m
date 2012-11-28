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

#import "WHColorChooserView.h"

@interface WHColorChooserView()

@property (strong, nonatomic) IBOutlet UISlider *rSlider;
@property (strong, nonatomic) IBOutlet UISlider *gSlider;
@property (strong, nonatomic) IBOutlet UISlider *bSlider;
@property (strong, nonatomic) IBOutlet UISlider *aSlider;

@property (strong, nonatomic) IBOutlet UITextField *rTextField;
@property (strong, nonatomic) IBOutlet UITextField *gTextField;
@property (strong, nonatomic) IBOutlet UITextField *bTextField;
@property (strong, nonatomic) IBOutlet UITextField *aTextField;

@end

@implementation WHColorChooserView

#pragma mark - Initializer

+ (WHColorChooserView *)colorChooserViewWithNibName:(NSString *)nibName {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];

    WHColorChooserView *colorChooser = nil;

    for(id currentObject in topLevelObjects) {
        if([currentObject isKindOfClass:[WHColorChooserView class]]) {
            colorChooser = (WHColorChooserView *)currentObject;
            break;
        }
    }

    return colorChooser;
}

#pragma mark - Actions

- (IBAction)sliderDidChange:(UISlider *)sender {
    UIColor *trackColor;
    UISlider *sliderToChange;
    
    float red = self.rSlider.value / 255.0f;
    float green = self.gSlider.value / 255.0f;
    float blue = self.bSlider.value / 255.0f;
    float alpha = self.aSlider.value / 255.0f;

    if (sender == self.rSlider) {
        trackColor = [UIColor colorWithRed:red
                                     green:0.0f
                                      blue:0.0f
                                     alpha:1.0f];
        sliderToChange = self.rSlider;
    } else if (sender == self.gSlider) {
        trackColor = [UIColor colorWithRed:0.0f
                                     green:green
                                      blue:0.0f
                                     alpha:1.0f];
        sliderToChange = self.gSlider;
    } else if (sender == self.bSlider) {
        trackColor = [UIColor colorWithRed:0.0f
                                     green:0.0f
                                      blue:blue
                                     alpha:1.0f];
        sliderToChange = self.bSlider;
    } else if (sender == self.aSlider) {
        trackColor = [UIColor colorWithRed:0.0f
                                     green:0.0f
                                      blue:0.0f
                                     alpha:alpha];
        sliderToChange = self.aSlider;
    }

    [sliderToChange setMinimumTrackTintColor:trackColor];
    
    if (self.OnColorChanged) {
        UIColor *newColor = [UIColor colorWithRed:red
                                            green:green
                                             blue:blue
                                            alpha:alpha];

        self.OnColorChanged(newColor);
    }
}

@end
