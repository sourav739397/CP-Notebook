#include <bits/stdc++.h>
using namespace std;

#ifdef LOCAL
#include "debug.h"
#else
#define dbg(...)
#endif

int32_t main() {
    ios::sync_with_stdio(0);
    cin.tie(nullptr);
    
    int Q; cin >> Q;
    do [&](){
        int n, k;
        cin >> n >> k;

        int ans = 0;
        set<int> S;
        for(int i = 1; i <= n; ++i) {
            int x; cin >> x;
            int y = abs(i - x) % k;
            if(y) {
                ans++;
                S.insert(y);
            }
        }

        dbg(ans);
        if(ans == 0) cout << "0\n";
        else if(ans == 2) cout << "1\n";
        else cout << "-1\n";
    }(); while(--Q);

    return 0;
}