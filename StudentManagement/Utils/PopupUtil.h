//
//  PopupUtil.h
//  StudentManagement
//
//  Created by Hydan on 20/9/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PopupUtil : NSObject

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
                viewController:(UIViewController *)viewController
                   completion:(void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
