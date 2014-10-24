//
//  FirstViewController.m
//  HearBud
//
//  Created by Ritchie Bui on 2014-10-21.
//  Copyright (c) 2014 Ritchie Bui. All rights reserved.
//

@import MediaPlayer;
@import MultipeerConnectivity;

#import "FirstViewController.h"
#import "MultipeerManager.h"

@interface FirstViewController ()

@property (weak, nonatomic) IBOutlet UITableView *songsTable;

@end

@implementation FirstViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didReceiveDataWithNotification:)
												 name:@"MCDidReceiveDataNotification"
											   object:nil];
	_songs = nil;
	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


#pragma mark - IBActions

- (IBAction)selectSongs
{
	MPMediaPickerController *mediaPickerController = [[MPMediaPickerController alloc]
													  initWithMediaTypes:MPMediaTypeAnyAudio];
	[mediaPickerController setDelegate:self];
	[mediaPickerController setAllowsPickingMultipleItems:YES];
	mediaPickerController.prompt = @"Select songs to share";

	[self presentViewController:mediaPickerController animated:YES completion:nil];
}


#pragma mark - Private Methods

-(void)didReceiveDataWithNotification: (NSNotification *) notification
{
	MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
	//	NSString *peerDisplayName = peerID.displayName;
	self.songs = [[notification userInfo] objectForKey:@"songs"];
	MultipeerManager *multiManager = [MultipeerManager sharedInstance];
}

#pragma mark - MPMediaPicker Delegate Methods

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker
  didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{

}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self.songsTable dequeueReusableCellWithIdentifier:@"CellIdentifier"];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
	}
	
	NSString *songTitle = ((MPMediaItem *)[self.songs objectAtIndex:indexPath.row]).title;
	cell.textLabel.text = songTitle;
	
	return cell;
}


@end
