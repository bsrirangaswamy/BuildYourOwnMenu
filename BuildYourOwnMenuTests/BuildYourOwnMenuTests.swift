//
//  BuildYourOwnMenuTests.swift
//  BuildYourOwnMenuTests
//
//  Created by Balakumaran Srirangaswamy on 5/22/19.
//  Copyright © 2019 Bala. All rights reserved.
//

import XCTest
@testable import BuildYourOwnMenu

class BuildYourOwnMenuTests: XCTestCase {
    
    var pMTest: PersistenceManager!

    override func setUp() {
        super.setUp()
        pMTest = PersistenceManager.sharedInstance
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func test_data_PreLoad() {
        let coreDataObjectCount = pMTest.fetchedResultsController.sections?[0].numberOfObjects ?? 0
        XCTAssertEqual(coreDataObjectCount, 3, "PreLoad to core data failed")
    }
    
    func test_update_Data() {
        let coreDataObjectCount = pMTest.fetchedResultsController.sections?[0].numberOfObjects ?? 0
        let indPath = IndexPath(row: coreDataObjectCount-1, section: 0)
        let menuUpdateObject = pMTest.fetchedResultsController.object(at: indPath)
        let nameBefore = menuUpdateObject.name!
        pMTest.updateMainMenuData(indexPath: indPath, name: nameBefore+nameBefore, imageData: nil)
        let menuUpdateObjectAfter = pMTest.fetchedResultsController.object(at: indPath)
        let nameAfter = menuUpdateObjectAfter.name!
        XCTAssertEqual(nameAfter, nameBefore+nameBefore, "Update to core data failed")
    }

}
