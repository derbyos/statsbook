import XCTest
@testable import statsbook

final class statsbookTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(statsbook().text, "Hello, World!")
    }
    
    func loadBlankFile() throws -> StatsBookFile {
        try .init(URL(fileURLWithPath: "/Users/gandreas/Downloads/wftda-statsbook-full-us-letter.xlsx"))
    }
    func loadSampleFile() throws -> StatsBookFile {
        try .init(URL(fileURLWithPath: "/Users/gandreas/Downloads/STATS-2023-04-30_NSRDSupernovas_vs_DRDAllstars_1.xlsx"))
    }

    func testLoading() throws {
        let file = try loadBlankFile()
        print(file.zipFile.entries.keys)
        XCTAssertEqual(try file.sheet(named: "Read Me")[row: 1, col: "A"]?.stringValue, "Women\'s Flat Track Derby Association")
        XCTAssertEqual(file.igrf.sheet[row: 3, col: "L"]?.comment, """
Hint:
Use this for doubleheaders or multi-game events. It will print on other sheets. 

Does not have to be entered as "A" or "B"; alphanumeric and multiple characters are honored.
""")
    }
    
    func testAddresses() {
        let a1 = Address(row: 5, column: "B")
        XCTAssertEqual(a1.adding(row: 3).row, a1.row + 3)
        XCTAssertEqual(a1.adding(column: 1).column, "C")
        XCTAssertEqual(Address(row: 5, column: "Z").adding(column: 1).column, "AA")
        XCTAssertEqual(Address(row: 5, column: "AA").adding(column: -1).column, "Z")
    }
    
    func testRead() throws {
        let file = try loadSampleFile()
        let igrf = file.igrf
        XCTAssertEqual(igrf.home.league, "North Star Roller Derby")
//        print("\(igrf.home.league ?? "")")
    }
    
    func testFormula() throws {
        let file = try loadSampleFile()
        let sheet = try file.sheet(named: "Score")
        // home color
        let cell = sheet[row: 1, col: "A"]!
        let formula = cell.formula!
//        print(try formula.eval())
        XCTAssertEqual(try formula.eval(), "North Star Roller Derby / NSRD Supernovas")
        
        let formula2 = sheet[row: 42, col: "A"]!.formula!
        XCTAssertEqual(try formula2.eval(), 20.0)
        let formula4 = sheet[row: 42, col: "T"]!.formula!
        XCTAssertEqual(try formula4.eval(), 20.0)
        // this is a shared formula
        let formula5 = sheet[row: 5, col: "Q"]!.formula!
        XCTAssertEqual(try formula5.eval(), 3.0)
        let formula3 = sheet[row: 42, col: "V"]!.formula!
        XCTAssertEqual(try formula3.eval(), 3.0)
        
        for row in 1...84 {
            var cols = [String]()
            for col in 0 ... 37 {
                guard let f = sheet[row: row, col: Address.columnName(col)], let value = try f.eval(force: true) else {
                    cols.append("")
                    continue
                }
                switch value {
                case .bool(let b):
                    cols.append(String(describing: b))
                case .number(let d):
                    cols.append(String(describing: d))
                case .string(let s):
                    cols.append(s)
                case .undefined:
                    cols.append("*")
                }
            }
            print(row, cols.joined(separator: "|"))
        }
    }
}
