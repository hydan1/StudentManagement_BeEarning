//
//  AddStudentViewController.m
//  StudentManagement
//
//  Created by Hydan on 20/9/24.
//

#import "AddStudentViewController.h"
#import "NotificationNames.h"
#import "PopupUtil.h"

@interface AddStudentViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *genderTextField;
@property (strong, nonatomic) NSArray *genders;
@property (strong, nonatomic) UIPickerView *genderPicker;

@end

@implementation AddStudentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI {
    self.ageTextField.keyboardType = UIKeyboardTypeNumberPad;
    // Array containing gender options
    self.genders = @[@"--", @"Nam", @"Nữ", @"Khác"];
    // Initialize UIPickerView and set its data source and delegate
    self.genderPicker = [[UIPickerView alloc] init];
    self.genderPicker.dataSource = self;
    self.genderPicker.delegate = self;
    
    // Assign picker view to the textField as inputView
    self.genderTextField.inputView = self.genderPicker;
    
    self.genderTextField.tintColor = [UIColor clearColor];
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
    
    // Check genderTextField
    if (self.genderTextField.text.length == 0) {
        [self showAlertWithTitle:@"Lỗi" message:@"Giới tính không được để trống."];
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
                                                    address:self.addressTextField.text
                                                     gender:self.genderTextField.text];
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

// MARK: - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.genders.count;
}

// MARK: - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.genders[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.genderTextField.text = row == 0 ? @"" : self.genders[row];
}

@end
