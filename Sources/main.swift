//
//  main.swift
//  FOO.BAR.BAS

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

guard CommandLine.arguments.count == 2 else {
    terminate(msg: "USAGE:\n\t\(CommandLine.arguments[0]) sourcefile",
              status: .usage)
}

let fd = open(CommandLine.arguments[1], O_RDONLY)
guard fd >= 0 else {
    var msg = "Error opening \(CommandLine.arguments[1])"
    msg += "\n" + String(cString: strerror(errno))
    terminate(msg: msg, status: .noInput)
}

var parser: Parser = BasicParser(lexer: SimpleLexer(input: FDInput(fd: fd)))
parser.run()
