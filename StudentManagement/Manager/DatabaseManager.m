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
        NSString *insertSQL = @"INSERT INTO students (name, age, gender) VALUES (?, ?, ?)";
        sqlite3_stmt *statement;
        
        // Prepare the SQL statement for execution
        if (sqlite3_prepare_v2(db, [insertSQL UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            // Bind the student's details to the prepared statement
            sqlite3_bind_text(statement, 1, [student.name UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement, 2, (int)student.age);
            sqlite3_bind_text(statement, 3, [student.gender UTF8String], -1, SQLITE_TRANSIENT);
            
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

// Function to fetch students
- (NSArray<Student *> *)fetchStudents {
    NSString *dbPath = [self getDatabasePath];
    NSMutableArray<Student *> *students = [NSMutableArray array];
    
    // Open the SQLite database connection
    if (sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK) {
        const char *sqlStatement = "SELECT id, name, age, gender FROM students";
        sqlite3_stmt *compiledStatement;
        // Prepare the SQL statement for execution
        if (sqlite3_prepare_v2(db, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            // Iterate over each row returned by the query
            while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                NSInteger studentID = sqlite3_column_int(compiledStatement, 0);
                const char *nameChars = (const char *)sqlite3_column_text(compiledStatement, 1);
                NSInteger age = sqlite3_column_int(compiledStatement, 2);
                const char *genderChars = (const char *)sqlite3_column_text(compiledStatement, 3);
                
                NSString *name = nameChars ? [NSString stringWithUTF8String:nameChars] : @"";
                NSString *gender = genderChars ? [NSString stringWithUTF8String:genderChars] : @"";
                
                Student *student = [[Student alloc] initWithID:studentID name:name age:age gender:gender];
                [students addObject:student];
            }
        }
        sqlite3_finalize(compiledStatement);
        
        // Close the database connection
        sqlite3_close(db);
    } else {
        NSLog(@"Failed to open database");
    }
    
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
        
        // MARK: Mirgate 2: - Create a temporary table without the address column
        const char *createTempTableSQL = "CREATE TABLE students_temp (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER, gender TEXT)";
        if (sqlite3_exec(db, createTempTableSQL, NULL, NULL, &errMsg) != SQLITE_OK) {
            NSLog(@"Error creating temporary table: %s", errMsg);
        }
        
        // Step 3: Copy data from the old table to the new temporary table
        const char *copyDataSQL = "INSERT INTO students_temp (id, name, age, gender) SELECT id, name, age, gender FROM students";
        if (sqlite3_exec(db, copyDataSQL, NULL, NULL, &errMsg) != SQLITE_OK) {
            NSLog(@"Error copying data to temporary table: %s", errMsg);
        }
        
        // Step 4: Drop the old table
        const char *dropOldTableSQL = "DROP TABLE students";
        if (sqlite3_exec(db, dropOldTableSQL, NULL, NULL, &errMsg) != SQLITE_OK) {
            NSLog(@"Error dropping old table: %s", errMsg);
        }
        
        // Step 5: Rename the temporary table to the original table name
        const char *renameTableSQL = "ALTER TABLE students_temp RENAME TO students";
        if (sqlite3_exec(db, renameTableSQL, NULL, NULL, &errMsg) != SQLITE_OK) {
            NSLog(@"Error renaming temporary table: %s", errMsg);
        }
        
        // Close the database
        sqlite3_close(db);
    } else {
        NSLog(@"Failed to open database");
    }
}

// Function to perform migration steps
- (BOOL)performMigrations {
    NSInteger currentVersion = [self getDatabaseVersion];
    NSLog(@"Current Database Version: %ld", (long)currentVersion);
    
    if (currentVersion < 1) {
        // Migration 1: Add gender column to students table
        if (![self addGenderColumn]) {
            return NO;
        }
        [self updateDatabaseVersion:1];
        NSLog(@"Migrated to version 1.");
    }
    
    if (currentVersion < 2) {
        // Migration 2: Delete 'address' column by creating a temporary table and copying the data
        if (![self removeAddressColumn]) {
            return NO;
        }
        [self updateDatabaseVersion:2];
        NSLog(@"Migrated to version 2 (removed 'address').");
    }
    
    return YES;
}

// Add 'gender' column to students table if needed
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

// Check current database version
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

// Update database version
- (void)updateDatabaseVersion:(NSInteger)newVersion {
    NSString *updateVersionSQL = [NSString stringWithFormat:@"PRAGMA user_version = %ld", (long)newVersion];
    sqlite3_exec(db, [updateVersionSQL UTF8String], NULL, NULL, NULL);
}

// Delete the 'address' column from the students table by creating a temporary table and copying the data
- (BOOL)removeAddressColumn {
    const char *createTempTableSQL = "CREATE TABLE students_temp (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER, gender TEXT)";
    const char *copyDataSQL = "INSERT INTO students_temp (id, name, age, gender) SELECT id, name, age, gender FROM students";
    const char *dropOldTableSQL = "DROP TABLE students";
    const char *renameTableSQL = "ALTER TABLE students_temp RENAME TO students";
    
    char *errMsg;

    // Step 1: Create temporary table students_temp with new structure
    if (sqlite3_exec(db, createTempTableSQL, NULL, NULL, &errMsg) != SQLITE_OK) {
        NSLog(@"Failed to create temp table: %s", errMsg);
        return NO;
    }

    // Step 2: Copy data from old table to temporary table
    if (sqlite3_exec(db, copyDataSQL, NULL, NULL, &errMsg) != SQLITE_OK) {
        NSLog(@"Failed to copy data to temp table: %s", errMsg);
        return NO;
    }

    // Step 3: Delete the old students table
    if (sqlite3_exec(db, dropOldTableSQL, NULL, NULL, &errMsg) != SQLITE_OK) {
        NSLog(@"Failed to drop old table: %s", errMsg);
        return NO;
    }

    // Step 4: Rename the temporary table to students
    if (sqlite3_exec(db, renameTableSQL, NULL, NULL, &errMsg) != SQLITE_OK) {
        NSLog(@"Failed to rename temp table: %s", errMsg);
        return NO;
    }

    NSLog(@"Column 'address' removed successfully.");
    return YES;
}


@end
