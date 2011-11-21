/*
 * BEncoding.m
 *
 * This file is part of the BEncoding framework.
 *
 * This framework is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This framework is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this framework.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Copyright (c) Nathan Ollerenshaw 2008.
 */

#import "BEncoding.h"

typedef struct {
	size_t		length;
	size_t		offset;
	const char	*bytes;
} BEncodingData;

/* Private methods
 *
 * They're not REALLY private, but there is no point exposing them
 * in the header.
 */

@interface BEncoding (Private)

+ (NSNumber *)numberFromEncodedData:(BEncodingData *)data;
+ (NSData *)dataFromEncodedData:(BEncodingData *)data;
+ (NSString *)stringFromEncodedData:(BEncodingData *)data;
+ (NSArray *)arrayFromEncodedData:(BEncodingData *)data;
+ (NSDictionary *)dictionaryFromEncodedData:(BEncodingData *)data;
+ (id)objectFromData:(BEncodingData *)data;

@end

@implementation BEncoding

/*
 * This method to returns an NSData object that contains the bencoded
 * representation of the object that you send. You can send complex structures
 * such as an NSDictionary that contains NSArrays, NSNumbers and NSStrings, and
 * the encoder will correctly serialise the data in the expected way.
 *
 * Supports NSData, NSString, NSNumber, NSArray and NSDictionary objects.
 *
 * NSStrings are encoded as NSData objects as there is no way to differentiate
 * between the two when decoding.
 *
 * NSNumbers are encoded and decoded with their longLongValue.
 *
 * NSDictionary keys must be NSStrings.
 */
+ (NSData *)encodedDataFromObject:(id)object
{
	NSMutableData *returnedData = [NSMutableData data];

	if ([object isKindOfClass:[NSData class]]) {
		/* Encode a chunk of bytes from an NSData */

		NSString *length = [NSString stringWithFormat:@"%lu:", (unsigned long int)[object length]];

		[returnedData appendData:[length dataUsingEncoding:NSUTF8StringEncoding]];
		[returnedData appendData:object];

		return returnedData;
	}
	
	if ([object isKindOfClass:[NSString class]]) {
		/* Encode an NSString */

		NSData *stringData = [object dataUsingEncoding:NSUTF8StringEncoding];
		NSString *length = [NSString stringWithFormat:@"%lu:", (unsigned long int)[stringData length]];

		[returnedData appendData:[length dataUsingEncoding:NSUTF8StringEncoding]];
		[returnedData appendData:stringData];

		return returnedData;
	}
	
	if ([object isKindOfClass:[NSNumber class]]) {
		/* Encode an NSNumber */

		NSString *stringData = [NSString stringWithFormat:@"i%llue", [object longLongValue]];
		
		return [stringData dataUsingEncoding:NSUTF8StringEncoding];
	}
	
	if ([object isKindOfClass:[NSArray class]]) {
		/* Encode an NSArray */

		[returnedData appendBytes:"l" length:1];
		for (id item in object) [returnedData appendData:[BEncoding encodedDataFromObject:item]];
		[returnedData appendBytes:"e" length:1];

		return returnedData;
	}
	
	if ([object isKindOfClass:[NSDictionary class]]) {
		/* Encode an NSDictionary */

		[returnedData appendBytes:"d" length:1];
		for (id key in object) {
			/* Assert that the key is a string. It is expected that you'll check before
			 * passing this class an array of objects as keys that are not NSStrings. */

			NSAssert([key isKindOfClass:[NSString class]], @"Cannot encode dictionary whose one of the key is not an NSString");

			NSData *keyAsData = [key dataUsingEncoding:NSUTF8StringEncoding];
			NSString *keyAsDataLength = [NSString stringWithFormat:@"%lu:", (unsigned long int)[keyAsData length]];

			[returnedData appendData:[keyAsDataLength dataUsingEncoding:NSUTF8StringEncoding]];
			[returnedData appendData:keyAsData];
			[returnedData appendData:[BEncoding encodedDataFromObject:[object objectForKey:key]]];
		}
		[returnedData appendBytes:"e" length:1];
		
		return returnedData;
	}

	return nil;
}

+ (NSNumber *)numberFromEncodedData:(BEncodingData *)data
{
	long long int number = 0;

	if (data->bytes[data->offset] != 'i') return nil;

	data->offset++; /* We start on the i so we need to move by one. */
	if (data->offset >= data->length) return nil;

	BOOL firstChar = YES, firstDigit = YES, negate = NO;
	while (data->offset < data->length && data->bytes[data->offset] != 'e') {
		unsigned char curChar = data->bytes[data->offset++];
		if (curChar > '9' || curChar < '0') {
			if (!firstChar) return nil;
			if      (curChar == '-') negate = YES;
			else if (curChar != '+') return nil;
		} else {
			/* This test may be deactivated. It is done in reference to the torrent
			 * file format specification which says that integers should not be
			 * padded with 0 ("03" for 3 is not allowed) */
			if (curChar == '0' && firstDigit && data->bytes[data->offset] != 'e')
				return nil;
			
			number *= 10;
			number += curChar - '0';
			firstDigit = NO;
		}
		firstChar = NO;
	}

	data->offset++; /* Always move the offset off the end of the encoded item. */

	return [NSNumber numberWithLongLong:negate? -number: number];
}

