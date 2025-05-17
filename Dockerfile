FROM ubuntu:22.04

# 设置中国时区
ENV TZ=Asia/Shanghai
RUN apt-get update && \
    apt-get install -y tzdata ca-certificates && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    rm -rf /var/lib/apt/lists/*

# 创建应用目录结构
RUN mkdir -p /app/Dice /app/napcat/config

# 复制程序文件和配置文件
COPY ./Dice /app/Dice
COPY ./config-example.json /app/napcat/config/

# 设置文件权限
RUN chmod +x /app/Dice/DiceDriver.OneBot

# 创建备份目录
RUN cp -a /app /opt/backup

# 启动脚本
RUN echo '#!/bin/bash\n\
# 主程序文件修复\n\
if [ ! -f "/app/Dice/DiceDriver.OneBot" ]; then\n\
    echo "从备份恢复主程序..."\n\
    cp -af /opt/backup/Dice /app/\n\
fi\n\
\n\
# NapCat配置文件不存在时从备份复制\n\
    NAPCAT_CONF="/app/napcat/config/onebot11_${ACCOUNT:-123456}.json"\n\
    if [ ! -f "${NAPCAT_CONF}" ]; then\n\
        mkdir -p /app/napcat/config\n\
        cp "/opt/backup-app/napcat/config/config-example.json" "${NAPCAT_CONF}"\n\
        echo "已生成 NapCat 配置文件：${NAPCAT_CONF}"\n\
    else\n\
        echo "检测到已有 NapCat 配置文件，保留用户修改：${NAPCAT_CONF}"\n\
    fi\n\
\n\
# 执行主程序\n\
exec /app/Dice/DiceDriver.OneBot "$@"' > /usr/local/bin/dice-entrypoint && \
    chmod +x /usr/local/bin/dice-entrypoint

# 设置工作目录和入口点
WORKDIR /app/Dice
ENTRYPOINT ["dice-entrypoint"]