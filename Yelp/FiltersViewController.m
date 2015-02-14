//
//  FiltersViewController.m
//  Yelp
//
//  Created by David Tong on 2/11/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "SwitchCell.h"
#import "SegmentedCell.h"


@interface FiltersViewController () <UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate, SegmentedCellDelegate>

@property (nonatomic, readonly) NSDictionary *filter;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *distances;
@property (nonatomic, strong) NSArray *sortOrders;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSMutableSet *selectedCategories;
@property (nonatomic) BOOL deal;

@property (nonatomic) NSString *distance;
@property (nonatomic, strong) NSString *sort;

- (void) initCategories;
- (SegmentedCell *) populateSegmentedCell:(UITableView *)myTableView inputArray:(NSArray *)array;

@end

@implementation FiltersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.selectedCategories = [NSMutableSet set];
        self.deal = NO;
        
        // Init "constants"
        [self initCategories];
        self.distances = @[@"1", @"5", @"10", @"25"];
        self.sortOrders = @[@"Best Match", @"Distance", @"Highest Rated"];
        self.sections = @[@"Most Popular", @"Distance", @"Sort By", @"Categories"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Navigation Bar
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButton)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor redColor];
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    
    // table view setup
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SegmentedCell" bundle:nil] forCellReuseIdentifier:@"SegmentedCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Table view methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.sections[indexPath.section] isEqual: @"Sort By"]) {

        return [self populateSegmentedCell:tableView inputArray:self.sortOrders];
        
    } else if ([self.sections[indexPath.section] isEqual: @"Distance"]) {

        return [self populateSegmentedCell:tableView inputArray:self.distances];
        
    } else if ([self.sections[indexPath.section] isEqual: @"Categories"]) {
        SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
        
        cell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
        cell.switchNameLabel.text = self.categories[indexPath.row][@"name"];
        cell.delegate = self;
        return cell;
        
    } else {
        SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
        
        cell.switchNameLabel.text = @"Offering a Deal";
        cell.on = self.deal;
        cell.delegate = self;
        return cell;
        
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.sections[section]  isEqual: @"Categories"]) {
        return self.categories.count;
    } else {
        return 1;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sections objectAtIndex:section];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

-(SegmentedCell *)populateSegmentedCell:(UITableView *)myTableView inputArray:(NSArray *)array {
    SegmentedCell *cell = [myTableView dequeueReusableCellWithIdentifier:@"SegmentedCell"];
    
    int i = 0;
    
    if (cell.segmentedControl.numberOfSegments != array.count) {
        [cell.segmentedControl removeAllSegments];
        cell.delegate = self;
        for (; i < array.count; i++) {
            [cell.segmentedControl insertSegmentWithTitle:array[i] atIndex:i animated:YES];
        }
    }
    return cell;
}



#pragma mark - Switch cell delegate methods

- (void)switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if ([self.sections[indexPath.section]  isEqual: @"Categories"]) {
        if (value) {
            [self.selectedCategories addObject:self.categories[indexPath.row]];
        } else {
            [self.selectedCategories removeObject:self.categories[indexPath.row]];
        }
    } else if ([self.sections[indexPath.section]  isEqual: @"Most Popular"]) {
        self.deal = value;
    }
}

#pragma mark - Segmented cell delegate methods

-(void)SegmentedCell:(SegmentedCell *)segmentedCell didUpdateValue:(NSInteger)selectedIndex {
//- (void)SegmentedCell:(SegmentedCell *)segmentedCell didUpdateValue:(NSInteger)selectedIndex {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:segmentedCell];
                  
    if ([self.sections[indexPath.section] isEqual: @"Distance"]) {
        float milesPerMeter = 0.00621371;
        double meters = [self.distances[segmentedCell.segmentedControl.selectedSegmentIndex] doubleValue] / milesPerMeter;
        self.distance = [[NSNumber numberWithDouble:meters] stringValue];
    }
    if ([self.sections[indexPath.section]  isEqual: @"Sort By"]) {
        self.sort = [NSString stringWithFormat:@"%li", (long)segmentedCell.segmentedControl.selectedSegmentIndex];
    }
}


#pragma mark - Private methods

