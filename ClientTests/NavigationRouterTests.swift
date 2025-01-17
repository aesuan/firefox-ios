// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import Foundation
@testable import Client
import WebKit

import XCTest

class NavigationRouterTests: XCTestCase {

    var appScheme: String {
        return URL.mozInternalScheme
    }

    func testOpenURLScheme() {
        let url = "http://google.com?a=1&b=2&c=foo%20bar".escape()!
        let appURL = "\(appScheme)://open-url?url=\(url)"
        let navItem = NavigationPath(url: URL(string: appURL)!)!
        XCTAssertEqual(navItem, NavigationPath.url(webURL: URL(string: url.unescape()!)!, isPrivate: false))

        let emptyNav = NavigationPath(url: URL(string: "\(appScheme)://open-url?private=true")!)
        XCTAssertEqual(emptyNav, NavigationPath.url(webURL: nil, isPrivate: true))

        let badNav = NavigationPath(url: URL(string: "\(appScheme)://open-url?url=blah")!)
        XCTAssertEqual(badNav, NavigationPath.url(webURL: URL(string: "blah"), isPrivate: false))
    }

    // Test EVERY deep link
    func testDeepLinks() {
        XCTAssertEqual(NavigationPath(url: URL(string: "\(appScheme)://deep-link?url=/settings/clear-private-data")!), NavigationPath.deepLink(DeepLink.settings(.clearPrivateData)))
        XCTAssertEqual(NavigationPath(url: URL(string: "\(appScheme)://deep-link?url=/settings/newTab")!), NavigationPath.deepLink(DeepLink.settings(.newtab)))
        XCTAssertEqual(NavigationPath(url: URL(string: "\(appScheme)://deep-link?url=/settings/newTab/")!), NavigationPath.deepLink(DeepLink.settings(.newtab)))
        XCTAssertEqual(NavigationPath(url: URL(string: "\(appScheme)://deep-link?url=/settings/homePage")!), NavigationPath.deepLink(DeepLink.settings(.homepage)))
        XCTAssertEqual(NavigationPath(url: URL(string: "\(appScheme)://deep-link?url=/settings/mailto")!), NavigationPath.deepLink(DeepLink.settings(.mailto)))
        XCTAssertEqual(NavigationPath(url: URL(string: "\(appScheme)://deep-link?url=/settings/search")!), NavigationPath.deepLink(DeepLink.settings(.search)))
        XCTAssertEqual(NavigationPath(url: URL(string: "\(appScheme)://deep-link?url=/settings/fxa")!), NavigationPath.deepLink(DeepLink.settings(.fxa)))
        XCTAssertEqual(NavigationPath(url: URL(string: "\(appScheme)://deep-link?url=/homepanel/bookmarks")!), NavigationPath.deepLink(DeepLink.homePanel(.bookmarks)))
        XCTAssertEqual(NavigationPath(url: URL(string: "\(appScheme)://deep-link?url=/homepanel/top-sites")!), NavigationPath.deepLink(DeepLink.homePanel(.topSites)))
        XCTAssertEqual(NavigationPath(url: URL(string: "\(appScheme)://deep-link?url=/homepanel/history")!), NavigationPath.deepLink(DeepLink.homePanel(.history)))
        XCTAssertEqual(NavigationPath(url: URL(string: "\(appScheme)://deep-link?url=/homepanel/reading-list")!), NavigationPath.deepLink(DeepLink.homePanel(.readingList)))
        XCTAssertEqual(NavigationPath(url: URL(string: "\(appScheme)://deep-link?url=/default-browser/system-settings")!), NavigationPath.deepLink(DeepLink.defaultBrowser(.systemSettings)))
        XCTAssertEqual(NavigationPath(url: URL(string: "\(appScheme)://deep-link?url=/homepanel/badbad")!), nil)
    }

    func testFxALinks() {
        XCTAssertEqual(NavigationPath(url: URL(string: "\(appScheme)://fxa-signin?signin=coolcodes&user=foo&email=bar")!), NavigationPath.fxa(params: FxALaunchParams(query: ["user": "foo","email": "bar", "signin": "coolcodes"])))
        XCTAssertEqual(NavigationPath(url: URL(string: "\(appScheme)://fxa-signin?user=foo&email=bar")!), nil)
    }

    func testCaseInsensitivity() {
        XCTAssertEqual(NavigationPath(url: URL(string: "HtTp://www.apple.com")!), NavigationPath.url(webURL: URL(string: "http://www.apple.com")!, isPrivate: false))
        XCTAssertEqual(NavigationPath(url: URL(string: "\(appScheme.uppercased())://Deep-Link?url=/settings/newTab")!), NavigationPath.deepLink(DeepLink.settings(.newtab)))
    }
    
    func testHostDoesntSpill() {
        // i.e ensure we check the entire host for our schemes, not just that they have the host as a prefix
        XCTAssertEqual(NavigationPath(url: URL(string: "http://glean.mywindows.com")!), NavigationPath.url(webURL: URL(string: "http://glean.mywindows.com")!, isPrivate: false))
        
        XCTAssertNil(NavigationPath(url: URL(string: "\(appScheme)://glean.mywindows.com")!))
        XCTAssertNil(NavigationPath(url: URL(string: "\(appScheme)://deep-links-are-fun?url=/settings/newTab/")!))

        // http[s] URLs stay as NavigationPath.url, even if their non-scheme components would match another type of NavigationPath
        XCTAssertEqual(NavigationPath(url: URL(string: "https://deep-link?url=/settings/newTab")!), NavigationPath.url(webURL: URL(string: "https://deep-link?url=/settings/newTab")!, isPrivate: false))

    }
}
