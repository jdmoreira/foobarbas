//
//  Lexer.swift
//  FOO.BAR.BAS

// MARK: Protocol
protocol Lexer {
    
    var line:UInt { get }
    var column:UInt { get }
    
    mutating func eat() -> Token
    mutating func peek() -> Token
    mutating func eat(until token: Token) -> Token
    
    init(input: Input)
}

// MARK: Implementation
struct SimpleLexer:Lexer {

    private var input: Input

    var line: UInt = 0
    var column: UInt = 0

    init(input: Input) {
        self.input = input
    }
    
    mutating func peek() -> Token {
        let beforeInput = input
        
        let tokenToReturn = eat()
        
        input = beforeInput
        return tokenToReturn
    }
    
    mutating func eat(until token: Token) -> Token {
        while (token != peek()) {
            let _ = eat()
        }
        return peek()
    }
    
    mutating func eat() -> Token {
        while(input.reachedEnd == false) {
            
            // Trim whitespaces and increment line / numbers
            switch input.char {
            case " ", "\t":
                self.column += 1
                input.advance()
                continue
            case "\n":
                self.line += 1
                self.column = 0
                input.advance()
                return Token._cr
            case "0", "1", "2", "3", "4",
                 "5", "6", "7", "8", "9":
                guard let token = Token(rawValue: String(input.char)) else {
                    terminate(msg: "Lexer: Can't find token for \(input.char) at line:\(line) column:\(column)",
                              status: .dataError)
                }
                input.advance()
                return token
            default:
                break
            }
            
            // Tokens
            var nextTokenStr = ""
            loop: while(true) {
                switch input.char {
                case " ", "\t", "\n":
                    break loop
                default:
                    nextTokenStr += String(input.char)
                    input.advance()
                }
            }
            
            guard let token = Token(rawValue: nextTokenStr) else {
                terminate(msg: "Lexer: Invalid token \"\(nextTokenStr)\" at line:\(line) column:\(column)",
                          status: .dataError)
            }
            
            return token
        }
        
        terminate(msg: "Lexer: Reached end of input at line:\(line) column:\(column)",
                  status: .dataError)
    }
}

// MARK: AUX
private extension BasicParser {

}
