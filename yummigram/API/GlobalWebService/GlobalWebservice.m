//
//  GlobalWebservice.m
//  Svarto
//
//  Created by NineHertzIndia on 27/09/13.
//  Copyright (c) 2013 Anveshan. All rights reserved.
//

#import "GlobalWebservice.h"
#import "JSON.h"
#import "Constants.h"
#import "CFNetwork/CFHTTPMessage.h"
#import <SystemConfiguration/SCNetworkReachability.h>

@implementation GlobalWebservice
static BOOL ServerIsReachable = FALSE;

#pragma mark Check network
/*
 // Method Name : IsServerReachable
 // Method Type :	Instance
 // Parameters : None
 // Returns	 : BOOL
 // Description : Check whether server is reachable or internet is connected. 
 */
+ (BOOL) IsServerReachable
{
	BOOL checkNetwork = YES;
    if (checkNetwork) { // Since checking the reachability of a host can be expensive, cache the result and perform the reachability check once.
        checkNetwork = NO;
        
		Boolean success;
		
		NSString* fullBaseUrl = mainURL;
		NSString* baseUrlByTrimmingProtocol = [fullBaseUrl stringByReplacingOccurrencesOfString:@"http://"withString:@""];
		//baseUrlByTrimmingProtocol = [fullBaseUrl stringByReplacingOccurrencesOfString:@"https://"withString:@""];
		@try {
			NSRange range = [baseUrlByTrimmingProtocol rangeOfString:@"/"];
			if(range.location != NSNotFound){
				baseUrlByTrimmingProtocol = [baseUrlByTrimmingProtocol substringToIndex:range.location];
				const char *host_name = [baseUrlByTrimmingProtocol UTF8String];
				SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
				SCNetworkReachabilityFlags flags;
				success = SCNetworkReachabilityGetFlags(reachability, &flags);
				ServerIsReachable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
				CFRelease(reachability);
			}
		}
		@catch (NSException * e) {
			NSLog(@"Exception occured : %@", [e description]);
		}
		@finally {
			
		}
	}
	
	if(! (ServerIsReachable) ){
        dispatch_async(dispatch_get_main_queue(), ^{
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Problem" message:@"Network Unreachable" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
//            [alert release];
            //alert = nil;
            
        });
		return FALSE;
	}
	else {
		return TRUE;
	}
}

+(NSArray*)GetDataFromJsonParser:(NSURL *)urlstring
{
	if(![[self class] IsServerReachable]){
		return nil;
	}	
	
	SBJSON* parser = [[SBJSON alloc] init];
	NSURLRequest *request = [NSURLRequest requestWithURL:urlstring];	
	NSData *response;
	@try{
		// Perform request and get JSON back as a NSData object
		NSError* error;
		response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];		
	}
	@catch (id theException) {
		NSLog(@"Error");
	}

	// Get JSON as a NSString from NSData response
	NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];	
	
	json_string = [json_string stringByReplacingOccurrencesOfString:@"<string xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/\">" withString:@""];
	json_string = [json_string stringByReplacingOccurrencesOfString:@"</string>" withString:@""];
	
	// Trimming the xml string from the string( if needed)
	NSRange startingRange = [json_string rangeOfString:@"<title>"];
	NSRange endRange = [json_string rangeOfString:@"</title>"];
	NSString* testString;
	if(endRange.length!=0)
	{
		NSRange jsonRange = NSMakeRange(startingRange.location+7, endRange.location - startingRange.location-7);
		
		//json_string = [json_string substringWithRange:jsonRange];
		testString=[json_string substringWithRange:jsonRange];
		
		if( [testString isEqualToString:@"ERROR: The requested URL could not be retrieved"])
		{
			
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"My Sports Plan !!" message:@"The requested url can not be retrived. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			alert = nil;
			return nil;		
		}
	}
	
	NSArray* statuses;
	// parse the JSON response into an object
	// Here we're using NSArray since we're parsing an array of JSON status objects
	
	id result = [parser objectWithString:json_string error:nil];
	//id anArchiver = [[NSArchiver alloc] initForWritingWithMutableData:[parser objectWithString:json_string error:nil] ];
	
	if(result !=nil)
	{
		//if( [result class] == [NSArray class]){
		if( [result isKindOfClass:[NSArray class] ] ) {
			statuses = [parser objectWithString:json_string error:nil];
		}else if( [result isKindOfClass:[NSDictionary class] ]) {
			statuses = [NSArray arrayWithObject : [parser objectWithString:json_string error:nil] ];
		}else if([result isKindOfClass:[NSString class]]){
			
			statuses = [NSArray arrayWithObject:[result stringValue]];
		}
	}else {
		statuses = nil;
	}
	
	//[json_string release];
	[parser release];
	
	return statuses;	
}


