//
//  ViewController.swift
//  JonnySearch
//
//  Created by Jonny on 3/29/17.
//  Copyright © 2017 Junyu Kuang <lightscreen.app@gmail.com>. All rights reserved.
//

import Cocoa
import MASShortcut

class ViewController: NSViewController {

    @IBOutlet var textField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.backgroundColor = .clear
        textField.cell?.focusRingType = .none // remove blue border
        textField.placeholderAttributedString = NSAttributedString(string: "Search...", attributes: [.foregroundColor : #colorLiteral(red: 0.6039215686, green: 0.6274509804, blue: 0.6274509804, alpha: 1), .font : NSFont.systemFont(ofSize: 32)])
        
		NotificationCenter.default.addObserver(self, selector: #selector(windowDidResignKey), name: NSWindow.didResignKeyNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeKey), name: NSWindow.didBecomeKeyNotification, object: nil)
    }
    
    /// The text in text field that last time active.
    private var textFieldTextWhenResignActive = ""
    
    @objc private func windowDidResignKey() {
        print(#function)
        textFieldTextWhenResignActive = textField.stringValue
    }
    
    @objc private func windowDidBecomeKey() {
        print(#function)
		
        if textField.stringValue == textFieldTextWhenResignActive {
            textField.selectText(nil)
        }
    }
}

extension ViewController: NSTextFieldDelegate {
    
    private func openURLAndCloseWindow(_ url: URL) {
        let isSuccess = NSWorkspace.shared.open(url)
        if isSuccess {
			(NSApp.delegate as! AppDelegate).toggleWindowVisibleState()
        }
    }
    
    // MARK: - Customizable
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
		print(#function)
		
        guard let event = NSApp.currentEvent else { return false }
        let keyCode = Int(event.keyCode)
        
        if keyCode == kVK_Escape {
			(NSApp.delegate as! AppDelegate).toggleWindowVisibleState()
            return true
        }
        
        let term = textField.stringValue
        let flags = event.modifierFlags
        var domain: URL.SearchDomain?
        
        if keyCode == kVK_Return {
            if flags.contains(.command) {
                domain = .baidu
            } else if flags.contains(.option) {
                domain = .stackOverflow
            } else if flags.contains(.control) {
                domain = .gitHub
            } else {
                domain = .google
            }
        } else if flags.contains(.command) {
            switch keyCode {
            case kVK_ANSI_D:
                domain = .dictionary
            case kVK_ANSI_F:
                domain = .google
            case kVK_ANSI_S:
                domain = .stackOverflow
            case kVK_ANSI_G:
                domain = .gitHub
            case kVK_ANSI_B:
                domain = .baidu
            case kVK_ANSI_T:
                if term.containsChinese {
                    domain = .googleTranslateToEnglish
                } else {
                    domain = .googleTranslateToSimplifiedChinese
                }
            default:
                break
            }
        }

        /// If the term is a url, then no need to search, just open it.
        if domain == .google, let url = URIFixup.makeURL(withEntry: term) {
            openURLAndCloseWindow(url)
            return true
        }
        
        if let domain = domain {
			let url = URL(search: term, in: domain)
            openURLAndCloseWindow(url)
            return true
        }
        
        return false
    }
}

extension URL {
    
    enum SearchDomain {
        case dictionary, google, baidu, stackOverflow, gitHub, googleTranslateToEnglish, googleTranslateToSimplifiedChinese
    }
    
    init(search term: String, in domain: SearchDomain) {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        let encodedText = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        switch domain {
        case .dictionary:
            self.init(string: "dict://" + encodedText)!
        case .google:
            self.init(string: "https://www.google.com/search?q=" + encodedText)!
        case .baidu:
            self.init(string: "https://www.baidu.com/s?wd=" + encodedText)!
        case .stackOverflow:
            self.init(string: "https://www.stackoverflow.com/search?q=" + encodedText)!
        case .gitHub:
            self.init(string: "https://www.github.com/search?q=" + encodedText)!
        case .googleTranslateToEnglish:
            self.init(string: "https://translate.google.com/#auto/en/" + encodedText)!
        case .googleTranslateToSimplifiedChinese:
            self.init(string: "https://translate.google.com/#auto/zh-CN/" + encodedText)!
        }
    }
}

private extension String {
    
    private static let chineseRegex = try! NSRegularExpression(pattern: "\\p{Script=Han}", options: .caseInsensitive)
    
    var containsChinese: Bool {
        
        var containsChinese = false
        
        String.chineseRegex.enumerateMatches(in: self, options: .withoutAnchoringBounds, range: NSRange(startIndex ..< endIndex, in: self)) { result, match, stop in
            containsChinese = true
            stop.pointee = true
        }
        
        return containsChinese
    }
    
}
