//
//  RegistrationViewController.m
//  Tubor
//
//  Created by Marcelo Sedano on 3/24/15.
//  Copyright (c) 2015 Marcelo Sedano. All rights reserved.
//

#import "RegistrationViewController.h"

#define trimString(object) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
#define USERNAME_MIN 4
#define USERNAME_MAX 10
#define PASSWORD_MIN 4
#define PASSWORD_MAX 10

@interface RegistrationViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordText;
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UITextField *fullNameText;
@property (weak, nonatomic) IBOutlet UITextField *majorText;
- (IBAction)register:(id)sender;
@property (weak, nonatomic) IBOutlet TuborBlueButton *registerButton;
- (IBAction)cancelButton:(id)sender;
@property PFUser * aUser;

@end

@implementation RegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initialize text for button
    self.registerButton.buttonText = @"Register";
    
    // Initialize placeholder text for each text field
    self.usernameText.placeholder = @"Enter username";
    self.passwordText.placeholder = @"Enter password";
    self.confirmPasswordText.placeholder = @"Confirm password";
    self.emailText.placeholder = @"Enter email";
    self.fullNameText.placeholder = @"Enter your full name";
    self.majorText.placeholder = @"Enter your major";
}

// Hide keyboard when user taps outside of keyboard area
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

// a conditional segue if the user correctly fills out registration form
-(void)loadDestinationVC: (BOOL) succeeded {
    if(succeeded == YES){
        
        [self performSegueWithIdentifier:@"registerSegue" sender:self];
    }
}

// Delegate methods for the textfield placeholders

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField setValue:[UIColor clearColor] forKeyPath:@"_placeholderLabel.textColor"];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField setValue:[UIColor colorWithWhite: 0.70 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
}

- (void)highlightErrorField:(UITextField *)textfield {
    
    UIColor * errorColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.3];
    
    UITextField *errorField = (UITextField *) textfield;
    [UIView animateWithDuration:4.0 animations:^{
        errorField.backgroundColor = errorColor;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:2.0 animations:^{
            errorField.backgroundColor = [UIColor whiteColor];
        } completion:NULL];
    }];
}

- (IBAction)register:(id)sender {
    
    // Dictionary of all text entries from registration fields
    NSDictionary * registrationInfo = @{
                                        @"username" : trimString([NSString stringWithString:self.usernameText.text]),
                                        @"password" : trimString([NSString stringWithString:self.passwordText.text]),
                                        @"confirm"  : trimString([NSString stringWithString:self.confirmPasswordText.text]),
                                        @"email"    : trimString([NSString stringWithString:self.emailText.text]),
                                        @"fullName": trimString([NSString stringWithString:self.fullNameText.text]),
                                        @"major" : trimString([NSString stringWithString:self.majorText.text])
                                        };
    
    
#pragma mark - Username Check
    
    // Check if username field is empty
    if ([registrationInfo[@"username"] length] == 0)
    {
        // Highlight text field with error
        [self highlightErrorField:self.usernameText];
        
        // Alert user to enter a username
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Invalid Username"
                              message:[NSString stringWithFormat: @"\nPlease enter a username"]
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    // Username field is not empty
    else
    {
        // Check if username is between 4-10 characters long
        if (([registrationInfo[@"username"] length] < USERNAME_MIN)
            || ([registrationInfo[@"username"] length] > USERNAME_MAX))
        {
            // Highlight text field with error
            [self highlightErrorField:self.usernameText];
            
            // Alert user to enter a username with correct with length
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Invalid Username"
                                  message:[NSString stringWithFormat: @"\nUsername must be 4-10 characters long"]
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            
            return;
        }
    }
    
#pragma mark - Password Check
    
    // Check if password field is empty
    if ([registrationInfo[@"password"] length] == 0)
    {
        // Highlight text field with error
        [self highlightErrorField:self.passwordText];
        
        // Alert user to enter a password
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Invalid Password"
                              message:[NSString stringWithFormat: @"\nPlease enter a password"]
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    // Password field is not empty
    else
    {
        // Check if password is between 4-10 characters long
        if (([registrationInfo[@"password"] length] < PASSWORD_MIN)
            || ([registrationInfo[@"password"] length] > PASSWORD_MAX))
        {
            // Highlight text field with error
            [self highlightErrorField:self.passwordText];
            
            // Alert user to enter a username with correct with length
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Invalid Password"
                                  message:[NSString stringWithFormat: @"\nPassword must be 4-10 characters long"]
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            
            return;
        }
    }
    
#pragma mark - Confirm Password Check
    
    // Check if confirm field matches password field
    if (![registrationInfo[@"confirm"] isEqualToString: registrationInfo[@"password"]])
    {
        // Highlight text field with error
        [self highlightErrorField:self.confirmPasswordText];
        
        // Alert user to enter matching password in confirm field
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Invalid Password"
                              message:[NSString stringWithFormat: @"\nPasswords do not match"]
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
#pragma mark - Email Check
    
    // Check if email field is empty
    if ([registrationInfo[@"email"] length] == 0)
    {
        // Highlight text field with error
        [self highlightErrorField:self.emailText];
        
        // Alert user to enter an email
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Invalid Email"
                              message:[NSString stringWithFormat: @"\nPlease enter an email"]
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    // Email field is not empty
    else
    {
    }
    
#pragma mark - Full Name Check
    
    // Check if full name field is empty
    if ([registrationInfo[@"fullName"] length] == 0)
    {
        // Highlight text field with error
        [self highlightErrorField:self.fullNameText];
        
        // Alert user to enter a full name
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Invalid Name"
                              message:[NSString stringWithFormat: @"\nPlease enter your full name"]
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    // Full name field is not empty
    else
    {
    }
    
#pragma mark - Major Check
    
    // Check if major field is empty
    if ([registrationInfo[@"major"] length] == 0)
    {
        // Highlight text field with error
        [self highlightErrorField:self.majorText];
        
        // Alert user to enter a major
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Invalid Major"
                              message:[NSString stringWithFormat: @"\nPlease enter a major"]
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    // Major field is not empty
    else
    {
    }
    
#pragma mark - Create New User
    
    // Create a new user object from registration info
    PFUser * user = [PFUser user];
    user.username = registrationInfo[@"username"];
    user.password = registrationInfo[@"password"];
    user.email = registrationInfo[@"email"];
    user[@"fullName"] = registrationInfo[@"fullName"];
    user[@"major"] = registrationInfo[@"major"];
    user[@"coursesTaking"] = [[NSMutableArray alloc] init];
    user[@"coursesTutoring"] = [[NSMutableArray alloc] init];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
            // Alert user successfully registered
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Successfully registered"
                                  message:[NSString stringWithFormat: @"\nThank you for registering!"]
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
            
            
        } else {
            NSString *errorString = [error userInfo][@"error"];
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Try Again"
                                  message:[NSString stringWithFormat: @"\nSorry, %@", errorString]
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
    }];
    
}

- (IBAction)cancelButton:(id)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}
@end
