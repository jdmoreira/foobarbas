# foobarbas
Tiny Tiny BASIC Interpreter in under 500 LOC of Swift. Implements a subset of the already [Tiny BASIC](https://en.wikipedia.org/wiki/Tiny_BASIC).

If you are looking for sample code on how to implement a simple parser or DSL in swift, this code should suit you.
The only dependencies are The Swift Standard Library and a Unix libc.
Pull requests are welcome.

### Build
```{r, engine='bash', count_lines}
$ swift build
Compile Swift Module 'foobarbas' (6 sources)
Linking ./.build/debug/foobarbas
```

### Run
```{r, engine='bash', count_lines}
$ ./.build/debug/foobarbas example-bas/factorial.bas
120
```

### Generate Xcode Project
```{r, engine='bash', count_lines}
$ swift package generate-xcodeproj
generated: ./foobarbas.xcodeproj
```

### Grammar
    program ::= line*
    
    line ::= number statement CR
    
    statement ::= PRINT expression
                  IF expression relop expression THEN statement
                  GOTO expression
                  LET var = expression
                  END
    
    relop ::= < (>|=|ε) | > (=|ε) | =
    
    expression ::= term | term (+|-) term
    
    term ::= factor | factor (*|/) factor
    
    factor ::= (-|ε)value | (expression)
    
    value ::= var | number
    
    var ::= A | B | C ... | Y | Z
    
    number ::= digit digit*
    
    digit ::= 0 | 1 | 2 | 3 | ... | 8 | 9
