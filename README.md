# ToneManager
## What can it do?
Installation of ringtones from popular ringtone apps on iOS without iTunes. Can also do manual import from filesystem or app. Registers itself in iOS as capable of handling most audio file formats so it can install ringtones from the share sheet in basically any app that uses the share sheet with audio files. Will convert all audio formats supported by iOS to m4r. Will only import the first 30 seconds of sound if longer than 30 seconds. 
See instructions in app.

## About this app
This is based on a tweak i made but I couldn't get it working reliably as a tweak so i rewrote it as an app. I've also disassembled Guitarband for iOS and analyzed the code that is doing the ringtone export/install and reimplemented it in swift as closely as possible. This includes using undocumented private frameworks, mainly ToneLibrary. 
This should increase compatibility of my code for ios 11-10 (possibly 9), theoretically (not tested on anything else than 11.3.1 for now). Testers are welcome! Only available on my development repo during the beta phase: https://jesperflodin1.github.io

## Jailbreak required!
This requires your iphone to be jailbroken! Installed ringtones will stay even if you reboot to a non-jailbroken state. Your ringtones will also be backed up to iCloud and restored if you ever update your iPhone, even if you update to an iOS version that can't be jailbroken. (In that case you wont be able to uninstall the ringtones without jailbreaking again...)

As far as i know there is no way to give my app the entitlements required to be able to work on a non-jailbroken iOS. If i could workaround this i would be releasing a version that wouldn't require jailbreak..


Please report bugs you may be experencing, it's the only way i can improve this app!

# License
MIT License

Copyright (c) 2018 Jesper Flodin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
