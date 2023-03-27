import XCTest
@testable import CDRecorder

final class CDRecorderTests: XCTestCase {
    
    var recorder: CDRecorder?
    
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        self.recorder?.finishRecording()
        self.recorder = nil
    }
    
    func testPrepareRecord() throws {
//        let exStart = self.expectation(description: "exStart")
        
        self.recorder = CDRecorder(completdBolck: { status in
            
            switch status {
            case .start(let success, let errorMessage):
                break
            case .end(let success, let errorMessage):
                break
            }
        })
        
        
        let ex = self.expectation(description: "testPrepareRecord")
        self.recorder?.prepare(complted: { isSuccess, errorMessage in
            ex.fulfill()
            XCTAssertTrue(isSuccess, errorMessage ?? "")
        })
        
        wait(for: [ex], timeout: 4)
    }
}
