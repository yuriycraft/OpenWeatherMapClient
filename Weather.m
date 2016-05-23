//
//  Weather.m
//  OpenWeatherMap
//
//  Created by book on 21.05.16.
//  Copyright © 2016 YuriyCraft. All rights reserved.
//

#import "Weather.h"
#import "Forecast.h"

@implementation Weather

// Insert code here to add functionality to your managed object subclass
- (void)fillData:(NSDictionary *)data
{
    self.nameCity = data[@"name"];
    NSArray *weather = data[@"weather"];
    NSDictionary *weatherDictionary = weather.firstObject;
    self.descriptionWeather = weatherDictionary[@"description"];
    
    NSDictionary *main = data[@"main"];
    self.temp = @([main[@"temp"] integerValue]);
    self.cityId = @([data[@"id"] integerValue]);
    self.currentTime = [NSDate date];
    
    NSLog(@"%@ %@ %@",self.nameCity,self.descriptionWeather,self.temp);
}
@end
