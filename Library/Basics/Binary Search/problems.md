# Binary Search

1. [CSES - Multiplication Table](https://cses.fi/problemset/task/2422)
    - Task : Median of the numbers in an $n \times n$ multiplication table
    - Binary Search on answer
    - Range : 1 - $n^2$ and f(x) = count frequency less than or equal to x
    - Smallest f(x) > $n^2/2$
    - Check : For $i^{th}$ row, $x/i$ column value is less than or equal to x
    - Time Complexity : $Nlog(N)$