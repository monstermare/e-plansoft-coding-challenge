//
//  ViewController.swift
//  e-plansoft-interview
//
//  Created by TaeYoun Kim on 10/2/19.
//  Copyright © 2019 TaeYoun Kim. All rights reserved.
//

import UIKit
import PDFKit
import MobileCoreServices

class ViewController: UIViewController {
    
    let SCREEN_MAXHEIGHT = UIScreen.main.bounds.height
    let SCREEN_MAXWIDTH = UIScreen.main.bounds.width

    var safeArea = false
    
    var pdfView = PDFView()
    var touchView = UIView()
    var loadBtn = UIButton()
    var saveBtn = UIButton()
    var drawRec = UIButton()
    var undoBtn = UIButton()
    
    var start_x: CGFloat = 0
    var start_y: CGFloat = 0
    var end_x: CGFloat = UIScreen.main.bounds.width
    var end_y: CGFloat = UIScreen.main.bounds.height
    
    var touch_start: CGPoint = CGPoint(x: 0, y: 0)
    var touch_end: CGPoint = CGPoint(x: 0, y: 0)
    
    var stack: [(PDFAnnotation,PDFPage)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(pdfView)
        self.view.addSubview(touchView)
        self.view.addSubview(loadBtn)
        self.view.addSubview(saveBtn)
        self.view.addSubview(drawRec)
        self.view.addSubview(undoBtn)
        
        //init pdfView setting
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(true)
        pdfView.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pdfView.autoScales = true
        pdfView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(!safeArea){initSafe(view.safeAreaInsets)}
    }
    
    @objc func loadBtnClicked(_ sender: UIButton){
        // using documentPicker, it reads local PDF files
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        self.present(documentPicker,animated: true, completion: nil)
    }
    
    @objc func saveBtnClicked(_ sender: UIButton){
        // save button is saving current pdf file to final.pdf file.
        
        // This uses activityViewController gives more options for save
        //guard let data = pdfView.document?.dataRepresentation() else { return }
        //let activityController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        //self.present(activityController, animated: true, completion: nil)
        let file = "final.pdf"
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = pdfView.document?.dataRepresentation() else { return }
        let fileURL = dir.appendingPathComponent(file)
        do {
            try data.write(to: fileURL)
        }catch{
            print(error.localizedDescription)
        }
    }
    
    @objc func drawBtnClicked(_ sender: UIButton){
        // once draw button is clicked, touchview enabled and button background becomes gray
        touchView.isHidden = false
        sender.backgroundColor = .gray
    }
    
    @objc func undoBtnClicked(_ sender: UIButton){
        // perform undo by popping stack
        if let pop = stack.popLast(){
            let annotation = pop.0
            let page = pop.1
            page.removeAnnotation(annotation)
        }
    }
    
    @objc func getRecSize(_ sender: UIPanGestureRecognizer){
        // this uses UIPanGesture to gain touched area.
        // For more precise point, we may use custom gesture inherited from UIPangesture
        let translation = sender.translation(in: sender.view)
        if(sender.state == .began){
            touch_start = sender.location(in: sender.view)
        }else if(sender.state == .ended){
            touch_end = CGPoint(x: touch_start.x+translation.x, y: touch_start.y+translation.y)
            touchView.isHidden = true
            drawRec.backgroundColor = .black
            drawBox()
        }
    }
    
    func drawBox(){
        // drawing box with given data
        guard let page = pdfView.currentPage else {return}
        let sp = pdfView.convert(touch_start, to: page)
        let ep = pdfView.convert(touch_end, to: page)
        let path = UIBezierPath(rect: CGRect(x: sp.x, y: sp.y, width: ep.x-sp.x, height: ep.y-sp.y))
        let inkAnnotation = PDFAnnotation(bounds: page.bounds(for: pdfView.displayBox), forType: .ink, withProperties: nil)
        inkAnnotation.add(path)
        inkAnnotation.color = .red
        page.addAnnotation(inkAnnotation)
        stack.append((inkAnnotation,page))
    }
    
    func initSafe(_ view: UIEdgeInsets){
        // initialize safe area
        start_x = view.left
        start_y = view.top
        end_x = SCREEN_MAXWIDTH - view.right
        end_y = SCREEN_MAXHEIGHT - view.bottom
        safeArea = true
        initView()
        loadPDF()
    }
    
    func loadPDF(){
        // load sample pdf for first time use
        let fileURL = Bundle.main.url(forResource: "sample", withExtension: "pdf")!
        let pdfDocument = PDFDocument(url: fileURL)
        pdfView.document = pdfDocument
    }
    
    func initView(){
        // initialize buttons and views
        let seg_y = end_y*0.9
        let seg_x = end_x/4
        pdfView.frame = CGRect(x: start_x, y: start_y, width: end_x, height: seg_y)
        touchView.frame = pdfView.frame
        let pgr = UIPanGestureRecognizer(target: self, action: #selector(getRecSize))
        touchView.addGestureRecognizer(pgr)
        touchView.isHidden = true
        
        loadBtn.frame = CGRect(x: start_x, y: seg_y, width: seg_x, height: end_y-seg_y)
        loadBtn.setTitle("Load", for: .normal)
        loadBtn.setTitleColor(.white, for: .normal)
        loadBtn.backgroundColor = .black
        loadBtn.addTarget(self, action: #selector(loadBtnClicked), for: .touchUpInside)
        
        saveBtn.frame = CGRect(x: start_x+seg_x, y: seg_y, width: seg_x, height: end_y-seg_y)
        saveBtn.setTitle("Save", for: .normal)
        saveBtn.setTitleColor(.white, for: .normal)
        saveBtn.backgroundColor = .black
        saveBtn.addTarget(self, action: #selector(saveBtnClicked), for: .touchUpInside)
        
        drawRec.frame = CGRect(x: start_x+(seg_x*2), y: seg_y, width: seg_x, height: end_y-seg_y)
        drawRec.setTitle("Draw", for: .normal)
        drawRec.setTitleColor(.white, for: .normal)
        drawRec.backgroundColor = .black
        drawRec.addTarget(self, action: #selector(drawBtnClicked), for: .touchUpInside)
        
        undoBtn.frame = CGRect(x: start_x+(seg_x*3), y: seg_y, width: seg_x, height: end_y-seg_y)
        undoBtn.setTitle("Undo", for: .normal)
        undoBtn.setTitleColor(.white, for: .normal)
        undoBtn.backgroundColor = .black
        undoBtn.addTarget(self, action: #selector(undoBtnClicked), for: .touchUpInside)
    }


}

extension ViewController: UIDocumentPickerDelegate {
    // this reads file when documentpicker picks file, and replace current pdf file to the file newly selected
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]){
        guard let selectedFileURL = urls.first else { return }
        let pdfDocument = PDFDocument(url: selectedFileURL)
        pdfView.document = pdfDocument
        stack = []
    }
}
