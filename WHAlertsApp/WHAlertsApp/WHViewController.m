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

#import "WHViewController.h"
#import "WHAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import "WHClassNameDataSource.h"

typedef enum {
    WHDataSourceAnimation = 0,
    WHDataSourceCustomization
} WHDataSource;

@interface WHViewController ()

@property (nonatomic, strong) WHClassNameDataSource *animationDataSource;
@property (nonatomic, strong) WHClassNameDataSource *customizationDataSource;
@property (nonatomic, strong) IBOutlet UISegmentedControl *dataSourceSwitcher;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation WHViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *classData = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Classes" ofType:@"plist"]];
    self.animationDataSource = [[WHClassNameDataSource alloc] init];
    self.customizationDataSource = [[WHClassNameDataSource alloc] init];

    self.animationDataSource.classItems = classData[@"animationClasses"];
    self.customizationDataSource.classItems = classData[@"customizationClasses"];

    [self updateDataSourceAnimated:NO];
}

- (void)viewDidUnload {
    [self setDataSourceSwitcher:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark - Instance Methods

- (void)updateDataSourceAnimated:(BOOL)animated {
    WHDataSource dataSource = self.dataSourceSwitcher.selectedSegmentIndex;
    switch (dataSource) {
        case WHDataSourceAnimation: {
            self.tableView.dataSource = self.animationDataSource;
            self.tableView.delegate = self.animationDataSource;
        }
            break;
        case WHDataSourceCustomization: {
            self.tableView.dataSource = self.customizationDataSource;
            self.tableView.delegate = self.customizationDataSource;
        }
            break;
        default:
            break;
    }
    if (animated) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.tableView reloadData];
    }
}

#pragma mark - Actions

- (IBAction)showAlert:(id)sender {
//    [WHAlertView registerAnimationClassForAlertAnimations:[WHTweetBotAlertViewAnimator class]];

    
    WHAlertButtonItem *cancel = [WHAlertButtonItem alertButtonItemWithTitle:@"Cancel"
                                                                     action:^{
                                                                         NSLog(@"cancelled!!!");
                                                                     }];
    WHAlertButtonItem *ok = [WHAlertButtonItem alertButtonItemWithTitle:@"OK"
                                                                     action:^{
                                                                         NSLog(@"OK!!!");
                                                                     }];

    WHAlertView *alert = [[WHAlertView alloc] initWithTitle:@"Check It Out!"
                                                    message:@"This custom alert view is almost ready for release!"
                                           cancelButtonItem:cancel
                                           otherButtonItems:ok, nil];
    
    /*  It is not necessary to set the animator and customizer every time you want to show an alert, we're just doing so here for demo
     *  purposes.  You can register a class at any time and all instances will instantiate the registered class.  These are just override
     *  points in cases where you want a special kind of alert.
     */
    alert.animator = [[[self.animationDataSource selectedClass] alloc] init];
    alert.customizer = [[[self.customizationDataSource selectedClass] alloc] init];

    [alert show];
 }

- (IBAction)showNormalAlert:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Check It Out!"
                                                    message:@"This custom alert view is almost ready for release!"
                                                   delegate:nil
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", @"Maybe", nil];
    [alert show];
}


- (IBAction)dataSourceDidChange:(id)sender {
    [self updateDataSourceAnimated:YES];
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
