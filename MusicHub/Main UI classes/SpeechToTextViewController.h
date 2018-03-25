//
//  SpeechToTextViewController.h
//  MusicHub
//
//  Created by Razmik Karapetyan on 3/25/18.
//  Copyright © 2018 Razmik Karapetyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Speech/Speech.h>
#import "NetworkController.h"
#import "YouTubeViewController.h"

@interface SpeechToTextViewController : UIViewController <SFSpeechRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UILabel *previewLabel;

- (IBAction)recordButtonPressed:(id)sender;

@end

