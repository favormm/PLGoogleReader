//
//  PLGoogleReaderViewController.m
//  PLGoogleReader
//
//  Created by popcornylu on 6/9/11.
//  Copyright 2011 SmartQ. All rights reserved.
//

#import "MyGoogleReaderViewController.h"
#import "CategoryViewController.h"
#import "ClientLoginViewController.h"

@interface MyGoogleReaderViewController ()
- (void)updateUI;
@end

@implementation MyGoogleReaderViewController
@synthesize lbEmail;
@synthesize lbAccessToken;
@synthesize btnNav;
@synthesize btnSignInNormal;
@synthesize btnSignInOauth;
@synthesize btnSignOut;
@synthesize btnReload;

#pragma mark NSObject
- (void)dealloc
{
    [lbEmail release];
    [lbAccessToken release];
    [btnNav release];
    [btnSignInNormal release];
    [btnSignInOauth release];
    [btnSignOut release];
    [btnReload release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [PLGoogleReader defaultGoogleReader].authType = PLGoogleReaderAuthTypeOAuth;
}

#pragma mark UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateUI];
    
    PLGRSubscription* subscription = [[PLGoogleReader defaultGoogleReader] subscription];
    if(![subscription isLoaded])
    {
        [subscription reload:self];
    }
}


- (void)viewDidUnload
{
    [self setLbEmail:nil];
    [self setLbAccessToken:nil];
    [self setBtnNav:nil];
    [self setBtnSignInNormal:nil];
    [self setBtnSignInOauth:nil];
    [self setBtnSignOut:nil];
    [self setBtnReload:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Private
- (void)updateUI
{
    PLGoogleReader* googleReader =[PLGoogleReader defaultGoogleReader];
    BOOL  isSignedIn = [googleReader isSignedIn];
    
    lbEmail.text       = [googleReader userEmail];
    lbAccessToken.text = [googleReader accessToken];
    
    btnSignInNormal.enabled = !isSignedIn;
    btnSignInOauth.enabled  = !isSignedIn;
    btnSignOut.enabled      = isSignedIn;
    btnReload.enabled       = isSignedIn;

    btnNav.enabled      = [[googleReader subscription] isLoaded];
}

#pragma mark Actions
- (IBAction)signInNormal:(id)sender {       
    ClientLoginViewController* viewController = [[[ClientLoginViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    viewController.loginBlock = ^(NSString* email, NSString* password)
    {
        PLGoogleReader* googleReader = [PLGoogleReader defaultGoogleReader];        
        googleReader.authType = PLGoogleReaderAuthTypeNormal;    
        [googleReader signInByEmail:email 
                           password:password 
                           delegate:self];    
        [self updateUI];            
    };
    
    [self.navigationController pushViewController:viewController animated:YES];    
}

- (IBAction)signInOauth:(id)sender {
    PLGoogleReader* googleReader = [PLGoogleReader defaultGoogleReader];        
    googleReader.authType = PLGoogleReaderAuthTypeOAuth;
    UIViewController* viewController = [googleReader viewControllerForSignIn:self];    
    [self.navigationController pushViewController:viewController animated:YES];            
    [self updateUI];    
}
- (IBAction)signOut:(id)sender {
    [[PLGoogleReader defaultGoogleReader] signOut];
    [self updateUI];    
}

- (IBAction)reload:(id)sender {
    PLGoogleReader* googleReader = [PLGoogleReader defaultGoogleReader];    
    [[googleReader subscription] reload:self];        
}

- (IBAction)navigate:(id)sender {
    CategoryViewController *viewController = [[CategoryViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];                
}

#pragma mark PLGoogleReaderSignInDelegate
- (void)googleReaderDidSignIn:(PLGoogleReader*)googleReader 
                        error:(NSError*)error
{    
    [self.navigationController popViewControllerAnimated:YES];
    if(error)
    {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Can't login" 
                                                             message:[error localizedDescription] 
                                                            delegate:nil 
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil] 
                                  autorelease];
        [alertView show];        
        NSLog(@"error:%@", error);        
    }        
    else
    {
        NSLog(@"sign successful");
        PLGoogleReader* googleReader = [PLGoogleReader defaultGoogleReader];    
        [[googleReader subscription] reload:self];            
        
        [self updateUI];
    }
}

#pragma mark PLGRSubscriptionDelegate
- (void) subscriptionDidLoad:(PLGRSubscription*)subscription
{
    NSLog(@"%@", subscription);
    [self updateUI];
}

#pragma mark PLGRRequestDelegate
- (void)request:(PLGRRequest*)request didLoad:(NSData*)result
{
    NSLog(@"request result:%@", [[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding] autorelease]);
}

- (void)request:(PLGRRequest*)request didFailWithError:(NSError*)error
{
    NSLog(@"request error:%@", [error localizedDescription]);    
}

@end
