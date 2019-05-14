# skynet_hotfix

#### 介绍
skynet 热更新功能演示
![image1](/image1.png)
<bar>
#### 软件架构
软件架构说明
>depends --skynet引擎已编译好 <br>
>server  --游戏框架 <br>
>>common --公用的代码，配置 <br>
>>config --配置文件 <br>
>>proto  --pb文件 <br>

每个节点里都有一个manager_service   负责节点消息派发与 service管理

#### 运行步骤


2. debug.sh
3. killall.sh 结束所有skynet进程

#### 规范和约定说明

1. server结尾的文件夹代表一个节点（进程）
2. _service结尾的文件夹代表一个服务与其业务集,一个服务相关的逻辑代码放在一个文件夹里
3. _service.lua 结尾的lua文件代码一个服务起动入口
4. 服务里的逻辑代码以类的形式存在，类文件名以大写字母开头如Command.lua
5. 类函数，使用小驼峰名字
6. 变量使用小字母加_ 的形式命名, 如 message_name 尽量不要让名字太长.


#### 目标
1. 探讨skynet的一种面向对象的开发方式
2. 感兴趣的朋友加qq群 373245593 一起学习
