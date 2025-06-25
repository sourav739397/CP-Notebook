/*
 *  Description: count the number of ways to construct sum n by throwing a dice
 *  Verification: https://cses.fi/problemset/task/1633/
 *  Time Complexity: O(N)
*/

#include <bits/stdc++.h>
using namespace std;

#ifdef LOCAL
#include "debug.h"
#else
#define dbg(...)
#endif

constexpr int MOD = 1'000'000'007;

int32_t main() {
    cin.tie(0)-> sync_with_stdio(0);
    
    int n;
    cin >> n;
    vector<int64_t> DP(n+1);
    DP[0] = 1;
    for (int i = 1; i <= n; ++i) {
        for (int d = 1; d <= 6 and i-d >= 0; ++d) {
            DP[i] += DP[i-d];
            DP[i] %= MOD;
        }
    }
    cout << DP[n] << "\n";

    return 0;
}