+ (NSData *)dataFromEncodedData:(BEncodingData *)data
{
	NSMutableData *decodedData = [NSMutableData data];
	size_t dataLength = 0;

	if (data->offset >= data->length) return nil;

	if (data->bytes[data->offset] < '0' || data->bytes[data->offset] > '9')
		return nil; /* Needed because we must fail to create a dictionary if it isn't a string. */

	/* strings are special; they start with a number so we don't move by one. */

	while (data->offset < data->length && data->bytes[data->offset] != ':') {
		unsigned char curChar = data->bytes[data->offset++];
		if (curChar > '9' || curChar < '0') return nil;
		dataLength *= 10;
		dataLength += curChar - '0';
	}

	if (data->bytes[data->offset] != ':')
		return nil; /* We must have overrun the end of the bencoded string. */

	data->offset++;
	if (data->offset+dataLength > data->length) return nil;

	[decodedData appendBytes:data->bytes+data->offset length:dataLength];

	data->offset += dataLength; /* Always move the offset off the end of the encoded item. */

	return decodedData;
}

+ (NSString *)stringFromEncodedData:(BEncodingData *)data
{
	/* A string is just bencoded data */

	NSData *decodedData = [self dataFromEncodedData:data];
	if (decodedData == nil) return nil;

	return [[[NSString alloc] initWithBytes:[decodedData bytes] length:[decodedData length] encoding:NSUTF8StringEncoding] autorelease];
}

+ (NSArray *)arrayFromEncodedData:(BEncodingData *)data
{
	NSMutableArray *array = [NSMutableArray array];

	if (data->bytes[data->offset] != 'l') return nil;

	data->offset++; /* Move off the l so we point to the first encoded item. */
	if (data->offset >= data->length) return nil;

	while (data->offset < data->length && data->bytes[data->offset] != 'e')
		[array addObject:[BEncoding objectFromData:data]];
	
	if (data->bytes[data->offset] != 'e') return nil;

	data->offset++; /* Always move off the end of the encoded item. */

	return array;
}

+ (NSDictionary *)dictionaryFromEncodedData:(BEncodingData *)data
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	NSString *key = nil;
	id value = nil;

	if (data->bytes[data->offset] != 'd') return nil;

	data->offset++; /* Move off the d so we point to the string key. */
	if (data->offset >= data->length) return nil;

	while (data->offset < data->length && data->bytes[data->offset] != 'e') {
		if (data->bytes[data->offset] >= '0' && data->bytes[data->offset] <= '9') {
			// Dictionaries are a bencoded string with a bencoded value.
			key = [BEncoding stringFromEncodedData:data];
			value = [BEncoding objectFromData:data];
			if (key != nil && value != nil)
				[dictionary setValue:value forKey:key];
		} else {
			/* There is definitely an error if we arrive here.
			 * a strategy to recover is to move the offset by one
			 * and continue the loop. */
			return nil;
		}
	}

	if (data->bytes[data->offset] != 'e') return nil;
	
	data->offset++; /* Move off the e so we point to the next encoded item. */

	return dictionary;
}

+ (id)objectFromData:(BEncodingData *)data
{
	/* Each of the decoders expect that the offset points to the first character
	 * of the encoded entity, for example the i in the bencoded integer "i18e" */

	if (data->offset >= data->length) return nil;

	switch (data->bytes[data->offset]) {
		case 'l':
			return [BEncoding arrayFromEncodedData:data];
			break;
		case 'd':
			return [BEncoding dictionaryFromEncodedData:data];
			break;
		case 'i':
			return [BEncoding numberFromEncodedData:data];
			break;
		default:
			if (data->bytes[data->offset] >= '0' && data->bytes[data->offset] <= '9')
				return [BEncoding dataFromEncodedData:data];
	}

	/* If we reach here, it doesn't appear that this is bencoded data. So, we'll
	 * just return nil and advance to the next byte in the hopes we'll decode
	 * something useful. Not sure if this is a good strategy. */
	data->offset++;
	return [self objectFromData:data];
}

+ (id)objectFromEncodedData:(NSData *)sourceData
{
	BEncodingData data;
	data.bytes = [sourceData bytes];
	data.length = [sourceData length];
	data.offset = 0;

	return data.bytes ? [BEncoding objectFromData:&data] : nil;
}

@end
