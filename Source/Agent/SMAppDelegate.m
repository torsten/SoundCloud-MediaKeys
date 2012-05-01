//
//  SMAppDelegate.m
//  SoundCloud-MediaKeys
//
//  Created by Torsten Becker on 29.04.12.
//  Copyright (c) 2012 Torsten Becker. All rights reserved.
//

#import "SMAppDelegate.h"


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


@end
