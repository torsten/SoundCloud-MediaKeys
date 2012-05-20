//
//  NSApplication+SMMediaKeys.m
//  SoundCloud-MediaKeys
//
//  Created by Torsten Becker on 16.04.12.
//  Copyright (c) 2012 Torsten Becker. All rights reserved.
//

#import "NSApplication+SMMediaKeys.h"
#import "SoundCloud.h"
#import <IOKit/hidsystem/ev_keymap.h>


@implementation NSApplication (SMMediaKeys)


// Credit for the sendEvent override goes to Rogue Amoeba:
// http://rogueamoeba.com/utm/2007/09/29/apple-keyboard-media-key-event-handling/

- (void)SM_mediaKeyEvent:(int)key state:(BOOL)state repeat:(BOOL)repeat
{
	switch (key)
	{
		case NX_KEYTYPE_PLAY:
			if (state == 0)
			{
				NSLog(@"PLAY"); // Play pressed and released
			    
                RainDropAppDelegate * appDelegate =
                    (RainDropAppDelegate *)[[NSApplication sharedApplication] delegate];
                
                // NSLog(@"delegate: %@", appDelegate);
                
                [appDelegate playPause:appDelegate.dockPlayPauseItem];
			}
            break;
            
		case NX_KEYTYPE_FAST:
			if (state == 0)
				NSLog(@"NEXT"); // Next pressed and released
            break;
            
		case NX_KEYTYPE_REWIND:
			if (state == 0)
				NSLog(@"BACK"); // Previous pressed and released
            break;
	}
}


- (void)SM_sendEventOverride:(NSEvent*)event
{
	if ([event type] == NSSystemDefined && [event subtype] == 8)
	{
		int keyCode = (([event data1] & 0xFFFF0000) >> 16);
		int keyFlags = ([event data1] & 0x0000FFFF);
		int keyState = (((keyFlags & 0xFF00) >> 8)) ==0xA;
		int keyRepeat = (keyFlags & 0x1);

		[self SM_mediaKeyEvent:keyCode state:keyState repeat:keyRepeat];
	}

	[self SM_sendEventOverride:event];
}


@end
