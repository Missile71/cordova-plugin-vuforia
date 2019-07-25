#import <UIKit/UIKit.h>

@interface ViewController : UIViewController 

@property (retain, nonatomic) NSDictionary *imageTargets;
@property (retain, nonatomic) NSDictionary *overlayOptions;
@property (retain, nonatomic) NSString *overlayText;
@property (retain, nonatomic) NSString *vuforiaLicenseKey;

@property (retain, nonatomic) NSString *book_id;
@property (retain, nonatomic) NSString *email;
@property (retain, nonatomic) NSString *prof_fullname;
@property (retain, nonatomic) NSString *prof_id;
@property (retain, nonatomic) NSString *extra;
@property (retain, nonatomic) NSString *path_documents;
@property (retain, nonatomic) NSString *tipo;

-(id)initWithFileName:(NSString *)fileName targetNames:(NSArray *)imageTargetNames overlayOptions:(NSDictionary*)overlayOptions vuforiaLicenseKey:(NSString *)vuforiaLicenseKey;
-(id)initWithFileNameZanichelli_OLD:(NSString *)fileName targetNames:(NSArray *)imageTargetNames overlayOptions:(NSDictionary*)overlayOptions vuforiaLicenseKey:(NSString *)vuforiaLicenseKey book_id:(NSString *)book_id email:(NSString *)email prof_fullname:(NSString *)profFullName prof_id:(NSString *)profId extra:(NSString *)extra  pathDocuments:(NSString *)path_documents  tipo:(NSString *)tipo;
-(id)initWithFileNameZanichelli:(NSString *)fileName targetNames:(NSArray *)imageTargetNames overlayOptions:(NSDictionary*)overlayOptions vuforiaLicenseKey:(NSString *)vuforiaLicenseKey book_id:(NSString *)book_id email:(NSString *)email prof_fullname:(NSString *)profFullName prof_id:(NSString *)profId extra:(NSString *)extra  pathDocuments:(NSString *)path_documents  tipo:(NSString *)tipo fileName2:(NSString *)fileName2;
- (bool) stopTrackers;
- (bool) startTrackers;
- (bool) updateTargets:(NSArray *)targets;
- (void) close;
-(void) showHTML:(NSString*)url markerid:(NSString*)markerid;
@end
