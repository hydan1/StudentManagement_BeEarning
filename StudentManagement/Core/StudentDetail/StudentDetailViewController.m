//
//  StudentDetailViewController.m
//  StudentManagement
//
//  Created by Hydan on 20/9/24.
//

#import "StudentDetailViewController.h"

@interface StudentDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIView *cardView;


@end

@implementation StudentDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self displayStudentDetails];
    [self makeShadownCard];
}

- (void)makeShadownCard {
    self.cardView.layer.cornerRadius = 10;
    self.cardView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.cardView.layer.shadowOffset = CGSizeMake(0, 2);
    self.cardView.layer.shadowOpacity = 0.3;
    self.cardView.layer.shadowRadius = 5;
}

- (void)displayStudentDetails {
    self.nameLabel.text = [NSString stringWithFormat:@"Tên: %@", self.student.name];
    self.ageLabel.text = [NSString stringWithFormat:@"Tuổi: %ld", (long)self.student.age];
    self.addressLabel.text = [NSString stringWithFormat:@"Địa chỉ: %@", self.student.address];
}

@end
