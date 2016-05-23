//
//  WeatherTableViewCell.h
//  OpenWeatherMap
//
//  Created by book on 21.05.16.
//  Copyright © 2016 YuriyCraft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeatherTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end
