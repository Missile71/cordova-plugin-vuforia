#import "VuforiaPlugin.h"
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface VuforiaPlugin()

@property CDVInvokedUrlCommand *command;
@property ViewController *imageRecViewController;
@property BOOL startedVuforia;
@property BOOL autostopOnImageFound;
    

@end

@implementation VuforiaPlugin
    
- (void) cordovaAddHTML:(CDVInvokedUrlCommand *)command {
    NSLog(@"Vuforia Plugin :: cordovaAddHTML");
    [self.imageRecViewController showHTML:[command.arguments objectAtIndex:0] markerid:[command.arguments objectAtIndex:1]];
}

- (void) cordovaStartVuforia:(CDVInvokedUrlCommand *)command {

    NSLog(@"Vuforia Plugin :: Start plugin");

    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        // do your logic
    } else if(authStatus == AVAuthorizationStatusDenied){
        // denied
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
        NSString *message = [NSString stringWithFormat:@"Per dare l'autorizzazione vai su: \nSettings > Privacy > Camera > %@ e seleziona ON.", appName];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Non è stato consentito l'uso della fotocamera!" message:message delegate:self cancelButtonTitle:@"Chiudi" otherButtonTitles:nil, nil];
        
        [alert show];
        return;
    } else if(authStatus == AVAuthorizationStatusRestricted){
        // restricted, normally won't happen
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
        NSString *message = [NSString stringWithFormat:@"User denied camera access to this App. To restore camera access, go to: \nSettings > Privacy > Camera > %@ and turn it ON.", appName];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iOS8 Camera Access Warning" message:message delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        
        [alert show];
        return;
    } else {
        // impossible, unknown authorization status
    }
    
    NSLog(@"Arguments: %@", command.arguments);
    NSLog(@"KEY: %@", [command.arguments objectAtIndex:3]);

    NSString *overlayText = ([command.arguments objectAtIndex:2] == (id)[NSNull null]) ? @"" : [command.arguments objectAtIndex:2];

    NSDictionary *overlayOptions =  [[NSDictionary alloc] initWithObjectsAndKeys: overlayText, @"overlayText", [NSNumber numberWithBool:[[command.arguments objectAtIndex:5] integerValue]], @"showDevicesIcon", nil];

    self.autostopOnImageFound = [[command.arguments objectAtIndex:6] integerValue];

    [self startVuforiaWithImageTargetFileZanichelli:[command.arguments objectAtIndex:0] imageTargetNames: [command.arguments objectAtIndex:1] overlayOptions: overlayOptions vuforiaLicenseKey: [command.arguments objectAtIndex:3] book_id:[command.arguments objectAtIndex:7] email:[command.arguments objectAtIndex:8] prof_fullname:[command.arguments objectAtIndex:9] prof_id:[command.arguments objectAtIndex:10] extra:@"" pathDocuments:[command.arguments objectAtIndex:11] tipo:[command.arguments objectAtIndex:12] imageTargetfile2:[command.arguments objectAtIndex:10]];
    self.command = command;

    self.startedVuforia = true;
}

- (void) cordovaStopVuforia:(CDVInvokedUrlCommand *)command {
    self.command = command;

    NSDictionary *jsonObj = [NSDictionary alloc];

    if(self.startedVuforia == true){
        NSLog(@"Vuforia Plugin :: Stopping plugin");

        jsonObj = [ [NSDictionary alloc] initWithObjectsAndKeys :
                   @"true", @"success",
                   nil
                   ];
    }else{
        NSLog(@"Vuforia Plugin :: Cannot stop the plugin because it wasn't started");

        jsonObj = [ [NSDictionary alloc] initWithObjectsAndKeys :
                   @"false", @"success",
                   @"No Vuforia session running", @"message",
                   nil
                   ];
    }

    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];

    [self VP_closeView];
}

- (void) cordovaStopTrackers:(CDVInvokedUrlCommand *)command{
    bool result = [self.imageRecViewController stopTrackers];

    [self handleResultMessage:result command:command];
}

- (void) cordovaStartTrackers:(CDVInvokedUrlCommand *)command{
    bool result = [self.imageRecViewController startTrackers];

    [self handleResultMessage:result command:command];
}

