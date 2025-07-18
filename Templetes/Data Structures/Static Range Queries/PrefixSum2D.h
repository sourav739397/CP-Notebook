template<typename T> struct PrefixSum2D {
    vector<vector<T>> pre;
    PrefixSum2D (const auto& grid) {
        int n = grid.size()+1, m = grid[0].size()+1;
        pre.assign(n, vector<T>(m, T{}));
        for (int i = 1; i < n; ++i) {
            for (int j = 1; j < m; ++j) {
                pre[i][j] = grid[i-1][j-1] + pre[i-1][j] + pre[i][j-1] - pre[i-1][j-1];
            }
        }
    }

    T query (int r1, int c1, int r2, int c2) {
        return pre[r2][c2] - pre[r1-1][c2] - pre[r2][c1-1] + pre[r1-1][c1-1];
    }
};
