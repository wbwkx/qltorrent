#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include <Cocoa/Cocoa.h>
#include "torrent.h"

/* -----------------------------------------------------------------------------
 Generate a preview for file

 This function's job is to create preview for designated file
 ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
	NSLog(@"Quicklook torrent thingy going!");
	CFDataRef data = (CFDataRef) getTorrentPreview((NSURL *)url, nil);
	if(data){
		CFDictionaryRef props = (CFDictionaryRef) [NSDictionary dictionary];
		QLPreviewRequestSetDataRepresentation(preview, data, kUTTypeHTML, props);
	}

	return noErr;
	// avoid warnings
	thisInterface = NULL;
	contentTypeUTI = NULL;
	options = NULL;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
	// implement only if supported
	// avoid warnings
	thisInterface = NULL;
	preview = NULL;
}
