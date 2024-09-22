//
//  ViewController.m
//  StudentManagement
//
//  Created by Hydan on 20/9/24.
//

#import "ListStudentViewController.h"
#import "NotificationNames.h"
#import "Student.h"
#import "StudentDetailViewController.h"

@interface ListStudentViewController ()

@property (nonatomic, strong) NSMutableArray<Student *> *studentsArray;

@end

@implementation ListStudentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.studentsArray = [[NSMutableArray alloc] init];
    [self fetchStudentsFromLocalDB];
    [self setupTableView];
    [self setupAddStudentButton];
    [self ListenReloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)fetchStudentsFromLocalDB {
    self.studentsArray = [[[DatabaseManager sharedInstance] fetchStudents] mutableCopy];
    [self updateTableViewBackground];
    [self.tableView reloadData];
}

- (void)updateTableViewBackground {
    if (self.studentsArray.count == 0) {
        TableViewBackground *backgroundView = [[TableViewBackground alloc] initWithFrame:self.tableView.bounds];
        self.tableView.backgroundView = backgroundView;
    } else {
        self.tableView.backgroundView = nil;
    }
}


- (void)ListenReloadData {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadStudentData)
                                                 name:Notification(ReloadStudentData)
                                               object:nil];
}

- (void)reloadStudentData {
    [self fetchStudentsFromLocalDB];
}

- (void)setupAddStudentButton {
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Add"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(navigateToAddStudentScreen)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (void)setupTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

// Function to get database path in Documents folder
- (NSString *)getDatabasePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:@"students.db"];
    return databasePath;
}

#pragma mark - UITableView DataSource

// Number of rows in tableView (equal to number of students)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.studentsArray.count;
}

// Configure each cell to display student information
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"StudentCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    // Get Student object
    Student *student = [self.studentsArray objectAtIndex:indexPath.row];
    
    // Cell configuration
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (Age: %ld)", student.name, (long)student.age];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Giới tính: %@", student.gender];
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    Student *selectedStudent = self.studentsArray[indexPath.row];
    StudentDetailViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"StudentDetailViewController"];
    detailVC.student = selectedStudent;
    [self.navigationController pushViewController:detailVC animated:YES];
}

// Specify the modification type for the row (Delete)
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// Handle when user presses delete button
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Get studentID from array
        Student *student = self.studentsArray[indexPath.row];
        // Delete student from database
        [[DatabaseManager sharedInstance] removeStudentWithID:student.studentID];
        // Remove student from array
        [self.studentsArray removeObjectAtIndex:indexPath.row];
        // Update tableView
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        // Update background if needed
        [self updateTableViewBackground];
    }
}

// Customize delete button title
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Delete";
}

#pragma mark - Functions

- (void)navigateToAddStudentScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"StudentManagement" bundle:nil];
    AddStudentViewController *addStudentVC = [storyboard instantiateViewControllerWithIdentifier:@"AddStudentViewController"];
    [self.navigationController pushViewController:addStudentVC animated:YES];
}


@end
