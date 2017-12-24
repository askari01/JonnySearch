//
//  URIFixup.swift
//  Shared
//
//  Created by Jonny on 12/13/17.
//  Copyright © 2017 Junyu Kuang <lightscreen.app@gmail.com>. All rights reserved.
//

//
//  URIFixup.swift
//  AuroraBrowser
//
//  Swift 3 Upgrade by Jonny on 1/28/17.
//  Original version made by FireFox.
//

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

public struct URIFixup {
    
    public static func makeURL(withEntry entry: String) -> URL? {
        
        let trimmed = entry.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            return nil
        }
        
        guard let escaped = trimmed.addingPercentEncoding(withAllowedCharacters: .urlAllowed) else {
            return nil
        }
        
        // Then check if the URL includes a scheme. This will handle
        // all valid requests starting with "http://", "about:", etc.
        // However, we ensure that the scheme is one that is listed in
        // the official URI scheme list, so that other such search phrases
        // like "filetype:" are recognised as searches rather than URLs.
        if let url = punycodedURL(from: escaped), url.isSchemeValid {
            return url
        }
        
        // If there's no scheme, we're going to prepend "http://". First,
        // make sure there's at least one "." in the host. This means
        // we'll allow single-word searches (e.g., "foo") at the expense
        // of breaking single-word hosts without a scheme (e.g., "localhost").
        if !trimmed.contains(".") || trimmed.first == "." || trimmed.last == "." {
            return nil
        }
        
        if trimmed.contains(" ") {
            return nil
        }
        
        // If there is a ".", prepend "http://" and try again. Since this
        // is strictly an "http://" URL, we also require a host.
        if let url = punycodedURL(from: "http://\(escaped)"), url.host != nil {
            return url
        }
        
        return nil
    }
    
    private static func punycodedURL(from string: String) -> URL? {
        let components = URLComponents(string: string)
        return components?.url
        
        //        let components = NSURLComponents(string: string)
        //        components?.host = AppConstants.MOZ_PUNYCODE ? components?.host?.utf8HostToAscii() : components?.host
        //        return components?.URL
    }
}

// The list of permanent URI schemes has been taken from http://www.iana.org/assignments/uri-schemes/uri-schemes.xhtml
private let permanentURISchemes: Set = ["aaa", "aaas", "about", "acap", "acct", "cap", "cid", "coap", "coaps", "crid", "data", "dav", "dict", "dns", "example", "file", "ftp", "geo", "go", "gopher", "h323", "http", "https", "iax", "icap", "im", "imap", "info", "ipp", "ipps", "iris", "iris.beep", "iris.lwz", "iris.xpc", "iris.xpcs", "jabber", "ldap", "mailto", "mid", "msrp", "msrps", "mtqp", "mupdate", "news", "nfs", "ni", "nih", "nntp", "opaquelocktoken", "pkcs11", "pop", "pres", "reload", "rtsp", "rtsps", "rtspu", "service", "session", "shttp", "sieve", "sip", "sips", "sms", "snmp", "soap.beep", "soap.beeps", "stun", "stuns", "tag", "tel", "telnet", "tftp", "thismessage", "tip", "tn3270", "turn", "turns", "tv", "urn", "vemmi", "vnc", "ws", "wss", "xcon", "xcon-userid", "xmlrpc.beep", "xmlrpc.beeps", "xmpp", "z39.50r", "z39.50s"]

private extension URL {
    
    /// Returns whether the URL's scheme is one of those listed on the official list of URI schemes.
    ///
    /// This only accepts permanent schemes: historical and provisional schemes are not accepted.
    var isSchemeValid: Bool {
        guard let scheme = scheme else { return false }
        return permanentURISchemes.contains(scheme)
    }
}



/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

private extension CharacterSet {
    
    static let urlAllowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~:/?#[]@!$&'()*+,;=%")
    
    static let searchTermsAllowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789*-_.")
}

