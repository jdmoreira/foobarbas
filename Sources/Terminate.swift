//
//  Error.swift
//  FOO.BAR.BAS

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

enum TerminationStatus {
    case success
    case usage
    case noInput
    case dataError
}

func terminate(msg:String? = nil, status:TerminationStatus = .success) -> Never {
    
    if let msg = msg {
        fputs(msg + "\n", stderr)
    }
    
    switch status {
    case .success:
        exit(EX_OK)
    case .usage:
        exit(EX_USAGE)
    case .noInput:
        exit(EX_NOINPUT)
    case .dataError:
        exit(EX_DATAERR)
    }
}
