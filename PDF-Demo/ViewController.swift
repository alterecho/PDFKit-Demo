//
//  ViewController.swift
//
//  Created by Max on 10/31/17.
//  Copyright (c) 2017 Max. All rights reserved.
//

import UIKit
import PDFKit
import MessageUI
class ViewController: UIViewController , MFMailComposeViewControllerDelegate{
    var pdfdocument: PDFDocument?
    
    var pdfview: PDFView!
    var pdfthumbView: PDFThumbnailView!
    let toolView = ToolView.instanceFromNib()
    
    var drawView : DrawingView!
    var testDrawingView: TestDrawingView!
    weak var observe : NSObjectProtocol?
    
    var doneButton : UIButton!
    var clearButton : UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        toolView.frame = CGRect(x: 10, y: view.frame.height - 50, width: self.view.frame.width - 20, height: 40)
        
        pdfview = PDFView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        
        let url = Bundle.main.url(forResource: "pdf-sample", withExtension: "pdf")
        pdfdocument = PDFDocument(url: url!)
        
        pdfview.document = pdfdocument
        pdfview.displayMode = PDFDisplayMode.singlePageContinuous
        pdfview.autoScales = true
        
        self.view.addSubview(pdfview)
        
        self.view.addSubview(toolView)
        toolView.bringSubview(toFront: self.view)
        
        toolView.editBtn.addTarget(self, action: #selector(editBtnClick), for: .touchUpInside)
        toolView.thumbBtn.addTarget(self, action: #selector(saveBtnClick), for: .touchUpInside)
        
        drawView = DrawingView()
        testDrawingView = TestDrawingView()
        drawView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width , height: view.frame.height)
        testDrawingView.frame = drawView.frame
        drawView.backgroundColor = UIColor.clear
        self.view.addSubview(drawView)
//        self.view.addSubview(testDrawingView)
//        drawView.bringSubview(toFront: self.view)
        drawView.delegate = self
        drawView.pdfview = self.pdfview
        
        doneButton = UIButton(frame: CGRect(x: self.view.frame.width - 100, y: 20, width: 80 , height: 40))
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(doneBtnClick(_:)), for: .touchUpInside)
        doneButton.setTitleColor(UIColor.black, for: .normal)
        doneButton.layer.cornerRadius = 4
        doneButton.layer.borderWidth = 1
        doneButton.layer.borderColor = UIColor.black.cgColor
        doneButton.backgroundColor = UIColor.white
        doneButton.clipsToBounds = true
        self.view.addSubview(doneButton)
        doneButton.bringSubview(toFront: self.view)
        doneButton.isHidden = true
        
        clearButton = UIButton(frame: CGRect(x: 20.0, y: 20, width: 80 , height: 40))
        clearButton.setTitle("Clear", for: .normal)
        clearButton.addTarget(self, action: #selector(clearBtnClick(_:)), for: .touchUpInside)
        clearButton.setTitleColor(UIColor.black, for: .normal)
        clearButton.layer.cornerRadius = 4
        clearButton.layer.borderWidth = 1
        clearButton.layer.borderColor = UIColor.black.cgColor
        clearButton.backgroundColor = UIColor.white
        clearButton.clipsToBounds = true
        self.view.addSubview(clearButton)
        clearButton.bringSubview(toFront: self.view)
        clearButton.isHidden = true
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        view.addGestureRecognizer(tapgesture)
        drawView.isHidden = true
    }
    
