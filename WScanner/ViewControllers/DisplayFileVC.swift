//
//  DisplayFileVC.swift
//  WScanner
//
//  Created by webtualApple on 27/01/21.
//

import UIKit
import WebKit

class DisplayFileVC: UIViewController, UIScrollViewDelegate {

    @IBOutlet var webkit : WKWebView!
    
    var fileName : String!
    var image : UIImage!
    
     var scrollView =  UIScrollView()
     var imageView = UIImageView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Display Files"
        self.navigationController?.navigationBar.backgroundColor = UIColor.systemBlue
        self.navigationController?.navigationBar.tintColor = UIColor.black
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if(self.fileName == nil){

            scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            scrollView.delegate = self
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 10.0
            self.view.addSubview(scrollView)
            
            imageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            scrollView.addSubview(imageView)
            
        }else{
            var pdfURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
            pdfURL = pdfURL.appendingPathComponent(fileName) as URL

            let url = pdfURL
            let request = URLRequest(url: url)
            self.webkit.load(request)
        }
    }

    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
