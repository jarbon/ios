//
//  DDGBookmarksViewController.h
//  DuckDuckGo
//
//  Created by Ishaan Gulrajani on 7/29/12.
//
//

#import <UIKit/UIKit.h>

@class DDGSearchController;
@interface DDGBookmarksViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *noBookmarksView;
@property (nonatomic, weak) DDGSearchController *searchController;

- (IBAction)plus:(id)sender;

@end
