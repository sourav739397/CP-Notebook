template<int SZ> struct TreeDiameter {
	int N, par[SZ], dist[SZ], diaLen;  
	vector<int> adj[SZ], dia, center;
	void eg(int a, int b) { 
        adj[a].push_back(b);
        adj[b].push_back(a); 
    }
	void dfs(int u) {
		for (auto& v: adj[u]) if (v != par[u]) {
            par[v] = u; 
            dist[v] = dist[u]+1; 
            dfs(v); 
        }
	}
	void genDist(int u) { par[u] = -1; dist[u] = 0; dfs(u); }
	void init(int _N) {
		N = _N; dia = {0,0}; 
		genDist(0); 
        for (int i = 0; i < N; ++i) { 
			if (dist[i]>dist[dia[0]]) dia[0] = i; 
		}
        genDist(dia[0]); 
        for (int i = 0; i < N; ++i) { 
			if (dist[i]>dist[dia[1]]) dia[1] = i; 
		} 
		diaLen = dist[dia[1]];
		int cen = dia[1]; 
        for (int i = 0; i < diaLen/2; ++i) { cen = par[cen]; }
		center = {cen}; if (diaLen&1) center.push_back(par[cen]);
	}
};
