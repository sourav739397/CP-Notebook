template<typename T> struct PrefixSum {
    vector<T> pre;
    PrefixSum (const auto& arr) {
        int n = arr.size();
        pre.assign(n+1, T{});
        for (int i = 0; i < n; ++i) {
            pre[i+1] = arr[i] + pre[i];
        }
    }

    T query (int l, int r) { return pre[r] - pre[l-1]; }
};
