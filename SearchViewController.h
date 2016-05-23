//
//  SearchViewController.h
//  OpenWeatherMap
//
//  Created by book on 20.05.16.
//  Copyright © 2016 YuriyCraft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
