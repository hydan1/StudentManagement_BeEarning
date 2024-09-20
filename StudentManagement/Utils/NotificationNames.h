//
//  NotificationNames.h
//  StudentManagement
//
//  Created by Hydan on 20/9/24.
//

#ifndef NotificationNames_h
#define NotificationNames_h

typedef NS_ENUM(NSInteger, NotificationName) {
    ReloadStudentData,
};

static inline NSString *Notification(NotificationName notificationName) {
    switch (notificationName) {
        case ReloadStudentData:
            return @"ReloadStudentData";
    }
}

#endif /* NotificationNames_h */
