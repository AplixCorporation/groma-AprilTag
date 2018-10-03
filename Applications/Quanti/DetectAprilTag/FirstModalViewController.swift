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
        
        modalTextField.text = "Description".local
    }

    // OKボタンが押されたらViewControllerに移動
    @IBAction func goToMain(_ sender: Any) {
        
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "NavigationStart")
        present(nextView, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
