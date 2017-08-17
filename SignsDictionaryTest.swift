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
    
    func test_duplicateResultsAreRemoved() {
        // There are 3 unique results for Auckland. This search term is used
        // because it was known to break and show duplicates, but also includes 
        // more than 1 unique result for the term
        let results = signsDictionary.search(for: "Auckland");
        let resultsMatchingAuckland = results?.filter { ($0 as AnyObject).gloss == "Auckland" }
        assert(resultsMatchingAuckland?.count == 3)
    }
    
    func test_searchForStartsWithMainGloss() {
        let results = signsDictionary.search(for: "bus");
        let firstResult = results?[0] as! DictEntry;
        assert(firstResult.gloss == "bus stop");
    }
    
    func test_searchForStartsWithMaoriGloss() {
        let results = signsDictionary.search(for: "Aorang");
        let firstResult = results?[0] as! DictEntry;
        assert(firstResult.gloss == "Feilding");
    }
    
    func test_searchForPrioritisesResults() {
        // A nice general term that returns a range of matched signs
        let results = signsDictionary.search(for: "bus");
        let result1 = results?[0] as! DictEntry;
        let result2 = results?[1] as! DictEntry;
        let result3 = results?[2] as! DictEntry;
        
        assert(result1.gloss == "bus stop");
        assert(result2.gloss == "bus, truck");
        assert(result3.gloss == "bush, tree");
    }
}
