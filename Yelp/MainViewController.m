//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpClient.h"
#import "Business.h"
#import "BusinessCell.h"
#import "FiltersViewController.h"

NSString * const kYelpConsumerKey = @"pu-55F9hleADeupXLcc2Cw";
NSString * const kYelpConsumerSecret = @"jhGR6mUuRV5PogBA1aeE9Acc6_U";
NSString * const kYelpToken = @"iHfCTUG6lc7vD2Vqn6bt359v10z947HY";
NSString * const kYelpTokenSecret = @"hl5-qYEFnS_TMkNKLpbaZ9K6ZMM";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSArray *businesses;
@property (nonatomic, strong) NSArray *filteredBusinesses;
@property (nonatomic, strong) NSArray *unfilteredBusinesses;
@property (nonatomic, strong) NSDate *lastSearchedTime;

- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        
        [self fetchBusinessesWithQuery:@"Restaurants" params:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.title = @"Yelp";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStyleDone target:self action:@selector(onFilterButton)];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"   " style:UIBarButtonItemStyleDone target:self action:nil];
    self.navigationController.navigationBar.backgroundColor = [UIColor redColor];
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    //[self.searchBar sizeToFit];
    //UIView *searchBarView = [[UIView alloc] init];
    //[searchBarView addSubview:self.searchBar];
    //[searchBarView sizeToFit];
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    
    // clear search bar
    self.searchBar.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    cell.business = self.businesses[indexPath.row];
    return cell;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString *term = searchBar.text;
    
    /*
    NSTimeInterval interval = [self.lastSearchedTime timeIntervalSinceNow];
    
    // wait 0.2 seconds to fire a request
    if (interval == 0 || interval < -0.2) {
        if (term.length) {
            [self fetchBusinessesWithQuery:term params:nil];
        }
    }
    */
    if (term.length) {
        [self fetchBusinessesWithQuery:term params:nil];
    }
    
    // if term is empty, always query just restaurants
    if (!term.length) {
        [self fetchBusinessesWithQuery:@"Restaurants" params:nil];
    }
    
    // store last-searched timestamp
    NSDate *timestamp = [NSDate date];
    self.lastSearchedTime = timestamp;
}

#pragma mark - Filter delegate methods

- (void)filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters {
    NSLog(@"fire new network event: %@", filters);
    
    [self fetchBusinessesWithQuery:@"Restaurants" params:filters];
}


#pragma mark - Private methods

- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params {
    [self.client searchWithTerm:query params:params success:^
     (AFHTTPRequestOperation *operation, id response) {
        //NSLog(@"response: %@", response);
        NSArray *businessesDictionary = response[@"businesses"];
        self.businesses = [Business businessesWithDictionaries:businessesDictionary];
        self.unfilteredBusinesses = self.businesses;
        
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
    }];
}

- (void)onFilterButton {
    FiltersViewController *vc = [[FiltersViewController alloc] init];
    
    vc.delegate = self;
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nvc animated:YES completion:nil];
}

@end
