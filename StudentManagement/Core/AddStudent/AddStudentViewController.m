//
//  AddStudentViewController.m
//  StudentManagement
//
//  Created by Hydan on 20/9/24.
//

#import "AddStudentViewController.h"
#import "NotificationNames.h"
#import "PopupUtil.h"

@interface AddStudentViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;

@end

@implementation AddStudentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ageTextField.keyboardType = UIKeyboardTypeNumberPad;
}

- (BOOL)validateInput {
    // Check nameTextField
    if (self.nameTextField.text.length == 0) {
        [self showAlertWithTitle:@"Lỗi" message:@"Tên không được để trống."];
        return NO;
    }
    
    // Check ageTextField
    NSString *ageString = self.ageTextField.text;
    NSInteger age = [ageString integerValue];
    if (ageString.length == 0 || age < 0 || age > 120) {
        [self showAlertWithTitle:@"Lỗi" message:@"Tuổi phải là một số hợp lệ (0-120)."];
        return NO;
    }
    
    // Check addressTextField
    if (self.addressTextField.text.length == 0) {
        [self showAlertWithTitle:@"Lỗi" message:@"Địa chỉ không được để trống."];
        return NO;
    }
    
    return YES;
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)addStudentAction:(id)sender {
    if ([self validateInput]) {
        Student *newStudent = [[Student alloc] initWithName:self.nameTextField.text
                                                        age:[self.ageTextField.text integerValue]
                                                    address:self.addressTextField.text];
        [[DatabaseManager sharedInstance] addStudent:newStudent];
        
        [PopupUtil showAlertWithTitle:@"Thành công"
                              message:@"Sinh viên đã được thêm thành công!"
                       viewController:self
                           completion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification(ReloadStudentData) object:nil];
    }
}

@end
