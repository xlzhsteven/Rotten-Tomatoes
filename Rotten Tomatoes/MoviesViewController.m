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

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *movies;
@property (strong, nonatomic) NSString *originalUrl;
@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Set title
    self.title = @"Movies";
    
    // Register MovieTableViewCell Nib and give the name MovieCell as cell identifier
    [self.tableView registerNib:[UINib nibWithNibName:@"MovieTableViewCell" bundle:nil] forCellReuseIdentifier:@"MovieCell"];
    
    // Set row height statically
    self.tableView.rowHeight = 100;
    
    // Loading view
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.75]];
    [SVProgressHUD showWithStatus:@"Loading"];
    
    // Get data from Rotten-Tomatoes API
    NSURL *url = [NSURL URLWithString:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=d22zvjtfkpnurvzd3wydc4fa"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 5.0;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            [self showError];
        } else {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            self.movies = responseDictionary[@"movies"];
            
            // reload table view after the data is loaded
            [self.tableView reloadData];
        }
        [SVProgressHUD dismiss];
    }];
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
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // create the cell with the cell identifier MovieCell
    MovieTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    // grab the movie from the dictionary
    NSDictionary *movie = self.movies[indexPath.row];
    
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Init movie details view controller
    MovieDetailsViewController *mdvc = [[MovieDetailsViewController alloc] init];
    
    // Pass movie dict to detail view controller
    NSDictionary *movie = self.movies[indexPath.row];
    mdvc.movie = movie;
    
    [self.navigationController pushViewController:mdvc animated:YES];
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
