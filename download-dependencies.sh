#!/bin/bash

echo "开始下载 Docker 容器所需的依赖..."

# 1. 下载 Playwright 浏览器
echo "========================================="
echo "步骤 1/4: 下载 Playwright 浏览器..."
echo "========================================="

mkdir -p playwright-cache

# 检查是否已下载过（使用 find 命令查找 chrome 可执行文件）
chromium_exists=$(find playwright-cache -name "chrome" -type f 2>/dev/null | head -n 1)

if [ -n "$chromium_exists" ]; then
    echo "检测到已下载的 Playwright 浏览器: $chromium_exists"
    echo "✓ Playwright 浏览器已存在于缓存目录，跳过下载"
else
    echo "首次下载 Playwright 浏览器，这可能需要几分钟时间..."

    # 强制删除现有的空目录或损坏的缓存
    rm -rf playwright-cache/.links playwright-cache/__dirlock 2>/dev/null

    docker run --rm -v $(pwd)/playwright-cache:/root/.cache/ms-playwright python:3.12-slim sh -c \
      "pip install playwright && python -m playwright install chromium && python -m playwright install-deps chromium"

    if [ $? -eq 0 ]; then
        echo "✓ Playwright 浏览器下载完成"

        # 验证下载是否成功
        chromium_exists_after=$(find playwright-cache -name "chrome" -type f 2>/dev/null | head -n 1)
        if [ -z "$chromium_exists_after" ]; then
            echo "⚠️ 警告：下载完成但未找到 chrome 可执行文件，请手动检查"
        fi
    else
        echo "✗ Playwright 浏览器下载失败"
        exit 1
    fi
fi

# 2. 下载 OpenJDK
echo ""
echo "========================================="
echo "步骤 2/4: 下载 OpenJDK..."
echo "========================================="
mkdir -p jdk-cache
cd jdk-cache

if [ -d "jdk-17.0.2" ]; then
    echo "检测到已下载的 OpenJDK，跳过下载步骤"
    echo "✓ OpenJDK 已存在于缓存目录"
else
    echo "首次下载 OpenJDK..."
    if [ ! -f "openjdk-17.0.2_linux-x64_bin.tar.gz" ]; then
        wget https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz
    fi

    if [ -f "openjdk-17.0.2_linux-x64_bin.tar.gz" ]; then
        tar -xzf openjdk-17.0.2_linux-x64_bin.tar.gz
        chmod +x jdk-17.0.2/bin/*
        echo "✓ OpenJDK 下载完成"
    else
        echo "✗ OpenJDK 下载失败"
        exit 1
    fi
fi
cd ..

echo ""
echo "========================================="
echo "所有依赖下载完成！"
echo "========================================="
echo ""
echo "下载的文件位置："
echo "  Playwright: ./playwright-cache/"
echo "  OpenJDK:    ./jdk-cache/jdk-17.0.2/"
echo ""
echo "========================================="
echo "启动 Selenium WebDriver 容器（可选，用于传统 UI 自动化）"
echo "========================================="
echo ""
echo "如果需要使用传统的 Selenium UI 自动化（非 AI 智能模式），请启动以下容器："
echo ""
echo "启动 Chrome:"
echo "  docker run -d --name selenium-chrome -p 4444:4444 selenium/standalone-chrome:latest"
echo ""
echo "启动 Firefox:"
echo "  docker run -d --name selenium-firefox -p 4445:4444 selenium/standalone-firefox:latest"
echo ""
echo "同时启动两个浏览器（推荐）："
echo "  docker run -d --name selenium-chrome -p 4444:4444 selenium/standalone-chrome:latest && \\"
echo "  docker run -d --name selenium-firefox -p 4445:4444 selenium/standalone-firefox:latest"
echo ""
echo "然后在 .env 文件中配置（已自动添加）："
echo "  SELENIUM_CHROME_URL=http://localhost:4444/wd/hub"
echo "  SELENIUM_FIREFOX_URL=http://localhost:4445/wd/hub"
echo ""
echo "或者使用统一配置（所有浏览器使用同一个 URL）："
echo "  SELENIUM_REMOTE_URL=http://localhost:4444/wd/hub"
echo ""
echo "注意：如果使用 AI 智能模式（browser-use），不需要 Selenium WebDriver"
echo ""
echo "========================================="
echo "Docker 启动配置"
echo "========================================="
echo ""
echo "启动后端容器时需要挂载以下目录："
echo "  -v $(pwd)/playwright-cache:/root/.cache/ms-playwright"
echo "  -v $(pwd)/jdk-cache/jdk-17.0.2:/opt/jdk"
echo ""
echo "如果使用远程 Selenium WebDriver，需要添加："
echo "  -e SELENIUM_REMOTE_URL=http://host.docker.internal:4444/wd/hub"
echo "  或在 .env 文件中设置 SELENIUM_REMOTE_URL"
