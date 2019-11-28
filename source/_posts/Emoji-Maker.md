---
title: Emoji Maker
date: 2019-11-28 19:57:42
tags:
---


{% asset_img big.png 先上祭品，自己训练的表情包，凑活看看 %}

&emsp;&emsp;上手总是用MNIST是不是没有成就感，那么来试试训练Emoji吧！这是学习GAN网络的第一个~~玩具~~应用。


## 准备工作
&emsp;&emsp;训练GAN网络生成表情包当然需要大量的表情包数据，当然就想到了万能的知乎了，而且以前也做过知乎的爬虫批量下载图片，这不是随手拿来改改就能用？不过万事皆有不如意，不出意外的知乎改版了，以前写的爬虫早就不能用了。后来经过一些尝试和努力（其实就是直接ctrl+s保存页面到本地然后手动筛选一下），我还是获得了两个我最喜欢的系列共计近两百张表情包，那么有了数据，当然就可以开始搭建网络开始训练咯。（当时年轻的我还没有意识到自己的数据其实少的可怜）


## 训练网络
&emsp;&emsp;不得不说，Keras对于新手来说简直不要太友好，菜如我也可以很快搭建好一个完整的GAN网络。GAN网络的实质其实就是一个动态博弈的过程，辨别器与生成器轮流训练，一起变强的过程。最后取出其中的生成器模型，我就可以拥有无限多的表情包，然后成为表情包之王，从此斗图再无对手！哈哈哈哈哈哈！（啊不是）

&emsp;&emsp;GAN网络的结构以及原理什么的网上资料非常多，我也就不再赘述了，这里就再额外记录一下我踩的坑，我走过的弯路。
&emsp;&emsp;由于GAN网络中的鉴别器D与生成器G在训练的时候的目标函数不同，因此不能同时训练，取而代之的就是G与D交替训练。其中D可以单独训练，而G需要依靠D的辨别结果的才能进行误差反向传递，也就是说单独的G不需要设置优化器或损失函数。
&emsp;&emsp;由于G没有损失函数也没有优化器，所以并不能算一个完整的模型（应该是这个原因），在模型保存中直接使用`model.save()`与`load_model()`时候会出现奇奇怪怪的错误，作为替换应该使用`model.save_weights()`与`model.load_weights()`只保存模型各层的权重，仅在需要时加载必要的权重。


## 优化模型
&emsp;&emsp;致命问题：**mode collapse**，指的是模型生成的数据失去多样性，其中很大原因就是样本数据太少（前后呼应了）。兵来将挡水来土掩，也有非常多的方法来提升与优化GAN的性能。那么接下来就走上了模型的漫漫优化之旅......
1. Large kernels and more filters
2. Flip labels (Generated=True, Real=False)
3. Soft and Noisy labels
4. Batch norm helps, but only if you have otherthings in place
5. One class at a time
6. Look at the Gradients
7. No early stopping
*尽管尝试了上述的多种方法，到最后我也没有解决模式坍塌的问题，而且Emoji生成质量并不高*


## 附录
### 相关资料
*数据集来源：[有哪些可爱的高糊小表情包？](https://www.zhihu.com/question/65141944)*
*学习框架：[Keras: 基于 Python 的深度学习库](https://keras-zh.readthedocs.io/)*
*模式坍塌与应对：[Keep Calm and train a GAN. Pitfalls and Tips on training Generative Adversarial Networks](https://medium.com/@utk.is.here/keep-calm-and-train-a-gan-pitfalls-and-tips-on-training-generative-adversarial-networks-edd529764aa9)*
*提升GAN：[Improved Techniques for Training GANs](https://arxiv.org/abs/1606.03498)*


<style type="text/css">
    .fancybox {
        display: inline-block;
    }
</style>

### 模型迭代

{% asset_img 0.jpg 0steps %}
{% asset_img 50.jpg 50steps %}
{% asset_img 100.jpg 100steps %}
{% asset_img 150.jpg 150steps %}
{% asset_img 200.jpg 200steps %}
{% asset_img 250.jpg 250steps %}
{% asset_img 300.jpg 300steps %}
{% asset_img 350.jpg 350steps %}
{% asset_img 400.jpg 400steps %}
{% asset_img 450.jpg 450steps %}
{% asset_img 500.jpg 500steps %}
{% asset_img 550.jpg 550steps %}
{% asset_img 600.jpg 600steps %}
{% asset_img 650.jpg 650steps %}
{% asset_img 700.jpg 700steps %}
