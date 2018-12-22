//
//  TestViewController.swift
//  PDF-Demo
//
//  Created by echo on 21/12/18.
//  Copyright © 2018 com.tzshlyt.demo. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    var drawingView: DrawingView!
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        drawingView = DrawingView()
        drawingView.backgroundColor = UIColor.purple.withAlphaComponent(0.5)
        view.addSubview(drawingView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        drawingView.frame = view.bounds
        
    }
    
    

    
}
