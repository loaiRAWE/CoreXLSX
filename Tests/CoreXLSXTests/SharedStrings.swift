//
//  SharedStrings.swift
//  CoreXLSXTests
//
//  Created by Max Desiatov on 30/11/2018.
//

@testable import CoreXLSX
import XCTest
import XMLCoder

private let parsed = SharedStrings(uniqueCount: 18, items: [
  SharedStrings.Item(text: "Table 1", richText: []),
  SharedStrings.Item(text: "Item", richText: []),
  SharedStrings.Item(text: "Name", richText: []),
  SharedStrings.Item(text: "Amount", richText: []),
  SharedStrings.Item(text: "Name:", richText: []),
  SharedStrings.Item(text: "Subtotal:", richText: []),
  SharedStrings.Item(text: "Andy", richText: []),
  SharedStrings.Item(text: "Item 1", richText: []),
  SharedStrings.Item(text: "Item 2", richText: []),
  SharedStrings.Item(text: "Item 3", richText: []),
  SharedStrings.Item(text: "Item 4", richText: []),
  SharedStrings.Item(text: "Item 5", richText: []),
  SharedStrings.Item(text: "Chloe", richText: []),
  SharedStrings.Item(text: "Item 6", richText: []),
  SharedStrings.Item(text: "Item 7", richText: []),
  SharedStrings.Item(text: "Item 8", richText: []),
  SharedStrings.Item(text: "Item 9", richText: []),
  SharedStrings.Item(text: "Item 10", richText: []),
])

private let columnC = ["Name", "Andy", "Andy", "Andy", "Andy", "Andy",
                       "Chloe", "Chloe", "Chloe", "Chloe", "Chloe"]

private let spacePreserveXML = """
<sst uniqueCount="1">
  <si>
    <r>
      <rPr>
        <sz val="10"/>
        <color indexed="8"/>
        <rFont val="Helvetica Neue"/>
      </rPr>
      <t xml:space="preserve"> the </t>
    </r>
  </si>
</sst>
""".data(using: .utf8)!

private let richTextXML = """
<sst uniqueCount="2">
  <si>
    <t>My Cell</t>
  </si>
  <si>
    <r>
      <rPr>
        <sz val="11"/>
        <color rgb="FFFF0000"/>
        <rFont val="Calibri"/>
        <family val="2"/>
        <scheme val="minor"/>
      </rPr>
      <t>Cell</t>
    </r>
    <r>
      <rPr>
        <b/>
        <sz val="11"/>
        <color theme="1"/>
        <rFont val="Calibri"/>
        <family val="2"/>
        <scheme val="minor"/>
      </rPr>
      <t>A2</t>
    </r>
  </si>
</sst>
""".data(using: .utf8)!

final class SharedStringsTests: XCTestCase {
  func testSharedStrings() throws {
    guard let file =
      XLSXFile(filepath: "\(currentWorkingPath)/categories.xlsx") else {
      XCTAssert(false, "failed to open the file")
      return
    }

    let sharedStrings = try file.parseSharedStrings()

    // check each individual item so that it's easier to debug when something
    // goes wrong
    for (i, item) in sharedStrings.items.enumerated() {
      XCTAssertEqual(item, parsed.items[i])
    }

    // check the complete value anyway to make sure all properties are equal
    XCTAssertEqual(sharedStrings, parsed)
  }

  func testSharedStringsOrder() throws {
    guard let file =
      XLSXFile(filepath: "\(currentWorkingPath)/categories.xlsx") else {
      XCTAssert(false, "failed to open the file")
      return
    }

    let sharedStrings = try file.parseSharedStrings()

    var columnCStrings: [String] = []

    for path in try file.parseWorksheetPaths() {
      let ws = try file.parseWorksheet(at: path)
      columnCStrings = ws.cells(atColumns: [ColumnReference("C")!])
        .filter { $0.type == "s" }
        .compactMap { $0.value }
        .compactMap { Int($0) }
        .compactMap { sharedStrings.items[$0].text }
    }

    XCTAssertEqual(columnC, columnCStrings)
  }

  func testSpacePreserve() throws {
    let decoder = XMLDecoder()
    let strings = try decoder.decode(SharedStrings.self, from: spacePreserveXML)
    XCTAssertEqual(strings.items.count, 1)
  }

  func testRichTextXML() throws {
    let decoder = XMLDecoder()
    let strings = try decoder.decode(SharedStrings.self, from: richTextXML)
    let text = strings.items[1].richText.reduce("") { (t, rt) -> String in
      t + (rt.text ?? "")
    }
    XCTAssertEqual(text, "CellA2")
  }

  static let allTests = [
    ("testSharedStrings", testSharedStrings),
    ("testSharedStringsOrder", testSharedStringsOrder),
    ("testSharedStringsRichText", testRichTextXML),
  ]
}
