//
//  BaseViewController.swift
//  Tour de World
//
//  Created by taralika on 3/23/20.
//  Copyright © 2020 at. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController
{
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        activityIndicator = UIActivityIndicatorView (style: UIActivityIndicatorView.Style.gray)
        self.view.addSubview(activityIndicator)
        activityIndicator.bringSubviewToFront(self.view)
        activityIndicator.center = self.view.center
    }

    func showActivityIndicator()
    {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator()
    {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    func showAlert(message: String, title: String, error: Error? = nil)
    {
        DispatchQueue.main.async
        {
            var message = message
            var title = title
            
            if error != nil && ((error! as NSError).code == NSURLErrorTimedOut || (error! as NSError).code == NSURLErrorNotConnectedToInternet || (error! as NSError).code == NSURLErrorNetworkConnectionLost || (error! as NSError).code == NSURLErrorCannotConnectToHost || (error! as NSError).code == NSURLErrorDataNotAllowed || (error! as NSError).code == NSURLErrorInternationalRoamingOff)
            {
                message = "Please check your network connection and try again."
                title = "Connection Error"
            }
            
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertVC, animated: true)
        }
    }
}
