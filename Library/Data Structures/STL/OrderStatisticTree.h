/**
 * Description: A set (not multiset!) with support for finding the $n$'th
   * element, and finding the index of an element. Change null_type to get a map.
 * Time: O(\log N)
 * Source: KACTL
   * https://codeforces.com/blog/entry/11080
 * Verification: many
*/

#include <ext/pb_ds/assoc_container.hpp>
using namespace __gnu_pbds;
template<typename T> 
using Tree = tree<T, null_type, less<T>, 
rb_tree_tag, tree_order_statistics_node_update>;