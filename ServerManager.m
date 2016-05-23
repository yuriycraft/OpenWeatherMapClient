//
//  ServerManager.m
//  OpenWeatherMap
//
//  Created by book on 19.05.16.
//  Copyright © 2016 YuriyCraft. All rights reserved.
//

#import "ServerManager.h"
#import <AFNetworking.h>
#import <MagicalRecord/MagicalRecord.h>
#import "Weather.h"
#import "Forecast.h"



@implementation ServerManager{
    int _connectionsCount;
}

+ (instancetype)sharedInstance {
    
    static ServerManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void)incrementConnections {
    _connectionsCount++;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)decrementConnections {
    _connectionsCount--;
    
    if (_connectionsCount < 1) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

- (void)fetchWeatherJSONresultWithCityId:(NSString*)cityName
                                  result:(void (^)(NSDictionary *result))resultBlock {
    
    [self incrementConnections];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]
                                     initWithSessionConfiguration:[NSURLSessionConfiguration
                                                                   defaultSessionConfiguration]];
    
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    
    [manager GET:[kServerPath stringByAppendingString:[NSString stringWithFormat:@"data/2.5/group?id=%@&units=metric&lang=ru&APPID=%@",cityName,kApiKey]]
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask *_Nonnull task,
                   id _Nullable responseObject) {
             resultBlock(responseObject);
             
             NSLog(@"%@",responseObject);
             
             for(NSDictionary *dict in responseObject[@"list"]){
                 Weather *weatherLocal = [Weather MR_findFirstByAttribute:@"cityId" withValue:dict[@"id"]];
                 if (!weatherLocal){
                     weatherLocal = [Weather MR_createEntity];
                     [weatherLocal fillData:dict];
                     
                 }
                 else
                 {
                     [weatherLocal fillData:dict];
                 }
                 
                 [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
                     
                 }];
             }
             
             [self decrementConnections];
         }
         failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
             NSLog(@"Error: %@", error);
             
             [self decrementConnections];
         }];
}

- (void)searchCity:(NSString*)cityName
            result:(void (^)(NSArray *result))resultBlock {
    
    [self incrementConnections];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]
                                     initWithSessionConfiguration:[NSURLSessionConfiguration
                                                                   defaultSessionConfiguration]];
    
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    
    [manager GET:[kServerPath stringByAppendingString:[NSString stringWithFormat:@"data/2.5/find?q=%@&type=like&lang=ru&units=metric&APPID=%@",cityName,kApiKey]]
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask *_Nonnull task,
                   id _Nullable responseObject) {
             
             resultBlock(responseObject[@"list"]);
             
             
             NSLog(@" Search %@",responseObject);
             
             [self decrementConnections];
         }
         failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
             NSLog(@"Error: %@", error);
             
             [self decrementConnections];
         }];
}

- (void)forecastCity:(NSNumber*)cityId
              result:(void (^)(NSArray *result))resultBlock {
    
    [self incrementConnections];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]
                                     initWithSessionConfiguration:[NSURLSessionConfiguration
                                                                   defaultSessionConfiguration]];
    
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    
    [manager GET:[kServerPath stringByAppendingString:[NSString stringWithFormat:@"data/2.5/forecast/daily?id=%@&type=like&lang=ru&units=metric&cnt=5&APPID=%@",cityId,kApiKey]]
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask *_Nonnull task,
                   id _Nullable responseObject) {
             
             resultBlock(nil);
             
             NSArray * oldForecastArray = [Forecast MR_findByAttribute:@"cityId" withValue:cityId];
             for(int i=0; i<oldForecastArray.count; i++ ){
                 Forecast *forec = oldForecastArray[i];
                 [forec MR_deleteEntity];
             }
             NSDictionary *city = responseObject[@"city"];
             for(NSDictionary *dict in responseObject[@"list"]){
                 
                 Forecast *forecast = [Forecast MR_createEntity];
                 NSNumber *startTime = dict[@"dt"];
                 forecast.dateTime =  [NSDate dateWithTimeIntervalSince1970:[startTime doubleValue]];
                 NSDictionary *dictTemp = dict[@"temp"];
                 forecast.tempByDate = @([dictTemp[@"day"] integerValue]);
                 forecast.cityId = @([city[@"id"] integerValue]);
                 NSDictionary *dictDescription= [dict[@"weather"] firstObject];
                 forecast.descriptionForecast = dictDescription[@"description"];
             }
             [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
             }];
             
             [self decrementConnections];
         }
         failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
             NSLog(@"Error: %@", error);
             
             [self decrementConnections];
         }];
}


@end
