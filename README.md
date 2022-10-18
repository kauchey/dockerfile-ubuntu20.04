# dockerfile-ubuntu20.04
本项目支持自动生成 Dockerfile 与 docker-compose.yml 文件

生成基于 ubuntu20.04 的自定义 image，安装了 sudo、git、ping、ifconfig 基础工具

使用方法：
当前目录执行 ./generate.sh
根据提示输入参数
执行上述脚本后，会在当前目录生成 Dockerfile 与 docker-compose.yml 文件
执行 docker-compose up -d 即可启动容器
