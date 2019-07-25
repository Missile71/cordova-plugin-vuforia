#import "ViewController.h"
#import "ImageTargetsViewController.h"

#import <Vuforia/TrackerManager.h>
#import <Vuforia/ObjectTracker.h>

@interface ViewController ()

@property BOOL launchedCamera;
@property ImageTargetsViewController *imageTargetsViewController;

@end

@implementation ViewController

-(void) showHTML:(NSString*)url markerid:(NSString *)markerid{
    if (markerid != self.imageTargetsViewController.markerid){
        self.imageTargetsViewController.book_id = self.book_id;
        self.imageTargetsViewController.email = self.email;
        self.imageTargetsViewController.prof_fullname = self.prof_fullname;
        self.imageTargetsViewController.prof_id = self.prof_id;
        self.imageTargetsViewController.extra = self.extra;
        self.imageTargetsViewController.path_documents = self.path_documents;
        self.imageTargetsViewController.tipo = self.tipo;
        
        [self.imageTargetsViewController showHTML:url markerid:markerid];
    }
    
}

-(id)initWithFileName:(NSString *)fileName targetNames:(NSArray *)imageTargetNames overlayOptions:( NSDictionary *)overlayOptions vuforiaLicenseKey:(NSString *)vuforiaLicenseKey {

    self = [super init];
    self.imageTargets = [[NSDictionary alloc] initWithObjectsAndKeys: fileName, @"imageTargetFile", imageTargetNames, @"imageTargetNames", nil];
    self.overlayOptions = overlayOptions;
    self.vuforiaLicenseKey = vuforiaLicenseKey;
    NSLog(@"Vuforia Plugin :: initWithFileName: %@", fileName);
    NSLog(@"Vuforia Plugin :: overlayOptions: %@", self.overlayOptions);
    NSLog(@"Vuforia Plugin :: License key: %@", self.vuforiaLicenseKey);
    return self;
}

-(id)initWithFileNameZanichelli:(NSString *)fileName targetNames:(NSArray *)imageTargetNames overlayOptions:( NSDictionary *)overlayOptions vuforiaLicenseKey:(NSString *)vuforiaLicenseKey book_id:(NSString *)book_id email:(NSString *)email prof_fullname:(NSString *)profFullName prof_id:(NSString *)profId extra:(NSString *)extra pathDocuments:(NSString *)path_documents tipo:(NSString *)tipo fileName2:(NSString *)fileName2{
    
    self = [super init];
    self.imageTargets = [[NSDictionary alloc] initWithObjectsAndKeys: fileName, @"imageTargetFile", fileName2, @"imageTargetFile2", imageTargetNames, @"imageTargetNames", nil];
    self.overlayOptions = overlayOptions;
    self.vuforiaLicenseKey = vuforiaLicenseKey;
    NSLog(@"Vuforia Plugin :: initWithFileName: %@", fileName);
    NSLog(@"Vuforia Plugin :: overlayOptions: %@", self.overlayOptions);
    NSLog(@"Vuforia Plugin :: License key: %@", self.vuforiaLicenseKey);
    
    //MI SALVO I PARAMETRI RICEVUTI
    self.book_id = book_id;
    self.email = email;
    self.prof_fullname = profFullName;
    self.prof_id = profId;
    self.extra = extra;
    self.path_documents = path_documents;
    self.tipo = tipo;
    
    return self;
}
    
-(id)initWithFileNameZanichelli_OLD:(NSString *)fileName targetNames:(NSArray *)imageTargetNames overlayOptions:( NSDictionary *)overlayOptions vuforiaLicenseKey:(NSString *)vuforiaLicenseKey book_id:(NSString *)book_id email:(NSString *)email prof_fullname:(NSString *)profFullName prof_id:(NSString *)profId extra:(NSString *)extra pathDocuments:(NSString *)path_documents tipo:(NSString *)tipo {
    
    self = [super init];
    self.imageTargets = [[NSDictionary alloc] initWithObjectsAndKeys: fileName, @"imageTargetFile", imageTargetNames, @"imageTargetNames", nil];
    self.overlayOptions = overlayOptions;
    self.vuforiaLicenseKey = vuforiaLicenseKey;
    NSLog(@"Vuforia Plugin :: initWithFileName: %@", fileName);
    NSLog(@"Vuforia Plugin :: overlayOptions: %@", self.overlayOptions);
    NSLog(@"Vuforia Plugin :: License key: %@", self.vuforiaLicenseKey);
    
    //MI SALVO I PARAMETRI RICEVUTI
    self.book_id = book_id;
    self.email = email;
    self.prof_fullname = profFullName;
    self.prof_id = profId;
    self.extra = extra;
    self.path_documents = path_documents;
    self.tipo = tipo;
    
    return self;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    //Execute javascript method or pure javascript if needed
    //[_webView stringByEvaluatingJavaScriptFromString:@"methodName();"];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];

    NSLog(@"Vuforia Plugin :: viewController did load");
    self.launchedCamera = false;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.launchedCamera == false) {
        self.imageTargetsViewController = [[ImageTargetsViewController alloc]  initWithOverlayOptions:self.overlayOptions vuforiaLicenseKey:self.vuforiaLicenseKey];
        self.launchedCamera = true;

        self.imageTargetsViewController.imageTargetFile = [self.imageTargets objectForKey:@"imageTargetFile"];
        self.imageTargetsViewController.imageTargetFile2 = [self.imageTargets objectForKey:@"imageTargetFile2"];
        self.imageTargetsViewController.imageTargetNames = [self.imageTargets objectForKey:@"imageTargetNames"];

        [self presentViewController:self.imageTargetsViewController animated:NO completion:nil];
        self.imageTargetsViewController.vc = self;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (bool) stopTrackers {
    return [self.imageTargetsViewController doStopTrackers];
}

- (bool) startTrackers {
    return [self.imageTargetsViewController doStartTrackers];
}

- (bool) updateTargets:(NSArray *)targets {
    return [self.imageTargetsViewController doUpdateTargets:targets];
}

- (void) close{
    [self.imageTargetsViewController dismissViewControllerAnimated:NO completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissMe {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CameraHasFound" object:self];
}

- (BOOL)shouldAutorotate {
    return [[self presentingViewController] shouldAutorotate];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [[self presentingViewController] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self presentingViewController] preferredInterfaceOrientationForPresentation];
}



@end
