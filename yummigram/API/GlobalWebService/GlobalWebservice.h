//
//  GlobalWebservice.h
//  Svarto
//
//  Created by NineHertzIndia on 27/09/13.
//  Copyright (c) 2013 Anveshan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalWebservice : NSObject <UIAlertViewDelegate> {

	NSMutableData* responseData;
}

+(BOOL) IsServerReachable;
+(NSArray*)GetDataFromJsonParser:(NSURL *)urlstring;
+(NSDate*)GetDateFromEpochFormat:(NSString*)dateInEpochFormat;
+(NSString*)GetStringInActualForm:(NSString*)InputString;
+(NSString *)GetFormatedString:(NSString*)stringWithHtmlIncluded;
+(NSArray*)GetImagesForAnimation;
+(NSArray*)doPostMethod:(NSDictionary *)dictparam;

@end

