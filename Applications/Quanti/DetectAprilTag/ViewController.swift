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

class ViewController: UIViewController, AVCaptureDelegate,
    UINavigationControllerDelegate {
    
    @IBOutlet weak var searchBarField: UISearchBar!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var errorTextView: UITextView!
    
    // Optionスイッチ
    @IBOutlet weak var orientationSwitch: UISwitch!
    @IBOutlet weak var orientationSwitchLabel: UILabel!
    @IBOutlet weak var distanceSwitch: UISwitch!
    @IBOutlet weak var distanceSwitchLabel: UILabel!
    
    let userDefaults = UserDefaults.standard
    let avCapture = AVCapture()
    let visp = VispDetector()
    
    // 設定値
    var targetTagIds = [Int32]()
    var tagFamily = "36h11"
    var captureStatus = "RUN"
    var modes:DisplayMode = .id
    var tagSize = 18 //mm


    override func viewDidLoad() {
        super.viewDidLoad()
        avCapture.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 各種設定の読み込み
        setUIItems()
        loadUserDefaults()
        cutomizeSearchBar()
        checkCameraAuth()
        
        // 設定画面から戻ってきた場合のために再起動
        setCaptureStatusRun()
    }
    
    func capture(image: UIImage, intrinsic:matrix_float3x3) {
        
        var params = [
            intrinsic.columns.0.x,
            intrinsic.columns.1.y,
            intrinsic.columns.2.x,
            intrinsic.columns.2.y
        ]
        
        // メインのタグ検知処理
        imageView.image
            = visp.detectAprilTag(image,targetIds:&targetTagIds, count:Int32(targetTagIds.count), family:tagFamily, intrinsic:&params, tagSize: Int32(tagSize), display:modes)
    }
    
    // doneボタン押下時の処理（検索IDの取得）
    @objc internal func done() {
        
        //何もない場合、何もせず終了
        guard (self.searchBarField.text != nil || self.searchBarField.text != "") else {
            
            print("searchFeild is null.")
            self.searchBarField.endEditing(true)
            return
        }
        
        // ターゲットID Arrayの生成
        targetTagIds.removeAll()
        let inputIds = self.searchBarField.text
        let inputIdArray = inputIds?.split(separator: ",")
        
        // カンマで区切られた指定のIDについて
        errorTextView.text = ""
        inputIdArray?.forEach{
            
            // トリム
            var idStr:String = String($0)
            idStr = idStr.trimmingCharacters(in: .whitespaces)
            if idStr == ""  { return } // 行末等
            
            // 「貼り付け」等で数字じゃないものがある場合
            guard let id = Int32(idStr) else {
                errorTextView.text = "ErrorOnlyNumber".local
                return
            }
            
            // 数字が規定の範囲に納まってるか見る
            if (tagFamily == "36h10" && (id > 2319 || id < 0)){
                errorTextView.text = "ErrorMaximum36h10".local
            } else if (tagFamily == "36h11" && (id > 586 || id < 0)) {
                errorTextView.text = "ErrorMaximum36h11".local
            } else {
                targetTagIds.append(id)
            }
        }
        
        // エラーが無い場合はキーボードを閉じる
        if (errorTextView.text  == "") {
            self.searchBarField.endEditing(true)
        }
    }
    
    // add ID ボタン（複数検索のためのセパレーター付与）
    @objc internal func add() {
        guard let currentText = self.searchBarField.text else {
            return
        }
        self.searchBarField.text = currentText + ", "
    }
    
    // cancelボタン
    @objc internal func cancel() {
        
        self.searchBarField.text = ""
        targetTagIds.removeAll()
        errorTextView.text = "ErrorNotSet".local
        self.searchBarField.endEditing(true)
        self.searchBarField.placeholder = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setCaptureStatusStop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        setCaptureStatusStop()
    }
}
