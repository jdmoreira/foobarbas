//
//  Input.swift
//  FOO.BAR.BAS

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

// MARK: Protocol
protocol Input {
    var reachedEnd: Bool { get }
    var char: Character { get }
    mutating func advance()
}

// MARK: Implementation
struct FDInput: Input {
    private let fd: Int32
    private var offset: off_t
    
    var reachedEnd: Bool {
        let buffer = [UInt8](repeating: 0, count: 1)
        return pread(fd, UnsafeMutablePointer(mutating: buffer), 1, offset) == 0
    }
    
    var char: Character {
        
        // 6 bytes seems to be a safe bet for the largest utf-8 codepoint
        let buffer = [UInt8](repeating: 0, count: 6)
        pread(fd, UnsafeMutablePointer(mutating: buffer), 6, offset)
        
        guard let char = String(cString: buffer).characters.first else {
            terminate(msg: "Input: Invalid UTF-8 code point", status: .dataError)
        }
        
        return char
    }
    
    mutating func advance() {
        offset += String(self.char).utf8.count
    }
    
    init(fd:Int32) {
        offset = lseek(fd, 0, SEEK_SET)
        self.fd = fd
    }
}
