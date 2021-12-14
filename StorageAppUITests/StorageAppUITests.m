//
//  StorageAppUITests.m
//  StorageAppUITests
//
//  Created by Ashwin Kumar on 10/12/21.
//  Copyright © 2021 CA Technologies. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface StorageAppUITests : XCTestCase

@end

@implementation StorageAppUITests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void) testInitialScreen {
    // UI tests must launch the application that they test.
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [self addUIInterruptionMonitorWithDescription:@"TestInitialScreenHandler" handler:^BOOL(XCUIElement * _Nonnull interruptingElement) {
        NSString * allowBtnText = @"Allow While Using App";
        XCUIElementQuery * buttons = interruptingElement.buttons;
        if ([buttons[allowBtnText] exists]) {
            [buttons[allowBtnText] tap];
            return YES;
        }
        XCTAssert(NO);
        return NO;
    }];
    [app launch];
    [app swipeUp];
    XCUIElementQuery * navBars = [app navigationBars];
    XCTAssert([navBars[@"Local Storage"] exists]);
    
    XCUIElement * appUserSegmentBtn = app.tables.buttons[@"AppUser Seg."];
    XCTAssert([appUserSegmentBtn exists]);
    
    XCUIElement * appSegmentBtn = app.tables.buttons[@"App Segment"];
    XCTAssert([appSegmentBtn exists]);
}

- (void) addObjectForApp:(XCUIApplication*)app isStringObject:(BOOL) isStringObject {
    
    NSString * shareBtnText = @"Share";
    NSString * navigationBarText = @"Local Storage";
    
    [app.navigationBars[navigationBarText].buttons[shareBtnText] tap];
    if (isStringObject) {
        NSString * addStringObjText = @"Add data of type String";
        [app.sheets.scrollViews.otherElements.buttons[addStringObjText] tap];
    } else {
        NSString * addImageObjText = @"Add data of type Image";
        [app.sheets.scrollViews.otherElements.buttons[addImageObjText] tap];
    }
}

- (void) verifyCreationAndUpdateOfObject:(BOOL)isAppUserSegment isStringObject:(BOOL)isStringObject {
    // UI tests must launch the application that they test.
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [self addUIInterruptionMonitorWithDescription:@"VerifyCreationAndUpdateOfObjectHandler" handler:^BOOL(XCUIElement * _Nonnull interruptingElement) {
        
        // handling permissions popup
        NSString * allowBtnText = @"Allow While Using App";
        XCUIElementQuery * buttons = interruptingElement.buttons;
        if ([buttons[allowBtnText] exists]) {
            [buttons[allowBtnText] tap];
            return YES;
        }
        
        if ([app.staticTexts[@"LocalStorageItem updated Successfully"] exists]) {
            XCUIElement *okButton = interruptingElement.buttons[@"OK"];
            [okButton tap];
            return YES;
        }
        
        // handling failure alert
        if ([app.alerts[@"Failure"] exists]) {
            [app.alerts[@"Failure"].scrollViews.otherElements.buttons[@"OK"] tap];
            XCTAssert(NO);
            return YES;
        }
        return NO;
    }];
    [app launch];
    [app swipeUp];
    
    if (isAppUserSegment) {
        [app.tables.buttons[@"AppUser Seg."] tap];
    }
    
    // add object
    [self addObjectForApp:app isStringObject:isStringObject];
    
    // check whether a new object is added
    NSUInteger numOfRows = [app.tables.cells count];
    NSString *newObjectRowText = [NSString stringWithFormat:@"NewLocalStorage%lu", (unsigned long)(numOfRows+1)];
    BOOL result = [app.tables.staticTexts[newObjectRowText] waitForExistenceWithTimeout:3];
    XCTAssert(result);
    
    // open newly created object
    [app.tables.staticTexts[newObjectRowText] tap];
    
    // verify the label
    XCUIElementQuery * navBars = [app navigationBars];
    XCTAssert([navBars[newObjectRowText] exists]);
    
    // update the object
    XCUIElement * itemNavigationBar = app.navigationBars[newObjectRowText];
    [itemNavigationBar.buttons[@"Update"] tap];
    
    // tap back button
    [itemNavigationBar.buttons[@"Local Storage"] tap];
    
    // tap the newly created object
    [app.tables.staticTexts[newObjectRowText] tap];
    
    // confirm the text
    NSString* updatingText = @"Testing Update";
    XCTAssert([app.staticTexts[updatingText] exists]);
    
    // tap back button
    [itemNavigationBar.buttons[@"Local Storage"] tap];
}

