//
//  Forecast+CoreDataProperties.h
//  OpenWeatherMap
//
//  Created by book on 23.05.16.
//  Copyright © 2016 YuriyCraft. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Forecast.h"

NS_ASSUME_NONNULL_BEGIN

@interface Forecast (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *dateTime;
@property (nullable, nonatomic, retain) NSString *descriptionForecast;
@property (nullable, nonatomic, retain) NSNumber *tempByDate;
@property (nullable, nonatomic, retain) NSNumber *cityId;

@end

NS_ASSUME_NONNULL_END
