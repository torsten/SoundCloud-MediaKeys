//
//  SMAppDelegate.m
//  SoundCloud-MediaKeys
//
//  Created by Torsten Becker on 29.04.12.
//  Copyright (c) 2012 Torsten Becker. All rights reserved.
//

#import "SMAppDelegate.h"
#import <SecurityInterface/SFAuthorizationView.h>
#import <mach_inject_bundle/mach_inject_bundle.h>


@interface SMAppDelegate ()

@property (retain, nonatomic) NSMenu * dockMenu;
@property (retain, nonatomic) NSMenuItem * statusMenuItem;

@end


@implementation SMAppDelegate

@synthesize dockMenu = _dockMenu;
@synthesize statusMenuItem = _statusMenuItem;


// --------------------------------------------------------------------------
#pragma mark - Initialization
// --------------------------------------------------------------------------


- (id)init
{
    if ((self = [super init]))
    {
        self.dockMenu = [[NSMenu alloc] init];
        self.statusMenuItem =
            [self.dockMenu addItemWithTitle:@"Status: Launching"
                                     action:nil
                              keyEquivalent:@""];
        NSMenuItem * item =
            [self.dockMenu addItemWithTitle:@"Hide from Dock"
                                     action:@selector(hideFromDock)
                              keyEquivalent:@""];
        item.target = self;
    }
    return self;
}


// --------------------------------------------------------------------------
#pragma mark - NSApplicationDelegate
// --------------------------------------------------------------------------


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // self.statusMenuItem.state = NSOnState;
    // Running, no SoundCloud Process found.
    // 
    
    [[[NSWorkspace sharedWorkspace] notificationCenter]
        addObserver:self
           selector:@selector(handleWorkspaceDidLaunchApp:)
               name:NSWorkspaceDidLaunchApplicationNotification
             object:nil];
}


- (NSMenu *)applicationDockMenu:(NSApplication *)sender
{
    return self.dockMenu;
}


// --------------------------------------------------------------------------
#pragma mark - Various Private Methods
// --------------------------------------------------------------------------


- (void)hideFromDock
{
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    TransformProcessType(&psn, kProcessTransformToBackgroundApplication);
}


- (void)handleWorkspaceDidLaunchApp:(NSNotification *)notification
{
    NSRunningApplication *app = (NSRunningApplication *)[notification.userInfo objectForKey:NSWorkspaceApplicationKey];
    
    // NSLog(@"Got notification %@ for app %@", notification, app.bundleIdentifier);
    
    if ([app.bundleIdentifier isEqualToString:@"com.soundcloud.desktop"])
    {
        [self injectIntoApp:app];
    }
}


- (NSString *)copyCodeBundleInContainerOfApp:(NSRunningApplication *)app
{
    NSFileManager *fm = [NSFileManager defaultManager];

    NSArray *urls = [fm URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
    assert([urls count] >= 1);

    NSString *librariesPath = [[urls objectAtIndex:0] path];
    assert(librariesPath != nil);
    
    NSString *appBundleID = [app bundleIdentifier];
    assert(appBundleID != nil);
    
    NSString *destination = [NSString stringWithFormat:@"%@/Containers/%@/Data/MediaKeysResponder.bundle",
                                                       librariesPath, appBundleID];
    // NSLog(@"destination %@", destination);
    
    NSString *codeBundle = [[NSBundle mainBundle] pathForResource:@"MediaKeysResponder" ofType:@"bundle"];
    // NSLog(@"codeBundle: %@", codeBundle);
    assert(codeBundle != nil);
    
    NSError *error;
    [fm removeItemAtPath:destination error:&error];
    BOOL copySuccess = [fm copyItemAtPath:codeBundle toPath:destination error:&error];
    if (! copySuccess)
    {
        NSLog(@"Copy failed: %@", error);
        return nil;
    }
    
    return destination;
}


- (void)injectIntoApp:(NSRunningApplication *)app
{       
    SFAuthorization *auth = [[SFAuthorization alloc] init];
    NSError *error;
    BOOL win = [auth obtainWithRight:"system.privilege.taskport"
                               flags:(kAuthorizationFlagExtendRights |
                                      kAuthorizationFlagInteractionAllowed |
                                      kAuthorizationFlagPreAuthorize)
                               error:&error];
    if (! win)
    {
        NSLog(@"getting auth for taskport failed: %@", error);
        return;
    }
    
    pid_t pid = app.processIdentifier;
    NSString *codeBundle = [self copyCodeBundleInContainerOfApp:app];
    
    mach_error_t err = mach_inject_bundle_pid([codeBundle UTF8String], pid);
    NSLog(@"inject error: %d", err);
}


@end
