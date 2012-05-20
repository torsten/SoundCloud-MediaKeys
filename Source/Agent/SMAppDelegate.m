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
    self = [super init];
    if (self) {
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
    
    // 
    // NSApplicationProcessIdentifier
    
    // NSLog(@"Got notification %@ for app %@", notification, app.bundleIdentifier);
    
    if ([app.bundleIdentifier isEqualToString:@"com.soundcloud.desktop"])
    {
        pid_t pid = app.processIdentifier;
        
        SFAuthorization * auth = [[SFAuthorization alloc] init];
        
        NSError * error;
        BOOL win = [auth obtainWithRight:"system.privilege.taskport"
                                   flags:(kAuthorizationFlagExtendRights | kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize) 
                                   error:&error];
        
        NSLog(@"win %d b/c %@", win, error);
        
        NSString *codeBundle = [[NSBundle mainBundle] pathForResource:@"MediaKeysResponder" ofType:@"bundle"];
        NSLog(@"codeBundle: %@", codeBundle);
        
        if (win)
        {
            mach_error_t err = mach_inject_bundle_pid([codeBundle UTF8String], pid);
            NSLog(@"inject error: %d", err);
        }
    }
}


@end
