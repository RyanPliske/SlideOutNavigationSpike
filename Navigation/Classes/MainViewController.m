//
//  MainViewController.m
//  Navigation
//
//  Created by Tammy Coron on 1/19/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MainViewController.h"
#import "CenterViewController.h"
#import "LeftPanelViewController.h"

#define CENTER_TAG 1
#define LEFT_PANEL_TAG 2
#define CORNER_RADIUS 4
#define SLIDE_TIMING .25
#define PANEL_WIDTH 60

@interface MainViewController () <CenterViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) CenterViewController *centerViewController;
@property (nonatomic) LeftPanelViewController * leftPanelViewController;
@property (nonatomic, assign) BOOL showingLeftPanel;
@property (nonatomic, assign) BOOL showPanel;
@property (nonatomic, assign) CGPoint preVelocity;

@end

@implementation MainViewController

#pragma mark -
#pragma mark View Did Load/Unload

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.centerViewController = [[CenterViewController alloc] initWithNibName:@"CenterViewController" bundle:nil];
    self.centerViewController.view.tag = CENTER_TAG;
    self.centerViewController.delegate = self;
    
    [self.view addSubview:self.centerViewController.view];
    [self addChildViewController:self.centerViewController];
    [self setupGestures];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark -
#pragma mark View Will/Did Appear

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

#pragma mark -
#pragma mark View Will/Did Disappear

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Setup View
- (void)showCenterViewWithShadow:(BOOL)value withOffset:(double)offset
{
    if (value) {
        [self.centerViewController.view.layer setCornerRadius:CORNER_RADIUS];
        [self.centerViewController.view.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.centerViewController.view.layer setShadowOpacity:0.8];
        [self.centerViewController.view.layer setShadowOffset:CGSizeMake(offset, offset)];
    } else {
        [self.centerViewController.view.layer setCornerRadius:0.0f];
        [self.centerViewController.view.layer setShadowOffset:CGSizeMake(offset, offset)];
    }
}

- (void)resetMainView
{
    if (self.leftPanelViewController != nil) {
        [self.leftPanelViewController.view removeFromSuperview];
        self.leftPanelViewController = nil;
        
        self.centerViewController.leftButton.tag = 1;
        self.showingLeftPanel = NO;
    }
    
    [self showCenterViewWithShadow:NO withOffset:0.0];
}

- (UIView *)getLeftView
{    
    if (self.leftPanelViewController == nil) {
        self.leftPanelViewController = [[LeftPanelViewController alloc] initWithNibName:@"LeftPanelViewController" bundle:nil];
        self.leftPanelViewController.view.tag = LEFT_PANEL_TAG;
        self.leftPanelViewController.delegate = _centerViewController;
        
        [self.view addSubview:self.leftPanelViewController.view];
        
        [self addChildViewController:self.leftPanelViewController];
        self.leftPanelViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    self.showingLeftPanel = YES;
    
    [self showCenterViewWithShadow:YES withOffset:-2];
    
    UIView *view = self.leftPanelViewController.view;
    return view;
}

- (UIView *)getRightView
{     
    UIView *view = nil;
    return view;
}

#pragma mark -
#pragma mark Swipe Gesture Setup/Actions

#pragma mark - setup

- (void)setupGestures
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    
    [self.centerViewController.view addGestureRecognizer:panRecognizer];
}

-(void)movePanel:(id)sender
{
    UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer*)sender;
    [tapRecognizer.view.layer removeAllAnimations];
    
    UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer*)sender;
    CGPoint translatedPoint = [panRecognizer translationInView:self.view];
    CGPoint velocity = [panRecognizer velocityInView:[sender view]];
    
    switch ([panRecognizer state]) {
            
        case UIGestureRecognizerStateBegan:
        {
            UIView *childView = [self getLeftView];
            [self.view sendSubviewToBack:childView];
            [[sender view] bringSubviewToFront:panRecognizer.view];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
            if (self.showPanel) {
                [self movePanelRight];
            } else {
                [self movePanelToOriginalPosition];
            }
            break;
            
        case UIGestureRecognizerStateChanged:
            // Show or Hide panel according to midwawy point of the screen
            self.showPanel = fabs([sender view].center.x - self.centerViewController.view.frame.size.width/2) > self.centerViewController.view.frame.size.width/2;
            // Allow dragging only in x-coordinate by only updating the x coordinate of the recognizer
            [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x, [sender view].center.y);
            [panRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];
            self.preVelocity = velocity;
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark Delegate Actions

- (void)movePanelLeft // to show right panel
{
}

- (void)movePanelRight // to show left panel
{
    UIView *childView = [self getLeftView];
    [self.view sendSubviewToBack:childView];
    
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.centerViewController.view.frame = CGRectMake(self.view.frame.size.width - PANEL_WIDTH, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    completion:^(BOOL finished) {
        if (finished) {
            self.centerViewController.leftButton.tag = 0;
        }
    }];
}

- (void)movePanelToOriginalPosition
{
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.centerViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            [self resetMainView];
        }
    }];
}

#pragma mark -
#pragma mark Default System Code

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
