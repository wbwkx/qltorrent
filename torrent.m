#import "torrent.h"
#import "BEncoding.h"

id replaceDataByStringInObject(id obj, NSString *key, NSString *exceptionKey);

NSArray *replaceDataByStringsInArray(NSArray *array, NSString *exceptionKey);
NSMutableDictionary *replaceDataByStringsInDic(NSDictionary *dic, NSString *exceptionKey);



NSString *stringFromFileSize(NSInteger theSize) {
	float floatSize = theSize;

	if (theSize < 1024)
		return([NSString stringWithFormat:@"%i B", theSize]);
	floatSize = floatSize / 1024;
	if (floatSize < 1024)
		return([NSString stringWithFormat:@"%1.1f KB", floatSize]);
	floatSize = floatSize / 1024;
	if (floatSize < 1024)
		return([NSString stringWithFormat:@"%1.1f MB", floatSize]);
	floatSize = floatSize / 1024;

	return([NSString stringWithFormat:@"%1.1f GB", floatSize]);
}

NSString *stringFromData(NSDictionary *torrent, NSString *key) {
	NSData *rawkey = [torrent objectForKey:key];
	NSString *strdata = [[[NSString alloc] initWithBytes:[rawkey bytes]
																 length:[rawkey length]
															  encoding:NSUTF8StringEncoding]
								autorelease];
	return strdata;
}

void replacer(NSMutableString *html, NSString *replaceThis, NSString *withThis, NSString *defaultString) {
	if(withThis == nil) withThis = defaultString;
	[html replaceOccurrencesOfString:replaceThis
								 withString:withThis
									 options:NSLiteralSearch
										range:NSMakeRange(0, [html length])];
}

id replaceDataByStringInObject(id obj, NSString *key, NSString *exceptionKey) {
	if (![obj isKindOfClass:[NSData class]] || ![key isEqual:exceptionKey]) {
		if      ([obj isKindOfClass:[NSDictionary class]]) return replaceDataByStringsInDic(obj, exceptionKey);
		else if ([obj isKindOfClass:[NSArray class]])      return replaceDataByStringsInArray(obj, exceptionKey);
		else                                               return obj;
	}
	
	return [[[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding] autorelease];
}

NSArray *replaceDataByStringsInArray(NSArray *array, NSString *exceptionKey) {
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:array.count];
	
	for (id obj in array) [result addObject:replaceDataByStringInObject(obj, nil, exceptionKey)];
	
	return result;
}

NSMutableDictionary *replaceDataByStringsInDic(NSDictionary *dic, NSString *exceptionKey) {
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:dic.count];
	
	for (id key in dic.allKeys) {
		id obj = [dic objectForKey:key];
		[result setObject:replaceDataByStringInObject(obj, key, exceptionKey) forKey:key];
	}
	
	return result;
}

