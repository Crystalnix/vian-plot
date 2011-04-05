#import "MainViewController.h"
#import "VianGraphHostingView.h"

@interface MainViewController()

@property(nonatomic, retain) VianYahooDataPuller *datapuller;

@end

@implementation MainViewController

@synthesize datapuller;
@synthesize graphHost;

-(void)dealloc
{
    [datapuller release];
    [graphHost release];
    datapuller = nil;
    graphHost = nil;    
    [super dealloc];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

-(void)setView:(UIView *)aView;
{
    [super setView:aView];
    if ( nil == aView ) {
        self.graphHost = nil;
    }
}

-(void)viewDidLoad 
{   
    NSAssert(self.graphHost != nil, @"View not initialized");
    
    graphHost.clickerDelegate = self;
    
    VianYahooDataPuller *dp = [[VianYahooDataPuller alloc] initWithTargetSymbol:@"AAPL" dateResolution:VianDateResolutionMonth];
    [self setDatapuller:dp];
    [dp setDelegate:self];
    [dp release];
        
    [super viewDidLoad];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {

    }
    return self;
}

-(NSString *)pathForSymbol:(NSString *)aSymbol
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *docPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", aSymbol]];
    return docPath;
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag;
{
    NSLog(@"writeToFile:%@", path);
    BOOL success = [[graphHost.model dictionaryRepresentation] writeToFile:path atomically:flag];
    return success;
}

-(void)dataPullerDidFinishFetch:(VianYahooDataPuller *)dp;
{
    graphHost.model = [dp modelForData];
    graphHost.handleTouch = YES;
    graphHost.graphIndexForTouch = 0;
    
    [self writeToFile:[self pathForSymbol:@"AAPL"] atomically:NO];
}

-(VianYahooDataPuller *)datapuller
{    
    return datapuller; 
}

-(void)setDatapuller:(VianYahooDataPuller *)aDatapuller
{    
    if (datapuller != aDatapuller) {
        [aDatapuller retain];
        [datapuller release];
        datapuller = aDatapuller;
    }
}

-(IBAction)res1d
{
    VianYahooDataPuller *dp = [[VianYahooDataPuller alloc] initWithTargetSymbol:@"AAPL" dateResolution:VianDateResolutionDay];
    [self setDatapuller:dp];
    [dp setDelegate:self];
    [dp release];
}

-(IBAction)res7d
{
    VianYahooDataPuller *dp = [[VianYahooDataPuller alloc] initWithTargetSymbol:@"AAPL" dateResolution:VianDateResolutionWeek];
    [self setDatapuller:dp];
    [dp setDelegate:self];
    [dp release];
}

-(IBAction)res1m
{
    VianYahooDataPuller *dp = [[VianYahooDataPuller alloc] initWithTargetSymbol:@"AAPL" dateResolution:VianDateResolutionMonth];
    [self setDatapuller:dp];
    [dp setDelegate:self];
    [dp release];
}

-(IBAction)res3m
{
    VianYahooDataPuller *dp = [[VianYahooDataPuller alloc] initWithTargetSymbol:@"AAPL" dateResolution:VianDateResolutionThreeMonths];
    [self setDatapuller:dp];
    [dp setDelegate:self];
    [dp release]; 
}

-(IBAction)res6m
{
    VianYahooDataPuller *dp = [[VianYahooDataPuller alloc] initWithTargetSymbol:@"AAPL" dateResolution:VianDateResolutionSixMonths];
    [self setDatapuller:dp];
    [dp setDelegate:self];
    [dp release];
}

-(IBAction)res1y
{
    VianYahooDataPuller *dp = [[VianYahooDataPuller alloc] initWithTargetSymbol:@"AAPL" dateResolution:VianDateResolutionYear];
    [self setDatapuller:dp];
    [dp setDelegate:self];
    [dp release]; 
}

-(IBAction)res2y
{
    VianYahooDataPuller *dp = [[VianYahooDataPuller alloc] initWithTargetSymbol:@"AAPL" dateResolution:VianDateResolutionTwoYears];
    [self setDatapuller:dp];
    [dp setDelegate:self];
    [dp release];
}

-(void)handleClick
{
    CPPlot* p = [[graphHost graph] plotWithIdentifier:@"OHLC Plot"];
    if (p.dataSource) {
        p.dataSource = nil;
    } else {
        p.dataSource = graphHost.model;
    }
    [[graphHost graph] reloadData];
}

@end

