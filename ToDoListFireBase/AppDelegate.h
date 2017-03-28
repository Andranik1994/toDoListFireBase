//
//  AppDelegate.h
//  ToDoListFireBase
//
//  Created by Andranik on 3/4/17.
//  Copyright © 2017 Andranik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

