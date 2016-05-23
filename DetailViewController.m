//
//  DetailViewController.m
//  OpenWeatherMap
//
//  Created by book on 21.05.16.
//  Copyright © 2016 YuriyCraft. All rights reserved.
//

#import "DetailViewController.h"
#import "Weather.h"
#import "ServerManager.h"
#import "WeatherTableViewCell.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Forecast.h"


static NSString *kForecastCellId = @"forecastCellId";

@interface DetailViewController ()<UITableViewDelegate,NSFetchedResultsControllerDelegate,UITableViewDataSource>
@property(nonatomic, strong) NSFetchedResultsController *frc;
@end

@implementation DetailViewController {
    
    UIRefreshControl *_refreshControl;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initHeader];
    [self refreshAction];
    _refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectZero];
    [self.tableView addSubview:_refreshControl];
    [_refreshControl addTarget:self
                        action:@selector(refreshAction)
              forControlEvents:UIControlEventValueChanged];

   
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
   [NSFetchedResultsController deleteCacheWithName:@"ForecastCache"];
}

#pragma mark - Actions

-(void)refreshAction {
    

    
       [[ServerManager sharedInstance]fetchWeatherJSONresultWithCityId:self.weather.cityId.stringValue result:^(NSDictionary *result) {
           
           [self initHeader];
        
    }];
    [[ServerManager sharedInstance]forecastCity:self.weather.cityId result:^(NSArray *result) {
         [_refreshControl endRefreshing];
        
    }];
    
}
-(void)initHeader{
    
    self.nameLabel.text = self.weather.nameCity;
    
    self.tempLabel.text = [NSString stringWithFormat:@" %@º",self.weather.temp];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"'Обновлено' dd MMMM 'в' HH:mm"];
    self.descriptionLabel.text =[formatter stringFromDate:self.weather.currentTime];
    self.currentDateLabel.text = self.weather.descriptionWeather;

}

#pragma mark - NSFetchedResultsControllerDelegate

- (NSFetchedResultsController *)frc {
    if (_frc != nil) {
        return _frc;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cityId == %@", self.weather.cityId];
    NSLog(@"qqqq %@",[Forecast MR_findByAttribute:@"cityId" withValue:self.weather.cityId]);

    NSFetchRequest *fetchRequest = [Forecast MR_requestAllSortedBy:@"dateTime" ascending:YES withPredicate:predicate];
    [fetchRequest setFetchLimit:100];
    [fetchRequest setFetchBatchSize:5];
    
    
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[NSManagedObjectContext MR_defaultContext] sectionNameKeyPath:nil cacheName:@"ForecastCache"];
    _frc = theFetchedResultsController;
    _frc.delegate = self;
    [_frc performFetch:nil];
    return _frc;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
   return [[[self frc]sections][section]  numberOfObjects];    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    WeatherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kForecastCellId forIndexPath:indexPath];
    
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;

}
- (void)configureCell:(WeatherTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    Forecast *forecast = [[self frc] objectAtIndexPath:indexPath];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd MMMM"];
    cell.dateLabel.text = [formatter stringFromDate:forecast.dateTime];
    cell.tempLabel.text = [NSString stringWithFormat:@"Днем %@º",forecast.tempByDate];
    cell.descriptionLabel.text = forecast.descriptionForecast;
}




@end
