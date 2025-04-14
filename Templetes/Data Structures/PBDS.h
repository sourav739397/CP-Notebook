#include <ext/pb_ds/assoc_container.hpp>
using namespace __gnu_pbds;
template<typename T, typename Compare = less<T>>
using IndexedSet = tree<T, null_type, Compare, rb_tree_tag, tree_order_statistics_node_update>;