//
// This file is part of the groma software.
// Copyright © 2018 Aplix and/or its affiliates.
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
// This file is copied and modified from original file, which is distributed under
// MIT License (https://github.com/furuya02/GekigaCamera/blob/master/LICENSE)
// and is copyrighted as follows.
//
// AvCapture.swift
//
// Created by hirauchi.shinichi on 2017/02/19.
// Copyright © 2017年 SAPPOROWORKS. All rights reserved.
//

import UIKit
import AVFoundation

protocol AVCaptureDelegate {
    func capture(image: UIImage, intrinsic:matrix_float3x3)
}

class AVCapture:NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let userDefaults = UserDefaults.standard
    var captureSession: AVCaptureSession!
    var delegate: AVCaptureDelegate?
    
    // DISMISS_COUNT に1回画像処理
    var counter = 0
    let DISMISS_COUNT = 3
    
    override init(){
        super.init()
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        if let lastResolution = userDefaults.string(forKey: "Resolution") {
            changeResolution(quality: lastResolution)
        }
        
        let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)
        videoDevice?.activeVideoMinFrameDuration = CMTimeMake(1, 30)// 1/30秒 (１秒間に30フレーム)
        let videoInput: AVCaptureInput!
        do {
            videoInput = try AVCaptureDeviceInput.init(device: videoDevice!)
        } catch {
            return
        }
        captureSession.addInput(videoInput)
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String : Int(kCVPixelFormatType_32BGRA)]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true

        // 内部パラメーターの取得
        captureSession.addOutput(videoDataOutput)
        if let connection = videoDataOutput.connections.first {
            if connection.isCameraIntrinsicMatrixDeliverySupported {
                print("Camera Intrinsic Matrix Delivery is supported.")
                connection.isCameraIntrinsicMatrixDeliveryEnabled = true
            } else {
                print("Camera Intrinsic Matrix Delivery is NOT supported.")
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
        
    }
    
    // 新しいキャプチャの追加で呼ばれる(1/30秒に１回)
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        // DISMISS_COUNTごとに画像処理の実行
        if (counter % DISMISS_COUNT) == 0 {
            
            var matrix = matrix_float3x3.init()
            if let camData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) as? Data {
                matrix = camData.withUnsafeBytes { $0.pointee }
            }
            
            let image = imageFromSampleBuffer(sampleBuffer: sampleBuffer)
            delegate?.capture(image: image, intrinsic:matrix)
            
        }
        counter += 1
        
    }
    
    func imageFromSampleBuffer(sampleBuffer :CMSampleBuffer) -> UIImage {
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        // イメージバッファのロック
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        // 画像情報を取得
        let base = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)!
        let bytesPerRow = UInt(CVPixelBufferGetBytesPerRow(imageBuffer))
        let width = UInt(CVPixelBufferGetWidth(imageBuffer))
        let height = UInt(CVPixelBufferGetHeight(imageBuffer))
        
        // ビットマップコンテキスト作成
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitsPerCompornent = 8
        let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue) as UInt32)
        let newContext = CGContext(data: base, width: Int(width), height: Int(height), bitsPerComponent: Int(bitsPerCompornent), bytesPerRow: Int(bytesPerRow), space: colorSpace, bitmapInfo: bitmapInfo.rawValue)! as CGContext
        
        // イメージバッファのアンロック
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        // 画像作成
        let imageRef = newContext.makeImage()!

        // アプリの向きを検知して向き変更
        let interfaceOrientation = UIApplication.shared.statusBarOrientation
        if(interfaceOrientation == UIInterfaceOrientation.landscapeLeft) {
            return  UIImage(cgImage: imageRef, scale: 1.0, orientation: UIImageOrientation.down)
        }
        if(interfaceOrientation == UIInterfaceOrientation.landscapeRight) {
            return  UIImage(cgImage: imageRef)
        }
        if(interfaceOrientation == UIInterfaceOrientation.portraitUpsideDown){
            return  UIImage(cgImage: imageRef, scale: 1.0, orientation: UIImageOrientation.left)
        }
        return  UIImage(cgImage: imageRef, scale: 1.0, orientation: UIImageOrientation.right) // デフォルト値
    }
    
    func stopCapturing () {
        captureSession.stopRunning()
    }
    func restartCapturing () {
        captureSession.startRunning()
    }
    func changeResolution (quality: String) {
        if(quality == "High"
            && captureSession.sessionPreset != AVCaptureSession.Preset.photo) {
            captureSession.sessionPreset = AVCaptureSession.Preset.photo
        }
        if(quality == "Medium"
            && captureSession.sessionPreset != AVCaptureSession.Preset.high) {
            captureSession.sessionPreset = AVCaptureSession.Preset.high
        }
    }
}


