//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 17.04.2023.
//

import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    // MARK: - Public Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var progressView: UIProgressView!
    
    // MARK: - Private Properties
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 self.updateProgress()
             })
        
        
        var urlComponents = URLComponents(string: Constants.unsplashAuthorizeURLString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        let url = urlComponents.url!
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    // MARK: - IBAction
    
    @IBAction private func didTapBackButton(_ sender: Any?) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    // MARK: - Private Methods
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}

// MARK: - WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        guard
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        else {
            return nil
        }
        return codeItem.value
    }
}