- (NSDictionary *)filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    if (self.selectedCategories.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *category in self.selectedCategories) {
            [names addObject:category[@"code"]];
        }
        NSString *categoryFilter = [names componentsJoinedByString:@","];
        [filters setObject:categoryFilter forKey:@"category_filter"];
    }
    
    [filters setObject:@(self.deal) forKey:@"deals_filter"];
    
    if (self.distance) {
        [filters setObject:self.distance forKey:@"radius_filter"];
    } else {
        [filters setObject:@"4000" forKey:@"radius_filter"];
    }
    
    if (self.sort) {
        [filters setObject:self.sort forKey:@"sort"];
    } else {
        [filters setObject:@"1" forKey:@"sort"];
    }

    
    return filters;
}

- (void)onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onApplyButton {
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initCategories {
    self.categories =
    @[@{@"name" : @"Afghan", @"code": @"afghani" },
      @{@"name" : @"African", @"code": @"african" },
      @{@"name" : @"American, New", @"code": @"newamerican" },
      @{@"name" : @"American, Traditional", @"code": @"tradamerican" },
      @{@"name" : @"Arabian", @"code": @"arabian" },
      @{@"name" : @"Argentine", @"code": @"argentine" },
      @{@"name" : @"Armenian", @"code": @"armenian" },
      @{@"name" : @"Asian Fusion", @"code": @"asianfusion" },
      @{@"name" : @"Asturian", @"code": @"asturian" },
      @{@"name" : @"Australian", @"code": @"australian" },
      @{@"name" : @"Austrian", @"code": @"austrian" },
      @{@"name" : @"Baguettes", @"code": @"baguettes" },
      @{@"name" : @"Bangladeshi", @"code": @"bangladeshi" },
      @{@"name" : @"Barbeque", @"code": @"bbq" },
      @{@"name" : @"Basque", @"code": @"basque" },
      @{@"name" : @"Bavarian", @"code": @"bavarian" },
      @{@"name" : @"Beer Garden", @"code": @"beergarden" },
      @{@"name" : @"Beer Hall", @"code": @"beerhall" },
      @{@"name" : @"Beisl", @"code": @"beisl" },
      @{@"name" : @"Belgian", @"code": @"belgian" },
      @{@"name" : @"Bistros", @"code": @"bistros" },
      @{@"name" : @"Black Sea", @"code": @"blacksea" },
      @{@"name" : @"Brasseries", @"code": @"brasseries" },
      @{@"name" : @"Brazilian", @"code": @"brazilian" },
      @{@"name" : @"Breakfast & Brunch", @"code": @"breakfast_brunch" },
      @{@"name" : @"British", @"code": @"british" },
      @{@"name" : @"Buffets", @"code": @"buffets" },
      @{@"name" : @"Bulgarian", @"code": @"bulgarian" },
      @{@"name" : @"Burgers", @"code": @"burgers" },
      @{@"name" : @"Burmese", @"code": @"burmese" },
      @{@"name" : @"Cafes", @"code": @"cafes" },
      @{@"name" : @"Cafeteria", @"code": @"cafeteria" },
      @{@"name" : @"Cajun/Creole", @"code": @"cajun" },
      @{@"name" : @"Cambodian", @"code": @"cambodian" },
      @{@"name" : @"Canadian", @"code": @"New)" },
      @{@"name" : @"Canteen", @"code": @"canteen" },
      @{@"name" : @"Caribbean", @"code": @"caribbean" },
      @{@"name" : @"Catalan", @"code": @"catalan" },
      @{@"name" : @"Chech", @"code": @"chech" },
      @{@"name" : @"Cheesesteaks", @"code": @"cheesesteaks" },
      @{@"name" : @"Chicken Shop", @"code": @"chickenshop" },
      @{@"name" : @"Chicken Wings", @"code": @"chicken_wings" },
      @{@"name" : @"Chilean", @"code": @"chilean" },
      @{@"name" : @"Chinese", @"code": @"chinese" },
      @{@"name" : @"Comfort Food", @"code": @"comfortfood" },
      @{@"name" : @"Corsican", @"code": @"corsican" },
      @{@"name" : @"Creperies", @"code": @"creperies" },
      @{@"name" : @"Cuban", @"code": @"cuban" },
      @{@"name" : @"Curry Sausage", @"code": @"currysausage" },
      @{@"name" : @"Cypriot", @"code": @"cypriot" },
      @{@"name" : @"Czech", @"code": @"czech" },
      @{@"name" : @"Czech/Slovakian", @"code": @"czechslovakian" },
      @{@"name" : @"Danish", @"code": @"danish" },
      @{@"name" : @"Delis", @"code": @"delis" },
      @{@"name" : @"Diners", @"code": @"diners" },
      @{@"name" : @"Dumplings", @"code": @"dumplings" },
      @{@"name" : @"Eastern European", @"code": @"eastern_european" },
      @{@"name" : @"Ethiopian", @"code": @"ethiopian" },
      @{@"name" : @"Fast Food", @"code": @"hotdogs" },
      @{@"name" : @"Filipino", @"code": @"filipino" },
      @{@"name" : @"Fish & Chips", @"code": @"fishnchips" },
      @{@"name" : @"Fondue", @"code": @"fondue" },
      @{@"name" : @"Food Court", @"code": @"food_court" },
      @{@"name" : @"Food Stands", @"code": @"foodstands" },
      @{@"name" : @"French", @"code": @"french" },
      @{@"name" : @"French Southwest", @"code": @"sud_ouest" },
      @{@"name" : @"Galician", @"code": @"galician" },
      @{@"name" : @"Gastropubs", @"code": @"gastropubs" },
      @{@"name" : @"Georgian", @"code": @"georgian" },
      @{@"name" : @"German", @"code": @"german" },
      @{@"name" : @"Giblets", @"code": @"giblets" },
      @{@"name" : @"Gluten-Free", @"code": @"gluten_free" },
      @{@"name" : @"Greek", @"code": @"greek" },
      @{@"name" : @"Halal", @"code": @"halal" },
      @{@"name" : @"Hawaiian", @"code": @"hawaiian" },
      @{@"name" : @"Heuriger", @"code": @"heuriger" },
      @{@"name" : @"Himalayan/Nepalese", @"code": @"himalayan" },
      @{@"name" : @"Hong Kong Style Cafe", @"code": @"hkcafe" },
      @{@"name" : @"Hot Dogs", @"code": @"hotdog" },
      @{@"name" : @"Hot Pot", @"code": @"hotpot" },
      @{@"name" : @"Hungarian", @"code": @"hungarian" },
      @{@"name" : @"Iberian", @"code": @"iberian" },
      @{@"name" : @"Indian", @"code": @"indpak" },
      @{@"name" : @"Indonesian", @"code": @"indonesian" },
      @{@"name" : @"International", @"code": @"international" },
      @{@"name" : @"Irish", @"code": @"irish" },
      @{@"name" : @"Island Pub", @"code": @"island_pub" },
      @{@"name" : @"Israeli", @"code": @"israeli" },
      @{@"name" : @"Italian", @"code": @"italian" },
      @{@"name" : @"Japanese", @"code": @"japanese" },
      @{@"name" : @"Jewish", @"code": @"jewish" },
      @{@"name" : @"Kebab", @"code": @"kebab" },
      @{@"name" : @"Korean", @"code": @"korean" },
      @{@"name" : @"Kosher", @"code": @"kosher" },
      @{@"name" : @"Kurdish", @"code": @"kurdish" },
      @{@"name" : @"Laos", @"code": @"laos" },
      @{@"name" : @"Laotian", @"code": @"laotian" },
      @{@"name" : @"Latin American", @"code": @"latin" },
      @{@"name" : @"Live/Raw Food", @"code": @"raw_food" },
      @{@"name" : @"Lyonnais", @"code": @"lyonnais" },
      @{@"name" : @"Malaysian", @"code": @"malaysian" },
      @{@"name" : @"Meatballs", @"code": @"meatballs" },
      @{@"name" : @"Mediterranean", @"code": @"mediterranean" },
      @{@"name" : @"Mexican", @"code": @"mexican" },
      @{@"name" : @"Middle Eastern", @"code": @"mideastern" },
      @{@"name" : @"Milk Bars", @"code": @"milkbars" },
      @{@"name" : @"Modern Australian", @"code": @"modern_australian" },
      @{@"name" : @"Modern European", @"code": @"modern_european" },
      @{@"name" : @"Mongolian", @"code": @"mongolian" },
      @{@"name" : @"Moroccan", @"code": @"moroccan" },
      @{@"name" : @"New Zealand", @"code": @"newzealand" },
      @{@"name" : @"Night Food", @"code": @"nightfood" },
      @{@"name" : @"Norcinerie", @"code": @"norcinerie" },
      @{@"name" : @"Open Sandwiches", @"code": @"opensandwiches" },
      @{@"name" : @"Oriental", @"code": @"oriental" },
      @{@"name" : @"Pakistani", @"code": @"pakistani" },
      @{@"name" : @"Parent Cafes", @"code": @"eltern_cafes" },
      @{@"name" : @"Parma", @"code": @"parma" },
      @{@"name" : @"Persian/Iranian", @"code": @"persian" },
      @{@"name" : @"Peruvian", @"code": @"peruvian" },
      @{@"name" : @"Pita", @"code": @"pita" },
      @{@"name" : @"Pizza", @"code": @"pizza" },
      @{@"name" : @"Polish", @"code": @"polish" },
      @{@"name" : @"Portuguese", @"code": @"portuguese" },
      @{@"name" : @"Potatoes", @"code": @"potatoes" },
      @{@"name" : @"Poutineries", @"code": @"poutineries" },
      @{@"name" : @"Pub Food", @"code": @"pubfood" },
      @{@"name" : @"Rice", @"code": @"riceshop" },
      @{@"name" : @"Romanian", @"code": @"romanian" },
      @{@"name" : @"Rotisserie Chicken", @"code": @"rotisserie_chicken" },
      @{@"name" : @"Rumanian", @"code": @"rumanian" },
      @{@"name" : @"Russian", @"code": @"russian" },
      @{@"name" : @"Salad", @"code": @"salad" },
      @{@"name" : @"Sandwiches", @"code": @"sandwiches" },
      @{@"name" : @"Scandinavian", @"code": @"scandinavian" },
      @{@"name" : @"Scottish", @"code": @"scottish" },
      @{@"name" : @"Seafood", @"code": @"seafood" },
      @{@"name" : @"Serbo Croatian", @"code": @"serbocroatian" },
      @{@"name" : @"Signature Cuisine", @"code": @"signature_cuisine" },
      @{@"name" : @"Singaporean", @"code": @"singaporean" },
      @{@"name" : @"Slovakian", @"code": @"slovakian" },
      @{@"name" : @"Soul Food", @"code": @"soulfood" },
      @{@"name" : @"Soup", @"code": @"soup" },
      @{@"name" : @"Southern", @"code": @"southern" },
      @{@"name" : @"Spanish", @"code": @"spanish" },
      @{@"name" : @"Steakhouses", @"code": @"steak" },
      @{@"name" : @"Sushi Bars", @"code": @"sushi" },
      @{@"name" : @"Swabian", @"code": @"swabian" },
      @{@"name" : @"Swedish", @"code": @"swedish" },
      @{@"name" : @"Swiss Food", @"code": @"swissfood" },
      @{@"name" : @"Tabernas", @"code": @"tabernas" },
      @{@"name" : @"Taiwanese", @"code": @"taiwanese" },
      @{@"name" : @"Tapas Bars", @"code": @"tapas" },
      @{@"name" : @"Tapas/Small Plates", @"code": @"tapasmallplates" },
      @{@"name" : @"Tex-Mex", @"code": @"tex-mex" },
      @{@"name" : @"Thai", @"code": @"thai" },
      @{@"name" : @"Traditional Norwegian", @"code": @"norwegian" },
      @{@"name" : @"Traditional Swedish", @"code": @"traditional_swedish" },
      @{@"name" : @"Trattorie", @"code": @"trattorie" },
      @{@"name" : @"Turkish", @"code": @"turkish" },
      @{@"name" : @"Ukrainian", @"code": @"ukrainian" },
      @{@"name" : @"Uzbek", @"code": @"uzbek" },
      @{@"name" : @"Vegan", @"code": @"vegan" },
      @{@"name" : @"Vegetarian", @"code": @"vegetarian" },
      @{@"name" : @"Venison", @"code": @"venison" },
      @{@"name" : @"Vietnamese", @"code": @"vietnamese" },
      @{@"name" : @"Wok", @"code": @"wok" },
      @{@"name" : @"Wraps", @"code": @"wraps" },
      @{@"name" : @"Yugoslav", @"code": @"yugoslav" }];
}

@end
