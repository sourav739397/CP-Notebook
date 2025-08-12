template<typename T> struct PrefixSum {
    vector<T> sum;
    PrefixSum (const vector<T>& v) {
        int n = v.size();
        sum.assign(n+1, T{});
        for (int i = 0; i < n; ++i) {
            sum[i+1] = v[i]+sum[i];
        }
    }
    T query (int l, int r) { return sum[r]-sum[l-1]; }
};
