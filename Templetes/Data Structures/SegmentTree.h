template <typename T> struct SegTree {
    const T ID{};
    T cmb(T a, T b) { return a + b; }
    int n = 1; vector<T> seg;
    SegTree(int SZ) {
        while (n < SZ) n *= 2;
        seg.assign(2*n, ID);
   }
    void pull(int p) { seg[p] = cmb(seg[2*p], seg[2*p+1]); }
    void update(int p, T val) { // set value at position p
        seg[p += n] = val;
        for (p /= 2; p; p /= 2) pull(p);
    }
    T query(int l, int r) { // zero-indexed, inclusive
        T ra = ID, rb = ID;
        for (l += n, r += n + 1; l < r; l /= 2, r /= 2) {
            if (l&1) ra = cmb(ra, seg[l++]);
            if (r&1) rb = cmb(seg[--r], rb);
        }
        return cmb(ra, rb);
    }
};

