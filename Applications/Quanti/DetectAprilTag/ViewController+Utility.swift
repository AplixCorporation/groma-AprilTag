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

import AVFoundation

extension ViewController {
    
    // UIパーツの初期設定
    func setUIItems(){
        
        // Optionスイッチ
        orientationSwitch.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        orientationSwitchLabel.text = "OrientationLabel".local
        distanceSwitch.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        distanceSwitchLabel.text = "DistanceLabel".local
    }
    
    // キーボードと検索バーをカスタマイズ
    func cutomizeSearchBar (){
        
        // ツールバーに各ボタンの追加
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let addItem = UIBarButtonItem(title: "AddID".local, style: .done, target: self, action: #selector(add))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let doneItem  = UIBarButtonItem(title: "Start".local, style: .done, target: self, action: #selector(done))
        
        toolbar.setItems([cancelItem, flexibleItem, addItem, flexibleItem, doneItem], animated: true)
        toolbar.sizeToFit()
        self.searchBarField.inputAccessoryView = toolbar
        
        // 検索バーの背景を透明に
        if #available(iOS 13.0, *) {
            self.searchBarField.searchBarStyle = .minimal
            self.searchBarField.searchTextField.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        } else {
            let searchBgImg = self.searchBarField.value(forKey: "_background") as! UIImageView
            searchBgImg.removeFromSuperview()
        }
        
        self.searchBarField.placeholder = "SearchField".local
    }
    
    // キャプチャ中止・再開ボタン
    @IBAction func stopDetecting(_ sender: Any) {
        if (captureStatus == "RUN"){
            setCaptureStatusStop()
        }
        else {
            setCaptureStatusRun()
        }
    }
    
    func setCaptureStatusStop () {
        stopButton.setImage(UIImage(named: "play"), for: UIControlState.normal)
        avCapture.stopCapturing()
        captureStatus = "STOP"
    }
    
    func setCaptureStatusRun () {
        stopButton.setImage(UIImage(named: "pause"), for: UIControlState.normal)
        avCapture.restartCapturing()
        captureStatus = "RUN"
    }
    
    // スイッチ：方向
    @IBAction func switchOrientationMode(_ sender: UISwitch) {
        
        if(sender.isOn){
            modes.insert(.orientation)
        }else{
            modes.remove(.orientation)
        }
    }
    // スイッチ：距離
    @IBAction func switchDistanceMode(_ sender: UISwitch) {
        
        if(sender.isOn){
            modes.insert(.distance)
        }else{
            modes.remove(.distance)
        }
    }
    
    // カメラの権限の確認
    func checkCameraAuth(){
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return
        case .notDetermined:
            // アラート画面で拒否ボタンが押されたら非同期でエラーの表示
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    DispatchQueue.main.sync() {
                        self.errorTextView.text = "ErrorAuthorization".local
                    }
                }
            }
        case .denied:
            errorTextView.text = "ErrorAuthorization".local
        case .restricted:
            errorTextView.text = "ErrorAuthorization".local
        }
        return
    }
    
    
    // ローカルデータの読み込み
    func loadUserDefaults () {
        
        userDefaults.register(defaults:[
            "TagFamily" : tagFamily,
            "Resolution": "Medium",
            "TagSize"   : 18
            ])
        tagFamily = userDefaults.string(forKey: "TagFamily")!
        let lastResolution = userDefaults.string(forKey: "Resolution")!
        avCapture.changeResolution(quality: lastResolution)
        tagSize = userDefaults.integer(forKey: "TagSize")
    }
    
}
