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
//
// This file is using a part of ImageDisplay.mm source code,
// which is distributed under the GNU GENERAL PUBLIC LICENSE Version 2 or (at your option) any later version.
// ImageDisplay.mm is copyrighted as follows.
//
// Copyright (C) 2005 - 2017 by Inria. All rights reserved.
//


#import "VispDetector.h"
#import "ImageConversion.h"
#import "ImageDisplay.h"
#import <AVFoundation/AVFoundation.h>
#import <Eureka/Eureka-Swift.h>
#import "DetectAprilTag-Swift.h"

@implementation VispDetector

- (UIImage *)detectAprilTag:(UIImage *)image targetIds:(int *)targetIds count:(int)targetCount
        family:(NSString *)tagFamilyName intrinsic:(float *)param tagSize:(int)tagSize display:(DisplayMode)modes{
    
    // 画像領域を確保
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // UIImageをvpImageにする
    vpImage<unsigned char> I = [ImageConversion vpImageGrayFromUIImage:image];

    // 内部パラメーター
    float px = param[0];
    float py = param[1];
    //float u0 = param[2];
    //float v0 = param[3];
    // こちらのほうが画面上の姿勢が綺麗
    float u0 = I.getWidth()/2;
    float v0 = I.getHeight()/2;
    // 内部パラメーターが取れてなかった場合
    if(px == 0.0 && py == 0.0){
        px = 1515.0;
        py = 1515.0;
    }
    
    // AprilTag 初期設定
    vpDetectorAprilTag::vpAprilTagFamily tagFamily;
    if([tagFamilyName  isEqual: @"36h11"]){
        tagFamily = vpDetectorAprilTag::TAG_36h11;
    } else if([tagFamilyName  isEqual: @"36h10"]){
        tagFamily = vpDetectorAprilTag::TAG_36h10;
    } else {
        tagFamily = vpDetectorAprilTag::TAG_36h11;
    }
    
    vpDetectorAprilTag::vpPoseEstimationMethod poseEstimationMethod = vpDetectorAprilTag::HOMOGRAPHY_VIRTUAL_VS;
    float quad_decimate = 3.0;
    int nThreads = 1;
    double vpTagSize = (double)tagSize / 1000.0; // (mm → m)

    // 設定の格納
    vpDetectorAprilTag detector(tagFamily);
    detector.setAprilTagQuadDecimate(quad_decimate);
    detector.setAprilTagPoseEstimationMethod(poseEstimationMethod);
    detector.setAprilTagNbThreads(nThreads);

    // 検知
    vpCameraParameters cam;
    cam.initPersProjWithoutDistortion(px,py,u0,v0);
    std::vector<vpHomogeneousMatrix> cMo_vec;
    detector.detect(I, vpTagSize, cam, cMo_vec);
    
    // 描画処理開始
    UIGraphicsBeginImageContext(image.size);
    [image drawAtPoint:CGPointMake(0,0)]; // まずは背景に元画像を表示
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 描画設定
    NSDictionary *attrTagId =
    @{
      NSForegroundColorAttributeName : [UIColor blueColor],
      NSFontAttributeName : [UIFont boldSystemFontOfSize:50]
    };
    NSDictionary *attrDistance =
    @{
      NSForegroundColorAttributeName : [UIColor whiteColor],
      NSFontAttributeName : [UIFont boldSystemFontOfSize:50],
      NSBackgroundColorAttributeName: [UIColor blueColor]
      };
    
    // タグごとに描画
    int tagNums = (int)detector.getNbObjects();
    for(int i=0; i < tagNums; i++){
        
        // タグIDの取得 "36h11 id: 1" -> 1
        NSString * message = [NSString stringWithCString:detector.getMessage(i).c_str()
                encoding:[NSString defaultCStringEncoding]];
        NSArray *phases = [message componentsSeparatedByString:@" "];
        int detectedTagId = [phases[2] intValue];
        
        // フレームの描画
        UIColor *color = [UIColor blueColor];
        int tagLineWidth = 5;
        for(int n=0; n < targetCount; n++){
            // 合致するIDがあれば色変更
            if (detectedTagId == targetIds[n]) {
                color = [UIColor redColor];
                tagLineWidth = 15;
            }
        }
        std::vector<vpImagePoint> polygon = detector.getPolygon(i);
        CGContextSetLineWidth(context, tagLineWidth);
        CGContextSetStrokeColorWithColor(context, [color CGColor]);
        for (size_t j = 0; j < polygon.size(); j++) {

            CGContextMoveToPoint(context, polygon[j].get_u(), polygon[j] .get_v());
            CGContextAddLineToPoint(context, polygon[(j+1)%polygon.size()].get_u(), polygon[(j+1)%polygon.size()].get_v());
            
            CGContextStrokePath(context);
        }
        
        // tagIdの描画
        if(modes & DisplayMode_Id){
            NSString *tagIdStr = [NSString stringWithFormat:@"%d", detectedTagId];
            CGRect rect = CGRectMake(polygon[0].get_u(), polygon[0].get_v(), 600, 100);
            
            [tagIdStr drawInRect:CGRectIntegral(rect) withAttributes:attrTagId];
        }

        // カメラからの距離
        if(modes & DisplayMode_Distance){
            vpTranslationVector trans = cMo_vec[i].getTranslationVector();
            float distance = sqrt(trans[0]*trans[0] + trans[1]*trans[1] + trans[2]*trans[2]);
            NSString *meter = [NSString stringWithFormat:@"%.2fm", distance];
            vpImagePoint cog = detector.getCog(i);
            CGRect rect = CGRectMake(cog.get_u(), cog.get_v(), 600, 100);
            
            [meter drawInRect:CGRectIntegral(rect) withAttributes:attrDistance];
        }
        
        // 姿勢の描画
        if(modes & DisplayMode_Orientation){
            
            int tickness = 6;
            vpPoint o( 0.0,  0.0,  0.0);
            vpPoint x(vpTagSize,  0.0,  0.0);
            vpPoint y( 0.0, vpTagSize,  0.0);
            vpPoint z( 0.0,  0.0, vpTagSize);
            
            o.track(cMo_vec[i]);
            x.track(cMo_vec[i]);
            y.track(cMo_vec[i]);
            z.track(cMo_vec[i]);
            
            vpImagePoint ipo, ip1;
            
            vpMeterPixelConversion::convertPoint (cam, o.p[0], o.p[1], ipo);
            
            // Draw red line on top of original image
            vpMeterPixelConversion::convertPoint (cam, x.p[0], x.p[1], ip1);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetLineWidth(context, tickness);
            CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
            CGContextMoveToPoint(context, ipo.get_u(), ipo.get_v());
            CGContextAddLineToPoint(context, ip1.get_u(), ip1.get_v());
            CGContextStrokePath(context);
            
            // Draw green line on top of original image
            vpMeterPixelConversion::convertPoint ( cam, y.p[0], y.p[1], ip1) ;
            context = UIGraphicsGetCurrentContext();
            CGContextSetLineWidth(context, tickness);
            CGContextSetStrokeColorWithColor(context, [[UIColor greenColor] CGColor]);
            CGContextMoveToPoint(context, ipo.get_u(), ipo.get_v());
            CGContextAddLineToPoint(context, ip1.get_u(), ip1.get_v());
            CGContextStrokePath(context);
            
            // Draw blue line on top of original image
            vpMeterPixelConversion::convertPoint ( cam, z.p[0], z.p[1], ip1) ;
            context = UIGraphicsGetCurrentContext();
            CGContextSetLineWidth(context, tickness);
            CGContextSetStrokeColorWithColor(context, [[UIColor blueColor] CGColor]);
            CGContextMoveToPoint(context, ipo.get_u(), ipo.get_v());
            CGContextAddLineToPoint(context, ip1.get_u(), ip1.get_v());
            CGContextStrokePath(context);
            
        }
    }
    
    // 新しい画像を上書き
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end
