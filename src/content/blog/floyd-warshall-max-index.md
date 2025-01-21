---
author: Joey Chau
pubDatetime: 2025-01-21T14:20:01.000+08:00
modDatetime:
title: Tricks about Maximum Index in Paths and Optimization for Floyd Warshall Algorithm
featured: false
draft: false
tags:
  - "shortest path"
  - "bitset"
description: A note about a trick of Floyd Warshall algorithm for problems about maximum index in paths.
---

## Table of contents

## [Prerequisite]: Floyd Warshall algorithm

[Floyd-Warshall algorithm](https://en.wikipedia.org/wiki/Floyd%E2%80%93Warshall_algorithm) is a simple dynamic programming for finding shortest paths between all pairs of vertices in a graph.

The essence of the algorithm is to calculate the minimum distance between two nodes $s$ and $t$ by trying all possible intermediate nodes $k$, which is shown in the following nested-loop (other implementation details are ommited here):

```cpp
for (int k = 1; k <= n; k++) {
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= n; j++) {
            dist[i][j] = min(dist[i][j], dist[i][k] + dist[k][j]);
        }
    }
}
```

What happen after each iteration of the outermost loop? The answer basically motivates the trick we are going to discuss.

## [Example 1]: AtCoder - ABC208 - D - Shortest Path Queries 2

We can start with an fairly easy problem for this trick idea: [AtCoder - ABC208 - D - Shortest Path Queries 2](https://atcoder.jp/contests/abc208/tasks/abc208_d).

Essentially, the problem asks for the minimum distance between two vertices $s$ and $t$ such that the maximum index in the path is in between $1$ and $k$.

Notice that after each iteration of the outermost loop of the Floyd-Warshall algorithm, the shortest path between any two vertices with maximum index less than $k$ is updated. More formally, denote $dist[i][j][k]$ as the minimum distance from node $i$ to node $j$ with paths using nodes in between $1$ and $k$. Then, we have the following recursive relation:

$$
\text{dist}(i, j, k)=\min\{\text{dist}(i, j, k-1), \text{dist}(i, k+1, k) + \text{dist}(k+1, j, k)\}
$$

> For implementation, we don't need a 3D array to store the intermediate distances. Instead we use two 2D arrays to store the distances in the current and next iteration.

Finally, the solution code in C++ is:

```cpp
#include <bits/stdc++.h>
using namespace std;
const long long INF = 1e18;

void solve() {
	int n, m;
	cin >> n >> m;
	vector<vector<long long>> dist(n+1, vector<long long>(n+1, INF));
	for (int i = 0; i < m; i++) {
		int a, b; long long c;
		cin >> a >> b >> c;
		dist[a][b] = c;
	}
	for (int i = 1; i <= n; i++) {
		dist[i][i] = 0;
	}

	long long ans = 0;
	for (int k = 1; k <= n; k++) {
		vector<vector<long long>> nxt_dist(n+1, vector<long long>(n+1, INF));
		for (int i = 1; i <= n; i++) {
			for (int j = 1; j <= n; j++) {
				nxt_dist[i][j] = min(dist[i][j], dist[i][k] + dist[k][j]);
				if (nxt_dist[i][j] < INF) ans += nxt_dist[i][j];
			}
		}
		dist = nxt_dist;
	}
	cout << ans << "\n";
}

int main() {
	ios::sync_with_stdio(0);
	int t=1;
	// cin >> t;
	while (t--) {
		solve();
	}
	return 0;
}
```

## [Example 2]: AtCoder - ABC287 - Ex - Directed Graph and Query

Now, let's move on to a more challenging problem: [AtCoder - ABC287 - Ex - Directed Graph and Query](https://atcoder.jp/contests/abc287/tasks/abc287_h).

To summarize, the problem defines the cost of a path as the maximum index of the nodes in the path. The task is to find the minimum cost of a path between two vertices $s$ and $t$.

From the other perspective, it is asking for the minimum $k$ such that there exists a path between $s$ and $t$ using only nodes with index less than or equal to $k$. Hence we can use the same idea from [the previous example](#example-1-atcoder---abc208---d---shortest-path-queries-2) to solve this problem.

However, for this problem, the constraint is $N \leq 2000$, which a $O(N^3)$ solution is not efficient enough. We need some optimization.

Since we are only considering reachability but not the path cost, a trick is to use `bitset` to optimize the time complexity of bitwise operations by a factor of $\frac{1}{32}$ or $\frac{1}{64}$. Check [this Codeforces blog post](https://codeforces.com/blog/entry/73558) for more details. More specifically, if there is a path from $i$ to $k$, then we can reach all nodes reachable from $k$ from $i$. The following code snippet shows the optimized solution:

```cpp
for (int k = 1; k <= n; k++) {
    for (int i = 1; i <= n; i++) {
        if (travel[i][k]) travel[i] |= travel[k];
    }
}
```

The complete code is as follows:

```cpp
#include <bits/stdc++.h>
using namespace std;
const int MAXN = 2001;

void solve() {
	int n, m;
    cin >> n >> m;
	vector<pair<int, int>> edges;
    for (int i = 0; i < m; i++) {
        int a, b;
        cin >> a >> b;
		edges.push_back(make_pair(a, b));
    }
	vector<bitset<MAXN>> travel(MAXN);
	for (int i = 1; i <= n; i++) travel[i][i] = 1;
	for (int i = 0; i < edges.size(); i++) {
		travel[edges[i].first][edges[i].second] = 1;
	}
	int q;
	cin >> q;
	vector<pair<int, int>> queries(q);
	vector<int> ans(q, -1);
	for (int i = 0; i < q; i++) {
		cin >> queries[i].first >> queries[i].second;
	}
	for (int i = 1; i <= n; i++) {
		for (int j = 1; j <= n; j++) {
			if (travel[j][i]) travel[j] |= travel[i];
		}
		for (int j = 0; j < q; j++) {
			if (ans[j] == -1 && travel[queries[j].first][queries[j].second])
				ans[j] = i;
		}
	}
	for (int i = 0; i < q; i++) {
		if (ans[i] == -1) cout << -1 << "\n";
		else cout << max({ans[i], queries[i].first, queries[i].second}) << "\n";
	}
}

int main() {
	ios::sync_with_stdio(0);
	int t=1;
	// cin >> t;
	while (t--) {
		solve();
	}
	return 0;
}
```

## [Conclusion]: A trick for maximum index in paths
