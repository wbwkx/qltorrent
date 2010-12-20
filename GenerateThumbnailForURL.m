#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

/* -----------------------------------------------------------------------------
 Generate a thumbnail for file
 
 This function's job is to create thumbnail for designated file as fast as possible
 ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
	return noErr;
	// avoid warnings
	thisInterface = thisInterface;
	thumbnail = thumbnail;
	url = url;
	contentTypeUTI = contentTypeUTI;
	options = options;
	maxSize = maxSize;
}

void CancelThumbnailGeneration(void* thisInterface, QLThumbnailRequestRef thumbnail)
{
	// implement only if supported
	// avoid warnings
	thisInterface = thisInterface;
	thumbnail = thumbnail;
}
