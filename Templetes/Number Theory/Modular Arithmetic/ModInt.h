struct Z {
    static constexpr int MOD = 1'000'000'007;
    int v; explicit operator int() const { return v; }
    Z():v(0) {}
    Z(int64_t _v) { v = int((-MOD < _v && _v < MOD) ? _v : _v % MOD); if (v < 0) v += MOD; }

    bool operator==(const Z& o) const { return v == o.v; }
    friend bool operator!=(const Z& a, const Z& b) { return !(a == b); }
    friend bool operator<(const Z& a, const Z& b) { return a.v < b.v; }
    Z& operator+=(const Z& o) { if ((v += o.v) >= MOD) v -= MOD; return *this; }
    Z& operator-=(const Z& o) { if ((v -= o.v) < 0) v += MOD; return *this; }
    Z& operator*=(const Z& o) { v = int((int64_t)v*o.v%MOD); return *this; }
    Z& operator/=(const Z& o) { return (*this) *= inv(o); }

    friend Z pow(Z a, int64_t p) {
        Z ans = 1; assert(p >= 0);
        for (; p; p /= 2, a *= a) if (p&1) ans *= a;
        return ans; 
    }
    friend Z inv(const Z& a) { assert(a.v != 0); return pow(a,MOD-2); }

    Z operator-() const { return Z(-v); }
    Z& operator++() { return *this += 1; }
    Z& operator--() { return *this -= 1; }
    friend Z operator+(Z a, const Z& b) { return a += b; }
    friend Z operator-(Z a, const Z& b) { return a -= b; }
    friend Z operator*(Z a, const Z& b) { return a *= b; }
    friend Z operator/(Z a, const Z& b) { return a /= b; }

    friend ostream &operator<<(ostream &os, const Z &a) { return os << a.v; }
    friend istream &operator>>(istream &is, Z &a) { int64_t v; is >> v; a = Z(v); return is; }
};