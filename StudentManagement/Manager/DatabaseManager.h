//
//  DatabaseManager.h
//  StudentManagement
//
//  Created by Hydan on 20/9/24.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Student.h"

NS_ASSUME_NONNULL_BEGIN

@interface DatabaseManager : NSObject

+ (instancetype)sharedInstance;
- (BOOL)createDatabase;
- (BOOL)createStudentsTable;
- (void)addStudent:(Student *)student;
- (NSArray<Student *> *)fetchStudents;
- (void)removeStudentWithID:(NSInteger)studentID;

@end

NS_ASSUME_NONNULL_END
