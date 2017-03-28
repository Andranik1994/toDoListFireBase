//
//  LoginViewController.m
//  ToDoListFireBase
//
//  Created by Andranik on 3/4/17.
//  Copyright © 2017 Andranik. All rights reserved.
//

#import "LoginViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
@import Firebase;

@interface LoginViewController ()

@property (strong, nonatomic) FIRDatabaseReference *ref;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([FBSDKAccessToken currentAccessToken]) {
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"mainTableViewController"];
        [self.navigationController pushViewController:vc animated:NO];
    }
    
}

- (void)loadView {
    [super loadView];
    FBSDKLoginButton *fbLoginBtn = [[FBSDKLoginButton alloc] init];
    fbLoginBtn.delegate = self;
    fbLoginBtn.center = self.view.center;
    fbLoginBtn.loginBehavior = FBSDKLoginBehaviorBrowser;
    fbLoginBtn.readPermissions = @[@"public_profile", @"email"];
    [self.view addSubview:fbLoginBtn];
}

- (BOOL)loginButtonWillLogin:(FBSDKLoginButton *)loginButton {
    NSLog(@"loginButtonWillLogin");
    NSLog(@"Read-Perms: %@", loginButton.readPermissions);
    return true;
}

- (void)loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
             error:(NSError *)error {
    NSLog(@"loginButton");
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"id,name,email" forKey:@"fields"];
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"fetched user:%@", result);
                 NSLog(@"name:%@", [result valueForKey:@"name"]);
                 NSLog(@"id:%@", [result valueForKey:@"id"]);
                 NSLog(@"email:%@", [result valueForKey:@"email"]);
                 
                 
                 
                 FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                                  credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
                                                  .tokenString];
                 
                 [[FIRAuth auth] signInWithCredential:credential
                                           completion:^(FIRUser *user, NSError *error) {
                                               
                                               self.ref = [[FIRDatabase database] referenceFromURL:@"https://todolistfirebase-72ceb.firebaseio.com/"];
                                               FIRDatabaseReference *usersReference = [[[FIRDatabase database] referenceFromURL:@"https://todolistfirebase-72ceb.firebaseio.com/users"] child:user.uid];
                                               NSDictionary *values = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                       [result valueForKey:@"id"],@"ID",
                                                                       [result valueForKey:@"name"],@"Name",
                                                                       [result valueForKey:@"email"],@"Email",
                                                                       nil];
                                               
                                               [usersReference updateChildValues:values withCompletionBlock:^(NSError *__nullable err, FIRDatabaseReference * ref){
                                                   if(err) {
                                                       NSLog(@"Error in updateChildValues:values withCompletionBlock ");
                                                       return;
                                                   }
                                                   NSLog(@"Saved user seccessfully in FireBace db");
                                               }];
                                               
                                               
                                               if (error) {
                                                   // ...
                                                   return;
                                               }}];
                 
                 UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"mainTableViewController"];
                 [self.navigationController pushViewController:vc animated:NO];
             }
         }];
    }
}

- (void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    NSLog(@"loginButtonDidLogOut");
}



@end
