//
//  SessionViewController.m
//  Tubor
//
//  Created by Marcelo Sedano on 5/6/15.
//  Copyright (c) 2015 Marcelo Sedano. All rights reserved.
//

#import "SessionViewController.h"

@interface SessionViewController ()

@end

@implementation SessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.user = [PFUser currentUser];
    
    [self.navigationItem setTitle:@"Current Session"];
    
    // Initialize end session button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"End" style:UIBarButtonItemStylePlain target:self action:@selector(endSession)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor]; // Color of button
    
    // Back button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButton)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor]; // Color of button
    
    // If student
    if (self.user[@"tutorInSession"])
    {
        // Initialize session info
        self.tutorLabel.text = self.user[@"tutorInSession"];
        self.studentLabel.text = self.user[@"fullName"];
        self.locationLabel.text = self.user[@"location"];
        self.courseLabel.text = self.user[@"courseRequested"];
        self.topicsTextView.text = self.user[@"topicsDescription"];
    }
    
    // If tutor
    else
    {
        // Initialize session info
        self.tutorLabel.text = self.user[@"fullName"];
        self.studentLabel.text = self.user[@"studentInSession"];
        self.locationLabel.text = self.user[@"location"];
        self.courseLabel.text = self.user[@"courseRequested"];
        self.topicsTextView.text = self.user[@"topicsDescription"];
    }
}

-(void)endSession
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:[NSString stringWithFormat: @"Are you sure you want to end your current session?"]
                          message:nil
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"End", nil];
    [alert setTag: 0];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // End session alert
    if (alertView.tag == 0 && buttonIndex == 1)
    {
        // Push notification to tutor that session has ended
        
        NSString *userToSearch;
        
        // If student is ending session
        if (self.user[@"tutorInSession"])
        {
            userToSearch = self.user[@"tutorInSession"];
            
            PFQuery *query = [PFUser query];
            [query whereKey:@"fullName" equalTo:userToSearch];
            [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
             {
                 self.tutor = [results objectAtIndex:0];
                 
                 PFQuery *pushQuery = [PFInstallation query];
                 [pushQuery whereKey:@"username" equalTo:self.tutor.username];
                 
                 NSString *message = [NSString stringWithFormat:@"%@ has ended the tutoring session.", self.user[@"fullName"]];
                 
                 NSDictionary *data = @{
                                        @"alert"            : message,
                                        @"content-available" : @"1",
                                        @"notificationName" : @"sessionEnded"
                                        };
                 
                 PFPush *push = [[PFPush alloc] init];
                 [push setQuery:pushQuery];
                 [push setData:data];
                 [push sendPushInBackground];
                 
                 // Check if student wants to rate tutor
                 UIAlertView *requestRatingAlert = [[UIAlertView alloc]
                                             initWithTitle:@"Tutoring session ended"
                                             message:[NSString stringWithFormat: @"\nYou can now request another tutor or make yourself available to tutor."]
                                             delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:@"Rate Tutor", nil];
                 
                 [requestRatingAlert setTag: 1];
                 [requestRatingAlert show];
             }];
        }
        
        // If tutor is ending session
        else
        {
            userToSearch = self.user[@"studentInSession"];
            
            PFQuery *query = [PFUser query];
            [query whereKey:@"fullName" equalTo:userToSearch];
            [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
             {
                 PFUser *foundUser = [results objectAtIndex:0];
                 
                 PFQuery *pushQuery = [PFInstallation query];
                 [pushQuery whereKey:@"username" equalTo:foundUser.username];
                 
                 NSString *message = [NSString stringWithFormat:@"%@ has ended the tutoring session.", self.user[@"fullName"]];
                 
                 NSDictionary *data = @{
                                        @"alert"            : message,
                                        @"content-available" : @"1",
                                        @"notificationName" : @"sessionEnded"
                                        };
                 
                 PFPush *push = [[PFPush alloc] init];
                 [push setQuery:pushQuery];
                 [push setData:data];
                 [push sendPushInBackground];
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionEnded" object:self userInfo:nil];
                 [self.user saveInBackground];
                 [self dismissViewControllerAnimated:YES completion:nil];
             }];
        }
    }
    
    // Student chooses not to rate tutor
    if ((alertView.tag == 1 && buttonIndex == 0) || (alertView.tag == 2 && buttonIndex == 0))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionEnded" object:self userInfo:nil];
        [self.user saveInBackground];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    // Student chooses to rate tutor
    if (alertView.tag == 1 && buttonIndex == 1)
    {
        UIAlertView *ratingAlert = [[UIAlertView alloc]
                                    initWithTitle:@"Rate Your Tutor"
                                    message:nil
                                    delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    otherButtonTitles:@"1", @"2", @"3", @"4", @"5", nil];
        
        [ratingAlert setTag: 2];
        [ratingAlert show];
    }
    
    // Student rates tutor
    if (alertView.tag == 2 && buttonIndex != 0)
    {
        double rating, ratingCount;
        
        // First rating for tutor
        if (!self.tutor[@"ratingCount"])
        {
            rating = 0;
            ratingCount = 0;
        }
        else
        {
            rating = [self.tutor[@"rating"] doubleValue];
            ratingCount = [self.tutor[@"ratingCount"] doubleValue];
        }
        
        double selectedRating = (double) buttonIndex;
        
        ratingCount++;
        double newRating = (rating + selectedRating) / ratingCount;
        
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"username" equalTo:self.tutor.username];
        
        NSDictionary *data = @{
                               @"content-available" : @"1",
                               @"notificationName"  : @"ratingPush",
                               @"newRating"         : [NSNumber numberWithDouble:newRating],
                               @"ratingCount"       : [NSNumber numberWithDouble:ratingCount]
                               };
        
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery];
        [push setData:data];
        [push sendPushInBackground];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionEnded" object:self userInfo:nil];
        [self.user saveInBackground];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)backButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
