//
//  SignsDictionaryTest.swift
//  NZSLDict
//
//  Created by Josh McArthur on 7/06/17.
//
//

import XCTest

@testable import NZSLDict
class SignsDictionaryTest: XCTestCase {
    var signsDictionary: SignsDictionary!;
    
    override func setUp() {
        super.setUp()
        signsDictionary = SignsDictionary.init(file: "");
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        signsDictionary = nil;
    }
    
    func test_searchForExactMainGlossMatch() {
        var results = signsDictionary.search(for: "Book");
        let firstResult: DictEntry = results![0] as! DictEntry;
        assert(firstResult.gloss == "book");
    }
    
    func test_searchForExactMaoriGlossMatch() {
        var results = signsDictionary.search(for: "ora");
        let firstResult: DictEntry = results![0] as! DictEntry;
        assert(firstResult.gloss == "alive, live, survive");
    }
    
    func test_searchForContainsMainGloss() {
        var results = signsDictionary.search(for: "classif");
        let firstResult: DictEntry = results![0] as! DictEntry;
        assert(firstResult.gloss == "classifier");
    }
    
    func test_searchForContainsMaoriGloss() {
        var results = signsDictionary.search(for: "akorang");
        let firstResult: DictEntry = results![0] as! DictEntry;
        assert(firstResult.gloss == "course");
    }
    
    func test_searchForExactSecondaryGloss() {
        var results = signsDictionary.search(for: "nought");
        let firstResult: DictEntry = results![0] as! DictEntry;
        assert(firstResult.gloss == "zero");
    }
    
    
    func test_searchForContainsSecondaryGloss() {
        var results = signsDictionary.search(for: "not get involved, nothing to do with");
        let firstResult: DictEntry = results![0] as! DictEntry;
        assert(firstResult.gloss == "neutral");
    }
    
}
