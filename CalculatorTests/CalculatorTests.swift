

import XCTest
@testable import Calculator

class CalculatorTests: XCTestCase {

    var calculator: CalculatorCompute!

    override func setUp() {
        super.setUp()
        // Initialize a new CalculatorCompute instance before each test
        calculator = CalculatorCompute()
    }

    override func tearDown() {
        // Clean up after each test (optional for this simple case)
        calculator = nil
        super.tearDown()
    }

    // Test setting an operand
    func testSetOperand() {
        calculator.setOperand(operand: 123.45)
        XCTAssertEqual(calculator.result, 123.45, "Setting operand should update the result")
    }

    // Test constant operation Pi
    func testConstantPi() {
        calculator.performOperation(symbol: "π")
        XCTAssertEqual(calculator.result, Double.pi, accuracy: 0.000000001, "Pi constant should be set correctly")
    }

    // Test constant operation AC (All Clear)
    func testConstantAC() {
        calculator.setOperand(operand: 100)
        calculator.performOperation(symbol: "+")
        calculator.setOperand(operand: 50)
        calculator.performOperation(symbol: "AC") // AC is treated as a constant 0
        XCTAssertEqual(calculator.result, 0, "AC operation should reset the result to 0")
        // Note: The current implementation of AC in CalculatorCompute just sets result to 0.
        // It doesn't clear the pending binary operation. A more robust AC might clear pending.
        // Testing the current behavior.
        calculator.performOperation(symbol: "=") // Should not crash or perform old pending op
        XCTAssertEqual(calculator.result, 0, "AC should also effectively clear pending operations state")
    }

    // Test unary operation Square Root
    func testUnaryOperationSqrt() {
        calculator.setOperand(operand: 81.0)
        calculator.performOperation(symbol: "√")
        XCTAssertEqual(calculator.result, 9.0, "Square root of 81 should be 9")
    }

    // Test unary operation Plus/Minus
    func testUnaryOperationPlusMinus() {
        calculator.setOperand(operand: 25.0)
        calculator.performOperation(symbol: "±")
        XCTAssertEqual(calculator.result, -25.0, "Plus/Minus on 25 should be -25")

        calculator.setOperand(operand: -10.0)
        calculator.performOperation(symbol: "±")
        XCTAssertEqual(calculator.result, 10.0, "Plus/Minus on -10 should be 10")
    }

    // Test binary operation Addition
    func testBinaryOperationAdd() {
        calculator.setOperand(operand: 5.0)
        calculator.performOperation(symbol: "+")
        calculator.setOperand(operand: 3.0)
        calculator.performOperation(symbol: "=")
        XCTAssertEqual(calculator.result, 8.0, "5 + 3 should equal 8")
    }

    // Test binary operation Subtraction
    func testBinaryOperationSubtract() {
        calculator.setOperand(operand: 10.0)
        calculator.performOperation(symbol: "−") // Note: This is the minus sign, not hyphen
        calculator.setOperand(operand: 4.0)
        calculator.performOperation(symbol: "=")
        XCTAssertEqual(calculator.result, 6.0, "10 - 4 should equal 6")
    }

    // Test binary operation Multiplication
    func testBinaryOperationMultiply() {
        calculator.setOperand(operand: 6.0)
        calculator.performOperation(symbol: "×")
        calculator.setOperand(operand: 7.0)
        calculator.performOperation(symbol: "=")
        XCTAssertEqual(calculator.result, 42.0, "6 * 7 should equal 42")
    }

    // Test binary operation Division
    func testBinaryOperationDivide() {
        calculator.setOperand(operand: 20.0)
        calculator.performOperation(symbol: "÷")
        calculator.setOperand(operand: 5.0)
        calculator.performOperation(symbol: "=")
        XCTAssertEqual(calculator.result, 4.0, "20 / 5 should equal 4")
    }

    // Test division by zero
    func testDivisionByZero() {
        calculator.setOperand(operand: 10.0)
        calculator.performOperation(symbol: "÷")
        calculator.setOperand(operand: 0.0)
        calculator.performOperation(symbol: "=")
        // Division by zero in Swift Double results in infinity
        XCTAssertEqual(calculator.result, Double.infinity, "Division by zero should result in infinity")
    }

