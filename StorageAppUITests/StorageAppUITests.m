//
//  StorageAppUITests.m
//  StorageAppUITests
//
//  Created by Ashwin Kumar on 10/12/21.
//  Copyright © 2021 CA Technologies. All rights reserved.
//

#import <XCTest/XCTest.h>

#define INTERRUPT_MONITOR_DESCRIPTION @"TestInitialScreenHandler"
#define PERMISSIONS_ALLOW_BUTTON @"Allow While Using App"
#define LOCAL_STORAGE_UPDATE_SUCCESS_TEXT @"LocalStorageItem updated Successfully"
#define LABEL_OK @"OK"
#define LABEL_FAILURE @"Failure"
#define LABEL_LOCAL_STORAGE @"Local Storage"
#define LABEL_APP_USER_SEGMENT @"AppUser Seg."
#define LABEL_APP_SEGMENT @"App Segment"
#define LABEL_SHARE @"Share"
#define LABEL_ADD_STRING_OBJECT @"Add data of type String"
#define LABEL_ADD_IMAGE_OBJECT @"Add data of type Image"
#define LABEL_UPDATE @"Update"
#define LABEL_DELETE @"Delete"
#define LABEL_UPDATED_OBJECT @"Testing Update"
#define LABEL_NEW_OBJECT_FORMAT_STRING @"NewLocalStorage%lu"

@interface StorageAppUITests : XCTestCase

@property(nonatomic,strong) XCUIApplication *app;

@end

@implementation StorageAppUITests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    _app = [self initializeApp];

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (XCUIApplication*) initializeApp {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [self addUIInterruptionMonitorWithDescription:INTERRUPT_MONITOR_DESCRIPTION handler:^BOOL(XCUIElement * _Nonnull interruptingElement) {
        
        // handling permissions popup
        NSString * allowBtnText = PERMISSIONS_ALLOW_BUTTON;
        XCUIElementQuery * buttons = interruptingElement.buttons;
        if ([buttons[allowBtnText] exists]) {
            [buttons[allowBtnText] tap];
            return YES;
        }
        
        // handling storage item update alert
        if ([app.staticTexts[LOCAL_STORAGE_UPDATE_SUCCESS_TEXT] exists]) {
            XCUIElement *okButton = interruptingElement.buttons[LABEL_OK];
            [okButton tap];
            return YES;
        }
        
        // handling failure alert
        if ([app.alerts[LABEL_FAILURE] exists]) {
            [app.alerts[LABEL_FAILURE].scrollViews.otherElements.buttons[LABEL_OK] tap];
            XCTAssert(NO);
            return YES;
        }

        XCTAssert(NO);
        return NO;
    }];
    [app launch];
    [app swipeUp];
    return app;
}

- (void) testInitialScreen {
    XCUIElementQuery * navBars = [_app navigationBars];
    XCTAssert([navBars[LABEL_LOCAL_STORAGE] exists]);
    
    XCUIElement * appUserSegmentBtn = _app.tables.buttons[LABEL_APP_USER_SEGMENT];
    XCTAssert([appUserSegmentBtn exists]);
    
    XCUIElement * appSegmentBtn = _app.tables.buttons[LABEL_APP_SEGMENT];
    XCTAssert([appSegmentBtn exists]);
}

- (void) addObjectForApp:(XCUIApplication*)app isStringObject:(BOOL) isStringObject {
    
    [app.navigationBars[LABEL_LOCAL_STORAGE].buttons[LABEL_SHARE] tap];
    if (isStringObject) {
        NSString * addStringObjText = LABEL_ADD_STRING_OBJECT;
        BOOL result = [app.sheets.scrollViews.otherElements.buttons[addStringObjText] waitForExistenceWithTimeout:3];
        XCTAssert(result);
        [app.sheets.scrollViews.otherElements.buttons[addStringObjText] tap];
    } else {
        NSString * addImageObjText = LABEL_ADD_IMAGE_OBJECT;
        BOOL result = [app.sheets.scrollViews.otherElements.buttons[addImageObjText] waitForExistenceWithTimeout:3];
        XCTAssert(result);
        [app.sheets.scrollViews.otherElements.buttons[addImageObjText] tap];
    }
}

- (void) verifyCreationAndUpdateOfObject:(BOOL)isAppUserSegment isStringObject:(BOOL)isStringObject {
    
    if (isAppUserSegment) {
        [_app.tables.buttons[LABEL_APP_USER_SEGMENT] tap];
    }
    
    // add object
    [self addObjectForApp:_app isStringObject:isStringObject];
    
    // check whether a new object is added
    NSUInteger numOfRows = [_app.tables.cells count];
    NSString *newObjectRowText = [NSString stringWithFormat:LABEL_NEW_OBJECT_FORMAT_STRING, (unsigned long)(numOfRows)];
    BOOL result = [_app.tables.staticTexts[newObjectRowText] waitForExistenceWithTimeout:3];
    XCTAssert(result);
    
    // open newly created object
    [_app.tables.staticTexts[newObjectRowText] tap];
    
    // verify the label
    XCUIElementQuery * navBars = [_app navigationBars];
    XCTAssert([navBars[newObjectRowText] exists]);
    
    // update the object
    XCUIElement * itemNavigationBar = _app.navigationBars[newObjectRowText];
    [itemNavigationBar.buttons[LABEL_UPDATE] tap];
    
    // tap back button
    [itemNavigationBar.buttons[LABEL_LOCAL_STORAGE] tap];
    
    // tap the newly created object
    [_app.tables.staticTexts[newObjectRowText] tap];
    
    // confirm the text
    NSString* updatingText = LABEL_UPDATED_OBJECT;
    XCTAssert([_app.staticTexts[updatingText] exists]);
    
    // tap back button
    [itemNavigationBar.buttons[LABEL_LOCAL_STORAGE] tap];
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
    NSUInteger numOfRows = [_app.tables.cells count];
    [self addObjectForApp:_app isStringObject:YES];
    NSString *newObjectRowText = [NSString stringWithFormat:LABEL_NEW_OBJECT_FORMAT_STRING, (unsigned long)(numOfRows + 1)];
    BOOL result = [_app.tables.staticTexts[newObjectRowText] waitForExistenceWithTimeout:3];
    XCTAssert(result);
    [_app.tables.staticTexts[newObjectRowText] swipeLeft];
    [[[XCUIApplication alloc] init].tables.buttons[LABEL_DELETE] tap];
    NSUInteger currentNumberOfRows = [_app.tables.cells count];
    XCTAssert(numOfRows == currentNumberOfRows);
}

- (void) testDeleteAppUserSegmentObject {
    [_app.tables.buttons[LABEL_APP_USER_SEGMENT] tap];
    NSUInteger numOfRows = [_app.tables.cells count];
    [self addObjectForApp:_app isStringObject:YES];
    NSString *newObjectRowText = [NSString stringWithFormat:LABEL_NEW_OBJECT_FORMAT_STRING, (unsigned long)(numOfRows + 1)];
    BOOL result = [_app.tables.staticTexts[newObjectRowText] waitForExistenceWithTimeout:3];
    XCTAssert(result);
    [_app.tables.staticTexts[newObjectRowText] swipeLeft];
    [[[XCUIApplication alloc] init].tables.buttons[LABEL_DELETE] tap];
    NSUInteger currentNumberOfRows = [_app.tables.cells count];
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
