# BPStatusBar

## Description

A utility class for displaying status updates in the iOS status bar.  Inspired by Mailbox and designed to function similar to SVProgressHUD.

## Usage

- Show a status with a spinner

        [BPStatusBar showWithStatus:@"Working..."];

- Show a message with an image and dismiss after 1 second

        [BPStatusBar showWithSuccess:@"Download Finished!"];
        
- See the included demo app for more.

## Known Issues

- Rotation support is untested.
- Timing hacks when restoring the system status bar.

## License

MIT - See LICENSE.txt

## Thanks

Sam Vermentte - Much of SVProgressHUD's design is the basis for this project.

## Contact

[Brian Partridge](http://brianpartridge.name) - @brianpartridge on [Twitter](http://twitter.com/brianpartridge) and [App.Net](http://alpha.app.net/brianpartridge)