NSDictionary *getTorrentInfo(NSURL *url) {
	// Read raw file, and de-bencode
	NSData *rawdata = [NSData dataWithContentsOfURL:url];
	NSDictionary *torrent = [BEncoding objectFromEncodedData:rawdata];

	if (![torrent isKindOfClass:[NSDictionary class]]) return nil;
	
	NSMutableDictionary *result = replaceDataByStringsInDic(torrent, @"pieces");
	
	return [result objectForKey:@"info"];
	
#if 0
	NSDictionary *infoData = [torrent objectForKey:@"info"];

	// Retrive interesting data
	NSString *announce = stringFromData(torrent, @"announce");

	NSString *torrentName = stringFromData(infoData, @"name");

	NSString *length = [infoData objectForKey:@"length"];

	NSNumber *isPrivate = [NSNumber numberWithBool:[infoData objectForKey:@"private"] == NULL];

	// Get filenames/sizes
	NSArray *filesData = [infoData objectForKey:@"files"];

	NSUInteger totalSize = 0;
	NSMutableArray *allFiles = [NSMutableArray array];
	for (NSDictionary *currentFileData in filesData) {
		NSString *currentSize = [currentFileData objectForKey:@"length"];

		NSMutableDictionary *currentFile = [NSMutableDictionary dictionaryWithObject:currentSize forKey:@"length"];

		totalSize = totalSize + [currentSize integerValue];

		NSMutableString *currentFilePath = [NSMutableString string];

		// Looping over path segments"
		for(NSData *currentSegmentData in [currentFileData objectForKey:@"path"]) {
			NSString *currentPathSegment = [[[NSString alloc] initWithBytes:[currentSegmentData bytes]
																						length:[currentSegmentData length]
																					 encoding:NSUTF8StringEncoding]
													  autorelease];
			[currentFilePath appendFormat:@"/%@", currentPathSegment];
		}
		[currentFile setObject:currentFilePath forKey:@"filename"];
		[allFiles addObject:currentFile];
	}

	// Store interesting data in dictionary, and return it

	NSMutableDictionary *ret = [NSMutableDictionary dictionary];
	if(length != NULL) [ret setObject:length forKey:@"length"];
	if(announce != NULL) [ret setObject:announce forKey:@"announce"];
	if(torrentName != NULL) [ret setObject:torrentName forKey:@"torrentName"];
	if(isPrivate != NULL) [ret setObject:isPrivate forKey:@"isPrivate"];
	if(allFiles != NULL) [ret setObject:allFiles forKey:@"files"];
	[ret setObject:[NSNumber numberWithInteger:totalSize] forKey:@"totalSize"];

	return ret;
#endif
}

NSData *getTorrentPreview(NSURL *url) {
	// Load template HTML
	NSString *templateFile = [NSString stringWithContentsOfFile:[[NSBundle bundleWithIdentifier:@"com.github.sillage.qltorrent"]
																					 pathForResource:@"torrentpreview" ofType:@"html"]
																		encoding:NSUTF8StringEncoding
																			error:NULL];
	NSDictionary *torrentInfo = getTorrentInfo(url);
	if (torrentInfo == nil) return nil;

	NSMutableString *html = [NSMutableString stringWithString:templateFile];

	// Replace torrentName
	replacer(html,
				@"{TORRENT_NAME}",
				[torrentInfo objectForKey:@"torrentName"],
				@"[Unknown]");

	// Replace torrent size with length or totalSize
	NSNumber *size = [torrentInfo objectForKey:@"length"];
	if (size == NULL) {
		// Multi-file torrents don't have length, so use the total file size
		size = [torrentInfo objectForKey:@"totalSize"];
	}

	NSString *torrentInfoString = [NSString stringWithFormat:@"<ul><li>Size: %@</li></ul>",
											 size != nil ? stringFromFileSize([size integerValue]) : @"N/D"];
	replacer(html,
				@"{TORRENT_INFO}",
				torrentInfoString,
				@"[Unknown]");

	// Replace files
	NSArray *files = [torrentInfo objectForKey:@"files"];
	if (files != nil) {
		NSMutableString *torrentFileString = [NSMutableString string];
		for(NSDictionary *currentFile in files) {
			NSString *currentName = [currentFile objectForKey:@"filename"];
			NSString *currentSizeData = [currentFile objectForKey:@"length"];
			NSString *currentSize = [NSString stringWithFormat:@"%@", currentSizeData == nil ? @"N/D" : stringFromFileSize([currentSizeData integerValue])];
			[torrentFileString appendString:[NSString stringWithFormat: @"<tr><td>%@</td><td>%@</td></tr>\n",
														currentName,
														currentSize]
			 ];
		}
		replacer(html,
					@"{TORRENT_FILES}",
					torrentFileString,
					@"<tr><td>[Cannot list files]</td><td>N/D</td></tr>"
					);
	}

	return [html dataUsingEncoding:NSUTF8StringEncoding];
}
