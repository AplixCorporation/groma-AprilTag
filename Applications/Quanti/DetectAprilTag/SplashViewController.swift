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

class SplashViewController: UIViewController {

    let userDefaults = UserDefaults.standard

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デフォルトの設定
        userDefaults.register(defaults: [
            "ShouldDisplayModal":true]
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let shouldDisplayModal = userDefaults.bool(forKey: "ShouldDisplayModal")
        
        if shouldDisplayModal == false {
            
            // 初回起動 以外
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "NavigationStart")
            present(nextView, animated: false, completion: nil)
            
        } else {
            
            // 初回起動
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "FirstModalView")
            present(nextView, animated: true, completion: nil)
            
            // 次回から起動しないように設定
            userDefaults.set(false, forKey: "ShouldDisplayModal")
        
        }
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
