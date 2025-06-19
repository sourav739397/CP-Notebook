/*
 *  Description: Count number of subarrays whose sum is divisible by x
 *  Verification: https://cses.fi/problemset/task/1662
 *  Time Complexity: O(n)
*/

#include <bits/stdc++.h>
using namespace std;

#ifdef LOCAL
#include "debug.h"
#else
#define dbg(...)
#endif

int32_t main() {
    cin.tie(0)-> sync_with_stdio(0);
    
    int n;    cin >> n;

    int64_t ans = 0; 
    vector<int> F(n); F[0] = 1; // use gp_hash_table value of x is >= 10^6
    for (int i = 0, sum = 0; i < n; ++i) {
        int x; cin >> x;
        sum += x; sum = ((sum%n) + n) % n;
        ans += F[sum];
        F[sum]++;
    }
    cout << ans << "\n";
    
    return 0;
}