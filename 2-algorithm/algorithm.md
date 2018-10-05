# 算法

- 动态规划

## 动态规划

参考：

- [漫画：什么是动态规划？](https://mp.weixin.qq.com/s/_kHeAI4PvF-KH7IQrmnRVg)

解题步骤：

- 最优子结构 f(10) = f(9)+f(8) , f(9) 和 f(8) 是 f(10) 的最优子结构
- 边界，可以直接得到结果的情况 f(1) f(2)
- 状态转移公式，f(n) = f(n-1) + f(n-2)

建模，求解，考虑时间复杂度

- 从顶到底：递归，有重复计算，优化：备忘录算法 (缓存)
- 从底到顶：迭代