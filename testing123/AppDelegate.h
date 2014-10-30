//
//  AppDelegate.h
//  testing123
//
//  Created by Viswa Chaitanya on 18/10/14.
//  Copyright (c) 2014 Viswa Gopisetty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,NSURLConnectionDataDelegate,UITableViewDataSource>
{
    NSMutableData *sampleData;
    NSArray *employeeData;
    UITableView *employData;
}
@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
