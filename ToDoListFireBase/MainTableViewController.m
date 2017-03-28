//
//  MainTableViewController.m
//  ToDoListFireBase
//
//  Created by Andranik on 3/4/17.
//  Copyright © 2017 Andranik. All rights reserved.
//

#import "MainTableViewController.h"
#import "AppDelegate.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
@import Firebase;

@interface MainTableViewController ()

@property (strong, nonatomic) NSMutableArray *toDoArray;

@property (strong, nonatomic) FIRDatabaseReference *ref;

@end

@implementation MainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.toDoArray = [NSMutableArray new];
    NSLog(@"self.toDoArray = %@",self.toDoArray);
    
    
    [self.navigationItem setHidesBackButton:YES];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.title = @"ToDoList";
    
    self.ref = [[FIRDatabase database] referenceFromURL:@"https://todolistfirebase-72ceb.firebaseio.com/"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.toDoArray removeAllObjects];
    FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                     credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
                                     .tokenString];
    
    
    [[FIRAuth auth] signInWithCredential:credential completion:^(FIRUser *user, NSError *error) {
        
        FIRDatabaseReference *usersReference = [[[FIRDatabase database] referenceFromURL:@"https://todolistfirebase-72ceb.firebaseio.com/users"] child:user.uid ];
        FIRDatabaseReference *toDoReference = [usersReference child:@"toDoList"];
        
        [toDoReference observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSMutableArray *noSortToDoArray = [NSMutableArray new];
            for (FIRDataSnapshot* child in snapshot.children) {
                [noSortToDoArray addObject:child];
                
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"value.date" ascending:YES];
                self.toDoArray = [NSMutableArray arrayWithArray:[noSortToDoArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]]];
            }
            [self.tableView reloadData];
        }];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.toDoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mainTableViewconrtollerCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellStyleValue1;
    
    FIRDataSnapshot* obj = [self.toDoArray objectAtIndex:indexPath.row];


    cell.textLabel.text = [obj.value objectForKey:@"title"];

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FIRDataSnapshot* obj = [self.toDoArray objectAtIndex:indexPath.row];
    NSString *title = [NSString stringWithFormat:@"%@",[[obj.value objectForKey:@"title"] lowercaseString]];
    
    FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                     credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
                                     .tokenString];
    
    
    [[FIRAuth auth] signInWithCredential:credential completion:^(FIRUser *user, NSError *error) {
        
        FIRDatabaseReference *usersReference = [[[FIRDatabase database] referenceFromURL:@"https://todolistfirebase-72ceb.firebaseio.com/users"] child:user.uid ];
        FIRDatabaseReference *toDoReference = [usersReference child:@"toDoList"];
        
        [toDoReference observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            NSLog(@"%@",[[snapshot childSnapshotForPath:title] childSnapshotForPath:@"completed"]);
            
            if([[[snapshot childSnapshotForPath:title] childSnapshotForPath:@"completed"].value isEqual:@0]){
                NSNumber *completed = [NSNumber numberWithBool:YES];
                NSDictionary *value = [NSDictionary dictionaryWithObjectsAndKeys:
                                       completed,@"completed",
                                       nil];
                
                [[snapshot childSnapshotForPath:title].ref updateChildValues:value];
            }else{
                
                NSNumber *completed = [NSNumber numberWithBool:NO];
                NSDictionary *value = [NSDictionary dictionaryWithObjectsAndKeys:
                                       completed,@"completed",
                                       nil];
                [[snapshot childSnapshotForPath:title].ref updateChildValues:value];
                
            }
            [self.tableView reloadData];
        }];
    }];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FIRDataSnapshot* obj = [self.toDoArray objectAtIndex:indexPath.row];
        [obj.ref removeValue];
        [self.tableView reloadData];
    }
    NSLog(@"commitEditingStyle");
    // Remove the row from data model
    [self.toDoArray removeObjectAtIndex:indexPath.row];
    
    // Request table view to reload
    [tableView reloadData];
}

- (void)addItem:sender {
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"toDoRegestrationViewController"];
    [self.navigationController pushViewController:vc animated:YES];
    
}

@end
