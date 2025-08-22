/**
 * Description: Tests primality up to $SZ$. Runs faster if only
 	* odd indices are stored.
 * Time: O(SZ\log\log SZ) or O(SZ)
 * Source: KACTL 
 * Verification: https://open.kattis.com/problems/primesieve
 */

template<int SZ> struct LinearSieve { 
    vector<int> primes; array<int, SZ> spf{}; // smallest prime that divides
	LinearSieve() {
		for (int i = 2; i < SZ; ++i) { 
			if (spf[i] == 0) 
			spf[i] = i, primes.push_back(i); 
			for (int p: primes) {
				if (p > spf[i] || i*p >= SZ) break;
				spf[i*p] = p;
			}
		}
	}
};