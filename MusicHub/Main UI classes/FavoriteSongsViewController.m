//
//  RecentlyListenedViewController.m
//  MusicHub
//
//  Created by Razmik Karapetyan on 3/25/18.
//  Copyright © 2018 Razmik Karapetyan. All rights reserved.
//

#import "FavoriteSongsViewController.h"

@interface FavoriteSongsViewController ()

@end

@implementation FavoriteSongsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)eventHandler:(NSNotification*) notification
{
    NSDictionary* dict = notification.userInfo;
    
    NSLog(@"Song title is  %@", [dict valueForKey:@"songTitle"]);
    NSLog(@"Artisr name is  %@", [dict valueForKey:@"artistName"]);
    
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
