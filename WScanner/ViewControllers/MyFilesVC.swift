//
//  MyFilesVC.swift
//  WScanner
//
//  Created by webtualApple on 23/01/21.
//

import UIKit
import SVProgressHUD


class MyFilesVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet var ClvMyDocs : UICollectionView!
    
    var ArrFileName = Array<Any>()
    @IBOutlet var lblNoPhotos : UILabel!
    
    var nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
    var nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "My Files"
        self.navigationController?.navigationBar.backgroundColor = UIColor.systemBlue
        self.navigationController?.navigationBar.tintColor = UIColor.black
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.GetFilesFromDocument()
        
        self.ClvMyDocs.delegate = self
        self.ClvMyDocs.dataSource = self
        
        lblNoPhotos.text = "No Record Found, Please Go Back & Scan Your Document"
        
        if(ArrFileName.count == 0){
            self.lblNoPhotos.isHidden = false
            self.ClvMyDocs.isHidden = true
        }else{
            self.lblNoPhotos.isHidden = true
            self.ClvMyDocs.isHidden = false
        }
        
        self.ClvMyDocs.reloadData()
        
    }
    

    //MARK:
    //MARK:- Get Downloaded File
    func GetFilesFromDocument(){
        //Get Files Name From Download Folder
        
        var theItems = [String]()
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)

        if let dirPath          = paths.first
        {
            let imageURL = URL(fileURLWithPath: dirPath)

            do {
                theItems = try FileManager.default.contentsOfDirectory(atPath: imageURL.path)
                
                print(imageURL.path)
                print(theItems)
                
                ArrFileName = theItems
                
                if(theItems.count != 0){
                    //For Get Image From Document
//                    let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(theItems[1])
//                    let image    = UIImage(contentsOfFile: imageURL.path)
                    
                    //For Get PDF Image from PDF File
    //                self.CropedImage.image = self.thumbnailFromPdf(withUrl: imageURL)
                }
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK:
    //MARK:-
    func removeImage(_ filename: String?, sender : Int) {
        let fileManager = FileManager.default
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)[0]

        let filePath = URL(fileURLWithPath: documentsPath).appendingPathComponent(filename ?? "").path
        var error: Error?
        var success = false
        do {
            try fileManager.removeItem(atPath: filePath)
            success = true
        } catch {
        }
        if success {
            
            ArrFileName.remove(at: sender)
            
            if(ArrFileName.count == 0){
                self.lblNoPhotos.isHidden = false
                self.ClvMyDocs.isHidden = true
            }else{
                self.lblNoPhotos.isHidden = true
                self.ClvMyDocs.isHidden = false
            }
            
            self.ClvMyDocs.reloadData()
        } else {
            print("Could not delete file -:\(error?.localizedDescription ?? "") ")
        }
    }
    
    //MARK:
    //MARK:- Collection Delegate & Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.ArrFileName.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyDocsCell", for: indexPath) as! MyDocsCell
        
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
       
        //For Add Shadow in Delete Button
        cell.viewShare.layer.cornerRadius = 15.0;
        cell.viewShare.layer.borderWidth = 1.0;
        cell.viewShare.layer.borderColor = UIColor.clear.cgColor
        cell.viewShare.layer.masksToBounds = true;

        cell.viewShare.layer.shadowColor = UIColor.gray.cgColor
        cell.viewShare.layer.shadowOffset = CGSize(width: 0, height: 2.0);
        cell.viewShare.layer.shadowRadius = 5.0;
        cell.viewShare.layer.shadowOpacity = 1.0;
        cell.viewShare.layer.masksToBounds = false;
        cell.viewShare.layer.shadowPath = UIBezierPath(roundedRect:cell.viewShare.bounds, cornerRadius:cell.viewShare.layer.cornerRadius).cgPath;
       
        
        cell.btnDelete.addTarget(self, action: #selector(self.btnDeleteTap), for: .touchUpInside)
        cell.btnDelete.tag = indexPath.row
        
        cell.btnShare.addTarget(self, action: #selector(self.btnShareTap), for: .touchUpInside)
        cell.btnShare.tag = indexPath.row
        
        //For Load Saved Files From Document
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath = paths.first
        {
            do {
                
                if(ArrFileName.count != 0){
                    //For Get Image From Document
                    let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(ArrFileName[indexPath.row] as! String)
                    let image    = UIImage(contentsOfFile: imageURL.path)
                    
                    if(image == nil){
                        cell.imgDocument.image = UIImage(named: "ic_pdf.png")
                    }else{
                        cell.imgDocument.image = image
                    }
                    
                    
                    //For Get PDF Image from PDF File
                    //self.CropedImage.image = self.thumbnailFromPdf(withUrl: imageURL)
                }
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        cell.lblFileName.text = self.ArrFileName[indexPath.row] as? String
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(self.ArrFileName[indexPath.row])
        
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "DisplayFileVC") as! DisplayFileVC
        VC.fileName = "\(self.ArrFileName[indexPath.row])"
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let column : CGFloat = 2.0;
        var totalWidth = collectionView.bounds.size.width-flowLayout.sectionInset.left-flowLayout.sectionInset.right;
        
        totalWidth = totalWidth - (column-1) * flowLayout.minimumInteritemSpacing
        
        return CGSize(width: totalWidth/column, height: totalWidth/column)
    }
    
    //MARK:
    //MARK:- Action Methods
    @objc func btnDeleteTap(_ sender : UIButton){
        print(sender.tag)
        
        self.removeImage(self.ArrFileName[sender.tag] as? String, sender: sender.tag)
        
    }
    
    @objc func btnShareTap(_ sender : UIButton){
        print(sender.tag)
        
        var pdfURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
        pdfURL = pdfURL.appendingPathComponent(self.ArrFileName[sender.tag] as! String) as URL

        let data = try! Data(contentsOf: pdfURL)
        let activityVC = UIActivityViewController(activityItems: [data as Any], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    
}