    // Test square root of a negative number
    func testSqrtNegativeNumber() {
        calculator.setOperand(operand: -9.0)
        calculator.performOperation(symbol: "√")
        // Square root of a negative number in Swift Double results in NaN (Not a Number)
        XCTAssertTrue(calculator.result.isNaN, "Square root of a negative number should result in NaN")
    }

    // Test chaining binary operations (e.g., 5 + 3 - 2 =)
    func testChainingOperations() {
        calculator.setOperand(operand: 5.0)
        calculator.performOperation(symbol: "+") // Pending: 5 + ...
        calculator.setOperand(operand: 3.0) // Current operand is 3
        calculator.performOperation(symbol: "−") // Performs 5 + 3 = 8, then sets pending: 8 - ...
        XCTAssertEqual(calculator.result, 8.0, "Result after 5 + 3 should be 8 before subtraction is set")
        calculator.setOperand(operand: 2.0) // Current operand is 2
        calculator.performOperation(symbol: "=") // Performs 8 - 2 = 6
        XCTAssertEqual(calculator.result, 6.0, "5 + 3 - 2 should equal 6")
    }

    // Test operation after equals (e.g., 5 + 3 = 8 + 2 =)
    func testOperationAfterEquals() {
        calculator.setOperand(operand: 5.0)
        calculator.performOperation(symbol: "+")
        calculator.setOperand(operand: 3.0)
        calculator.performOperation(symbol: "=") // Result is 8, pending is nil
        XCTAssertEqual(calculator.result, 8.0, "5 + 3 should equal 8")

        calculator.performOperation(symbol: "+") // Sets pending: 8 + ...
        calculator.setOperand(operand: 2.0) // Current operand is 2
        calculator.performOperation(symbol: "=") // Performs 8 + 2 = 10
        XCTAssertEqual(calculator.result, 10.0, "8 + 2 after previous calculation should equal 10")
    }

    // Test multiple operations without equals until the end (e.g., 10 * 5 / 2 + 3 =)
    func testComplexChaining() {
        calculator.setOperand(operand: 10.0)
        calculator.performOperation(symbol: "×") // Pending: 10 * ...
        calculator.setOperand(operand: 5.0) // Current operand is 5
        calculator.performOperation(symbol: "÷") // Performs 10 * 5 = 50, then sets pending: 50 / ...
        XCTAssertEqual(calculator.result, 50.0, "Result after 10 * 5 should be 50")
        calculator.setOperand(operand: 2.0) // Current operand is 2
        calculator.performOperation(symbol: "+") // Performs 50 / 2 = 25, then sets pending: 25 + ...
        XCTAssertEqual(calculator.result, 25.0, "Result after 50 / 2 should be 25")
        calculator.setOperand(operand: 3.0) // Current operand is 3
        calculator.performOperation(symbol: "=") // Performs 25 + 3 = 28
        XCTAssertEqual(calculator.result, 28.0, "10 * 5 / 2 + 3 should equal 28")
    }

    // Test pressing equals multiple times
    func testMultipleEquals() {
        calculator.setOperand(operand: 5.0)
        calculator.performOperation(symbol: "+")
        calculator.setOperand(operand: 3.0)
        calculator.performOperation(symbol: "=") // Result 8
        XCTAssertEqual(calculator.result, 8.0, "5 + 3 should equal 8")

        calculator.performOperation(symbol: "=") // Pressing equals again should not change the result if no pending operation
        XCTAssertEqual(calculator.result, 8.0, "Pressing equals again should not change the result")
    }

    // Test mixing unary and binary operations
    func testMixingUnaryAndBinary() {
        calculator.setOperand(operand: 9.0)
        calculator.performOperation(symbol: "√") // Result is 3
        XCTAssertEqual(calculator.result, 3.0, "Sqrt of 9 should be 3")

        calculator.performOperation(symbol: "×") // Pending: 3 * ...
        calculator.setOperand(operand: 4.0) // Current operand is 4
        calculator.performOperation(symbol: "=") // Performs 3 * 4 = 12
        XCTAssertEqual(calculator.result, 12.0, "Sqrt(9) * 4 should equal 12")
    }
}
