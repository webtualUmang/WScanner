//
//  HomeVC.swift
//  WScanner
//
//  Created by webtualApple on 23/01/21.
//

import UIKit
import WeScan
import SVProgressHUD
import PDFKit


class HomeVC: UIViewController, ImageScannerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet var ClvPhotos : UICollectionView!
    @IBOutlet var lblNoPhotos : UILabel!

    var ArrImages: [UIImage] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Home"
        self.navigationController?.navigationBar.backgroundColor = UIColor.systemBlue
        self.navigationController?.navigationBar.tintColor = UIColor.black
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(btnAddTap))
        let download = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(btnDownloadTap))
        
        let files = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(btnMyFilesTap))

        add.tintColor = UIColor.black
        files.tintColor = UIColor.black

        navigationItem.rightBarButtonItems = [add, download]
        
        navigationItem.leftBarButtonItems = [files]
        
        self.ClvPhotos.delegate = self
        self.ClvPhotos.dataSource = self
        
        lblNoPhotos.text = "Tap + to add or scan documents"
        
        if(ArrImages.count == 0){
            self.lblNoPhotos.isHidden = false
            self.ClvPhotos.isHidden = true
        }else{
            self.lblNoPhotos.isHidden = true
            self.ClvPhotos.isHidden = false
        }
        
        self.ClvPhotos.reloadData()
    }
    
    //MARK:
    //MARK:- Helper Methods
    
    //Use For Single Image Convert to PDF
    func createPDFDataFromImage(image: UIImage) -> NSMutableData {
        
        
        let pdfData = NSMutableData()
        let imgView = UIImageView.init(image: image)
        let imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        UIGraphicsBeginPDFContextToData(pdfData, imageRect, nil)
        UIGraphicsBeginPDFPage()
        let context = UIGraphicsGetCurrentContext()
        imgView.layer.render(in: context!)
        UIGraphicsEndPDFContext()

        // For Download image in Document Directory
//        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
//        let path = dir?.appendingPathComponent("Document.pdf")
//        print(path as Any)
//
//        do {
//            try pdfData.write(to: path!, options: NSData.WritingOptions.atomic)
//        } catch {
//            print("error catched")
//        }
        
        // Return PDF Data
        return pdfData
    
    }

    func createPdf(withName name: String?, array images: [UIImage]) -> NSData? {
        SVProgressHUD.show()
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil)
        for image in images {
            let imgView = UIImageView.init(image: image)
            imgView.frame = CGRect(x: 0, y: 0, width: 595, height: 842)
            imgView.contentMode = .scaleAspectFit
            UIGraphicsBeginPDFPageWithInfo(imgView.bounds, nil)
            let context = UIGraphicsGetCurrentContext()
            imgView.layer.render(in: context!)
        }
        UIGraphicsEndPDFContext()
        
        SVProgressHUD.dismiss()
        return pdfData
    }
    
    //Use For Multiple image Convert to PDF
    func createPDFS(arrImages: [UIImage]) -> NSData? {

        SVProgressHUD.show()
        
        
        
        var pageHeight = 0.0
        var pageWidth = 0.0

        for img in arrImages
        {
            pageHeight =  pageHeight+Double(img.size.height)

            if Double(img.size.width) > pageWidth
            {
                pageWidth = Double(img.size.width)
            }
        }

        
        let pdfData = NSMutableData()
        let pdfConsumer = CGDataConsumer(data: pdfData as CFMutableData)!
        
        var mediaBox = CGRect.init(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaBox, nil)!
        
        for img in arrImages
        {
            var mediaBox2 = CGRect.init(x: 0, y: 0, width: img.size.width, height: img.size.height)

            pdfContext.beginPage(mediaBox: &mediaBox2)
            pdfContext.draw(img.cgImage!, in: CGRect.init(x: 0.0, y: 0, width: pageWidth, height: Double(img.size.height)))

            pdfContext.endPage()
        }

        SVProgressHUD.dismiss()
        
        return pdfData
    }
    
    func StoreImageInDocument(){
        
        
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let result = formatter.string(from: date)
        print("File Name"+result)
        
        let alertController = UIAlertController(title: "Enter File Name", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter File Name*"
            textField.text = "Document \(result)"
        }
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let FileName = alertController.textFields![0] as UITextField
            print(FileName.text! as Any)
            
            if(FileName.text! == ""){
                
            }else{
                SVProgressHUD.show()
                
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    var i = 1
                    for img in self.ArrImages{
                        
                        let path = dir.appendingPathComponent(FileName.text!+"(\(i)).png")
                        
                        let Image = img.pngData()
                        print(path as Any)

                        do {
                            i = i + 1
                            try Image!.write(to: path, options: NSData.WritingOptions.atomic)
                        } catch {
                            print("error catched")
                        }
                    }
                    
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        
                        let VC = self.storyboard?.instantiateViewController(withIdentifier: "MyFilesVC") as! MyFilesVC
                        self.navigationController?.pushViewController(VC, animated: true)

                    }
                }
                
            }
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
                (action : UIAlertAction!) -> Void in })
            
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
            
        self.present(alertController, animated: true, completion: nil)
       
    }
    
    func StorePDFInDocument(){
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let result = formatter.string(from: date)
        print("File Name"+result)
        
        let alertController = UIAlertController(title: "Enter File Name", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter File Name*"
            textField.text = "Document \(result)"
        }
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let FileName = alertController.textFields![0] as UITextField
            print(FileName.text! as Any)
            
            if(FileName.text! == ""){
                
            }else{
                SVProgressHUD.show()
                    
                let PDF = self.createPdf(withName: FileName.text!, array: self.ArrImages)
                
//                    let PDF = self.createPDFS(arrImages: self.ArrImages)
                let pdfData = PDF
                
                let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let path = dir.appendingPathComponent(FileName.text!+".pdf")
                do {
                    try pdfData!.write(to: path, options: NSData.WritingOptions.atomic)
                } catch {
                    print("error catched")
                }
                
                SVProgressHUD.dismiss()
                
                let VC = self.storyboard?.instantiateViewController(withIdentifier: "MyFilesVC") as! MyFilesVC
                self.navigationController?.pushViewController(VC, animated: true)
                                
                // For Open Share Controller
//                    let activityVC = UIActivityViewController(activityItems: [pdfData as Any], applicationActivities: nil)
//                    self.present(activityVC, animated: true, completion: nil)
            }
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
                (action : UIAlertAction!) -> Void in })
            
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
            
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK:
    //MARK:-Open Scanner Methods
    func scanImage() {
        let scannerViewController = ImageScannerController(delegate: self)
        scannerViewController.modalPresentationStyle = .fullScreen
    
        if #available(iOS 13.0, *) {
            scannerViewController.navigationBar.tintColor = .label
        } else {
            scannerViewController.navigationBar.tintColor = .black
        }
        
        self.present(scannerViewController, animated: true)
    }
    
    func selectImage() {
        
        SVProgressHUD.show()
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    //MARK:
    //MARK:- Collection Delegate & Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.ArrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosCell", for: indexPath) as! PhotosCell
        
        //For Add Shadow in Cell
        cell.contentView.layer.cornerRadius = 5.0;
        cell.contentView.layer.borderWidth = 1.0;
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true;

        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0);
        cell.layer.shadowRadius = 5.0;
        cell.layer.shadowOpacity = 1.0;
        cell.layer.masksToBounds = false;
        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath;
        
        //For Add Shadow in Delete Button
        cell.viewDelete.layer.cornerRadius = 15.0;
        cell.viewDelete.layer.borderWidth = 1.0;
        cell.viewDelete.layer.borderColor = UIColor.clear.cgColor
        cell.viewDelete.layer.masksToBounds = true;

        cell.viewDelete.layer.shadowColor = UIColor.gray.cgColor
        cell.viewDelete.layer.shadowOffset = CGSize(width: 0, height: 2.0);
        cell.viewDelete.layer.shadowRadius = 5.0;
        cell.viewDelete.layer.shadowOpacity = 1.0;
        cell.viewDelete.layer.masksToBounds = false;
        cell.viewDelete.layer.shadowPath = UIBezierPath(roundedRect:cell.viewDelete.bounds, cornerRadius:cell.viewDelete.layer.cornerRadius).cgPath;
        
        cell.imgDocument.image = ArrImages[indexPath.row]
        cell.imgDocument.layer.cornerRadius = 5.0
        
        cell.btnDelete.addTarget(self, action: #selector(self.btnDeleteTap), for: .touchUpInside)
        cell.btnDelete.tag = indexPath.row
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "DisplayFileVC") as! DisplayFileVC
        VC.image = self.ArrImages[indexPath.row]
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let column : CGFloat = 2.0;
        var totalWidth = collectionView.bounds.size.width-flowLayout.sectionInset.left-flowLayout.sectionInset.right;
        
        totalWidth = totalWidth - (column-1) * flowLayout.minimumInteritemSpacing
        
        return CGSize(width: totalWidth/column, height: totalWidth/column)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    }
    
    //MARK:
    //MARK:- Scanner Delegate
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        // You are responsible for carefully handling the error
        
        
        print(error)
    }

    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        // The user successfully scanned an image, which is available in the ImageScannerResults
        // You are responsible for dismissing the ImageScannerController
        
        SVProgressHUD.dismiss()
        
        let data = results
        
        let img = results.croppedScan.image
        print(data)
        
        //Add Image to Array
        ArrImages.append(img)
        
        if(ArrImages.count == 0){
            self.lblNoPhotos.isHidden = false
            self.ClvPhotos.isHidden = true
        }else{
            self.lblNoPhotos.isHidden = true
            self.ClvPhotos.isHidden = false
        }
        self.ClvPhotos.reloadData()
        
        scanner.dismiss(animated: true)
        
    }

    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        // The user tapped 'Cancel' on the scanner
        // You are responsible for dismissing the ImageScannerController
        
        scanner.dismiss(animated: true)
    }
    
    //MARK:
    //MARK:- Image Picker Delegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        SVProgressHUD.dismiss()
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        
        SVProgressHUD.dismiss()
        
        guard let image = info[.originalImage] as? UIImage else { return }
        let scannerViewController = ImageScannerController(image: image, delegate: self)
        present(scannerViewController, animated: true)
    }
    
    
    //MARK:
    //MARK:- Action Methods
    
    @objc func btnAddTap(_ sender : UIButton){
        
        var alertStyle = UIAlertController.Style.actionSheet
        if (UIDevice.current.userInterfaceIdiom == .pad) {
          alertStyle = UIAlertController.Style.alert
        }else{
            alertStyle = UIAlertController.Style.actionSheet
        }
        
        let actionSheet = UIAlertController(title: "Would you like to scan an image or select one from your photo library?", message: nil, preferredStyle: alertStyle)
        
       
        let scanAction = UIAlertAction(title: "Scan", style: .default) { (_) in
            self.scanImage()
        }
        
        let selectAction = UIAlertAction(title: "Select", style: .default) { (_) in
            self.selectImage()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(scanAction)
        actionSheet.addAction(selectAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true)
    }
    
    @objc func btnMyFilesTap(_ sender : UIButton){
        
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "MyFilesVC") as! MyFilesVC
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @objc func btnDownloadTap(_ sender : UIButton){
        
        if(self.ArrImages.count == 0){
            
            let alertController = UIAlertController(title: "Alert", message: "Please Scan your Document First", preferredStyle: UIAlertController.Style.alert)
            
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
        }else{
        
            var alertStyle = UIAlertController.Style.actionSheet
            if (UIDevice.current.userInterfaceIdiom == .pad) {
              alertStyle = UIAlertController.Style.alert
            }else{
                alertStyle = UIAlertController.Style.actionSheet
            }
            
            let actionSheet = UIAlertController(title: "Select Your Suitable Option for Download Document", message: nil, preferredStyle: alertStyle)
            
            let scanAction = UIAlertAction(title: "Image", style: .default) { (_) in
                
                self.StoreImageInDocument()
            }
            
            let selectAction = UIAlertAction(title: "PDF File", style: .default) { (_) in
                
                self.StorePDFInDocument()

            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            actionSheet.addAction(scanAction)
            actionSheet.addAction(selectAction)
            actionSheet.addAction(cancelAction)
            
            present(actionSheet, animated: true)
        }
    }
    
    
    @objc func btnDeleteTap(_ sender : UIButton){
        print(sender.tag)
        
        ArrImages.remove(at: sender.tag)
        
        if(ArrImages.count == 0){
            self.lblNoPhotos.isHidden = false
            self.ClvPhotos.isHidden = true
        }else{
            self.lblNoPhotos.isHidden = true
            self.ClvPhotos.isHidden = false
        }
        
        self.ClvPhotos.reloadData()
    }
}
