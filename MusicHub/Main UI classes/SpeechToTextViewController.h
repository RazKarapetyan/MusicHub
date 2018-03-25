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

@interface SpeechToTextViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *recordButton;

- (IBAction)recordButtonPressed:(id)sender;

@end

