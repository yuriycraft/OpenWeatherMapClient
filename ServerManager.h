//
//  ServerManager.h
//  OpenWeatherMap
//
//  Created by book on 19.05.16.
//  Copyright © 2016 YuriyCraft. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString const * kServerPath = @"http://api.openweathermap.org/";
static NSString const * kApiKey = @"2401f92d470b7e2aa7945c02488f5ccf";
static NSString *const AddNewCityNotification = @"AddNewCityNotificationNotification";
static NSString *const AddNewCityInfoKey = @"AddNewCityInfoKey";

@interface ServerManager : NSObject

+ (instancetype)sharedInstance;
- (void)fetchWeatherJSONresultWithCityId:(NSString*)cityName
                                result:(void (^)(NSDictionary *result))resultBlock;
- (void)searchCity:(NSString*)cityName
            result:(void (^)(NSArray *result))resultBlock;

- (void)forecastCity:(NSNumber*)cityId
              result:(void (^)(NSArray *result))resultBlock;
@end