+(NSDate*)GetDateFromEpochFormat:(NSString*)dateInEpochFormat
{
	NSRange  startDateRange=[dateInEpochFormat  rangeOfString:@"("];
	NSRange  endDateRange=[dateInEpochFormat rangeOfString:@")"];
	NSRange  DateRange=NSMakeRange(startDateRange.location+1, endDateRange.location-startDateRange.location-1);
	dateInEpochFormat=[dateInEpochFormat substringWithRange:DateRange];
	return [NSDate dateWithTimeIntervalSince1970:([dateInEpochFormat doubleValue]/1000)];
}

+(NSString*)GetStringInActualForm:(NSString*)InputString{
	
	InputString=[InputString stringByReplacingOccurrencesOfString:@"\\" withString:@"//"];
	return InputString;
	
}

+ (NSString *)GetFormatedString:(NSString*)stringWithHtmlIncluded
{
	stringWithHtmlIncluded=[stringWithHtmlIncluded stringByReplacingOccurrencesOfString:@"&amp;nbsp;" withString:@""];
	stringWithHtmlIncluded=[stringWithHtmlIncluded stringByReplacingOccurrencesOfString:@"&lt;br /&gt;" withString:@""];
	return stringWithHtmlIncluded;
}

+ (NSArray*)GetImagesForAnimation{	
	NSArray* AnimationImages=[NSArray arrayWithObjects:	[UIImage imageNamed:@"iwish.png"],
							  [UIImage imageNamed:@"kitesurf.png"],
							  [UIImage imageNamed:@"racecar.png"], 
							  [UIImage imageNamed:@"safari.png"], 
							  [UIImage imageNamed:@"sailboat.png"], 
							  [UIImage imageNamed:@"skier.png"], 
							  [UIImage imageNamed:@"spa2.png"], nil];
    return AnimationImages;
	
}

+(NSArray*)doPostMethod:(NSDictionary *)dictparam {
	
	SBJSON *parser = [[SBJSON alloc] init];
	NSURL *theURL = [NSURL URLWithString:mainURL];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0f];
	[theRequest setHTTPMethod:@"POST"];
	//[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	//[theRequest setValue:@"application/json" forHTTPHeaderField:@"accept"];
	NSString *theBodyString = [dictparam JSONRepresentation];
	NSLog(@"%@", theBodyString);
	NSData *theBodyData = [theBodyString dataUsingEncoding:NSUTF8StringEncoding];
	[theRequest setHTTPBody:theBodyData];
	
	NSHTTPURLResponse *theResponse = NULL;
	NSError *theError = NULL;
	NSData *theResponseData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&theResponse error:&theError];
	NSString *json_string = [[NSString alloc] initWithData:theResponseData encoding:NSUTF8StringEncoding];	
	
	json_string = [json_string stringByReplacingOccurrencesOfString:@"<string xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/\">" withString:@""];
	json_string = [json_string stringByReplacingOccurrencesOfString:@"</string>" withString:@""];
	//json_string=  [json_string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	
	//NSInteger responseCode=[urlResponse statusCode];
	// Trimming the xml string from the string( if needed)
	NSRange startingRange = [json_string rangeOfString:@"<title>"];
	NSRange endRange = [json_string rangeOfString:@"</title>"];
	NSString* testString;
	if(endRange.length!=0)
	{
		NSRange jsonRange = NSMakeRange(startingRange.location+7, endRange.location - startingRange.location-7);
		
		//json_string = [json_string substringWithRange:jsonRange];
		testString=[json_string substringWithRange:jsonRange];
		
		if( [testString isEqualToString:@"ERROR: The requested URL could not be retrieved"])
		{        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"My Sports Plan" message:@"The requested url can not be retrived. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			return nil;		
		}
	}
	
	
	NSArray* statuses;
	// parse the JSON response into an object
	// Here we're using NSArray since we're parsing an array of JSON status objects
	
	id result = [parser objectWithString:json_string error:nil];
	//id anArchiver = [[NSArchiver alloc] initForWritingWithMutableData:[parser objectWithString:json_string error:nil] ];
	
	if(result !=nil)
	{
		//if( [result class] == [NSArray class]){
		if( [result isKindOfClass:[NSArray class] ] ) {
			statuses = [parser objectWithString:json_string error:nil];
		}else if( [result isKindOfClass:[NSDictionary class] ]) {
			statuses = [NSArray arrayWithObject : [parser objectWithString:json_string error:nil] ];
		}
	}else {
		statuses = nil;
	}
    return statuses;
}

@end


