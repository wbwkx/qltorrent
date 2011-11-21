/*
 * main.m
 * StaticQLTorrentTests
 *
 * Created by François LAMBOLEY on 11/20/11.
 * Copyright (c) 2011 Sillage. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import "torrent.h"

/* Ugly, but avoids a lot of troubles */
static NSString * const torrentHTML = @"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n"
@"<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\" xml:lang=\"en\">\n"
@"<head>\n"
@"<title>qltorrent</title>\n"
@"<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />\n"
@"<style type=\"text/css\" media=\"screen\">\n"
@"html,body{\n"
@"margin:0;\n"
@"padding:0;\n"
@"}\n"
@"html{\n"
@"	background-color:rgb(11%,11%,11%);\n"
@"color:#ccc;\n"
@"}\n"
@"#title{\n"
@"background:#111;\n"
@"color:#666;\n"
@"padding-bottom:.2em;\n"
@"margin-bottom:1em;\n"
@"}\n"
@"#title #torrentname h2{\n"
@"line-height:1em;\n"
@"background:#000;\n"
@"color:#273F51;\n"
@"padding:.2em;\n"
@"padding-left:1em;\n"
@"}\n"
@"#main{\n"
@"clear:both;\n"
@"border:0;\n"
@"width:40em;\n"
@"margin-left:auto;\n"
@"margin-right:auto;\n"
@"}\n"
@"#size{\n"
@"width:7em;\n"
@"}\n"
@".odd{\n"
@"background:#222;\n"
@"}\n"
@".even{\n"
@"background:#333;\n"
@"}\n"
@"</style>\n"
@"</head>\n"
@"<body>\n"
@"<div id=\"title\">\n"
@"<div id=\"torrentname\">\n"
@"<h2>{TORRENT_NAME}</h2>\n"
@"</div>\n"
@"<div id=\"info\">\n"
@"{TORRENT_INFO}\n"
@"</div>\n"
@"</div>\n"
@"<table id=\"main\">\n"
@"<tr><th>File Name</th><th id=\"size\">Size</th></tr>\n"
@"{TORRENT_FILES}\n"
@"</table>\n"
@"</body>\n"
@"</html>\n";

/* This program must be given one argument: a file:// type url: the url of the tested file */
int main (int argc, const char *argv[]) {
	if (argc != 2) {
		fprintf(stderr, "Usage: %s url\n", argv[0]);
		return 42;
	}
	
	@autoreleasepool {
		NSData *torrentPreview = getTorrentPreview([NSURL URLWithString:[NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding]], torrentHTML);
		NSLog(@"%@", [[NSString alloc] initWithData:torrentPreview encoding:NSUTF8StringEncoding]);
	}
	
	return 0;
}
