//
//  LoginViewController.m
//  Tubor
//
//  Created by Marcelo Sedano on 3/24/15.
//  Copyright (c) 2015 Marcelo Sedano. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet TuborBlueButton *loginButton;
@property (weak, nonatomic) IBOutlet TuborBlueButton *registerButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
- (IBAction)login:(id)sender;
- (IBAction)register:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([PFUser currentUser]) {
        [self performSegueWithIdentifier:@"loginToProfileSegue" sender:self];
    }

    // Initialize text for buttons
    self.loginButton.buttonText = @"Log in";
    self.registerButton.buttonText = @"Register";
    
    // Initialize placeholder text for each text field
    self.usernameText.placeholder = @"Username";
    self.passwordText.placeholder = @"Password";
    
    // Supposed to hide "Back" button in navigation bar >:(
    [self.navigationItem setHidesBackButton:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    // Hide navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

// Delegate methods for the textfield placeholders

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //[textField setValue:[UIColor clearColor] forKeyPath:@"_placeholderLabel.textColor"];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    //[textField setValue:[UIColor colorWithWhite: 0.70 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
}

// Hides keyboard when user taps somewhere other than the keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"loginToProfileSegue"]) {
        UITabBarController *tabBarVC = [[segue.destinationViewController viewControllers] firstObject];
        ProfileViewController *userProfileViewController = [[tabBarVC viewControllers] firstObject];

        // If you need to pass data to the next controller do it here
        userProfileViewController.user = [PFUser currentUser];
        userProfileViewController.previousVC = @"Login";
    }
}

- (IBAction)login:(id)sender {
    // Get the username and password from the text fields
    NSString *username = [NSString stringWithString:self.usernameText.text];
    NSString *password = [NSString stringWithString:self.passwordText.text];
    
    // Try to login
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
        if (user) {
            user[@"studentAvailable"] = @YES;
            user[@"isAvailable"] = @NO;
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            currentInstallation[@"username"] = [PFUser currentUser].username;
            [[PFUser currentUser] saveInBackground];
            
            [self performSegueWithIdentifier:@"loginToProfileSegue" sender:self];
        } else {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Invalid username or password"
                                  message:[NSString stringWithFormat: @"\nThe username and password you entered did not match our records.  Please double-check and try again."]
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}
- (IBAction)register:(id)sender {
    [self performSegueWithIdentifier:@"loginToRegistrationSegue" sender:self];
}
@end