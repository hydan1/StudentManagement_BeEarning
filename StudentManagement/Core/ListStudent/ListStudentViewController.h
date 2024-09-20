//
//  ViewController.h
//  StudentManagement
//
//  Created by Hydan on 20/9/24.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "TableViewBackground.h"
#import "AddStudentViewController.h"

@interface ListStudentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    sqlite3 *db;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

