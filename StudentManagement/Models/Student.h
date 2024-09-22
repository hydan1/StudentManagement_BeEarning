//
//  Student.h
//  StudentManagement
//
//  Created by Hydan on 20/9/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Student : NSObject

@property (nonatomic, assign) NSInteger studentID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, strong) NSString *gender;

- (instancetype)initWithID:(NSInteger)studentID
                      name:(NSString *)name
                       age:(NSInteger)age
                    gender:(NSString *)gender;;

- (instancetype)initWithName:(NSString *)name
                         age:(NSInteger)age
                      gender:(NSString *)gender;;

@end

NS_ASSUME_NONNULL_END
