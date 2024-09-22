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
    // SQLite database reference
    sqlite3 *db;
}

// Method to get the database path in the documents directory
- (NSString *)getDatabasePath;


@end

@implementation DatabaseManager

// Singleton pattern implementation to ensure only one instance of DatabaseManager
+ (instancetype)sharedInstance {
    static DatabaseManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        // Create the database and table when the manager is first initialized
        [sharedInstance createDatabase];
        [sharedInstance createStudentsTable];
        [sharedInstance performMigrations];
    });
    return sharedInstance;
}

// Returns the path to the SQLite database file in the app's Documents directory
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

// Adds a new student record to the database
- (void)addStudent:(Student *)student {
    NSString *dbPath = [self getDatabasePath];

    // Open the database
    if (sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK) {
        // SQL query to insert a new student record, including the gender column
        NSString *insertSQL = @"INSERT INTO students (name, age, address, gender) VALUES (?, ?, ?, ?)";
        sqlite3_stmt *statement;

        // Prepare the SQL statement for execution
        if (sqlite3_prepare_v2(db, [insertSQL UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            // Bind the student's details to the prepared statement
            sqlite3_bind_text(statement, 1, [student.name UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement, 2, (int)student.age);
            sqlite3_bind_text(statement, 3, [student.address UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 4, [student.gender UTF8String], -1, SQLITE_TRANSIENT);
            
            // Execute the SQL statement and check if it was successful
            if (sqlite3_step(statement) == SQLITE_DONE) {
                NSLog(@"Student added successfully");
            } else {
                NSLog(@"Error adding student: %s", sqlite3_errmsg(db));
            }
        } else {
            NSLog(@"Failed to prepare statement: %s", sqlite3_errmsg(db));
        }

        // Finalize the statement and close the database
        sqlite3_finalize(statement);
        sqlite3_close(db);
    } else {
        // Log an error if the database cannot be opened
        NSLog(@"Failed to open database");
    }
}

// Fetches all student records from the database
- (NSArray<Student *> *)fetchStudents {
    // Get the database file path
    NSString *dbPath = [self getDatabasePath];
    
    // Create a mutable array to hold the list of students
    NSMutableArray<Student *> *students = [NSMutableArray array];

    // Open the SQLite database connection
    if (sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK) {
        // SQL query to select all student details, including the new gender column
        const char *sqlStatement = "SELECT id, name, age, address, gender FROM students";
        sqlite3_stmt *compiledStatement;

        // Prepare the SQL statement for execution
        if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            // Iterate over each row returned by the query
            while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Fetch individual column values from the current row
                NSInteger studentID = sqlite3_column_int(compiledStatement, 0);
                const char *nameChars = (const char *)sqlite3_column_text(compiledStatement, 1);
                NSInteger age = sqlite3_column_int(compiledStatement, 2);
                const char *addressChars = (const char *)sqlite3_column_text(compiledStatement, 3);
                const char *genderChars = (const char *)sqlite3_column_text(compiledStatement, 4);

                // Convert C strings to NSString objects, checking for NULL values
                NSString *name = nameChars ? [NSString stringWithUTF8String:nameChars] : @"";
                NSString *address = addressChars ? [NSString stringWithUTF8String:addressChars] : @"";
                NSString *gender = genderChars ? [NSString stringWithUTF8String:genderChars] : @"";

                // Initialize a new Student object with the retrieved data
                Student *student = [[Student alloc] initWithID:studentID name:name age:age address:address gender:gender];
                
                // Add the student object to the array
                [students addObject:student];
            }
        }
        // Finalize the prepared statement to release resources
        sqlite3_finalize(compiledStatement);
        
        // Close the database connection
        sqlite3_close(db);
    } else {
        // Log an error if the database connection could not be opened
        NSLog(@"Failed to open database");
    }
    
    // Return the array of students
    return students;
}

// Removes a student record from the database by student ID
- (void)removeStudentWithID:(NSInteger)studentID {
    NSString *dbPath = [self getDatabasePath];
    
    // Open the database
    if (sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK) {
        // SQL query to delete a student by ID
        const char *deleteSQL = "DELETE FROM students WHERE id = ?";
        sqlite3_stmt *statement;

        // Prepare the SQL statement for execution
        if (sqlite3_prepare_v2(db, deleteSQL, -1, &statement, NULL) == SQLITE_OK) {
            // Bind the studentID to the delete statement
            sqlite3_bind_int(statement, 1, (int)studentID);
            
            // Execute the SQL statement and check if the deletion was successful
            if (sqlite3_step(statement) == SQLITE_DONE) {
                NSLog(@"Student with ID %ld deleted successfully", (long)studentID);
            } else {
                NSLog(@"Error deleting student: %s", sqlite3_errmsg(db));
            }
        }
        // Finalize the statement and close the database
        sqlite3_finalize(statement);
        sqlite3_close(db);
    }
}

// Migrates the database to add new columns or modify the schema
- (void)migrateDatabase {
    NSString *dbPath = [self getDatabasePath];

    // Open the database
    if (sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK) {
        // SQL query to add the gender column if it does not already exist
        const char *alterTableSQL = "ALTER TABLE students ADD COLUMN gender TEXT";
        char *errMsg;
        
        // Execute the SQL statement to alter the table
        if (sqlite3_exec(db, alterTableSQL, NULL, NULL, &errMsg) != SQLITE_OK) {
            // If the error is due to the column already existing, ignore it
            if (strcmp(errMsg, "duplicate column name: gender") != 0) {
                NSLog(@"Error adding gender column: %s", errMsg);
            }
        } else {
            NSLog(@"Gender column added successfully or already exists");
        }
        
        // Close the database
        sqlite3_close(db);
    } else {
        NSLog(@"Failed to open database");
    }
}

// Hàm thực hiện các bước migrate
- (BOOL)performMigrations {
    NSInteger currentVersion = [self getDatabaseVersion];
    NSLog(@"Current Database Version: %ld", (long)currentVersion);
    
    if (currentVersion < 1) {
        // Migration 2: Thêm cột gender vào bảng students
        if (![self addGenderColumn]) {
            return NO;
        }
        [self updateDatabaseVersion:1];
        NSLog(@"Migrated to version 1.");
    }
    
    return YES;
}

// Thêm cột 'gender' vào bảng students nếu cần
- (BOOL)addGenderColumn {
    const char *addColumnSQL = "ALTER TABLE students ADD COLUMN gender TEXT";
    char *errMsg;
    if (sqlite3_exec(db, addColumnSQL, NULL, NULL, &errMsg) == SQLITE_OK) {
        NSLog(@"Column 'gender' added successfully.");
        return YES;
    } else {
        NSLog(@"Failed to add 'gender' column: %s", errMsg);
        return NO;
    }
}

// Kiểm tra phiên bản cơ sở dữ liệu hiện tại
- (NSInteger)getDatabaseVersion {
    const char *getVersionSQL = "PRAGMA user_version";
    sqlite3_stmt *statement;
    NSInteger version = 0;

    if (sqlite3_prepare_v2(db, getVersionSQL, -1, &statement, NULL) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            version = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
    }
    
    return version;
}

// Cập nhật phiên bản cơ sở dữ liệu
- (void)updateDatabaseVersion:(NSInteger)newVersion {
    NSString *updateVersionSQL = [NSString stringWithFormat:@"PRAGMA user_version = %ld", (long)newVersion];
    sqlite3_exec(db, [updateVersionSQL UTF8String], NULL, NULL, NULL);
}


@end
