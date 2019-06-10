# groma AprilTag Solution
This repository is distributed by Aplix Corporation.  
See <a href='https://groma.jp/AprilTag' target='_blank'>groma.jp/AprilTag</a> for more information.

# For Developer

## Build Environment
XCode 10.2.1, macOS Mojave 10.14.4

## Confirmed Devices and OSes
(surveyed on June 2019.)
This App only supports iOS 11.0+.  
Note: if you are using iPhone 5s or earlier model, you can't get intrinsic param.
3D Position and Orientation will not be correct.

|device model|iOS version|
|-|-|
|iPhone SE|12.3.1|
|iPhone 6|12.3.1|
|iPhone 6s Plus|12.0.1|
|iPhone 7|12.0|
|iPhone 8|11.0.3|
|iPad 5|12.1.4|
|iPad Pro (12.9-inch)|11.4.1|


## How to Install
### clone from our repository

```
$ git clone https://github.com/AplixCorporation/groma-AprilTag.git
```
### install ViSP framework
1. [download "ViSP for iOS"](https://visp.inria.fr/download/) (current latest version is 3.2.0, please do not use `Daily updated snapshots`.)
2. install the framework to Xcode  
see [Tutorial: How to create a basic iOS application that uses ViSP](http://visp-doc.inria.fr/doxygen/visp-daily/tutorial-getting-started-iOS.html)

If you have some trouble in installing the framework, please delete the framework cache on the sbelow settings.  
Then re-install(drag & drop) the framework to root folder.
- General -- Linked Frameworks and Libraries
- Build Setting -- Framework Search Path
- Build Phases -- Link Binary with Libraries
- Project navigator

### open Xcode
Finally, open DetectAprilTag.xcworkspace (not DetectAprilTag.xcodeproj).

# Information
## Copyright notice and license statement
Copyright © 2018 Aplix and/or its affiliates.  
GNU General Public License, version 2

## Acknowledgment
[AprilTag (BSD 2-Clause)](https://april.eecs.umich.edu/software/apriltag.html)  
[ViSP (GNU GPLv2 or (at your option) any later version)](https://github.com/lagadic/visp)  
[OpenCV (BSD 3-Clause)](https://github.com/opencv/opencv)  
[Eureka (MIT)](https://github.com/xmartlabs/Eureka)  
[Gekiga Camera (MIT)](https://github.com/furuya02/GekigaCamera)  

## Contact
[Contact Form](https://www.aplix.co.jp/en/inquiry_en/product/)  
[お問い合わせ (Japanese)](https://www.aplix.co.jp/inquiry/product/)

