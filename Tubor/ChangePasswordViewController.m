//
//  ChangePasswordViewController.m
//  Tubor
//
//  Created by Marcelo Sedano on 5/7/15.
//  Copyright (c) 2015 Marcelo Sedano. All rights reserved.
//

#import "ChangePasswordViewController.h"

@interface ChangePasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}
- (IBAction)requestButton:(id)sender
{
    NSString *email = self.emailField.text;
    
    [PFUser requestPasswordResetForEmailInBackground:email];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Success!"
                          message:@"A link to reset your password has been sent to your email."
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Hides keyboard when user taps somewhere other than the keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

@end
