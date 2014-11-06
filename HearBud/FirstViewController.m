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
#import "SongMetaData.h"
#import "AppDelegate.h"
#import "SongTableViewCell.h"

#define SONG_CELL_IDENTIFIER @"SongCell"

@interface FirstViewController ()

@property (weak, nonatomic) IBOutlet UITableView *songsTable;

@end

@implementation FirstViewController

-(void) viewDidLoad
{
	[self.songsTable registerClass:[SongTableViewCell class]forCellReuseIdentifier:SONG_CELL_IDENTIFIER];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
	DLog(@"init called");
	if((self = [super initWithCoder:aDecoder]) == nil)
	{
		return nil;
	}
	_songs = [[NSMutableArray alloc] init];
	
	DLog(@"registered for notification %@", HBReceivedSongListNotificationKey);
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didReceiveSongsWithNotification:)
												 name:HBReceivedSongListNotificationKey
											   object:nil];
	
	return self;
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:HBReceivedSongListNotificationKey object:nil];
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

- (IBAction)pausePlayback:(id)sender {
	UIButton *button = sender;
	if (button.selected)
	{
		[[MultipeerManager sharedInstance] resumePlayback];
		button.selected = !button.selected;
	}
	else
	{
		[[MultipeerManager sharedInstance] pausePlayback];
		button.selected = !button.selected;
	}
	
}


#pragma mark - Private Methods

-(void)didReceiveSongsWithNotification: (NSNotification *) notification
{
	MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
	NSArray *songs = [[notification userInfo] objectForKey:@"songs"];
		DLog(@"notified for songs received %@", notification.description);
	if ([songs count] > 0 && ![peerID isEqual:nil])
	{
		DLog(@"Received %lu songs from %@", (unsigned long)[self.songs count], peerID.displayName);
		[self.songs addObjectsFromArray:songs];
		[self.songsTable reloadData];
	}
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
	SongTableViewCell *cell = [self.songsTable dequeueReusableCellWithIdentifier:SONG_CELL_IDENTIFIER];
	if (cell == nil)
	{
		cell = [[SongTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SONG_CELL_IDENTIFIER];
	}
	
	SongMetaData *song = [self.songs objectAtIndex:indexPath.row];
	cell.title.text = [NSString stringWithFormat:@"%@ %f", song.title, song.duration];
	cell.artist.text = song.artist;
//	cell.textLabel.text = [NSString stringWithFormat:@"%@ %f", song.title, song.duration];
	

//	cell.textLabel.text = [self.songs objectAtIndex:indexPath.row];
	
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[[MultipeerManager sharedInstance] sendSongRequestToPeer: [self.songs objectAtIndex:indexPath.row]];
}


@end
