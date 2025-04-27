#include <bits/stdc++.h>
using namespace std;

#ifdef LOCAL
#include "debug.h"
#else
#define dbg(...)
#endif

constexpr int N = 2E5 + 5;

int32_t main() {
    ios::sync_with_stdio(0);
    cin.tie(nullptr);
    
    vector<int64_t> dp(N);
    for (int i = 1; i < N; ++i) {
        int x = i, c = 0;
        while (x) {
            c++;
            x /= 3;
        }
        dp[i] = dp[i - 1] + c;
    }

    int Q; cin >> Q;
    do [&](){
        int l, r; 
        cin >> l >> r;
        cout << dp[r] + dp[l] - 2 * dp[l - 1] << "\n";
    }(); while(--Q);

    return 0;
}