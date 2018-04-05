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

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@end

@implementation YouTubeViewController

#pragma mark - UI actions
- (IBAction)playButtonClicked:(UIButton*)sender {
    
    static bool pressed = false;
    if (pressed) {
        [sender setImage:[UIImage imageNamed:@"icon-12.png"] forState:UIControlStateNormal];
        pressed = false;
    } else {
        [sender setImage:[UIImage imageNamed:@"icon-11.png"] forState:UIControlStateNormal];
        pressed = true;
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.videoView.delegate = self;
    
    NSLog(@"Video link = %@", self.videoLink);
    NSString* id = [self extractYoutubeIdFromLink:self.videoLink];
    NSLog(@"ID = %@", id);
    
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
@end


