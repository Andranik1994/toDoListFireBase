//
//  ToDoRegestrationViewController.m
//  ToDoListFireBase
//
//  Created by Andranik on 3/5/17.
//  Copyright © 2017 Andranik. All rights reserved.
//

#import "ToDoRegestrationViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
@import Firebase;

@interface ToDoRegestrationViewController ()

@property (strong, nonatomic) IBOutlet UITextField *commentsTextField;
@property (strong, nonatomic) IBOutlet UITextField *toDoTextField;
@property (strong, nonatomic) IBOutlet UITextField *dateTextField;

@property (strong , nonatomic) UIDatePicker *datePicker;

@property (strong, nonatomic) FIRDatabaseReference *ref;



@end

@implementation ToDoRegestrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Amigo :D";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButton:)];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButton:)];
    
    self.toDoTextField.delegate = self;
    
    self.commentsTextField.delegate = self;
    
    
    
#pragma mark - DatePicher
    self.dateTextField.delegate = self;
    
    // alloc/init your date picker, and (optional) set its initial date
    self.datePicker = [[UIDatePicker alloc]init];
    [self.datePicker setDate:[NSDate date]]; //this returns today's date
    
    // theMinimumDate (which signifies the oldest a person can be) and theMaximumDate (defines the youngest a person can be) are the dates you need to define according to your requirements, declare them:
    
    // the date string for the minimum age required (change according to your needs)
    NSString *maxDateString = @"01-Jan-2028";
    // the date formatter used to convert string to date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // the specific format to use
    dateFormatter.dateFormat = @"dd-MMM-yyyy";
    // converting string to date
    NSDate *theMaximumDate = [dateFormatter dateFromString: maxDateString];
    
    // repeat the same logic for theMinimumDate if needed
    
    // here you can assign the max and min dates to your datePicker
    [self.datePicker setMaximumDate:theMaximumDate]; //the min age restriction
    [self.datePicker setMinimumDate:[NSDate date]];
    
    // set the mode
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    
    // update the textfield with the date everytime it changes with selector defined below
    [self.datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    
    // and finally set the datePicker as the input mode of your textfield
    [self.dateTextField setInputView:self.datePicker];
}

- (NSString *)formatDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"dd-MMM-yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    return formattedDate;
}

-(void)updateTextField:(id)sender {
    UIDatePicker *picker = (UIDatePicker*)self.dateTextField.inputView;
    self.dateTextField.text = [self formatDate:picker.date];
}

#pragma mark - BarButtons Methods

- (void)saveButton:sender {
    
    FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                     credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
                                     .tokenString];
    
    [[FIRAuth auth] signInWithCredential:credential
                              completion:^(FIRUser *user, NSError *error) {
                                  
                                  self.ref = [[FIRDatabase database] referenceFromURL:@"https://todolistfirebase-72ceb.firebaseio.com/"];
                                  FIRDatabaseReference *usersReference = [[[FIRDatabase database] referenceFromURL:@"https://todolistfirebase-72ceb.firebaseio.com/users"] child:user.uid ];
                                  FIRDatabaseReference *toDoReference = [usersReference child:@"toDoList"];
                                
                                  NSNumber *completed = [NSNumber numberWithBool:NO];
                                  NSDictionary *values = [NSDictionary dictionaryWithObjectsAndKeys:
                                                          self.toDoTextField.text,@"title",
                                                          self.commentsTextField.text,@"comment",
                                                          self.dateTextField.text,@"date",
                                                          completed,@"completed",
                                                          nil];
                                  
                                  [[toDoReference child:[self.toDoTextField.text lowercaseString]] updateChildValues:values withCompletionBlock:^(NSError *__nullable err, FIRDatabaseReference * ref){
                                      if(err) {
                                          NSLog(@"Error in updateChildValues:values withCompletionBlock ");
                                          return;
                                      }
                                      NSLog(@"Saved data seccessfully in FireBace db");
                                      [self.navigationController popViewControllerAnimated:YES];
                                  }];
                                  
                                  
                                  if (error) {
                                      // ...
                                      return;
                                  }}];
    
}

- (void)cancelButton:sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - other Methods

-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    NSInteger nextTag = textField.tag + 1;
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    } else {
        
        [textField resignFirstResponder];
    }
    return NO;
}


@end
