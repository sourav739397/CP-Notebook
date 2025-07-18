auto dfs = [&](this auto&& self, int u)-> void {
    visited[u] = true;
    for (auto& v: adj[u]) {
        if (!visited[v]) {
            self(v);
        }
    }
};