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

import UIKit
import SafariServices
import Eureka

class SettingsViewController: FormViewController {

    let userDefaults = UserDefaults.standard
    var tagFamily : String!
    var resolutioin: String!
    var tagSize : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let aplixURL:URL! = URL(string: "AplixURL".local)
        let contactURL:URL! = URL(string: "ContactURL".local)
        let apriltagURL:URL! = URL(string: "AprilTagURL".local)
        let downloadURL:URL! = URL(string: "DownloadURL".local)
        let eulaURL:URL! = URL(string: "EULAURL".local)
        
        // ローカルデータの読み込み
        loadSettings()
        
        // 設定画面の作成
        form
            // 画像ヘッダー
            +++ Section() { section in
                
                let header = HeaderFooterView<UIView>(
                    .callback({
                        
                        let width = Int(self.view.frame.width)
                        let height = 100
                        let rect = CGRect(x: 0, y: 0, width:width , height: height)
                        let view = UIView(frame:rect)
                        
                        let logo = UIImage(named: "Quanti")
                        let imageView = UIImageView(image:logo)
                        imageView.frame = rect
                        imageView.center = CGPoint(x:width/2, y:height/2)
                        imageView.contentMode = UIViewContentMode.scaleAspectFit
                        view.addSubview(imageView)
                        
                        return view
                    })
                )
                section.header = header
            }
            // 画像ヘッダー
            +++ Section(footer:"Usage".local) { section in
            
                let header = HeaderFooterView<UIView>(
                    .callback({
                        let width = Int(self.view.frame.width)
                        let height = 200
                        let rect = CGRect(x: 0, y: 0, width:width , height: height)
                        let view = UIView(frame:rect)

                        let logo = UIImage(named: "usage1-1")
                        let imageView = UIImageView(image:logo)
                        imageView.frame = rect
                        imageView.center = CGPoint(x:width/2, y:height/2)
                        imageView.contentMode = UIViewContentMode.scaleAspectFit
                        view.addSubview(imageView)
                        
                        return view
                    })
                )
                section.header = header
            }
            
            //
            +++ Section()
            <<< PushRow<String>() {
                // タグプリント画面
                $0.title = "TagPrint".local
                $0.selectorTitle = nil
                $0.options = nil
                $0.value = nil // 初期値
                $0.disabled = true
                $0.onCellSelection() {_,_ in
                    let url = downloadURL
                    self.openURLoutofApp(url: url!)
                }
            }
            
        // アプリの設定
        +++ Section(
            header:"AppSettings".local,
            footer:"ResolutionDetail".local
            )
        
        // 解像度
        <<< PushRow<String>() {
            
            //
            $0.title = "Resolution".local
            $0.value = self.resolutioin //initial value
            $0.options = ["High", "Medium"]
            $0.onChange { [unowned self] row in
                if let value = row.value {
                    self.resolutioin = value
                    self.userDefaults.set(self.resolutioin, forKey: "Resolution")
                }
            }
        }
        // タグファミリー
        +++ Section(
            footer:"TagFamilyDetail".local
        )
        <<< PushRow<String>() {
            
            $0.title = "TagFamily".local
            $0.value = tagFamily //initial value
            $0.options = ["36h11", "36h10"]
            $0.onChange { [unowned self] row in
                if let value = row.value {
                    self.tagFamily = value
                    self.userDefaults.set(self.tagFamily, forKey: "TagFamily")
                }
            }
        }
            
        // 距離表示の設定
        +++ Section(
            header:"DistanceHeader".local,
            footer:"DistanceDetail".local
        )
        <<< IntRow() {
            
            $0.title = "TagSize".local
            $0.value = tagSize
            $0.onChange { [unowned self] row in
                if let value = row.value {
                    self.tagSize = value
                    self.userDefaults.set(self.tagSize, forKey:"TagSize")
                } else {
                    row.value = self.tagSize
                }
            }
        }
        
        // 各種情報
        +++ Section(header: "Information".local, footer:"Quanti".local)
        
        <<< PushRow<String>() {
            // groma/AprilTag サイト
            $0.title = "WhatIsGroma".local
            $0.selectorTitle = nil
            $0.options = nil
            $0.value = nil // 初期値
            $0.disabled = true
            $0.onCellSelection() {_,_ in
                let url = apriltagURL
                self.openURLInApp(url: url!)
            }
        }
        +++ Section()
        <<< PushRow<String>() {
            // お問い合わせ
            $0.title = "FeedbackAndContact".local
            $0.selectorTitle = nil
            $0.options = nil
            $0.value = nil // 初期値
            $0.disabled = true
            $0.onCellSelection() {_,_ in
                let url = contactURL
                self.openURLInApp(url: url!)
            }
        }
            
        <<< PushRow<String>() {
            // 組み込み希望
            $0.title = "CloudAndEmbed".local
            $0.selectorTitle = nil
            $0.options = nil
            $0.value = nil // 初期値
            $0.disabled = true
            $0.onCellSelection() {_,_ in
                let url = contactURL  /* TODO: FAQに変更 */
                self.openURLInApp(url: url!)
            }
        }
            
        <<< TextRow(){
            // アプリのバージョン
            $0.title = "Version".local
            $0.value = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            $0.disabled = true
        }
        
        <<< TextRow(){
            // iOSの必須バージョン
            $0.title = "Requirements".local
            $0.value = "RequirementsValue".local
            $0.disabled = true
            
        }
    
        // 会社情報等
        +++ Section("Others".local)

        <<< TextRow() {
            
            $0.title = "CompanyName".local
            $0.value = "CompanyValue".local
            $0.disabled = true
        }
            
        <<< PushRow<String>() {
            // 会社Webサイト
            $0.title = "CompanySite".local
            $0.selectorTitle = nil
            $0.options = nil
            $0.value = nil // 初期値
            $0.disabled = true
            $0.onCellSelection() {_,_ in
                let url = aplixURL
                self.openURLInApp(url: url!)
            }
        }
            
        <<< PushRow<String>() {
            // EULA
            $0.title = "EULA".local
            $0.selectorTitle = nil
            $0.options = nil
            $0.value = nil // 初期値
            $0.disabled = true
            $0.onCellSelection() {_,_ in
                let url = eulaURL
                self.openURLInApp(url: url!)
            }
        }
    }
        

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openURLInApp(url:URL){
        
        let vc = SFSafariViewController(url: url)
        self.present(vc, animated: true, completion: nil)
    }
    
    func openURLoutofApp(url:URL){
        UIApplication.shared.open(url)
    }
    
    // ローカルデータの読み書き
    func loadSettings () {
        // データの読み込み
        tagFamily = userDefaults.string(forKey: "TagFamily")
        resolutioin = userDefaults.string(forKey: "Resolution")
        tagSize = userDefaults.integer(forKey: "TagSize")
        
    }
    
}
