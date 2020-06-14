//
//  ViewController.swift
//  WQWKWebView
//
//  Created by chenweiqiang on 2020/6/6.
//  Copyright © 2020 chenweiqiang. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    var webView: WKWebView!
    var spinner: UIActivityIndicatorView!
    
    //自定义根视图--当整个页面是webview或图片时推荐这么做
    override func loadView() {
        let config = WKWebViewConfiguration()
//        config.preferences.javaScriptEnabled = true //是否支持javaScript
        //        config.allowsAirPlayForMediaPlayback = true
        //        ...
        
        //        可以接受web前端(js)传过来的数据--委托给self来接住传来的数据
        config.userContentController.add(self, name: "jsToNativeNoPrams")
        config.userContentController.add(self, name: "jsToNativeWithPrams")
        webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setSpinner() //配置加载小菊花
        //webView.load("https://www.baidu.com")
        //            handleHTMLString()
        handleHTMLFile()
        
        //添加观察者--实时监测加载进度(estimatedProgress)属性的值
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        //测试原生调JS
        let btn = UIButton(frame: CGRect(x: 200, y: 400, width: 100, height: 30))
        btn.backgroundColor = .lightGray
        btn.setTitle("原生调JS", for: .normal)
        
        self.view.addSubview(btn)
        btn.addTarget(self, action: #selector(callJS), for: .touchUpInside)
        
        
        
        //        webView.isLoading
        //        webView.reload()
        //        webView.reloadFromOrigin() //根据缓存机制是否从源头获取数据（web端知识）
        //        webView.stopLoading()
        //
        //        webView.canGoBack
        //        webView.goBack()
        //        webView.canGoForward
        //        webView.goForward()
        //
        //        webView.backForwardList //存储已打开过的历史网页。可以跳转到某个指定历史页面
        
    }
    //MARK:----原生调JS方法事件-----
    @objc func callJS(){
        let msg = "aaa"
        let callStr = "receiveMsgFromNative('\(msg)')"
        webView.evaluateJavaScript(callStr) { (res, error) in
            print("==\(res),err=\(error)")
            //print(res as! Int)
        }
    }
    func setSpinner(){
        spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.7966609589)
        spinner.layer.cornerRadius = 10
        spinner.translatesAutoresizingMaskIntoConstraints = false
        webView.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: webView.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: webView.centerYAnchor).isActive = true
        spinner.widthAnchor.constraint(equalToConstant: 80).isActive = true
        spinner.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    //执行小段html代码
    func handleHTMLString(){
        //三引号用来引用大段字符串，以最后的三引号为基准缩放点
        let html = """
            <!DOCTYPE html>
            <html lang="en">
            <head>
            <meta charset="UTF-8">
            <title>iOS</title>
            </head>
            <body>
            <div style="text-align: center;font-size: 80px;margin-top: 350px">自定义网页</div>
            </body>
            </html>
            """
        //baseURL相当于HTML的<base>标签，定义页面中所有链接的默认相对地址
        webView.loadHTMLString(html, baseURL: Bundle.main.resourceURL)
    }
    //执行大段web前端代码（主要是html）
    func handleHTMLFile(){
        let url = Bundle.main.url(forResource: "HomePage", withExtension: "html")!
        //allowingReadAccessTo-html文件里面要用到的图片，css，js文件，通常都是放在一个文件夹里面拖进来
        //deletingLastPathComponent返回父url
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }
    //执行js代码--也叫Injecting JavaScript
    func handleJS(){
        webView.evaluateJavaScript("document.body.offsetHeight") { (res, error) in
            print(res as! Int)
        }
    }
    
    //实时获取加载进度的值
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress){
            print("加载进度=\(webView.estimatedProgress)")
            //可以把实时变化的值赋给progress view的progress属性，做一个加载进度条的功能
        }
    }
    
    //生成截图
    func takeSnapShot(){
//        let config = WKSnapshotConfiguration()
//        config.rect = CGRect(x: 0, y: 0, width: 200, height: 200)
//        //从webview的左上角起截取200x200的图像，with nil 的话就是截取整个画面
//        webView.takeSnapshot(with: config) { (image, error) in
//            guard let image = image else{return}
//            print(image.size)
//            //存储到用户相册等
//        }
    }
    
    //读取cookie的value和删除cookie
    func handleCookie(){
//        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies{ cookies in
//            for cookie in cookies{
//                if cookie.name == "auth"{
//                    //删除--用的较少
//                    self.webView.configuration.websiteDataStore.httpCookieStore.delete(cookie)
//                }else{
//                    print(cookie.value) //获取cookie
//                }
//            }
//        }
    }
    
    //class销毁的时候一定要移除观察者
    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
    
    
}
//MARK:----JS调原生方法事件-----
extension ViewController: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        //js对象(字符串，json等)会被自动序列化为Swift对象
        if message.name == "jsToNativeNoPrams" {
            print("JS调原生不带参数")
        }else if message.name == "jsToNativeWithPrams"{
            print("JS调原生带参数:\(message.body)")
            //可以对数据做一些处理
        }
    }
}


//从请求到响应的一些钩子函数
extension ViewController: WKNavigationDelegate{
    //1.决定要不要在当前webview中加载网站（比如load里面是动态url时）--主要根据请求头等信息
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print(#function)
//        比如所有google的页面都会在外部浏览器打开，其余的在本app的webView中打开
//        if let url = navigationAction.request.url{
//            if url.host == "www.google.com"{
//                UIApplication.shared.open(url)
//                decisionHandler(.cancel)
//                return
//            }
//        }
        decisionHandler(.allow)
    }
    //2.向Web服务器请求数据时调用(网页开始加载)
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print(#function)
        spinner.startAnimating()
    }
    //3.在收到服务器的响应后，决定要不要在当前webview中加载网站--主要根据响应头等信息
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print(#function)
//        比如可以根据statusCode决定是否加载
//        if let httpResponse = navigationResponse.response as? HTTPURLResponse,
//            httpResponse.statusCode == 200{
//            decisionHandler(.allow)
//        }else{
//            decisionHandler(.cancel)
//        }
        decisionHandler(.allow)
    }
    //4.开始从Web服务器接收数据时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print(#function)
    }
    //5.从Web服务器接收完数据时调用(网页加载完成)
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(#function)
        spinner.stopAnimating()
        spinner.removeFromSuperview()
        handleJS()
    }
    //网页加载失败时调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(#function)
        spinner.stopAnimating()
        spinner.removeFromSuperview()
    }
}

//主要用来把网站的三种弹出框转化为iOS原生的弹出框
extension ViewController: WKUIDelegate{
    //闭包：被用作为参数的函数
    
    //非逃逸闭包-默认：外围函数执行完毕后被释放
    //逃逸闭包-@escaping：外围函数执行完毕后，他的引用仍旧被其他对象持有，不会被释放
    //逃逸闭包对内存管理有风险--谨慎使用除非明确知道
    
    // [js]alert()警告框
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) in
            completionHandler()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // [js]confirm()确认框
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
            completionHandler(false)
        }))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) in
            completionHandler(true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // [js]prompt()输入框
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = defaultText
        }
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) in
            completionHandler(alert.textFields?.last?.text)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
}

