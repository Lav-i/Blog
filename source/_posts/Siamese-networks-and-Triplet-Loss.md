---
title: Siamese networks and Triplet Loss
date: 2020-01-09 10:17:51
tags: 
    - Meta learning 
    - One Shot learning
---

<script type="text/javascript"
   src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>

## 问题背景
 
&emsp;&emsp;相区别于传统的分类器，Siamese networks采取的分类策略为比较模型的两个输入是否相似，如果相似，那么就可以判断两个输入属于同一个类；如果不相似，则属于不同类别。
&emsp;&emsp;与传统分类器更大的区别在于，前者需要每个类都拥有非常大的样本量供模型提取特征以便判断后续样本样本是否属于某个类，而Siamese networks可以基于只有一个样本的情况下做出决定，判断两个输入是否相同。

## 实现原理

&emsp;&emsp;实现思路类似于聚类算法，已有的不同类别的样本在样本空间中分别聚集在一起，相同类别的样本之间距离很近，不同类别的样本之间距离很远。当新进入一个样本时，计算新样本在样本空间中的位置，并且与样本空间中的其他样本计算距离，根据距离即可判断出所属类别。

## 实现流程

&emsp;&emsp;本次实验的数据为Mnist数据集，形状为(28, 28)，一般情况下不直接使用原数据进行距离计算，因此需要一个网络结构进行编码同时实现降维（这个过程称为Embeddings）。同时，处理后的数据需要进行L2归一化，即使其位于一个单位超球面上。对于具体用多少维度的向量来表示，需要进行实验尝试，本次实验中选择使用10维。

&emsp;&emsp;对样本处理完后，需要设计Loss。在本次实验中选择使用了Triple Loss，即一个训练样本中包含了三张图片：
* Anchor：起始图片；
* Positive：与Anchor属于同一类别的图片；
* Negative：与Anchor属于不同类别的图片。

我们期望\\(distance(A, P) < distance(A, N)\\)同时又要防止模型通过为所有内容输出零来满足要求的简单解决方案，添加margin变量。最终Loss函数为：$$L = max(d(A, P) - d(A, N) + margin, 0)$$

&emsp;&emsp;为保证模型可以从样本产生的Loss中能够正常学习，需要适当添加困难样本。在本次实验中，样本可以分为三类：
* Easy triplets: \\(d(A, P) + margin < d(A, N)\\)，产生的Loss值为0；
* Hard triplets：\\(d(A, N) < d(A, P)\\)，产生的Loss非常大；
* Semi-hard triplets：\\(d(A, P) < d(A, N) < d(A, P) + margin\\)，产生正常的Loss。

实验中选择一半Hard sample与一半的Random sample。

## 模型评估

&emsp;&emsp;如何判断模型是否学习到了东西，主要从两个方面进行考虑：
1. 距离多近才能判断为属于同一个类别，还涉及到如何选择阈值；
2. 不同类别的样本距离有多远，一般来说不同类之间越远越好。

## 参考资料
*文章：[One Shot learning, Siamese networks and Triplet Loss with Keras](https://medium.com/@crimy/one-shot-learning-siamese-networks-and-triplet-loss-with-keras-2885ed022352)*
*代码：[CrimyTheBold/tripletloss](https://github.com/CrimyTheBold/tripletloss/blob/master/02%20-%20tripletloss%20MNIST.ipynb)*
