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

#import "VispDetector.h"
#import "ImageConversion.h"
#import "ImageDisplay.h"
#import <AVFoundation/AVFoundation.h>
#import <Eureka/Eureka-Swift.h>
#import "DetectAprilTag-Swift.h"

@implementation VispDetector

- (UIImage *)detectAprilTag:(UIImage *)image targetIds:(int *)targetIds count:(int)targetCount family:(NSString *)tagFamilyName{
    
    // 画像を回転させる
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // UIImageをvpImageにする
    vpImage<unsigned char> I = [ImageConversion vpImageGrayFromUIImage:image];

    // 内部パラメーター（今回は距離や姿勢を検知しないので決め打ち）
    float px = 1515.0;
    float py = 1515.0;
    float u0 = I.getWidth()/2;
    float v0 = I.getHeight()/2;

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
    double tagSize = 0.13;

    // 設定の格納
    vpDetectorAprilTag detector(tagFamily);
    detector.setAprilTagQuadDecimate(quad_decimate);
    detector.setAprilTagPoseEstimationMethod(poseEstimationMethod);
    detector.setAprilTagNbThreads(nThreads);

    // 検知
    vpCameraParameters cam;
    cam.initPersProjWithoutDistortion(px,py,u0,v0);
    std::vector<vpHomogeneousMatrix> cMo_vec;
    detector.detect(I, tagSize, cam, cMo_vec);
    
    // 描画処理開始
    UIGraphicsBeginImageContext(image.size);
    [image drawAtPoint:CGPointMake(0,0)]; // まずは背景に元画像を表示
    CGContextRef context = UIGraphicsGetCurrentContext();

    // タグごとに描画
    int tagNums = (int)detector.getNbObjects();
    for(int i=0; i < tagNums; i++){
        
        // タグIDの取得 "36h11 id: 1" -> 1
        NSString * message = [NSString stringWithCString:detector.getMessage(i).c_str()
                encoding:[NSString defaultCStringEncoding]];
        NSArray *phases = [message componentsSeparatedByString:@" "];
        int detectedTagId = [phases[2] intValue];
        
        // ターゲットかどうかで色分け
        UIColor *color = [UIColor blueColor];
        int tagLineWidth = 2;
        for(int n=0; n < targetCount; n++){
            // 合致するIDがあれば色変更
            if (detectedTagId == targetIds[n]) {
                color = [UIColor redColor];
                tagLineWidth = 15;
            }
        }

        // フレームの描画
        std::vector<vpImagePoint> polygon = detector.getPolygon(i);
        CGContextSetLineWidth(context, tagLineWidth);
        CGContextSetStrokeColorWithColor(context, [color CGColor]);
        for (size_t j = 0; j < polygon.size(); j++) {

            CGContextMoveToPoint(context, polygon[j].get_u(), polygon[j] .get_v());
            CGContextAddLineToPoint(context, polygon[(j+1)%polygon.size()].get_u(), polygon[(j+1)%polygon.size()].get_v());
            
            CGContextStrokePath(context);
        }
        
        // tagIdの描画
        UIFont *font = [UIFont boldSystemFontOfSize:50];
        CGRect rect = CGRectMake(polygon[0].get_u(), polygon[0].get_v(), 200, 100);
        NSDictionary *attributes =
            @{
              NSForegroundColorAttributeName : color,
              NSFontAttributeName : font
        };
        NSString *tagIdStr = [NSString stringWithFormat:@"%d", detectedTagId];
        [tagIdStr drawInRect:CGRectIntegral(rect) withAttributes:attributes];

    }
    
    // 新しい画像を上書き
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end
