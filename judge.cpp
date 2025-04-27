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
        int n , m;
        cin >> n >> m;

        vector<int> a(n);
        for(auto& _ : a) cin >> _;
        vector<int> b(m);
        for(auto& _ : b) cin >> _;
        

        int ans = 1E9;
        for (int k = 0; k < 100; ++k) {
            for (int i = 0; i <= n; ++i) {
                vector<int> t = a;
                t.insert(t.begin() + i, k);
                int l = 0, r = 0, c= 0;
                while (l <= n and r < m) {
                    if (t[l] >= b[r]) {
                        l++, r++, c++;
                    }
                    else {
                        l++;
                    }
                }
                if (c >= m) ans = min(ans, k);
            }
        }
        cout << (ans == 1E9 ? -1 : ans) << "\n";
    }(); while(--Q);

    return 0;
}