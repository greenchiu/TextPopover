//
//  ViewController.swift
//  TextPopover
//
//  Created by GreenChiu on 2019/1/2.
//  Copyright © 2019 Green. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var passthroughViews: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.black
        
        let rightButton = UIButton(type: .system)
        rightButton.setTitle("Right", for: .normal)
        rightButton.addTarget(self, action: #selector(rightButtonHandler(_:)), for: .touchUpInside)
        rightButton.sizeToFit()
        rightButton.center = view.center
        rightButton.center.x += 180
        rightButton.center.y -= 230
        view.addSubview(rightButton)
        
        let upButton = UIButton(type: .system)
        upButton.setTitle("Up", for: .normal)
        upButton.addTarget(self, action: #selector(upButtonHandler(_:)), for: .touchUpInside)
        upButton.sizeToFit()
        upButton.center = view.center
        upButton.center.x = 60
        view.addSubview(upButton)
        
        let downButton = UIButton(type: .system)
        downButton.setTitle("Down", for: .normal)
        downButton.addTarget(self, action: #selector(downButtonHandler(_:)), for: .touchUpInside)
        downButton.sizeToFit()
        downButton.center = view.center
        downButton.center.x += 180
        downButton.center.y += 230
        view.addSubview(downButton)
        
        passthroughViews = [rightButton, upButton, downButton]
    }

    func displayPopover( message: String, arrow: TextPopoverArrowDirection, sourceRect: CGRect, width: CGFloat = 120) -> Void {
        let popover = TextPopover(withMessage: message)
        popover.preferredWidth = width
//        popover.passthroughViews = passthroughViews
        popover.show(inView: view, sourceRect: sourceRect, preferredArrow: arrow)
    }
    
    @objc func upButtonHandler(_ button: UIButton ) -> Void {
        displayPopover(message: "Uuuuuppppppppppppppp~", arrow: .up, sourceRect: button.frame, width: 220)
    }

    @objc func downButtonHandler(_ button: UIButton ) -> Void {
        displayPopover(message: "Dddddddddddddddddddddddddddd~", arrow: .down, sourceRect: button.frame)
    }
    
    @objc func rightButtonHandler(_ button: UIButton ) -> Void {
        displayPopover(message: "Rrrrrrrrrrrrrrrrrrr~", arrow: .right, sourceRect: button.frame, width: 320)
    }
}

