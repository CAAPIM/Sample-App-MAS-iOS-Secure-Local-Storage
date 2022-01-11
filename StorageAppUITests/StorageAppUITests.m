//
//  StorageAppUITests.m
//  StorageAppUITests
//
//  Created by Ashwin Kumar on 10/12/21.
//  Copyright © 2021 CA Technologies. All rights reserved.
//

#import <XCTest/XCTest.h>

#define KEY_INTERRUPT_MONITOR_DESCRIPTION @"interrupt.monitor.description"
#define KEY_LABEL_PERMISSIONS_ALLOW_BUTTON @"label.permissions.allow.button"
#define KEY_LOCAL_STORAGE_UPDATE_SUCCESS_TEXT @"text.localstorage.update.success"
#define KEY_LABEL_OK @"label.ok"
#define KEY_LABEL_FAILURE @"label.failure"
#define KEY_LABEL_LOCAL_STORAGE @"label.localstorage"
#define KEY_LABEL_APP_USER_SEGMENT @"label.appuser.segment"
#define KEY_LABEL_APP_SEGMENT @"label.app.segment"
#define KEY_LABEL_SHARE @"label.share"
#define KEY_LABEL_ADD_STRING_OBJECT @"label.add.string.object"
#define KEY_LABEL_ADD_IMAGE_OBJECT @"label.add.image.object"
#define KEY_LABEL_UPDATE @"label.update"
#define KEY_LABEL_DELETE @"label.delete"
#define KEY_LABEL_UPDATED_OBJECT @"label.updated.object"
#define KEY_LABEL_NEW_OBJECT_FORMAT_STRING @"label.new.object.format.string"

@interface StorageAppUITests : XCTestCase

@property(nonatomic,strong) XCUIApplication *app;
@property(nonatomic,strong) NSDictionary *externalStringsDict;

@end

@implementation StorageAppUITests

- (NSDictionary *)JSONFromFile
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"ui_tests_config" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

- (void)setUp {
    //
    // In UI tests it is usually best to stop immediately when a failure occurs.
    //
    self.continueAfterFailure = NO;
    _externalStringsDict = [self JSONFromFile];
    _app = [self initializeApp];
}

- (void)tearDown {
    //
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    //
}

