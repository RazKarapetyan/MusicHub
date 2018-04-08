//
//  YouTubeViewController.m
//  MusicHub
//
//  Created by Razmik Karapetyan on 3/25/18.
//  Copyright © 2018 Razmik Karapetyan. All rights reserved.
//

#import "YouTubeViewController.h"
#import <Speech/Speech.h>

@interface YouTubeViewController ()
@end

@implementation YouTubeViewController

#pragma mark - UI actions

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.favoriteButton setSelected:YES];
    [self.favoriteButton setImage:[UIImage imageNamed:@"icon-01_25x25.png"] forState:UIControlStateNormal];
    
    self.videoView.delegate = self;
    NSString* id;
    if (self.videoLink) {
        NSLog(@"Video link = %@", self.videoLink);
        id = [self extractYoutubeIdFromLink:self.videoLink];
        NSLog(@"ID = %@", id);
    }
    if (id != nil) {
        /* Set audio session to PLAYBACK, for being able play audio in youtube player */
        AVAudioSession* audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback  error:nil];

        NSDictionary *playerVars = @{
                                     @"playsinline" : @1,
                                     @"autoplay" : @1,
                                     @"rel" : @0,
                                     @"showinfo" : @0,
                                     //@"allowsInlineMediaPlayback" : @1,
                                     @"origin" : @"http://www.youtube.com",
                                     };

        [self.videoView loadWithVideoId:id playerVars:playerVars];
    } else {
        id = @"6CvuyaKmLnw";
        /* Set audio session to PLAYBACK, for being able play audio in youtube player */
        AVAudioSession* audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback  error:nil];
        
        NSDictionary *playerVars = @{
                                     @"playsinline" : @1,
                                     @"autoplay" : @1,
                                     @"rel" : @0,
                                     @"showinfo" : @0,
                                     //@"allowsInlineMediaPlayback" : @1,
                                     @"origin" : @"http://www.youtube.com",
                                     };
        
        [self.videoView loadWithVideoId:id playerVars:playerVars];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Utilit methods
- (NSString *)extractYoutubeIdFromLink:(NSString *)link {
    NSString *regexString = @"((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)";
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:regexString
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:nil];
    
    NSArray *array = [regExp matchesInString:link options:0 range:NSMakeRange(0,link.length)];
    if (array.count > 0) {
        NSTextCheckingResult *result = array.firstObject;
        return [link substringWithRange:result.range];
    }
    return nil;
}

#pragma mark - Delegate
-(void)playerViewDidBecomeReady:(YTPlayerView *)playerView{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Playback started" object:self];
    [self.videoView playVideo];
    [self.videoView seekToSeconds:self.seekToSec allowSeekAhead:YES];
    NSLog(@"delegate method");
}

- (IBAction)favoriteButtonPressed:(UIButton*)sender {
   
    self.alertLabel.alpha = 1;
    self.alertLabel.hidden = NO;
   
    if ([sender isSelected]) {
        [sender setImage:[UIImage imageNamed:@"icon-02_25x25.png"] forState:UIControlStateNormal];
        [sender setSelected:NO];
        
        [UIView animateWithDuration:3 animations:^{
            self.alertLabel.alpha = 0;
            [self.alertLabel setText:@"Added to favorites"];

        } completion: ^(BOOL finished) {
            self.alertLabel.hidden = finished;
        }];
        
    } else {
        [sender setImage:[UIImage imageNamed:@"icon-01_25x25.png"] forState:UIControlStateSelected];
        [sender setSelected:YES];
        
        [UIView animateWithDuration:3 animations:^{
            self.alertLabel.alpha = 0;
            [self.alertLabel setText:@"Removed from favorites"];
            
        } completion: ^(BOOL finished) {
            self.alertLabel.hidden = finished;
        }];
        
        NSLog(@"Is not selected branch");
    }
    
}
@end


