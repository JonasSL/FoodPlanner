//
//  DishDetailWebViewController.swift
//  Food Planner
//
//  Created by Jonas Larsen on 11/12/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import UIKit
import WebKit

class DishDetailWebViewController: UITableViewController, WKNavigationDelegate {

    var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL(string: "http://www.dk-kogebogen.dk/opskrifter/visopskrift.php?id=28546")!
        webView.loadRequest(NSURLRequest(URL: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
}
