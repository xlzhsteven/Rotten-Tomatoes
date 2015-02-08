//
//  MovieDetailsViewController.m
//  Rotten Tomatoes
//
//  Created by Xiaolong Zhang on 2/3/15.
//  Copyright (c) 2015 Xiaolong Zhang. All rights reserved.
//

#import "MovieDetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MovieDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;


@end

@implementation MovieDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Grab original resolution movie image
    NSString *url = [self.movie valueForKeyPath:@"posters.thumbnail"];
    NSString *backgroundImageUrl = [url stringByReplacingOccurrencesOfString:@"tmb" withString:@"ori"];
    
    // Content View setup (additional height to prevent inconsist background scrolling when the poster image is non-dark color)
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 250, 320, self.view.frame.size.height+400)];
    
    contentView.backgroundColor = [UIColor blackColor];
    contentView.alpha = 0.75;
    [self.mainScrollView addSubview:contentView];
    
    // Set properties in the detail view
    UILabel *movieTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 290, 20)];
    movieTitleLabel.text = [self.movie valueForKey:@"title"];
    movieTitleLabel.textColor = [UIColor whiteColor];
    [movieTitleLabel setFont:[UIFont boldSystemFontOfSize:25]];
    self.title = movieTitleLabel.text;
    
    UILabel *criticsScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 35, 290, 20)];
    criticsScoreLabel.text = [NSString stringWithFormat:@"Critics Score: %@", [[self.movie valueForKeyPath:@"ratings.critics_score"] stringValue]];
    criticsScoreLabel.textColor = [UIColor whiteColor];

    UILabel *audienceScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 50, 290, 20)];
    audienceScoreLabel.text = [NSString stringWithFormat:@"Audience Score: %@", [[self.movie valueForKeyPath:@"ratings.audience_score"] stringValue]];
    audienceScoreLabel.textColor = [UIColor whiteColor];

    UILabel *synopsisLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 70, 290, 20)];
    synopsisLabel.text = [self.movie valueForKey:@"synopsis"];
    synopsisLabel.textColor = [UIColor whiteColor];
    synopsisLabel.numberOfLines = 0;
    [synopsisLabel sizeToFit];
    
    [contentView addSubview:movieTitleLabel];
    [contentView addSubview:criticsScoreLabel];
    [contentView addSubview:audienceScoreLabel];
    [contentView addSubview:synopsisLabel];
    
    [self.backgroundImageView setImageWithURL:[NSURL URLWithString:backgroundImageUrl]];
    
    // TODO: fix hard code offset value
    float scrollHeight = 310 + movieTitleLabel.frame.size.height + criticsScoreLabel.frame.size.height + audienceScoreLabel.frame.size.height + synopsisLabel.frame.size.height - self.navigationController.toolbar.frame.size.height;
    
    self.mainScrollView.contentSize = CGSizeMake(320, scrollHeight);
    
//    CGRect contentRect = CGRectZero;
//    for (UIView *view in self.mainScrollView.subviews) {
//        contentRect = CGRectUnion(contentRect, view.frame);
//    }
//    CGSize scrollableSize = CGSizeMake(320, contentRect.size.height);
//    self.mainScrollView.contentSize = scrollableSize;
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

@end
