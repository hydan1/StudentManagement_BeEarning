//
//  PopupUtil.m
//  StudentManagement
//
//  Created by Hydan on 20/9/24.
//

#import "PopupUtil.h"

@implementation PopupUtil

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
            viewController:(UIViewController *)viewController
                   completion:(void (^_Nullable)(void))completion {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
        if (completion) {
            completion();
        }
    }];
    
    [alert addAction:okAction];
    [viewController presentViewController:alert animated:YES completion:nil];
}

@end
