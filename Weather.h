//
//  Weather.h
//  OpenWeatherMap
//
//  Created by book on 21.05.16.
//  Copyright © 2016 YuriyCraft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Forecast;

NS_ASSUME_NONNULL_BEGIN

@interface Weather : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
- (void)fillData:(NSDictionary *)data;
@end

NS_ASSUME_NONNULL_END

#import "Weather+CoreDataProperties.h"
