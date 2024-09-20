//
//  Student.m
//  StudentManagement
//
//  Created by Hydan on 20/9/24.
//

#import "Student.h"

@implementation Student

- (instancetype)initWithID:(NSInteger)studentID
                      name:(NSString *)name
                       age:(NSInteger)age
                   address:(NSString *)address {
    self = [super init];
    if (self) {
        _studentID = studentID;
        _name = name;
        _age = age;
        _address = address;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name
                         age:(NSInteger)age
                     address:(NSString *)address {
    return [self initWithID:0 name:name age:age address:address];
}

@end