- (void) cordovaUpdateTargets:(CDVInvokedUrlCommand *)command{
    NSArray *targets = [command.arguments objectAtIndex:0];

    // We need to ensure our targets are flatened, if we pass an array of items it'll crash if we dont
    NSMutableArray *flattenedTargets = [[NSMutableArray alloc] init];
    for (int i = 0; i < targets.count ; i++)
    {
        if([[targets objectAtIndex:i] respondsToSelector:@selector(count)]) {
            [flattenedTargets addObjectsFromArray:[targets objectAtIndex:i]];
        } else {
            [flattenedTargets addObject:[targets objectAtIndex:i]];
        }
    }

    targets = [flattenedTargets copy];

    NSLog(@"Updating targets: %@", targets);

    bool result = [self.imageRecViewController updateTargets:targets];

    [self handleResultMessage:result command:command];
}

#pragma mark - Util_Methods
- (void) startVuforiaWithImageTargetFile:(NSString *)imageTargetfile imageTargetNames:(NSArray *)imageTargetNames overlayOptions:(NSDictionary *)overlayOptions vuforiaLicenseKey:(NSString *)vuforiaLicenseKey {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ImageMatched" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageMatched:) name:@"ImageMatched" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CloseRequest" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeRequest:) name:@"CloseRequest" object:nil];

    self.imageRecViewController = [[ViewController alloc] initWithFileName:imageTargetfile targetNames:imageTargetNames overlayOptions:overlayOptions vuforiaLicenseKey:vuforiaLicenseKey];

    
    [self.viewController presentViewController:self.imageRecViewController animated:YES completion:nil];
}

- (void) startVuforiaWithImageTargetFileZanichelli:(NSString *)imageTargetfile imageTargetNames:(NSArray *)imageTargetNames overlayOptions:(NSDictionary *)overlayOptions vuforiaLicenseKey:(NSString *)vuforiaLicenseKey book_id:(NSString *)book_id email:(NSString *)email prof_fullname:(NSString *)profFullName prof_id:(NSString *)profId extra:(NSString *)extra pathDocuments:(NSString *)path_documents tipo:(NSString *)tipo imageTargetfile2:(NSString *)imageTargetfile2{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ImageMatched" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageMatched:) name:@"ImageMatched" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CloseRequest" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeRequest:) name:@"CloseRequest" object:nil];
    
//    self.imageRecViewController = [[ViewController alloc] initWithFileName:imageTargetfile targetNames:imageTargetNames overlayOptions:overlayOptions vuforiaLicenseKey:vuforiaLicenseKey];
    
    self.imageRecViewController = [[ViewController alloc] initWithFileNameZanichelli:imageTargetfile targetNames:imageTargetNames overlayOptions:overlayOptions vuforiaLicenseKey:vuforiaLicenseKey book_id:book_id email:email prof_fullname:profFullName prof_id:profId extra:extra pathDocuments:path_documents tipo:tipo fileName2:imageTargetfile2];
    
    [self.viewController presentViewController:self.imageRecViewController animated:YES completion:nil];
}


- (void)imageMatched:(NSNotification *)notification {
    NSDictionary* userInfo = notification.userInfo;

    NSLog(@"Vuforia Plugin :: image matched");
    NSDictionary* jsonObj = @{@"status": @{@"imageFound": @true, @"message": @"Image Found."}, @"result": @{@"imageName": userInfo[@"result"][@"imageName"]}};

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary: jsonObj];

    if(!self.autostopOnImageFound){
        [pluginResult setKeepCallbackAsBool:TRUE];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];

    if(self.autostopOnImageFound){
        [self VP_closeView];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ImageMatched" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageMatched:) name:@"ImageMatched" object:nil];
    }
}

- (void)closeRequest:(NSNotification *)notification {

    NSDictionary* jsonObj = @{@"status": @{@"manuallyClosed": @true, @"message": @"User manually closed the plugin."}};

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_NO_RESULT messageAsDictionary: jsonObj];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
    [self VP_closeView];
}

- (void) VP_closeView {
    if(self.startedVuforia == true){
        [self.imageRecViewController close];
        self.imageRecViewController = nil;
        self.startedVuforia = false;
    }
}

-(void) handleResultMessage:(bool)result command:(CDVInvokedUrlCommand *)command {
    if(result){
        [self sendSuccessMessage:command];
    } else {
        [self sendErrorMessage:command];
    }
}

-(void) sendSuccessMessage:(CDVInvokedUrlCommand *)command {
    NSDictionary *jsonObj = [ [NSDictionary alloc] initWithObjectsAndKeys :
                             @"true", @"success",
                             nil
                             ];

    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void) sendErrorMessage:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_ERROR
                                     messageAsString: @"Did not successfully complete"
                                     ];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
