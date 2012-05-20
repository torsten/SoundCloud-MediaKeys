//
//  SMPrincipal.m
//  SoundCloud-MediaKeys
//
//  Created by Torsten Becker on 16.04.12.
//  Copyright (c) 2012 Torsten Becker. All rights reserved.
//

#import "JRSwizzle.h"
#import "SMBundlePrincipal.h"


@implementation SMPrincipal


+ (void)load
{
    NSLog(@"FUCK YEAH, loaded SMPrincipal!!!");
    
    NSError *err;
    if ([NSApplication jr_swizzleMethod:@selector(sendEvent:) withMethod:@selector(SM_sendEventOverride:) error:&err])
        NSLog(@"Swizzeled sendEvent: for fun and profit");
    else
        NSLog(@"Failed to swizzle sendEvent:");
    
}


@end
