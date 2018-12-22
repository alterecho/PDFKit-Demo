//
//  DrawingView.swift
//
//  Created by Max on 10/31/17.
//  Copyright (c) 2017 Max. All rights reserved.
//

import UIKit
import PDFKit
protocol DrawingViewDelegate: class {
    func didEndDrawLine(bezierPath: UIBezierPath)
}

class DrawingView: UIView {
	
	var drawColor = UIColor.black
    var lineWidth: CGFloat = 1 {
        didSet {
            bezierPath.lineWidth = lineWidth
            pdfDocPath.lineWidth = lineWidth
        }
    }
	weak var delegate: DrawingViewDelegate?
	private var lastPoint: CGPoint!
	private var bezierPath: UIBezierPath!
    private var pdfDocPath: UIBezierPath!
	private var pointCounter: Int = 0
	private let pointLimit: Int = 128
	private var preRenderImage: UIImage!
	var pdfview : PDFView?
	// MARK: - Initialization
	
	override init(frame: CGRect) {
		super.init(frame: frame)
        
		initBezierPath()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		initBezierPath()
	}
	
	func initBezierPath() {
		bezierPath = UIBezierPath()
		bezierPath.lineCapStyle = CGLineCap.round
		bezierPath.lineJoinStyle = CGLineJoin.round
        
        pdfDocPath = UIBezierPath()
        pdfDocPath.lineCapStyle = CGLineCap.round
        pdfDocPath.lineJoinStyle = CGLineJoin.round
	}
	
	// MARK: - Touch handling
    
    var scaleFactor = 1.0 as CGFloat
    
    private func scaled(point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x * scaleFactor, y: point.y * scaleFactor)
    }
    
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        scaleFactor = pdfview?.scaleFactor ?? 1.0
		let touch: AnyObject? = touches.first
		lastPoint = touch!.location(in: self)
		pointCounter = 0
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
		let touch: AnyObject? = touches.first
        
		let newPoint = touch!.location(in: self)
        bezierPath.move(to: lastPoint)
        bezierPath.addLine(to: newPoint)
        pdfDocPath.move(to: self.convert(lastPoint, to: pdfview?.documentView))
        pdfDocPath.addLine(to: self.convert(newPoint, to: pdfview?.documentView))
        
		lastPoint = newPoint
		
		pointCounter += 1
		
		if pointCounter == pointLimit {
			pointCounter = 0
			renderToImage()
			setNeedsDisplay()
			bezierPath.removeAllPoints()
		}
		else {
			setNeedsDisplay()
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
		pointCounter = 0
		renderToImage()
		setNeedsDisplay()
        delegate?.didEndDrawLine(bezierPath: pdfDocPath)
		clear()
	}
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }
	
	// MARK: - Pre render
	
	func renderToImage() {
		
		UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
		if preRenderImage != nil {
			preRenderImage.draw(in: self.bounds)
		}
		
		
		drawColor.setFill()
		drawColor.setStroke()
		bezierPath.stroke()
		
		preRenderImage = UIGraphicsGetImageFromCurrentImageContext()
		
		UIGraphicsEndImageContext()
	}
	
	// MARK: - Render
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		
		if preRenderImage != nil {
			preRenderImage.draw(in: self.bounds)
		}
		
		drawColor.setFill()
		drawColor.setStroke()
		bezierPath.stroke()
	}

	// MARK: - Clearing
	
	func clear() {
		preRenderImage = nil
		bezierPath.removeAllPoints()
        pdfDocPath.removeAllPoints()
		setNeedsDisplay()
	}
	
	// MARK: - Other

	func hasLines() -> Bool {
		return preRenderImage != nil || !bezierPath.isEmpty
	}

}
