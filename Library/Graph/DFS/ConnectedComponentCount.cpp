/*
 *  Description: Count the number of connected component.
 *  Verification: https://cses.fi/problemset/task/1666
 *  Time Complexity: O(n+m)
*/

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
	
	int n, m;
	cin >> n >> m;
 
	vector adj(n, vector<int> ());
	for (int i = 0; i < m; ++i) {
		int u, v;
		cin >> u >> v;
		u--, v--;
		adj[u].push_back(v);
		adj[v].push_back(u);
	}
 
	vector<int> visited(n);
	auto dfs = [&](auto self, int u) -> void{
		visited[u] = true;
		for (auto& v: adj[u]) {
			if (!visited[v]) {
				self(self, v);
			}
		}
	};
 
	vector<int> ans;
	for (int i = 0; i < n; ++i) {
		if (!visited[i]) {
			dfs(dfs, i);
			ans.push_back(i);
		}
	}
 
	cout << ans.size()-1 << "\n";
	for (int i = 1; i < (int)ans.size(); ++i) {
		cout << "1 " << ans[i]+1 << "\n";
	}
 
	return 0;
}
