---
title: Graph Convolutional Networks
date: 2020-11-16 23:06:05
tags:
---

<script type="text/javascript"
   src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>

&emsp;&emsp;不知不觉已经第二年了，在过去的一年里我曾沉迷机器学习，沉迷集成学习，沉迷单细胞拷贝数变异检测。现在回想起来真的是苦不堪言，上手就给自己准备了个地狱难度开局，结果什么都没做出来。好在这学期一开学及时更换了方向，从DNA转去RNA，从机器学习变成深度学习，并且还有大佬指点，感觉一切都顺利多了。

## CNN与GCN
&emsp;&emsp;观察一个3x3大小的卷积核，当这个卷积核在进行学习的时候，不仅能学习到目标像素点的信息，还包括了目标像素点周围的额外八个像素点。卷积核通过这紧挨着的9个像素点所存储的信息进行特征提取，学习到有用的信息。这在图（*Image*）上是可行的，因为相互临近的像素点确实是存储着相同或相似的信息。

&emsp;&emsp;但是当使用的是非结构化数据比如图（*Graph*）时，普通的卷积核就不能工作了。在图卷积中，每个卷积核依然从周围的点中获取信息进行特征提取，但不同的是“周围的点”不再是目标点周围紧挨的点，而是在图结构中，由有向边或无向边连接的点。这种边在具体问题中通常代表了具体的含义，也可以附有不同的权重。


## 代码解读

### 图卷积层 layer

&emsp;&emsp;图卷积中的层对应的是如下的公式：\\(H^{(k+1)} = f(H^{(k)},A) = \sigma(AH^{(k)}W^{(k)})\\)
其中\\(\sigma(\cdot)\\)是激活函数，\\(W^{k}\\)是可学习的权重，\\(A\\)是邻接矩阵，而\\(H^{k}\\)则是第k层节点的特征。

&emsp;&emsp;一般来说在正式的模型训练中，也不会直接使用临界矩阵\\(A\\)，而是对\\(A\\)做一定的变换:\\(\sigma(AH^{(k)}W^{(k)})=\sigma(\hat{D}^{-\frac{1}{2}}\hat{A}\hat{D}^{-\frac{1}{2}}H^{(k)}W^{(k)})\\)
其中\\(\hat{A}=A+I\\)，\\(\hat{D}\\)是\\(\hat{A}\\)的度矩阵，而\\(\hat{D}^{-\frac{1}{2}}\hat{A}\hat{D}^{-\frac{1}{2}}\\)是对\\(A\\)做了一个对称的归一化。

```python
class GraphConvolution(Module):
    def __init__(self, in_features, out_features, bias=True):
        ......


    def forward(self, input, adj):
        support = torch.mm(input, self.weight)
        output = torch.spmm(adj, support)
        ......
```

```python
def normalize_adj(adj):
    """compute L=D^-0.5 * (A+I) * D^-0.5"""
    adj += sp.eye(adj.shape[0])
    degree = np.array(adj.sum(1))
    d_hat = sp.diags(np.power(degree, -0.5).flatten())
    norm_adj = d_hat.dot(adj).dot(d_hat)
    return norm_adj
```



### 图卷积模型 model

&emsp;&emsp;在图卷积的模型中，一般只使用两层图卷积，过多的添加层会引起过分的泛化进而降低模型的性能。同时，根据具体任务的不同，在图卷积层后可以添加需要的步骤，在节点分类任务中，只需要在最后一层添加`softmax()`激活函数即可。

```python
class GCN(nn.Module):
    def __init__(self, nfeat, nhid, nclass, dropout):
        super(GCN, self).__init__()

        self.gc1 = GraphConvolution(nfeat, nhid)
        self.gc2 = GraphConvolution(nhid, nclass)
        self.dropout = dropout

    def forward(self, x, adj):
        x = F.relu(self.gc1(x, adj))
        x = F.dropout(x, self.dropout, training=self.training)
        x = self.gc2(x, adj)
        return F.log_softmax(x, dim=1)
```

&emsp;&emsp;在链接预测任务中，要求模型在最后输出的是\\(A\\)，则需要在模型中再添加模型`InnerProductDecoder`:

```python
class InnerProductDecoder(nn.Module):
    """Decoder for using inner product for prediction."""

    ......

    def forward(self, z):
        z = F.dropout(z, self.dropout, training=self.training)
        adj = self.act(torch.mm(z, z.t()))
        return adj
```


## 后记

### 基于注意力的图卷积模型

&emsp;&emsp;注意力机制的核心就是关注目标点的所有邻接点，在这些邻接点中选择出对提取特征贡献值最大的部分邻接点，也就是对所有邻接节点使用`softmax`函数，将有限的 **“注意力”** （*也就是`softmax`中的最大值1*）分配给所有的邻接节点。
&emsp;&emsp;作为注意力机制的改进，可以引入 **多头注意力** （*multi head attention*）机制，也就是将多个带有`softmax`的注意力层并行，将得到的结果进行拼接。


## 参考资料
*[Graph Convolutional Networks in PyTorch](https://github.com/tkipf/pygcn)*
*[Pytorch Graph Attention Network](https://github.com/Diego999/pyGAT)*