- (XCUIApplication*) initializeApp {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    NSString *labelOK = [_externalStringsDict objectForKey:KEY_LABEL_OK];
    NSString *labelFailure = [_externalStringsDict objectForKey:KEY_LABEL_FAILURE];
    NSString *allowBtnText = [_externalStringsDict objectForKey:KEY_LABEL_PERMISSIONS_ALLOW_BUTTON];
    NSString *updateSuccessText = [_externalStringsDict objectForKey:KEY_LOCAL_STORAGE_UPDATE_SUCCESS_TEXT];
    [self addUIInterruptionMonitorWithDescription:[_externalStringsDict objectForKey:KEY_INTERRUPT_MONITOR_DESCRIPTION] handler:^BOOL(XCUIElement * _Nonnull interruptingElement) {
        
        //
        // handling permissions popup
        //
        XCUIElementQuery * buttons = interruptingElement.buttons;
        if ([buttons[allowBtnText] exists]) {
            [buttons[allowBtnText] tap];
            return YES;
        }

        //
        // handling storage item update alert
        //
        if ([app.staticTexts[updateSuccessText] exists]) {
            XCUIElement *okButton = interruptingElement.buttons[labelOK];
            [okButton tap];
            return YES;
        }

        //
        // handling failure alert
        //
        if ([app.alerts[labelFailure] exists]) {
            [app.alerts[labelFailure].scrollViews.otherElements.buttons[labelOK] tap];
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
    XCTAssert([navBars[[_externalStringsDict objectForKey:KEY_LABEL_LOCAL_STORAGE]] exists]);
    
    XCUIElement * appUserSegmentBtn = _app.tables.buttons[[_externalStringsDict objectForKey:KEY_LABEL_APP_USER_SEGMENT]];
    XCTAssert([appUserSegmentBtn exists]);
    
    XCUIElement * appSegmentBtn = _app.tables.buttons[[_externalStringsDict objectForKey:KEY_LABEL_APP_SEGMENT]];
    XCTAssert([appSegmentBtn exists]);
}

- (void) addObjectForApp:(XCUIApplication*)app isStringObject:(BOOL) isStringObject {
    
    [app.navigationBars[[_externalStringsDict objectForKey:KEY_LABEL_LOCAL_STORAGE]].buttons[[_externalStringsDict objectForKey:KEY_LABEL_SHARE]] tap];
    if (isStringObject) {
        NSString * addStringObjText = [_externalStringsDict objectForKey:KEY_LABEL_ADD_STRING_OBJECT];
        BOOL result = [app.sheets.scrollViews.otherElements.buttons[addStringObjText] waitForExistenceWithTimeout:3];
        XCTAssert(result);
        [app.sheets.scrollViews.otherElements.buttons[addStringObjText] tap];
    } else {
        NSString * addImageObjText = [_externalStringsDict objectForKey:KEY_LABEL_ADD_IMAGE_OBJECT];
        BOOL result = [app.sheets.scrollViews.otherElements.buttons[addImageObjText] waitForExistenceWithTimeout:3];
        XCTAssert(result);
        [app.sheets.scrollViews.otherElements.buttons[addImageObjText] tap];
    }
}

- (void) verifyCreationAndUpdateOfObject:(BOOL)isAppUserSegment isStringObject:(BOOL)isStringObject {
    
    if (isAppUserSegment) {
        [_app.tables.buttons[[_externalStringsDict objectForKey:KEY_LABEL_APP_USER_SEGMENT]] tap];
    }

    //
    // add object
    //
    [self addObjectForApp:_app isStringObject:isStringObject];

    //
    // check whether a new object is added
    //
    NSUInteger numOfRows = [_app.tables.cells count];
    NSString *newObjectRowText = [NSString stringWithFormat:[_externalStringsDict objectForKey:KEY_LABEL_NEW_OBJECT_FORMAT_STRING], (unsigned long)(numOfRows)];
    BOOL result = [_app.tables.staticTexts[newObjectRowText] waitForExistenceWithTimeout:3];
    XCTAssert(result);

    //
    // open newly created object
    //
    [_app.tables.staticTexts[newObjectRowText] tap];
    
    //
    // verify the label
    //
    XCUIElementQuery * navBars = [_app navigationBars];
    XCTAssert([navBars[newObjectRowText] exists]);

    //
    // update the object
    //
    XCUIElement * itemNavigationBar = _app.navigationBars[newObjectRowText];
    [itemNavigationBar.buttons[[_externalStringsDict objectForKey:KEY_LABEL_UPDATE]] tap];

    //
    // tap back button
    //
    [itemNavigationBar.buttons[[_externalStringsDict objectForKey:KEY_LABEL_LOCAL_STORAGE]] tap];

    //
    // tap the newly created object
    //
    [_app.tables.staticTexts[newObjectRowText] tap];

    //
    // confirm the text
    //
    NSString* updatingText = [_externalStringsDict objectForKey:KEY_LABEL_UPDATED_OBJECT];
    XCTAssert([_app.staticTexts[updatingText] exists]);

    //
    // tap back button
    //
    [itemNavigationBar.buttons[[_externalStringsDict objectForKey:KEY_LABEL_LOCAL_STORAGE]] tap];
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
    NSString *newObjectRowText = [NSString stringWithFormat:[_externalStringsDict objectForKey:KEY_LABEL_NEW_OBJECT_FORMAT_STRING], (unsigned long)(numOfRows + 1)];
    BOOL result = [_app.tables.staticTexts[newObjectRowText] waitForExistenceWithTimeout:3];
    XCTAssert(result);
    [_app.tables.staticTexts[newObjectRowText] swipeLeft];
    [[[XCUIApplication alloc] init].tables.buttons[[_externalStringsDict objectForKey:KEY_LABEL_DELETE]] tap];
    NSUInteger currentNumberOfRows = [_app.tables.cells count];
    XCTAssert(numOfRows == currentNumberOfRows);
}

- (void) testDeleteAppUserSegmentObject {
    [_app.tables.buttons[[_externalStringsDict objectForKey:KEY_LABEL_APP_USER_SEGMENT]] tap];
    NSUInteger numOfRows = [_app.tables.cells count];
    [self addObjectForApp:_app isStringObject:YES];
    NSString *newObjectRowText = [NSString stringWithFormat:[_externalStringsDict objectForKey:KEY_LABEL_NEW_OBJECT_FORMAT_STRING], (unsigned long)(numOfRows + 1)];
    BOOL result = [_app.tables.staticTexts[newObjectRowText] waitForExistenceWithTimeout:3];
    XCTAssert(result);
    [_app.tables.staticTexts[newObjectRowText] swipeLeft];
    [[[XCUIApplication alloc] init].tables.buttons[[_externalStringsDict objectForKey:KEY_LABEL_DELETE]] tap];
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
