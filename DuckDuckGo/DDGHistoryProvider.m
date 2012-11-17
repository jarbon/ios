//
//  DDGSearchHistoryProvider.m
//  DuckDuckGo
//
//  Created by Ishaan Gulrajani on 3/31/12.
//  Copyright (c) 2012 DuckDuckGo, Inc. All rights reserved.
//

#import "DDGCache.h"
#import "DDGAppDelegate.h"
#import "DDGHistoryProvider.h"

@implementation DDGHistoryProvider

static DDGHistoryProvider *sharedInstance;

+(id)sharedProvider {
    if(!sharedInstance)
        sharedInstance = [[self alloc] init];
    return sharedInstance;
}

-(id)init {
    self = [super init];
    if(self) {
        history = [[NSMutableArray alloc] initWithContentsOfFile:self.historyPath];
        if(!history)
            history = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)clearHistory {
    [history removeAllObjects];
    [self save];
}

-(void)logHistoryItem:(NSDictionary *)historyItem
{
    if ([[DDGCache objectForKey:@"history" inCache:@"settings"] boolValue])
    {
		NSMutableDictionary *historyItemDictionary = [NSMutableDictionary dictionaryWithDictionary:historyItem];
		
		[historyItemDictionary setObject:[NSDate date] forKey:@"date"];
		
		for (int i = 0; i < history.count; i++)
		{
			if ([[[history objectAtIndex:i] objectForKey:@"text"] isEqualToString:[historyItem  objectForKey:@"text"]])
			{
				// add the new history item at the end to keep the array ordered
				[history removeObjectAtIndex:i];
				[history addObject:historyItemDictionary];
				return;
			}
		}
		[history addObject:historyItemDictionary];
		[self save];
	}
}

-(NSArray *)allHistoryItems {
    return [[history reverseObjectEnumerator] allObjects];
}

-(NSArray *)pastHistoryItemsForPrefix:(NSString *)prefix {
    // there are certain cases in which we don't want to return any history
    if([prefix isEqualToString:@""] || ![[DDGCache objectForKey:@"history" inCache:@"settings"] boolValue])
        return @[];
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    for(NSDictionary *historyItem in history)
	{
        NSString *text = [historyItem objectForKey:@"text"];
		// be case insensitive when comparing search strings (and not URL's)
        if ([[text lowercaseString] hasPrefix:[prefix lowercaseString]]			||
			[text hasPrefix:[@"http://" stringByAppendingString:prefix]]		||
			[text hasPrefix:[@"https://" stringByAppendingString:prefix]]		||
			[text hasPrefix:[@"http://www." stringByAppendingString:prefix]]	||
			[text hasPrefix:[@"https://www." stringByAppendingString:prefix]]
           )
            [results addObject:historyItem];
    }
    
    // if the array is too large, remove all but the 3 most recent items
    while(results.count > 3)
        [results removeObjectAtIndex:0];

    // the array is currently in ascending chronological order; reverse it and make it non-mutable
    return [[results reverseObjectEnumerator] allObjects];
}

-(void)removeOldHistoryItemsWithoutSaving {
    for(int i=history.count-1; i>=0; i--) {
        if([[NSDate date] timeIntervalSinceDate:[[history objectAtIndex:i] objectForKey:@"date"]] >= 30*24*60*60)
            [history removeObjectAtIndex:i];
    }
}

-(void)save {
    [self removeOldHistoryItemsWithoutSaving];
    [history writeToFile:self.historyPath atomically:YES];
}

-(NSString *)historyPath {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingPathComponent:@"history.plist"];
}

@end
