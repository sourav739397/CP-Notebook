/*
*   Description: Integer factorization
*   Time: O(sqrt N)
*   Source: https://github.com/bqi343/cp-notebook
*/

template<class T> vector<pair<T,int>> factor(T x) { 
	vector<pair<T, int>> factorization;
	for (T i = 2; i*i <= x; ++i) if (x % i == 0) {
		int t = 0;
		while (x % i == 0) x /= i, t ++;
		factorization.push_back({i,t});
	}
	if (x > 1) factorization.push_back({x,1});
	return factorization;
}