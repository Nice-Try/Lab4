# Array loop assembly test

Simple test of load/store operations

## Expected results

Each element of `my_array` will be incremented by 5.

## Memory layout requirements

Allocate array `my_array` in .data segment:

| address | initial value | final value |
|---------|---------------|-------------|
| 00      | 0x00000000    | 0x00000005  | 
| 04      | 0x11110000    | 0x11110005  | 
| 08      | 0x22220000    | 0x22220005  | 
| 12      | 0x33330000    | 0x33330005  | 
| 16      | 0x44440000    | 0x44440005  | 
| 20      | 0x55550000    | 0x55550005  | 
| 24      | 0x66660000    | 0x66660005  | 
| 28      | 0x77770000    | 0x77770005  | 
| 32      | 0x88880000    | 0x88880005  | 
| 36      | 0x99990000    | 0x99990005  | 
| 40      | 0xAAAA0000    | 0xAAAA0005  | 
| 44      | 0xBBBB0000    | 0xBBBB0005  | 
| 48      | 0xCCCC0000    | 0xCCCC0005  | 
| 52      | 0xDDDD0000    | 0xDDDD0005  | 
| 56      | 0xEEEE0000    | 0xEEEE0005  | 
| 60      | 0xFFFF0000    | 0xFFFF0005  | 


## Instructions required

 `addi, beq, lw, sw, j`
 
(all from basic subset)