- (void) testAppSegmentWithStringTypeObject {
    [self verifyCreationAndUpdateOfObject:NO isStringObject:YES];
}

- (void) testAppUserSegmentWithStringTypeObject {
    [self verifyCreationAndUpdateOfObject:YES isStringObject:YES];
}

- (void) testAppSegmentWithImageTypeObject {
    [self verifyCreationAndUpdateOfObject:NO isStringObject:NO];
}

- (void) testAppUserSegmentWithImageTypeObject {
    [self verifyCreationAndUpdateOfObject:YES isStringObject:NO];
}

- (void) testDeleteAppSegmentObject {
    // UI tests must launch the application that they test.
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [self addUIInterruptionMonitorWithDescription:@"TestDeleteAppSegmentObjectHandler" handler:^BOOL(XCUIElement * _Nonnull interruptingElement) {
        NSString * allowBtnText = @"Allow While Using App";
        XCUIElementQuery * buttons = interruptingElement.buttons;
        if ([buttons[allowBtnText] exists]) {
            [buttons[allowBtnText] tap];
            return YES;
        }
        XCTAssert(NO);
        return NO;
    }];
    [app launch];
    [app swipeUp];
    NSUInteger numOfRows = [app.tables.cells count];
    [self addObjectForApp:app isStringObject:YES];
    NSString *newObjectRowText = [NSString stringWithFormat:@"NewLocalStorage%lu", (unsigned long)(numOfRows + 1)];
    BOOL result = [app.tables.staticTexts[newObjectRowText] waitForExistenceWithTimeout:3];
    XCTAssert(result);
    [app.tables.staticTexts[newObjectRowText] swipeLeft];
    [[[XCUIApplication alloc] init].tables/*@START_MENU_TOKEN@*/.buttons[@"Delete"]/*[[".cells.buttons[@\"Delete\"]",".buttons[@\"Delete\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    NSUInteger currentNumberOfRows = [app.tables.cells count];
    XCTAssert(numOfRows == currentNumberOfRows);
}

- (void) testDeleteAppUserSegmentObject {
    // UI tests must launch the application that they test.
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [self addUIInterruptionMonitorWithDescription:@"TestDeleteAppUserSegmentObjectHandler" handler:^BOOL(XCUIElement * _Nonnull interruptingElement) {
        NSString * allowBtnText = @"Allow While Using App";
        XCUIElementQuery * buttons = interruptingElement.buttons;
        if ([buttons[allowBtnText] exists]) {
            [buttons[allowBtnText] tap];
            return YES;
        }
        XCTAssert(NO);
        return NO;
    }];
    [app launch];
    [app swipeUp];
    [app.tables.buttons[@"AppUser Seg."] tap];
    NSUInteger numOfRows = [app.tables.cells count];
    [self addObjectForApp:app isStringObject:YES];
    NSString *newObjectRowText = [NSString stringWithFormat:@"NewLocalStorage%lu", (unsigned long)(numOfRows + 1)];
    BOOL result = [app.tables.staticTexts[newObjectRowText] waitForExistenceWithTimeout:3];
    XCTAssert(result);
    [app.tables.staticTexts[newObjectRowText] swipeLeft];
    [[[XCUIApplication alloc] init].tables/*@START_MENU_TOKEN@*/.buttons[@"Delete"]/*[[".cells.buttons[@\"Delete\"]",".buttons[@\"Delete\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    NSUInteger currentNumberOfRows = [app.tables.cells count];
    XCTAssert(numOfRows == currentNumberOfRows);
}

/*
- (void)testLaunchPerformance {
    if (@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *)) {
        // This measures how long it takes to launch your application.
        [self measureWithMetrics:@[[[XCTApplicationLaunchMetric alloc] init]] block:^{
            [[[XCUIApplication alloc] init] launch];
        }];
    }
} */

@end
