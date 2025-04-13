#include <bits/stdc++.h>
using namespace std;
#define uid(a, b) uniform_int_distribution<int>(a, b)(rng)
mt19937 rng(chrono::steady_clock::now().time_since_epoch().count());




int main() {
    cout << 1 << "\n";
    int n = 1E5, q = 1E5;
    cout << n << " " << q << "\n";
    for(int i = 0; i < n; ++i) {
        cout << uid(0, 1);
    }
    cout << "\n";

    for(int i = 0; i < q; ++i) {
        int l = uid(1, n - 1);
        cout << l << " " << uid(l + 1, n) << "\n";
    }


    return 0;
}
