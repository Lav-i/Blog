---
title: Few-Shot Learning With Graph Neural Networks
date: 2021-04-06 23:23:26
tags:
    - Few Shot learning
    - Graph Neural Networks
---

<script type="text/javascript"
   src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>

## 前言

&emsp;&emsp;小样本学习并不使用小样本数据集。以*5-way 1-shot*为例子，为了模型能够在最终时候实现*5-way 1-shot*，前期依然需要用大量的数据用来训练，只不过数据不再是*5-way many-shot*，而是使用*5-way 1-shot*一组，非常多组的样本来训练。

## 模型

### 核心部分
&emsp;&emsp;模型的中心是将节点的特征与标签进行拼接,构成*V(nodes)*，其中\\( \phi \\)代表了图嵌入，\\( \phi(x) \\)表示图嵌入后的向量。\\( h(l) \\)表示标签，其中有标签的support set，标签以*one-hot*的形式进行处理，无标签的query set则用全零进行填充。

{% asset_img model.png 模型结构 %}

### 核心上游

&emsp;&emsp;模型的上游部分承担了图嵌入的工作，将输入的二维图片转化为一维的向量，在论文中使用的是卷积层与线性层来共同实现的。

### 核心下游

&emsp;&emsp;下游部分则是一个GCN结构，特别的是，图卷积所需要的相似矩阵是不断变化的。在论文中使用了两层图卷积结构，每个图卷积结构都包含了重新计算相似矩阵，以及节点的信息传递两项功能。在代码中，每次由图卷积结构得到的新的X总是与旧的X进行拼接，猜测是为了更好的保持有用信息。

{% asset_img GCN.png 图卷积结构 %}

&emsp;&emsp;同时，在计算相似矩阵的时候，所使用的方法是计算绝对误差后再通过多层感知机，代替了一般常用的所以说最后得到的相似矩阵也是可以进行误差反向传播然后更新的。在代码中，最后的相似矩阵是和单位矩阵拼接作为最后的图相似性矩阵，猜测也是为了更好的保持有用信息。

{% asset_img formula.png 相似度公式 %}

## 参考资料
*文章：[Few-shot learning with graph neural networks](https://arxiv.org/abs/1711.04043)*
*代码：[few-shot-gnn](https://github.com/vgsatorras/few-shot-gnn)*

*论文解读：[Few-shot learning with graph neural networks](https://www.zdaiot.com/DeepLearningApplications/Few-shot%20Learning/Few-shot%20learning%20with%20graph%20neural%20networks/)*
