
#import <UIKit/UIKit.h>
#import "VianYahooDataPuller.h"
#import "CorePlot-CocoaTouch.h"
#import "MultiresDateFormatter.h"
#import "PlotAreaDescription.h"
#import "VianGraphHostingView.h"

@class VianYahooDataPuller;

@interface MainViewController : UIViewController <VianYahooDataPullerDelegate, VianGraphClickHandler> {
    VianGraphHostingView *graphHost;
    
	@private
    VianYahooDataPuller *datapuller;
    VianDateResolution dateRes;
}

@property (nonatomic, retain) IBOutlet VianGraphHostingView *graphHost;

-(IBAction)res1d;
-(IBAction)res7d;
-(IBAction)res1m;
-(IBAction)res3m;
-(IBAction)res6m;
-(IBAction)res1y;
-(IBAction)res2y;

@end