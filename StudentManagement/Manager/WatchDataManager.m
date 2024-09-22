//
//  WatchDataManager.m
//  StudentManagement
//
//  Created by Hydan on 22/9/24.
//

#import "WatchDataManager.h"
#import "Student.h"
#import "DatabaseManager.h"
#import <WatchConnectivity/WatchConnectivity.h>


@implementation WatchDataManager

// Shared instance method for singleton
+ (instancetype)sharedInstance {
    static WatchDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

// Function to send students data to watchOS
- (void)sendStudentsToWatch {
    NSArray *students = [[DatabaseManager sharedInstance] fetchStudents];
    NSMutableArray *studentsDict = [NSMutableArray array];
    
    for (Student *student in students) {
        [studentsDict addObject:@{
            @"id": @(student.studentID),
            @"name": student.name,
            @"age": @(student.age),
            @"gender": student.gender
        }];
    }
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:studentsDict options:0 error:&error];
    
    if (!error) {
        [WCSession.defaultSession sendMessage:@{@"students": data} replyHandler:nil errorHandler:^(NSError *error) {
            NSLog(@"Error sending message to watch: %@", error.localizedDescription);
        }];
    } else {
        NSLog(@"Error serializing students data: %@", error.localizedDescription);
    }
}

@end
