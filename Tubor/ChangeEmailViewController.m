//
//  ChangeEmailViewController.m
//  Tubor
//
//  Created by Marcelo Sedano on 5/7/15.
//  Copyright (c) 2015 Marcelo Sedano. All rights reserved.
//

#import "ChangeEmailViewController.h"

@interface ChangeEmailViewController ()

@property (nonatomic) PFUser *user;
@property (weak, nonatomic) IBOutlet UITextField *oldTextField;
@property (weak, nonatomic) IBOutlet UITextField *updatedTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmTextField;

@end

@implementation ChangeEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.user = [PFUser currentUser];
    
    // Done button
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButton)];
    [[self navigationItem] setRightBarButtonItem:doneButton];
}

-(void)doneButton
{
    BOOL valid = [self validateTextFields];
    
    if (valid)
    {
        self.user.email = self.updatedTextField.text;
        
        [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                // Alert user successfully registered
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Successfully updated email!"
                                      message:@""
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
                [self dismissViewControllerAnimated:YES completion:nil];
                
                
            } else {
                self.user.email = self.oldTextField.text;
                
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
}

-(BOOL)validateTextFields
{
    // Grab strings from text fields
    NSString *oldEmail = self.oldTextField.text;
    NSString *updatedEmail = self.updatedTextField.text;
    NSString *confirmEmail = self.confirmTextField.text;
    
    // First check if any text fields are empty
    if ([oldEmail length] == 0 || [updatedEmail length] == 0 || [confirmEmail length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message:@"Please fill out all fields"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    // Check if old email does not match records
    if (![oldEmail isEqualToString:self.user.email])
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Old email does not match records"
                              message:@"Try again"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    // Check if the confirmation text field does not match the new email text field
    if (![updatedEmail isEqualToString:confirmEmail])
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"New email fields do not match"
                              message:@"Try again"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    return YES;
}

// Hides keyboard when user taps somewhere other than the keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

@end
