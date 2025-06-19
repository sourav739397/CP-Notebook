/*
 *  Description: Count number of subarrays sum divisible by x
 *  Verification: https://cses.fi/problemset/task/1662
 *  Time Complexity: O(n)
*/

#include <bits/stdc++.h>
#include <ext/pb_ds/assoc_container.hpp>
using namespace std;
using namespace __gnu_pbds;

#ifdef LOCAL
#include "debug.h"
#else
#define dbg(...)
#endif

int32_t main() {
    cin.tie(0)-> sync_with_stdio(0);
    
    int n;    cin >> n;

    gp_hash_table<int, int> F;
    int64_t sum = 0, ans = 0; F[0] = 1;
    for (int i = 0; i < n; ++i) {
        int x; cin >> x;
        sum += x; sum = ((sum%n) + n) % n;
        ans += F[sum];
        F[sum]++;
    }
    cout << ans << "\n";
    
    return 0;
}