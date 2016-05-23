//
//  SearchViewController.m
//  OpenWeatherMap
//
//  Created by book on 20.05.16.
//  Copyright © 2016 YuriyCraft. All rights reserved.
//

#import "SearchViewController.h"
#import "ServerManager.h"
#import "Weather.h"
#import <MagicalRecord/MagicalRecord.h>

static NSString *kSearchCellId = @"searchcellId";

@interface SearchViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>{

    NSMutableArray *_content;
}

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchBar.delegate = self;
    _content = [NSMutableArray array];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _content.count;
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//
//    //return [[[self frc]sections] count];
//
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSearchCellId forIndexPath:indexPath];
    
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
   
    cell.textLabel.text = _content[indexPath.row][@"name"];
    NSDictionary * sysDict = _content[indexPath.row][@"sys"];
    cell.detailTextLabel.text = sysDict[@"country"];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    Weather *weatherLocal = [Weather MR_findFirstByAttribute:@"cityId" withValue:_content[indexPath.row][@"id"]];
    if (!weatherLocal){
        weatherLocal = [Weather MR_createEntity];
        [weatherLocal fillData:_content[indexPath.row]];
        
    }
    else
    {
        [weatherLocal fillData:_content[indexPath.row]];
    }
 
    [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
        
    }];

    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}


#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    self.tableView.allowsSelection=NO;
    
    [searchBar setShowsCancelButton:YES animated:YES];
    
    UIButton *cancelButton;
    
    UIView *topView = searchBar.subviews[0];
    
    for (UIView *subView in topView.subviews) {
        
        if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
            
            cancelButton = (UIButton *)subView;
        }
        
    }
    
    if (cancelButton) {
        
        [cancelButton setTitle:@"Готово" forState:UIControlStateNormal];
        
        [cancelButton setNeedsLayout];
        
    }
    
    [searchBar setShowsCancelButton:NO animated:YES];
    
    [searchBar setShowsCancelButton:YES animated:YES];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {

    [self hideKeyboard];
}



- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self hideKeyboard];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self hideKeyboard];
    NSString *escapedString = [searchBar.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    [[ServerManager sharedInstance]searchCity:escapedString result:^(NSArray *result) {
        _content = [NSMutableArray arrayWithArray:result];
         [self.tableView reloadData];
    }];

}


- (void) hideKeyboard {
    
    [self.tableView.window endEditing:YES];
    
    [self.searchBar setShowsCancelButton:NO animated:YES];
    
    self.tableView.allowsSelection = YES;
    
}


@end
