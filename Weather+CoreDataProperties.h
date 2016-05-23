//
//  Weather+CoreDataProperties.h
//  OpenWeatherMap
//
//  Created by book on 21.05.16.
//  Copyright © 2016 YuriyCraft. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Weather.h"

NS_ASSUME_NONNULL_BEGIN

@interface Weather (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *cityId;
@property (nullable, nonatomic, retain) NSDate *currentTime;
@property (nullable, nonatomic, retain) NSString *descriptionWeather;
@property (nullable, nonatomic, retain) NSString *nameCity;
@property (nullable, nonatomic, retain) NSNumber *temp;

@end



NS_ASSUME_NONNULL_END
