#include <bits/stdc++.h>
using namespace std;

#ifdef LOCAL
#include "debug.h"
#else
#define dbg(...)
#endif

string smallestPalindrome(string s) {
    int n = s.size();
    map<char, int> M;
    for(int i = 0; i < n; ++i) {
        M[s[i]]++;
    }
    string ans = s;
    int l = 0, r = n - 1;
    for(auto [k, c]: M) {
        while(c > 0) {
            if(c == 1) {
                ans[n / 2] = k;
                c--;
            }
            else {
                ans[l] = k, ans[r] = k;
                l++, r--;
                c -= 2;
            }
        }
    }
    return ans;
}

int32_t main() {
    ios::sync_with_stdio(0);
    cin.tie(nullptr);
    
    string s;
    cin >> s;
    cout << smallestPalindrome(s) << "\n";

    return 0;
}