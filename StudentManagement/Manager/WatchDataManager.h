//
//  WatchDataManager.h
//  StudentManagement
//
//  Created by Hydan on 22/9/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WatchDataManager : NSObject

+ (instancetype)sharedInstance;
- (void)sendStudentsToWatch;

@end

NS_ASSUME_NONNULL_END
