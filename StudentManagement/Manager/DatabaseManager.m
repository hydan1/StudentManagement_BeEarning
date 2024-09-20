//
//  DatabaseManager.m
//  StudentManagement
//
//  Created by Hydan on 20/9/24.
//

#import "DatabaseManager.h"
#import "Student.h"
#import <sqlite3.h>

@interface DatabaseManager () {
    sqlite3 *db;
}

- (NSString *)getDatabasePath;


@end

@implementation DatabaseManager

+ (instancetype)sharedInstance {
    static DatabaseManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSString *)getDatabasePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"students.db"];
}

- (BOOL)createDatabase {
    NSString *dbPath = [self getDatabasePath];
    NSLog(@"Database path: %@", dbPath);

    if (sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK) {
        NSLog(@"Database created successfully.");
        return YES;
    } else {
        NSLog(@"Failed to create/open the database.");
        return NO;
    }
}

- (BOOL)createStudentsTable {
    const char *createTableSQL = "CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER, address TEXT)";

    char *errMsg;
    if (sqlite3_exec(db, createTableSQL, NULL, NULL, &errMsg) == SQLITE_OK) {
        NSLog(@"Table 'students' created successfully.");
        return YES;
    } else {
        NSLog(@"Failed to create table: %s", errMsg);
        return NO;
    }
}

- (void)addStudent:(Student *)student {
    NSString *dbPath = [self getDatabasePath];
    
    if (sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK) {
        const char *insertSQL = "INSERT INTO students (name, age, address) VALUES (?, ?, ?)";
        sqlite3_stmt *statement;

        if (sqlite3_prepare_v2(db, insertSQL, -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [student.name UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement, 2, (int)student.age);
            sqlite3_bind_text(statement, 3, [student.address UTF8String], -1, SQLITE_TRANSIENT);
            
            if (sqlite3_step(statement) == SQLITE_DONE) {
                NSLog(@"Student added successfully");
            } else {
                NSLog(@"Error adding student: %s", sqlite3_errmsg(db));
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(db);
    }
}

- (NSArray<Student *> *)fetchStudents {
    NSString *dbPath = [self getDatabasePath];
    NSMutableArray<Student *> *students = [NSMutableArray array];

    if (sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK) {
        const char *querySQL = "SELECT id, name, age, address FROM students";
        sqlite3_stmt *statement;

        if (sqlite3_prepare_v2(db, querySQL, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                NSInteger studentID = sqlite3_column_int(statement, 0); // Lấy ID từ cột đầu tiên
                const char *nameChars = (const char *)sqlite3_column_text(statement, 1);
                NSInteger age = sqlite3_column_int(statement, 2);
                const char *addressChars = (const char *)sqlite3_column_text(statement, 3);
                
                NSString *name = nameChars ? [NSString stringWithUTF8String:nameChars] : @"";
                NSString *address = addressChars ? [NSString stringWithUTF8String:addressChars] : @"";
                
                // Sử dụng initializer mới
                Student *student = [[Student alloc] initWithID:studentID name:name age:age address:address];
                [students addObject:student];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(db);
    }
    return students;
}

- (void)removeStudentWithID:(NSInteger)studentID {
    NSString *dbPath = [self getDatabasePath];
    
    if (sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK) {
        const char *deleteSQL = "DELETE FROM students WHERE id = ?";
        sqlite3_stmt *statement;

        if (sqlite3_prepare_v2(db, deleteSQL, -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_int(statement, 1, (int)studentID);
            if (sqlite3_step(statement) == SQLITE_DONE) {
                NSLog(@"Student with ID %ld deleted successfully", (long)studentID);
            } else {
                NSLog(@"Error deleting student: %s", sqlite3_errmsg(db));
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(db);
    }
}

@end
