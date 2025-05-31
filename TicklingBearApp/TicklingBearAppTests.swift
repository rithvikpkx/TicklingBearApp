import XCTest
import SwiftUI
@testable import TicklingBearApp

final class TicklingBearAppTests: XCTestCase {
    
    func testBearViewCreation() throws {
        // Test that BearView can be created without crashing
        let bearView = BearView()
        XCTAssertNotNil(bearView)
    }
    
    func testContentViewCreation() throws {
        // Test that ContentView can be created without crashing
        let contentView = ContentView()
        XCTAssertNotNil(contentView)
    }
    
    func testSoundManagerCreation() throws {
        // Test that SoundManager can be created without crashing
        let soundManager = SoundManager()
        XCTAssertNotNil(soundManager)
    }
    
    func testSoundManagerPlayGiggle() throws {
        // Test that playGiggle method doesn't crash
        let soundManager = SoundManager()
        
        // This should not crash
        XCTAssertNoThrow(soundManager.playGiggle())
        XCTAssertNoThrow(soundManager.playRandomGiggle())
    }
}
