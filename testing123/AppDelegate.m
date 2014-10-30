//
//  AppDelegate.m
//  testing123
//
//  Created by Viswa Chaitanya on 18/10/14.
//  Copyright (c) 2014 Viswa Gopisetty. All rights reserved.
//

#import "AppDelegate.h"
#import "Employee.h"
#import "Department.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    NSURLConnection *testConnection = [[NSURLConnection alloc]initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.whitehouse.gov/facts/json/all/economy"]] delegate:self];
    
    if(testConnection) {
        NSLog(@"connection Successful");
    } else {
        NSLog(@"Error in Connection");
    }
    employData = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
    [employData setDelegate:self];
    [employData setDataSource:self];
    [self.window addSubview:employData];
    
    [self.window makeKeyAndVisible];
    return YES;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return employeeData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    if(indexPath.row == 0)
        cell.textLabel.text = [[employeeData objectAtIndex:indexPath.section] valueForKey:@"name"];
    else
        cell.textLabel.text = [[employeeData objectAtIndex:indexPath.section]valueForKey:@"marks"];
    
    return cell;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    sampleData = [NSMutableData data];
    [sampleData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [sampleData appendData:data]; // appending data
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error;
    NSArray *responseDict = [NSJSONSerialization JSONObjectWithData:sampleData options:NSJSONReadingMutableContainers error:&error];
    
    for(int i = 0;i<responseDict.count;i++) {
        [self addEmployUid:[[responseDict objectAtIndex:i] valueForKey:@"uid"] andCategory:[[responseDict objectAtIndex:i] valueForKey:@"category"]];
    }
    
    for(int i=0; i < responseDict.count; i++) {
        [self addDepartment:[[responseDict objectAtIndex:i] valueForKey:@"url"] andURL_title:[[responseDict objectAtIndex:i] valueForKey:@"url_title"]];
    }
    
    employeeData = [self fetchingEmployees];
    [employData reloadData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}

-(void)addDepartment:(NSString *)url andURL_title:(NSString *)url_title {
    Department *departmentObj;
    
    departmentObj = [NSEntityDescription insertNewObjectForEntityForName:@"Department" inManagedObjectContext:self.managedObjectContext];
    
    [departmentObj setValue:url forKey:@"url"];
    
    [departmentObj setValue:url_title forKey:@"url_title"];
    
    [self saveContext];
}

-(void)addEmployUid:(NSString *)uid andCategory:(NSString *)category {
    Employee *employ;
    
    employ = [self getEmployee:uid];
    if(employ == nil){
        employ = [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:self.managedObjectContext];
    }
    
    [employ setValue:uid forKey:@"marks"];

    [employ setValue:category forKey:@"name"];

    [self saveContext];

}

-(Employee *)getEmployee:(NSString *)uid { //Fetching from Database
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Employee" inManagedObjectContext:self.managedObjectContext]];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"marks == %@",uid]];
    
    NSError *error;
    
    NSArray *arr = [self.managedObjectContext executeFetchRequest:fetch error:&error];
    
    if([arr count]) {
        return [arr objectAtIndex:0];
    } else {
        return nil;
    }
}

- (NSArray *)fetchingEmployees {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Employee" inManagedObjectContext:self.managedObjectContext]];// fetch the records from DB
    
//    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"url == %@",@"example"]];//predicate to fetch comment it out to get all the records
    
    NSError *error;
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if([result count])
        return result;
    else
        return nil;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"testing123" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"testing123.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
