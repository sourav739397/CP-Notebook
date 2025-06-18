/*
 *  Description: Deterministic Miller-Rabin primality test
 *  Verification: https://www.spoj.com/problems/PON/
 *  Time Complexity: O(log(n))
*/

#include <bits/stdc++.h>
using namespace std;

#ifdef LOCAL
#include "debug.h"
#else
#define dbg(...)
#endif

uint64_t modMul(uint64_t a, uint64_t b, const uint64_t mod) { 
    __int128_t mul = __int128(1) * a * b;
    return mul % mod;
}

uint64_t modPow(uint64_t a, uint64_t b, const uint64_t mod) {
    if (b == 0) return 1;
    uint64_t res = modPow(a,b/2,mod); 
    res = modMul(res,res,mod);
    return b&1 ? modMul(res,a,mod) : res;
}

bool isPrime(uint64_t n) {
	if (n < 2 || n % 6 % 4 != 1) return n-2 < 2;
	uint64_t A[] = {2, 325, 9375, 28178, 450775, 9780504, 1795265022},
	s = __builtin_ctzll(n-1), d = n>>s;
	for (auto& a : A) {   // ^ count trailing zeroes
		uint64_t p = modPow(a, d, n), i = s;
		while (p != 1 && p != n-1 && a%n && i--) p = modMul(p, p, n);
		if (p != n-1 && i != s) return 0;
    }
	return 1;
}

int32_t main() {
    cin.tie(0)-> sync_with_stdio(0);
    
    int Q; cin >> Q;
    do [&](){
        int64_t n;
        cin >> n;
        cout << (isPrime(n) ? "YES" : "NO") << "\n";
    }(); while(--Q);

    return 0;
}