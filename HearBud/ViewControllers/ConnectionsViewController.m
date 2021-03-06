//
//  ConnectionsViewController.m
//  HearBud
//
//  Created by Ritchie Bui on 2014-10-21.
//  Copyright (c) 2014 Ritchie Bui. All rights reserved.
//

#import "ConnectionsViewController.h"
#import "MultipeerManager.h"

@interface ConnectionsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *advertiseVisibleSwitch;
@property (weak, nonatomic) IBOutlet UITableView *connectionsTable;
@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification;

@end

@implementation ConnectionsViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]) == nil)
	{
		return nil;
	}
	DLog(@"connections view controlled inited");
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(browserSetupDidComplete) name:@"MCBrowserSetupComplete" object:nil];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(peerDidChangeStateWithNotification:)
												 name:@"MCDidChangeStateNotification"
											   object:nil];
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.connectionsTable setDelegate:self];
	[self.connectionsTable setDataSource:self];
	
	//TODO: remove observer when view unloads
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)browseForDevices
{
	[self presentViewController: [MultipeerManager sharedInstance].browser animated:YES completion:nil];
}

- (IBAction)disconnect
{
	MultipeerManager *multiManager = [MultipeerManager sharedInstance];
	[multiManager.session disconnect];
	
	self.nameTextField.enabled = YES;
	
	[multiManager.connectedDevices removeAllObjects];
	[self.connectionsTable reloadData];
}

#pragma mark - Private Methods

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification
{
	MultipeerManager *multiManager = [MultipeerManager sharedInstance];
	
	[self.connectionsTable reloadData];
	
	BOOL peersExist = ([[multiManager.session connectedPeers] count] == 0);
	[self.disconnectButton setEnabled:!peersExist];
	[self.nameTextField setEnabled:peersExist];
}

-(void)browserSetupDidComplete
{
	[[MultipeerManager sharedInstance].browser setDelegate:self];
}


#pragma mark - MCBrowserViewController Delegate Methods

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
	[[MultipeerManager sharedInstance].browser
	 dismissViewControllerAnimated:YES completion:nil];
}


-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
	[[MultipeerManager sharedInstance].browser
	 dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITextField Delegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (![textField.text isEqualToString: @""])
	{
		[self.nameTextField resignFirstResponder];
		
		MultipeerManager *multiManager = [MultipeerManager sharedInstance];
		
		if ([self.advertiseVisibleSwitch isOn]) {
			[multiManager advertiseSelf: NO];
		}
		[multiManager changeDisplayNameAndRestartSession: textField.text];
		[multiManager advertiseSelf: self.advertiseVisibleSwitch.isOn];
	}
	
	return YES;
	
}


#pragma mark - UITableView Delegate Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[MultipeerManager sharedInstance].connectedDevices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self.connectionsTable dequeueReusableCellWithIdentifier:@"CellIdentifier"];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
	}
	
	NSString *peerDisplayName = ((MCPeerID *)[[MultipeerManager sharedInstance].connectedDevices
											  objectAtIndex:indexPath.row]).displayName;
	cell.textLabel.text = peerDisplayName;
	
	return cell;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
