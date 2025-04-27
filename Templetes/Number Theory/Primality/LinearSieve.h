/**
 * Description: Tests primality up to $SZ$. Runs faster if only
 	* odd indices are stored.
 * Time: O(SZ\log\log SZ) or O(SZ)
 * Source: KACTL 
 * Verification: https://open.kattis.com/problems/primesieve
 */

 template<int SZ> struct LinearSieve { 

    vector<int> primes; int spf[SZ]{}; // smallest prime that divides
	LinearSieve() {
		for (int i = 0; i < n; ++i) { 
			if (spf[i] == 0) spf[i] = i, primes.push_back(i); 
			for (int p: primes) {
				if (p > sp[i] || i*p >= SZ) break;
				sp[i*p] = p;
			}
		}
	}
};