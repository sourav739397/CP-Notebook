/*
 *  Description: Count number of subarrays whose sum is x
 *  Verification: https://cses.fi/problemset/task/1661/
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

struct chash {
   const uint64_t C = int64_t(4e18*acos(0))+71;
   const uint64_t RANDOM = chrono::steady_clock::now().time_since_epoch().count();
   size_t operator()(int64_t x) const { return __builtin_bswap64((x^RANDOM)*C); }
};

int32_t main() {
    cin.tie(0)-> sync_with_stdio(0);
    
    int n;    cin >> n;
    int64_t x;  cin >> x;

    int64_t sum = 0, ans = 0;
    gp_hash_table<int64_t, int, chash> F; F[0] = 1;
    for (int i = 0; i < n; ++i) {
        int a; cin >> a; sum += a; 
        if (F.find(sum-x) != F.end()) {
            ans += F[sum-x];
        }
        F[sum]++;
    }
    cout << ans << "\n";
    
    return 0;
}