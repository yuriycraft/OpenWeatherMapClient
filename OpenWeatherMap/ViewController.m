//
//  ViewController.m
//  OpenWeatherMap
//
//  Created by book on 19.05.16.
//  Copyright © 2016 YuriyCraft. All rights reserved.
//

#import "DetailViewController.h"
#import "Forecast.h"
#import "ServerManager.h"
#import "ViewController.h"
#import "Weather.h"
#import <MagicalRecord/MagicalRecord.h>

static NSString *const kFirstStart = @"kFirstStart";
static NSString *kCellId = @"cellId";

@interface ViewController () <UITableViewDelegate,
                              NSFetchedResultsControllerDelegate,
                              UITableViewDataSource>
@property(nonatomic, strong) NSFetchedResultsController *frc;

@end

@implementation ViewController {
  UIRefreshControl *_refreshControl;
  NSString *updateCityId;
}

- (void)viewDidLoad {

  [super viewDidLoad];
  [self refreshAction];
  _refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectZero];
  [self.tableView addSubview:_refreshControl];
  [_refreshControl addTarget:self
                      action:@selector(refreshAction)
            forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:YES];
  [NSFetchedResultsController deleteCacheWithName:@"WeatherCache"];
}

#pragma mark - Actions

- (void)refreshAction {

  NSArray *elements = [Weather MR_findAllSortedBy:@"currentTime" ascending:YES];
  NSArray *attributes = [elements valueForKey:@"cityId"];

  if (![[NSUserDefaults standardUserDefaults] boolForKey:kFirstStart]) {

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFirstStart];
    [[NSUserDefaults standardUserDefaults] synchronize];

    updateCityId = @"524901,519690"; // костыль
  } else {
    updateCityId = [NSString
        stringWithFormat:@"%@", [attributes componentsJoinedByString:@","]];
  }

  [[ServerManager sharedInstance]
      fetchWeatherJSONresultWithCityId:updateCityId
                                result:^(NSDictionary *result) {

                                  [_refreshControl endRefreshing];

                                }];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (NSFetchedResultsController *)frc {
  if (_frc != nil) {
    return _frc;
  }

  NSFetchRequest *fetchRequest =
      [Weather MR_requestAllSortedBy:@"currentTime" ascending:NO];
  [fetchRequest setFetchLimit:100];
  [fetchRequest setFetchBatchSize:10];

  NSFetchedResultsController *theFetchedResultsController =
      [[NSFetchedResultsController alloc]
          initWithFetchRequest:fetchRequest
          managedObjectContext:[NSManagedObjectContext MR_defaultContext]
            sectionNameKeyPath:nil
                     cacheName:@"WeatherCache"];
  _frc = theFetchedResultsController;
  _frc.delegate = self;
  [_frc performFetch:nil];
  return _frc;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
  [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {

  switch (type) {
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

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {

  UITableView *tableView = self.tableView;

  switch (type) {

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

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  NSLog(@"%lu", [[[self frc] sections][section] numberOfObjects]);
  return [[[self frc] sections][section]
      numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:kCellId
                                      forIndexPath:indexPath];

  [self configureCell:cell atIndexPath:indexPath];

  return cell;
}

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath {

  Weather *weather = [[self frc] objectAtIndexPath:indexPath];

  cell.textLabel.text =
      [NSString stringWithFormat:@"%@ , %@º ", weather.nameCity, weather.temp];
}

#pragma mark - UITableViewDelegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
  if ([segue.identifier isEqualToString:@"DetailViewControllerSegue"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Weather *weather = [self.frc objectAtIndexPath:indexPath];
    DetailViewController *viewController = segue.destinationViewController;
    viewController.weather = weather;
  }
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {

  if (editingStyle == UITableViewCellEditingStyleDelete) {

    Weather *weather = [self.frc objectAtIndexPath:indexPath];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
      NSArray *oldForecastArray =
          [Forecast MR_findByAttribute:@"cityId" withValue:weather.cityId];
      for (int i = 0; i < oldForecastArray.count; i++) {
        Forecast *forec = oldForecastArray[i];
        [forec MR_deleteEntity];
      }

      Weather *localWeather = [weather MR_inContext:localContext];
      [localWeather MR_deleteEntity];
    }];

  }
}



@end
