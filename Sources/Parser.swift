//
//  Parser.swift
//  FOO.BAR.BAS

// MARK: Protocol
protocol Parser {
    mutating func run()
    init(lexer:Lexer)
}

// MARK: Implementation
struct BasicParser: Parser {
    fileprivate var lexer: Lexer
    
    fileprivate var variables: [String : Int] = [ : ]
    fileprivate var lines: [Int : Lexer] = [ : ]
    
    mutating func run() {
        preparse() // We need to populate the lines array
        program()  // The entry point for the parser
    }
    
    init(lexer: Lexer) {
        self.lexer = lexer
    }
}

// MARK: AUX
private extension BasicParser {
    
    mutating func preparse() {
        let beforeLexer = lexer
        while(true) {
            if let lineNumber = number() {
                lines[lineNumber] = self.lexer
            }
            if(lexer.peek() == ._end) {
                break
            } else {
                let _ = lexer.eat(until: ._cr)
            }
            guard case Token._cr = lexer.eat() else {
                error(msg: "Not a line. Must end with a CR")
            }
        }
        lexer = beforeLexer
    }
    
    func error(msg: String) -> Never {
        terminate(msg: "Parser: \(msg)\nline:\(lexer.line) column:\(lexer.column)",
                  status: .dataError)
    }
}

// MARK: Recursive Descent Parser
private extension BasicParser {
    
    mutating func number() -> Int? {
        var number: Int? = nil
        
        while(true) {
            var digit: Int
            switch lexer.peek() {
            case ._0:
                digit = 0
            case ._1:
                digit = 1
            case ._2:
                digit = 2
            case ._3:
                digit = 3
            case ._4:
                digit = 4
            case ._5:
                digit = 5
            case ._6:
                digit = 6
            case ._7:
                digit = 7
            case ._8:
                digit = 8
            case ._9:
                digit = 9
            default:
                return number
            }
            
            number = number ?? 0
            number! *= 10
            number! += digit
            let _ = lexer.eat()
        }
    }
    
    mutating func variable() -> String? {
        switch lexer.peek() {
        case ._A, ._B, ._C, ._D, ._E, ._F, ._G,
             ._H, ._I, ._J, ._K, ._L, ._M, ._N,
             ._O, ._P, ._Q, ._R, ._S, ._T, ._U,
             ._V, ._W, ._X, ._Y, ._Z:
            return lexer.eat().rawValue
        default:
            return nil
        }
    }
    
    mutating func relop() -> Bool {
        let lhs = expression()
        let relop = lexer.eat()
        let rhs = expression()
        
        switch relop {
        case ._less:
            return lhs < rhs
        case ._greater:
            return lhs > rhs
        case ._equal:
            return lhs == rhs
        case ._lessOrEqual:
            return lhs <= rhs
        case ._greaterOrEqual:
            return lhs >= rhs
        case ._notEqual:
            return lhs != rhs
        default:
            error(msg: "Not a relop. Invalid token")
        }
    }
    
    mutating func value() -> Int {
        if let number = number() {
            return Int(number)
        } else if let variableName = variable() {
            guard let val = variables[variableName] else {
                error(msg: "Use of undeclared variable \(variableName)")
            }
            
            return val
        }
        
        error(msg: "Not a value. Invalid token")
    }
    
    mutating func factor() -> Int {
        var multiplier = 1
        
        switch lexer.peek() {
        case ._parenthesisLeft:
            let _ = lexer.eat() // left  parenthesis
            let retVal = expression()
            let _ = lexer.eat() // right parenthesis
            return retVal
        case ._minus:
            let _ = lexer.eat() // -
            multiplier = -1
            fallthrough
        default:
            return value() * multiplier
        }
    }
    
    mutating func term() -> Int {
        let lhs = factor() // 1st factor
        
        switch lexer.peek() {
        case ._asterisk:
            let _ = lexer.eat() // *
            return lhs * factor()
        case ._slash:
            let _ = lexer.eat() // /
            return lhs / factor()
        default:
            return lhs // 2nd factor is optional
        }
    }
    
    mutating func expression() -> Int {
        let lhs = term() // 1st term
        
        switch lexer.peek() {
        case ._plus:
            let _ = lexer.eat() // +
            return lhs + term()
        case ._minus:
            let _ = lexer.eat() // -
            return lhs - term()
        default:
            return lhs // 2nd term is optional
        }
    }
    
    mutating func statement() -> Bool {
        switch lexer.eat() {
        case ._print:
            print(expression())
        case ._if:
            if relop() {
                guard case Token._then = lexer.eat() else {
                    error(msg: "Not a statement. missing 'THEN' in 'IF' statement")
                }
                return statement()
            } else {
                let _ = lexer.eat(until: ._cr)
                return false
            }
        case ._goto:
            let lineNum = expression()
            self.lexer = lines[lineNum]!
            return true
        case ._let:
            guard let variableName = variable() else {
                error(msg: "Not a statement. Missing a variable in 'LET' statement")
            }
            guard case Token._equal = lexer.eat() else {
                error(msg: "Not a statement. Missing an '=' in 'LET' statement")
            }
            variables[variableName] = expression()
        case ._end:
            terminate() // We are done. Success!
        default:
            error(msg: "Not a statement. First token is invalid")
        }
        return false
    }
    
    mutating func line() {
        let _ = number()
        if statement() { // 'GOTO' returns true
            return       // and we need to skip the 'CR' check
        }
        guard case Token._cr = lexer.eat() else {
            error(msg:"Not a line. Must end with a CR")
        }
    }
    
    mutating func program() {
        while(true) {
            line()
        }
    }
}
