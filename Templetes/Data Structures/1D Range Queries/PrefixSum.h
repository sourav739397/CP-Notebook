template<typename T> struct PrefixSum {
    vector<T> pre;
    PrefixSum (const auto& arr) {
        int n = arr.size()+1;
        pre.assign(n, T{});
        for (int i = 1; i < n; ++i) {
            pre[i] = a[i-1] + pre[i-1];
        }
    }

    T query (int l, int r) {
        return pre[r] - pre[l-1];
    }
};
