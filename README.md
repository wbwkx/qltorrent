# BitTorrent Quick Look Preview #

## qltorrent ##

This is a Quick Look generator plugin which displays the content of a
BitTorrent file.  It is useful if you ever have to sort through
torrent files that are named by 10 year old children, but don't feel
like firing up your client just to see what's in it.

## Installation ##

1. Download and extract the [tarball][tarball] or [zipball][zipball]
of the project.

2. Open the file `qltorrent.xcodeproj` with Xcode.

3. Build the project by clicking on the menu `Build/Build` (or
`<cmd>+B`).

4. Copy the generated file `qltorrent.qlgenerator` which is in
`build/Debug` or `build/Release` folder into `~/Library/QuickLook` in
your home folder.

5. You may need to reset Quick Look Server and all Quick Look
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

[tarball]: https://github.com/sillage/qltorrent/tarball/master
[zipball]: https://github.com/sillage/qltorrent/zipball/master
[framework]: https://code.google.com/p/cocoabtutils/
[bep3]: http://bittorrent.org/beps/bep_0003.html
[torrentspec]: http://wiki.theory.org/BitTorrentSpecification
[wikipedia]: http://en.wikipedia.org/wiki/Bencode
