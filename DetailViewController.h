//
//  DetailViewController.h
//  OpenWeatherMap
//
//  Created by book on 21.05.16.
//  Copyright © 2016 YuriyCraft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Weather;

@interface DetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic)Weather * weather;
@end
