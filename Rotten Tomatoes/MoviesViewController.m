//
//  MoviesViewController.m
//  Rotten Tomatoes
//
//  Created by Xiaolong Zhang on 2/3/15.
//  Copyright (c) 2015 Xiaolong Zhang. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieTableViewCell.h"
#import "MovieDetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "SVProgressHUD.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *movies;
@property (strong, nonatomic) NSString *originalUrl;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSString *lastUpdatedTime;
@property (strong, nonatomic) NSMutableArray *searchedArray;
@property (assign, nonatomic) BOOL isSearch;


@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Enter movie name here";
    
    // Set title
    self.title = @"Movies";
    
    // Register MovieTableViewCell Nib and give the name MovieCell as cell identifier
    [self.tableView registerNib:[UINib nibWithNibName:@"MovieTableViewCell" bundle:nil] forCellReuseIdentifier:@"MovieCell"];
    
    // Set row height statically
    self.tableView.rowHeight = 100;
    [self getData];
    
    // Pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

#pragma mark - Helper methods
- (void)getData {
    // Get data from Rotten-Tomatoes API
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSURL *url = [NSURL URLWithString:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=d22zvjtfkpnurvzd3wydc4fa"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 5.0;
    [self loading];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            [self showError];
            [self.refreshControl endRefreshing];
        } else {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            self.movies = responseDictionary[@"movies"];
            
            // reload table view after the data is loaded
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
            self.lastUpdatedTime = [NSString stringWithFormat:@"Last updated on %@", [formatter stringFromDate:[NSDate date]]];
        }
        [SVProgressHUD dismiss];
    }];
}

- (void)refresh: (UIRefreshControl *)refresh {
    [self getData];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:self.lastUpdatedTime];
}

- (void)loading{
    // Loading view
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.75]];
    [SVProgressHUD showWithStatus:@"Loading"];
}

- (void)showError {
    UIView *errorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.navigationController.toolbar.frame.size.height, 320, 20)];
    errorView.backgroundColor = [UIColor blackColor];
    errorView.alpha = 0;
    [self.view addSubview:errorView];
    
    UILabel *errorLabel = [[UILabel alloc] init];
    errorLabel.text = @"Network error, please try again later";
    errorLabel.font = [UIFont systemFontOfSize:8];
    errorLabel.textColor = [UIColor whiteColor];
    [errorLabel sizeToFit];
    
    CGRect myFrame = errorLabel.frame;
    myFrame = CGRectMake(160-myFrame.size.width/2, 10-myFrame.size.height/2, myFrame.size.width, myFrame.size.height);
    errorLabel.frame = myFrame;
    
    [errorView addSubview:errorLabel];
    
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        errorView.center = CGPointMake(errorView.center.x, errorView.center.y + 20);
        errorView.alpha = 0.75;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 delay:1 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            errorView.center = CGPointMake(errorView.center.x, errorView.center.y - 20);
            errorView.alpha = 0;
        } completion:^(BOOL finished) {
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearch) {
        return self.searchedArray.count;
    } else {
        return self.movies.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // create the cell with the cell identifier MovieCell
    MovieTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    // grab the movie from the dictionary
    NSDictionary *movie = [[NSDictionary alloc] init];
    if (self.isSearch) {
        movie = self.searchedArray[indexPath.row];
    } else {
        movie = self.movies[indexPath.row];
    }
    
    // set the title and synopsis
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"synopsis"];
    cell.synopsisLabel.font = [UIFont systemFontOfSize:10];
    
    // set movie poster
    NSString *posterUrl = [movie valueForKeyPath:@"posters.thumbnail"];
    self.originalUrl = [posterUrl stringByReplacingOccurrencesOfString:@"tmb" withString:@"ori"];
    [cell.posterView setImageWithURL:[NSURL URLWithString:posterUrl]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // dismiss keyboard when scroll
    [self.searchBar resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Init movie details view controller
    MovieDetailsViewController *mdvc = [[MovieDetailsViewController alloc] init];
    
    // Pass movie dict to detail view controller
    NSDictionary *movie = [[NSDictionary alloc] init];
    if (self.isSearch) {
        movie = self.searchedArray[indexPath.row];
    } else {
        movie = self.movies[indexPath.row];
    }
    mdvc.movie = movie;
    
    // get movie table view cell object
    MovieTableViewCell *cell = (MovieTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    mdvc.preloadedImage = cell.posterView.image;
    [self.navigationController pushViewController:mdvc animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // dismiss keyboard when scroll
    [self.searchBar resignFirstResponder];
}

#pragma mark - Search bar methods
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // isSearch is false when the search bar is empty or nil
    if ([searchText isEqualToString:@""] || searchText == nil) {
        self.isSearch = NO;
        [self.tableView reloadData];
        return;
    }
    
    self.isSearch = YES;
    
    // set filter
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"title contains[c] %@", searchText];
    // filter and set the share property searchedArray
    self.searchedArray = (NSMutableArray *)[self.movies filteredArrayUsingPredicate:filter];
    
    // reload table view to refresh data
    [self.tableView reloadData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
