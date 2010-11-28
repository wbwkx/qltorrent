# BitTorrent Quick Look Preview #

## qltorrent ##

This is a Quick Look generator plugin which displays the content of a
BitTorrent file.  It is useful if you ever have to sort through
torrent files that are named by 10 year old children, but don't feel
like firing up your client just to see what's in it.

## Installation ##

1. Download the last compiled version of the project: [version
1.0][qltorrent].

2. Copy the file `qltorrent.qlgenerator` into (if the folder is not
present, then you will need to create it first):

   * `~/Library/QuickLook`, if _just you_ want to use this plugin, or
     into

   * `/Library/QuickLook`, if you want _any user_ on this machine to use
     plugin.

3. You may need to reset Quick Look Server and all Quick Look
client's generator cache: open up Terminal and type `qlmanage -r`.

## Thanks ##

This Quick Look plugin uses the BEncoding framework by Nathan
Ollerenshaw ([Cocoa BitTorrent Utilities][framework]).  Thanks to him.

## Info ##

The BitTorrent Protocol Specification: [Official protocol
specification][bep3].

A detailed specification wiki maintained by the development community:
[BitTorrent Specification][torrentspec].

Article about _Bencode_ on [Wikipedia][wikipedia].

[qltorrent]: https://github.com/downloads/sillage/qltorrent/qltorrent.qlgenerator
[framework]: https://code.google.com/p/cocoabtutils/
[bep3]: http://bittorrent.org/beps/bep_0003.html
[torrentspec]: http://wiki.theory.org/BitTorrentSpecification
[wikipedia]: http://en.wikipedia.org/wiki/Bencode
