# Number Theory

#### Sieve of Eratosthenes
1. [Bear and Prime Numbers](https://codeforces.com/problemset/problem/385/C)
    - Combine some subproblem together and care about them individually
    - By frequency count and Sieve of Eratosthenes for every prime number $p$ calculate $f(p)$
    - Finally, answer the query by prefix sum and shouldn't forget that right boundaries of intervals can be greater than $10^7$
    - Time complexity : $Nlog(N)$