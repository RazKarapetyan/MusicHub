//
//  SpeechToTextViewController.m
//  MusicHub
//
//  Created by Razmik Karapetyan on 3/25/18.
//  Copyright © 2018 Razmik Karapetyan. All rights reserved.
//

#import "SpeechToTextViewController.h"

#define SERVER_BAD_RESPONCE @"Not Available"

@interface SpeechToTextViewController ()

@property (strong, nonatomic) SFSpeechRecognizer* recognizer;
@property (strong, nonatomic) SFSpeechAudioBufferRecognitionRequest* recognitionRequest;
@property (strong, nonatomic) SFSpeechRecognitionTask* recognitionTask;
@property (strong, nonatomic) AVAudioEngine* audioEngine;
@property (strong, nonatomic) NSString* recognizedString;
@property (strong, nonatomic) NSString* lastSent;
@property (strong, nonatomic) NSString* serverResponse;
@property (assign, nonatomic) BOOL linkReceived;

@end

@implementation SpeechToTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.recognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"en-US"]];
    self.recognizer.delegate = self;
    self.recordButton.enabled = false;
    self.recognizedString = @"";
    self.serverResponse = @"";
    
    /* Get authorization from user */
    [self authorizeSpeechRecognization];
    
    self.audioEngine = [[AVAudioEngine alloc] init];
    
    // Enable input and show keyboard as soon as connection is established.
    [NetworkController sharedInstance].connectionOpenedBlock = ^(NetworkController* connection){
        NSLog(@">>> Connection opened <<<");
    };
    
    // Disable input and hide keyboard when connection is closed.
    [NetworkController sharedInstance].connectionClosedBlock = ^(NetworkController* connection){
        NSLog(@">>> Connection closed <<<");
    };
    
    // Display error message and do nothing if connection fails.
    [NetworkController sharedInstance].connectionFailedBlock = ^(NetworkController* connection){
        NSLog(@">>> Connection FAILED <<<");
    };
    
    // Append incoming message to the output text view.
    [NetworkController sharedInstance].messageReceivedBlock = ^(NetworkController* connection, NSString* message){
        NSLog(@"received: %@", message);
        //self.textFromServer.text = message;
        self.serverResponse = message;
        
        
        
        //Send to server, if response is bad
        if ([message isEqualToString:SERVER_BAD_RESPONCE] ) {
            //            NSLog(@"BEFORE SLEEPING\n");
            //            [NSThread sleepForTimeInterval:2.0f];
            //            NSLog(@"AFTER SLEEPING\n");
            
            NSLog(@"RECOGNIZED = %@", self.recognizedString);
            NSLog(@"Last sent  = %@", self.lastSent);
            
            if (![self.lastSent isEqualToString:self.recognizedString]) {
                NSLog(@" RAZ sending from message receiving");
                self.lastSent = self.recognizedString;
                [[NetworkController sharedInstance] sendMessage:self.recognizedString];
            } else {
                
                NSLog(@" RAZ going to show alert");
                
                UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Server warning"
                                                                              message:@"Could not find song with that words :( "
                                                                       preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Try again :)"
                                                                    style:UIAlertActionStyleDestructive
                                                                  handler:^(UIAlertAction * action)
                                            {
                                                [self stopRecordingDuringGoodServerRespond];
                                            }];
                
                [alert addAction:yesButton];
                
                [self stopRecordingDuringGoodServerRespond];
                [self presentViewController:alert animated:YES completion:nil];
            }}
        
        YouTubeViewController* videoview = [self.storyboard instantiateViewControllerWithIdentifier:@"raz"];
        videoview.videoLink = self.serverResponse;
        // For now hardcode the seek value
        videoview.seekToSec = 50;
        NSLog(@"videoview link  =%@", videoview.videoLink);
        
        // Present playing controller only for valid video IDs
        if ([self extractYoutubeIdFromLink:videoview.videoLink]) {
            [self stopRecordingDuringGoodServerRespond];
            [self presentViewController:videoview animated:YES completion:nil];
            
        }
    };
}

