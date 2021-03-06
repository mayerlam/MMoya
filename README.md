# MMoya
> 此文档仍在维护中

一个网络请求辅助工具（基于Moya）

## 动机
一个完善理想的工作流，大概是由Master规划功能，并且制定接口。这样客户端和服务端就可以只根据接口文档独立开发。从而减少无谓的讨论以提高效率。

而由于客户端和服务端的开发速度不一样（通常是服务端滞后一些），这样客户端可能无法从服务端获取到合格的数据。导致程序不得不中断。如果我们希望测试客户端完整的执行流程，这将会一个大问题。

在敏捷开发中，我们尽量保证各端的开发独立，避免任何一方的滞后导致另一方的滞后（前提是Master有做好前期的规划。如果随手就来开始写代码建工程，那上面的讨论就已经没有意义）。

而由于客户端和服务端之间的联系，大多数时候就是网络的请求连接。因此这个工具，可以帮助客户端去忽略网络的请求错误，而继续执行程序。

代码中已经有详细的注释，可以从中得到使用的方法。请放心，日后我会完善这个文档。

## 依赖

你需要安装[Moya](https://github.com/Moya/Moya)，这是一个拥有12K Star的库，它是对`Alamofire`的封装，如果你习惯了使用`Alamofire`，那你应该不会害怕使用这个库，因为它帮你做了很多事情。

© Mayer Lam
