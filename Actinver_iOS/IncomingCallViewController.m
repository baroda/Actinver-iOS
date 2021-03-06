//
//  IncomingCallViewController.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 16.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "IncomingCallViewController.h"
#import "ContainerViewController.h"
#import "ConnectionManager.h"
#import "CornerView.h"
#import "IAButton.h"
#import "QMSoundManager.h"
#import "SettingsCallViewController.h"


#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Quickblox/Quickblox.h>
#import <QuickbloxWebRTC/QuickbloxWebRTC.h>

@interface IncomingCallViewController () <QBRTCClientDelegate>

@property (weak, nonatomic) IBOutlet UILabel *callStatusLabel;
@property (weak, nonatomic) IBOutlet UITextView *callInfoTextView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet CornerView *colorMarker;
@property (weak, nonatomic) IBOutlet IAButton *declineBtn;
@property (weak, nonatomic) IBOutlet IAButton *acceptBtn;
@property (weak, nonatomic) NSTimer *dialignTimer;

@end

@implementation IncomingCallViewController

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [QBRTCClient.instance addDelegate:self];
    self.users = [ConnectionManager.instance usersWithIDS:self.session.opponents];
    [self confiugreGUI];
    
    self.dialignTimer =
    [NSTimer scheduledTimerWithTimeInterval:[QBRTCConfig dialingTimeInterval]
                                     target:self
                                   selector:@selector(dialing:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)dialing:(NSTimer *)timer {
    
    [QMSoundManager playRingtoneSound];
}

#pragma mark - Update GUI

- (void)confiugreGUI {
    
    [self defaultToolbarConfiguration];
    [self updateOfferInfo];
    [self updateCallInfo];
}

- (void)defaultToolbarConfiguration {
 
    [self.toolbar setBackgroundImage:[[UIImage alloc] init]
                  forToolbarPosition:UIToolbarPositionAny
                          barMetrics:UIBarMetricsDefault];
    
    [self.toolbar setShadowImage:[[UIImage alloc] init]
              forToolbarPosition:UIToolbarPositionAny];
    
    [self configureAIButton:self.declineBtn
              withImageName:@"decline"
                    bgColor:[UIColor colorWithRed:0.906 green:0.000 blue:0.191 alpha:1.000]
              selectedColor:[UIColor colorWithRed:0.916 green:0.668 blue:0.683 alpha:1.000]];

    
    [self configureAIButton:self.acceptBtn
              withImageName:@"answer"
                    bgColor:[UIColor colorWithRed:0.130 green:0.889 blue:0.074 alpha:1.000]
              selectedColor:[UIColor colorWithRed:0.596 green:0.920 blue:0.647 alpha:1.000]];
}

- (void)updateOfferInfo {
    
    QBUUser *caller = [ConnectionManager.instance userWithID:self.session.callerID];
    
    self.colorMarker.bgColor = caller.color;
    self.colorMarker.title = caller.fullName;
    self.colorMarker.fontSize = 30.f;
}

- (void)updateCallInfo {
    
    NSMutableArray *info = [NSMutableArray array];
    
    [self.users enumerateObjectsUsingBlock:^(QBUUser *user, NSUInteger idx, BOOL *stop) {
        [info addObject:[NSString stringWithFormat:@"%@(ID %@)", user.fullName, @(user.ID)]];
    }];
    
    self.callInfoTextView.text = [info componentsJoinedByString:@", "];
    self.callInfoTextView.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:19];
    self.callInfoTextView.textAlignment = NSTextAlignmentCenter;
    
    NSString *text =
    self.session.conferenceType == QBConferenceTypeVideo ? @"Incoming video call" : @"Incoming audio call";
    self.callStatusLabel.text = NSLocalizedString(text, nil);
}

#pragma mark - Actions

- (void)cleanUp {
    
    [self.dialignTimer invalidate];
    self.dialignTimer = nil;
    
    [QBRTCClient.instance removeDelegate:self];
    [QMSysPlayer stopAllSounds];
}

- (IBAction)pressAcceptCall:(id)sender {
    
    [self cleanUp];
    [self.containerViewController next];
}

- (IBAction)pressDeclineBtn:(id)sender {
    
    [self cleanUp];
    [self.session rejectCall:@{@"reject" : @"busy"}];

    
}

- (void)sessionWillClose:(QBRTCSession *)session {
    
    [self cleanUp];
}

@end