    @objc func tapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        UIView.animate(withDuration: CATransaction.animationDuration()) { [weak self] in
            self?.toolView.alpha = 1 - (self?.toolView.alpha)!
        }
    }
    
    @IBAction func clearBtnClick(_ sender: Any) {
        drawView.clear()
        pdfview.document?.page(at: 0)?.annotations.forEach {(annotation) in
            pdfdocument?.page(at: 0)?.removeAnnotation(annotation)
        }
    }
    
    @IBAction func doneBtnClick(_ sender: Any) {
        drawView.isHidden = true
        doneButton.isHidden = true
        clearButton.isHidden = true
        
        for subview in self.pdfview.subviews {
            
            if let item = subview as? UIScrollView
            {
                item.isScrollEnabled = true
            }
            
        }
        
    }
    
    @objc func editBtnClick(sender: UIButton) {
        drawView.isHidden = false
        self.pdfview.documentView!.bringSubview(toFront: drawView)

        for subview in self.pdfview.subviews {
            
            if let item = subview as? UIScrollView
            {
                item.isScrollEnabled = false
            }
            
        }

        drawView.frame = CGRect(x: 4 , y: -4 , width: (pdfview.documentView?.frame.size.width)!  / pdfview.scaleFactor , height: (pdfview.documentView?.frame.size.height)!  / pdfview.scaleFactor)
        testDrawingView.frame = drawView.frame
        drawView.lineWidth = (pdfview?.documentView?.frame.width)! / UIScreen.main.bounds.width
//      
//        drawView.backgroundColor = UIColor.red
//        drawView.alpha = 0.5
        clearButton.isHidden = false
        doneButton.isHidden = false
    }
    @objc func saveBtnClick(sender: UIButton) {
      
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }
        guard let writePath = NSURL(fileURLWithPath: path).appendingPathComponent("pdf") else { return }
        try? FileManager.default.createDirectory(atPath: writePath.path, withIntermediateDirectories: true)
        
        let filename = randomString(length: 6) + ".pdf"
        let file1 = writePath.appendingPathComponent(filename)
        
        pdfdocument?.write(to: file1)
        if( MFMailComposeViewController.canSendMail() ) {
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            //Set the subject and message of the email
            mailComposer.setSubject("Have you heard a swift?")
            mailComposer.setMessageBody("This is what they sound like.", isHTML: false)
            
            
            if let fileData = NSData(contentsOfFile: file1.path) {
                
                mailComposer.addAttachmentData(fileData as Data, mimeType: "application/pdf", fileName: "annotation")
            }
            
            self.present(mailComposer, animated: true, completion: nil)
        }
        
    }
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("**** didReceiveMemoryWarning ****")
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ViewController : DrawingViewDelegate {
    func didEndDrawLine(bezierPath: UIBezierPath) {
        let cloneBezierPath = UIBezierPath(cgPath: bezierPath.cgPath)
        
//        cloneBezierPath.apply(CGAffineTransform(scaleX: 1.0 / pdfview.scaleFactor, y: 1.0 / pdfview.scaleFactor))
//
//        // Create two transforms, one to mirror across the x axis, and one to
//        // to translate the resulting path back into the desired boundingRect
//        //this rect should be the bounds of your path within its superviews
//        //coordinate system
        let rect1 = cloneBezierPath.bounds
//        //first, you need to move the view all the way to the left
//        //because otherwise, if you mirror it in its current position,
//        //the view will be thrown way off screen to the left
        cloneBezierPath.apply(CGAffineTransform (translationX: 0, y: -rect1.origin.y))
//        //then you mirror it
        cloneBezierPath.apply(CGAffineTransform(scaleX: 1, y: -1))
//        //then, after its mirrored, move it back to its original position
        print(pdfview.documentView?.frame)
        print(pdfview.documentView?.bounds)
        print(pdfview.currentPage?.bounds(for: .cropBox))
        
//        print(pdfview.currentPage?.bounds(for: .trimBox))
        cloneBezierPath.apply(CGAffineTransform(translationX: 0, y: (pdfview.documentView?.bounds.height)! - (rect1.origin.y)))
//
//        let pathRect = CGRect(
//            origin: CGPoint(x: cloneBezierPath.bounds.origin.x, y: cloneBezierPath.bounds.origin.y - cloneBezierPath.bounds.size.height),
//            size: cloneBezierPath.bounds.size
//        )
//
        
        let rect = CGRect(x: 0, y: 0, width: (pdfview.documentView?.bounds.width)!, height: (pdfview.documentView?.bounds.height)!)
        let annotation = PDFAnnotation(bounds: rect, forType: .ink, withProperties: nil)
        annotation.backgroundColor = .blue

        annotation.add(cloneBezierPath)

        pdfview.document?.page(at: 0)?.addAnnotation(annotation)
        
        
    
    }
    
}
