//
//  YouTubeViewController.h
//  MusicHub
//
//  Created by Razmik Karapetyan on 3/25/18.
//  Copyright © 2018 Razmik Karapetyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTPlayerView.h"

@interface YouTubeViewController : UIViewController <YTPlayerViewDelegate>

@property (weak, nonatomic) IBOutlet  UIButton * _Nullable dismissButton;
@property (weak, nonatomic) IBOutlet YTPlayerView * _Nullable videoView;

@property (strong, nonnull) NSString* videoLink;
@property (assign) float seekToSec;

- (IBAction)dismissAction:(UIButton*)sender;
@property (weak, nonatomic) IBOutlet UIButton *_Nullable favoriteButton;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property (weak, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;

@end
