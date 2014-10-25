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
#import "Common.h"
#import "SongMetaData.h"

@interface FirstViewController ()

@property (weak, nonatomic) IBOutlet UITableView *songsTable;

@end

@implementation FirstViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didReceiveDataWithNotification:)
												 name:MMDidReceiveSongListNotificationKey
											   object:nil];
	
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
	self.songs = [[notification userInfo] objectForKey:@"songs"];

	DLog(@"Received %lu songs from %@", (unsigned long)[self.songs count], peerID.displayName);
	[self.songsTable reloadData];
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
	return [self.songs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self.songsTable dequeueReusableCellWithIdentifier:@"CellIdentifier"];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
	}
	
	NSString *songTitle = ((SongMetaData *)[self.songs objectAtIndex:indexPath.row]).title;
	cell.textLabel.text = songTitle;

//	cell.textLabel.text = [self.songs objectAtIndex:indexPath.row];
	
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
}


@end
