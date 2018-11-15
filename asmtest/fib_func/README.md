# Recursive Fibonacci assembly test

Simple test of recursive function calls

## Expected results

Computes Fibonacci(4) + Fibonacci(10) = 3 + 55 = 58.

Equivalent C code:

```C
     int Fibonacci(int n) {
         if (n == 0) return 0;  // Base case
         if (n == 1) return 1;  // Base case
         int fib_1 = Fibonacci(n - 1);
         int fib_2 = Fibonacci(n - 2);
         return fib_1+fib_2;
     }

     int fib_test(arg0, arg1) {
         return Fibonacci(arg0) + Fibonacci(arg1);
     }
```

Follows standard MIPS calling conventions:
 - arguments in `$a0` (and `$a1` for `fib_test`)
 - return value in `$v0`

## Memory layout requirements

No .data section required.

## Instructions required

 `add, addi, bne, lw, sw, j, jal, jr`
 
(all from basic subset)
