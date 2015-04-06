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
	thisInterface = NULL;
	thumbnail = NULL;
	url = NULL;
	contentTypeUTI = NULL;
	options = NULL;
	maxSize = CGSizeZero;
}

void CancelThumbnailGeneration(void* thisInterface, QLThumbnailRequestRef thumbnail)
{
	// implement only if supported
	// avoid warnings
	thisInterface = NULL;
	thumbnail = NULL;
}