-(void) stopRecordingDuringGoodServerRespond {
    [self.audioEngine stop];
    [self.recognitionRequest endAudio];
    [self.recordButton setTitle:@"Start recording" forState:UIControlStateNormal];
}

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
-(void) setBackgroundImageFromPath:(NSString*) path {
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:path] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

-(void) viewDidUnload {
    [NetworkController sharedInstance].connectionOpenedBlock = nil;
    [NetworkController sharedInstance].connectionFailedBlock = nil;
    [NetworkController sharedInstance].connectionClosedBlock = nil;
    [NetworkController sharedInstance].messageReceivedBlock = nil;
    
    [super viewDidUnload];
}

#pragma mark -Speach recognation methods
-(void) authorizeSpeechRecognization {
    
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        
        bool buttonIsEnabled = false;
        
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                buttonIsEnabled = true;
                break;
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                buttonIsEnabled = false;
                NSLog(@"Speech recognition restricted on this device");
                break;
            case SFSpeechRecognizerAuthorizationStatusDenied:
                buttonIsEnabled = false;
                NSLog(@"User denied access to speech recognition");
                break;
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                buttonIsEnabled = false;
                NSLog(@"Speech recognition not yet authorized");
                break;
            default:
                break;
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.recordButton.enabled = buttonIsEnabled;
        }];
        
    }];
}

-(void) startRecording {
    if(self.recognitionTask != nil) {
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
    }
    
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    
    [audioSession setCategory:AVAudioSessionCategoryRecord  error:nil];
    [audioSession setMode:AVAudioSessionModeMeasurement error:nil];
    [audioSession setActive:YES error:nil];
    
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    if(!self.recognitionRequest)
        NSAssert(false, @"Unable to create an SFSpeechAudioBufferRecognitionRequest object");
    
    AVAudioNode* inputNode = self.audioEngine.inputNode;
    if(!inputNode)
        NSAssert(false, @"Audio engine has no input node");
    
    [self.recognitionRequest setShouldReportPartialResults:YES];
    
    self.recognitionTask = [self.recognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        bool isFinal = false;
        
        if (result != nil) {
            //self.speechTextField.text = [[result bestTranscription] formattedString];
            self.recognizedString = [[result bestTranscription] formattedString];
            
            /*  Flag for sending data to server again, after youtube playing */
            if(self.linkReceived) {
                NSLog(@"Sending from recording");
                [[NetworkController sharedInstance] sendMessage:self.recognizedString];
                self.lastSent = self.recognizedString;
                self.linkReceived = NO;
            }
            
            
            NSLog(@"result = %@", self.recognizedString);
            isFinal = [result isFinal];
        }
        
        if(error != nil || isFinal) {
            [self.audioEngine stop];
            [inputNode removeTapOnBus:(0)];
            self.recognitionRequest = nil;
            self.recognitionTask = nil;
            self.recordButton.enabled = true;
        }
    }];;
    
    
    AVAudioFormat* recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:(0) bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self.recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    
    [self.audioEngine prepare];
    bool returnVal = [self.audioEngine startAndReturnError:nil];
    
    if(returnVal)
        NSLog(@"audio engine started ok");
    else
        NSLog(@"audio engine started is not ok");
    
    //self.speechTextField.text = @"Say something, I'am listening";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)recordButtonPressed:(UIButton*)sender {
    
    [[NetworkController sharedInstance] connect];
    
    if(self.audioEngine.isRunning) {
        [self.audioEngine stop];
        [self.recognitionRequest endAudio];
        self.recordButton.enabled = NO;
        [self.recordButton setTitle:@"Start recording" forState:UIControlStateNormal];
        NSLog(@"if branch");
    } else {
        NSLog(@"else branch");
        // Reset flag for sending after youtube playing
        self.linkReceived = YES;
        [self.recordButton setTitle:@"Stop recording" forState:UIControlStateNormal];
        [self startRecording];
    }
}

#pragma mark - SFSpeechRecognizerDelegate
- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available {
    NSLog(@"speechRecognizer availabilityDidChange");
    if (available) {
        self.recordButton.enabled = YES;
    } else {
        self.recordButton.enabled = NO;
    }
}

@end