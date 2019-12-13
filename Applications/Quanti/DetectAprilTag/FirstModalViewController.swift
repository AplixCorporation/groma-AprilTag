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

class FirstModalViewController: UIViewController {

    @IBOutlet weak var modalTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalTextField.backgroundColor = UIColor.white
        modalTextField.text = "Description".local
        modalTextField.textColor = UIColor.black
        
        // 次回から起動しないように設定
        UserDefaults.standard.set(false, forKey: "ShouldDisplayModal")
    }

    // OKボタンが押されたらViewControllerに移動
    @IBAction func goToMain(_ sender: Any) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "NavigationStart") as! UINavigationController
        nextVC.modalPresentationStyle = .fullScreen
        nextVC.modalTransitionStyle = .crossDissolve
        self.present(nextVC, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
