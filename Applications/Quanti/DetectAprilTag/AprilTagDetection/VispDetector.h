//
// This file is part of the groma software.
// Copyright © 2018 Aplix and/or its affiliates. All rights reserved.
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// version 2 as published by the Free Software Foundation.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//
// See https://groma.jp for more information.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>

typedef NS_OPTIONS(NSUInteger, DisplayMode){
    DisplayMode_Id          = 1 << 0,
    DisplayMode_Orientation = 1 << 1,
    DisplayMode_Distance    = 1 << 2
};

@interface VispDetector : NSObject

- (UIImage *)detectAprilTag: (UIImage*)image targetIds:(int *)targetIds count:(int)targetCount
    family:(NSString *)tagFamilyName intrinsic:(float *)param tagSize:(int)tagSize display:(DisplayMode)modes;

@end

