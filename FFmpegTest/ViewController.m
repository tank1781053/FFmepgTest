//
//  ViewController.m
//  FFmpegTest
//
//  Created by chenhairong on 15/5/3.
//  Copyright (c) 2015年 times. All rights reserved.
//

#import "ViewController.h"
#include "avformat.h"
#include "avcodec.h"
#import "KxMovieViewController.h"

@interface ViewController ()
{
    NSArray *_localMovies;
    NSArray *_remoteMovies;
}
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation ViewController

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor whiteColor];
    //self.tableView.backgroundView = [[UIImageView alloc] initWithImage:image];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    [self.view addSubview:self.tableView];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (BOOL)prefersStatusBarHidden { return YES; }

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"FFmpegPlayer";
    self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag: 0];
    
    _remoteMovies = @[
                      @"http://www.qeebu.com/newe/Public/Attachment/99/52958fdb45565.mp4",                     @"http://10.0.15.30:5000/nn_live.ts?id=wifi-nmgws&url_c1=2000&nn_ak=01e0c4ebd4d5c4b8a550931c64e7abd6df&npips=10.0.14.87:5100&ncmsid=199999&ngs=5667f68900034392d05f9c037045fef0&nn_user_id=&ndi=&ndv=&nst=iptv&cms=V15667f689c962057a012caf3d2d20adc2&nal=0189f667560607688cd268bf77a33230b13a14f4576371",
                      @"http://10.0.15.30:5000/nn_live.ts?id=wifi-hbws&url_c1=2000&nn_ak=012f55b235468961d83c256bdb3b89419c&npips=10.0.14.87:5100&ncmsid=199999&ngs=5667f6830004c63a10045573b43e893a&nn_user_id=&ndi=&ndv=&nst=iptv&cms=V15667f68312b49053b69d95331304c453&nal=0183f6675606076f5629ba21ea520910d395c21a5e290a",
                      @"http://10.0.15.30:5000/nn_live.ts?id=wifi-cctv5p&url_c1=2000&nn_ak=012c5424299463625b74c6264c087f6ff7&npips=10.0.14.87:5100&ncmsid=199999&ngs=5667f69a000344198af12bb6d220ee49&nn_user_id=&ndi=&ndv=&nst=iptv&cms=V15667f69ac8329ac38528b770c9117370&nal=019af667560607b8ef444222930b98e5acb65c49c25cdf",
                      @"rtsp://184.72.239.149/vod/mp4:BigBuckBunny_115k.mov",
                      
                      ];
    

#ifdef DEBUG_AUTOPLAY
    [self performSelector:@selector(launchDebugTest) withObject:nil afterDelay:0.5];
#endif
    
    [self.tableView reloadData];
}

- (void)launchDebugTest
{
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:4
                                                                              inSection:1]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self reloadMovies];
    [self.tableView reloadData];
}

- (void) reloadMovies
{
    NSMutableArray *ma = [NSMutableArray array];
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSString *folder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                            NSUserDomainMask,
                                                            YES) lastObject];
    NSArray *contents = [fm contentsOfDirectoryAtPath:folder error:nil];
    
    for (NSString *filename in contents) {
        
        if (filename.length > 0 &&
            [filename characterAtIndex:0] != '.') {
            
            NSString *path = [folder stringByAppendingPathComponent:filename];
            NSDictionary *attr = [fm attributesOfItemAtPath:path error:nil];
            if (attr) {
                id fileType = [attr valueForKey:NSFileType];
                if ([fileType isEqual: NSFileTypeRegular] ||
                    [fileType isEqual: NSFileTypeSymbolicLink]) {
                    
                    NSString *ext = path.pathExtension.lowercaseString;
                    
                    if ([ext isEqualToString:@"mp3"] ||
                        [ext isEqualToString:@"caff"]||
                        [ext isEqualToString:@"aiff"]||
                        [ext isEqualToString:@"ogg"] ||
                        [ext isEqualToString:@"wma"] ||
                        [ext isEqualToString:@"m4a"] ||
                        [ext isEqualToString:@"m4v"] ||
                        [ext isEqualToString:@"wmv"] ||
                        [ext isEqualToString:@"3gp"] ||
                        [ext isEqualToString:@"mp4"] ||
                        [ext isEqualToString:@"mov"] ||
                        [ext isEqualToString:@"avi"] ||
                        [ext isEqualToString:@"mkv"] ||
                        [ext isEqualToString:@"mpeg"]||
                        [ext isEqualToString:@"mpg"] ||
                        [ext isEqualToString:@"flv"] ||
                        [ext isEqualToString:@"vob"]) {
                        
                        [ma addObject:path];
                    }
                }
            }
        }
    }
    
    // Add all the movies present in the app bundle.
    NSBundle *bundle = [NSBundle mainBundle];
    [ma addObjectsFromArray:[bundle pathsForResourcesOfType:@"mp4" inDirectory:@"SampleMovies"]];
    [ma addObjectsFromArray:[bundle pathsForResourcesOfType:@"mov" inDirectory:@"SampleMovies"]];
    [ma addObjectsFromArray:[bundle pathsForResourcesOfType:@"m4v" inDirectory:@"SampleMovies"]];
    [ma addObjectsFromArray:[bundle pathsForResourcesOfType:@"wav" inDirectory:@"SampleMovies"]];
    [ma addObjectsFromArray:[bundle pathsForResourcesOfType:@"avi" inDirectory:@"SampleMovies"]];
    //[ma addObject:[bundle pathForResource:@"ios"ofType:@"mkv"]];
    [ma sortedArrayUsingSelector:@selector(compare:)];
    
    _localMovies = [ma copy];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:     return @"Remote";
        case 1:     return @"Local";
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:     return _remoteMovies.count;
        case 1:     return _localMovies.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSString *path;
    
    if (indexPath.section == 0) {
        
        path = _remoteMovies[indexPath.row];
        
    } else {
        
        path = _localMovies[indexPath.row];
    }
    
    cell.textLabel.text = path.lastPathComponent;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *path;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (indexPath.section == 0) {
        
        if (indexPath.row >= _remoteMovies.count) return;
        path = _remoteMovies[indexPath.row];
        
    } else {
        
        if (indexPath.row >= _localMovies.count) return;
        path = _localMovies[indexPath.row];
    }
    
    // increase buffering for .wmv, it solves problem with delaying audio frames
    if ([path.pathExtension isEqualToString:@"wmv"])
        parameters[KxMovieParameterMinBufferedDuration] = @(5.0);
    
    // disable deinterlacing for iPhone, because it's complex operation can cause stuttering
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
    
    // disable buffering
    //parameters[KxMovieParameterMinBufferedDuration] = @(0.0f);
    //parameters[KxMovieParameterMaxBufferedDuration] = @(0.0f);
    
    KxMovieViewController *vc = [KxMovieViewController movieViewControllerWithContentPath:path
                                                                               parameters:parameters];
    [self presentViewController:vc animated:YES completion:nil];
    //[self.navigationController pushViewController:vc animated:YES];    
    
   // LoggerApp(1, @"Playing a movie: %@", path);
}

@end
