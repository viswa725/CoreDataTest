//
//  Employee.h
//  testing123
//
//  Created by Viswa Chaitanya on 18/10/14.
//  Copyright (c) 2014 Viswa Gopisetty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Employee : NSManagedObject

@property (nonatomic, retain) NSString * marks;
@property (nonatomic, retain) NSString * name;

@end
