#import "torrent.h"
#import "BEncoding.h"

id replaceDataByStringInObject(id obj, NSString *key, NSString *exceptionKey);

NSArray *replaceDataByStringsInArray(NSArray *array, NSString *exceptionKey);
NSMutableDictionary *replaceDataByStringsInDic(NSDictionary *dic, NSString *exceptionKey);


NSString *stringFromFileSize(long long int theSize);
NSString *stringFromData(NSDictionary *torrent, NSString *key);
void replacer(NSMutableString *html, NSString *replaceThis, NSString *withThis, NSString *defaultString);

NSString *pathFromPathComponents(NSArray *pc);


NSString *stringFromFileSize(long long int theSize) {
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
	if (![obj isKindOfClass:[NSData class]] || [key isEqual:exceptionKey]) {
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
	
	return replaceDataByStringsInDic([torrent objectForKey:@"info"], @"pieces");
}

NSString *pathFromPathComponents(NSArray *pc) {
	if (pc.count == 0) return @"[Unknown File Name]";
	
	NSMutableString *result = [NSMutableString stringWithCapacity:[[pc objectAtIndex:0] length] * pc.count];
	for (NSString *curPathComponent in pc) {
		[result appendString:@"/"];
		[result appendString:curPathComponent];
	}
	
	return result;
}

// FLFL: tempFile argument is for tests only
NSData *getTorrentPreview(NSURL *url, NSString *tempFile)
{
	/* Load HTML Template */
	NSString *templateFile = [NSString stringWithContentsOfFile:
									  [[NSBundle bundleWithIdentifier:@"com.github.sillage.qltorrent"] pathForResource:@"torrentpreview" ofType:@"html"]
																		encoding:NSUTF8StringEncoding
																			error:NULL];
	/* FLFL: line below is for tests only */
	if (templateFile == nil) templateFile = tempFile;
	
	NSDictionary *torrentInfo = getTorrentInfo(url);
	if (torrentInfo == nil) return nil;

	NSMutableString *html = [NSMutableString stringWithString:templateFile];
	
//	BOOL isPrivate = ([torrentInfo objectForKey:@"private"] == nil);

	/* Replace torrent name */
	replacer(html, @"{TORRENT_NAME}", [torrentInfo objectForKey:@"name"], @"[Unknown]");

	long long int totalSize = 0;
	NSArray *files = [torrentInfo objectForKey:@"files"];
	if (files != nil) {
		NSMutableString *torrentFileString = [NSMutableString string];
		for (NSDictionary *curFile in [torrentInfo objectForKey:@"files"]) {
			NSString *currentSize = @"N/D";
			NSNumber *nn = [curFile objectForKey:@"length"];
			if (nn != nil) {
				long long int n = [nn longLongValue];
				totalSize += n;
				currentSize = stringFromFileSize(n);
			}
			NSArray *currentPathComponents = [curFile objectForKey:@"path"];
			
			[torrentFileString appendString:
			 [NSString stringWithFormat:@"<tr><td>%@</td><td>%@</td></tr>\n",
			  pathFromPathComponents(currentPathComponents),
			  currentSize]];
		}
		replacer(html, @"{TORRENT_FILES}", torrentFileString,
					@"<tr><td>[Cannot list files]</td><td>N/D</td></tr>");
	}
	
	if (totalSize == 0) {
		NSNumber *n = [torrentInfo objectForKey:@"length"];
		if (n != nil) totalSize = [n longLongValue];
		else          totalSize = -1;
	}
	
	NSString *torrentInfoString = [NSString stringWithFormat:@"<ul><li>Size: %@</li></ul>", totalSize != -1? stringFromFileSize(totalSize): @"N/D"];
	replacer(html, @"{TORRENT_INFO}", torrentInfoString, @"[Unknown]");

	return [html dataUsingEncoding:NSUTF8StringEncoding];
}
