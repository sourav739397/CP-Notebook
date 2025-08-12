struct chash { 
    const uint64_t C = int64_t(4e18*acos(0))+71; 
    const uint64_t RANDOM =  
        chrono::steady_clock::now().time_since_epoch().count();
    int64_t operator()(int64_t x) const { 
        return __builtin_bswap64((x^RANDOM)*C); }
};
