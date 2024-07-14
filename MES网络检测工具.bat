@echo off
:: 设置字符编码为ANSI
chcp 936 > nul  
setlocal enabledelayedexpansion
title 网络检测工具

:: 定义数组长度
set targetsK_count=2
:: 定义数组 targetsK数组放的是需要PING的服务器名，targetsV数组放的是对应的服务器的域名
set targetsK[0]=MES生产环境
set targetsV[0]=.com.cn
set targetsK[1]=IAM
set targetsV[1]=.com.cn

:: 定义结果
set pingServerResult=0
set pingGateResult=1

:: 设置倒计时时间（秒）用于关闭窗口
set countdown=360

:: 显示欢迎信息
echo ===================================================
echo            欢迎使用MES网络检测工具
echo ===================================================
echo.

echo ===============一、当前终端的网络详细信息===============
ipconfig /all
echo.

echo ===============二、访问服务器===============
:: 循环遍历数组并进行ping操作
:: 计算数组长度减1
set /a targetsK_max=%targetsK_count%-1
for /L %%i in (0,1,!targetsK_max!) do (
    set targetK=!targetsK[%%i]!
    set targetV=!targetsV[%%i]!
    echo *** %%i. 尝试访问【!targetK!】：

    ping !targetV! -n 3
    if !errorlevel! EQU 0 (
        echo *** %%i. 访问【!targetK!】结果：可达
	:: 累加成功结果
        set /a pingServerResult=!pingServerResult!+1
    ) else (
        echo *** %%i. 访问【!targetK!】结果：失败
    )
    echo.
)

echo ===============三、访问网关===============
:: 获取并显示所有网关地址并进行ping操作
for /f "tokens=3" %%i in ('route print ^| findstr "\<0.0.0.0\>"') do (
    echo 开始检测网关地址 %%i：
    ping %%i -n 3
    if !errorlevel! EQU 0 (
        echo *** 访问【%%i】结果：可达
    set /a pingGateResult=0
    ) else (
        echo *** 访问【%%i】结果：失败
    )
    echo.
)


:: 显示检测完成信息
echo.
echo ===============检测结果===============
echo.
echo 1. 尝试访问服务器【%targetsK_count%】，可达【!pingServerResult!】。
if !pingGateResult! EQU 0 (
    echo 2. 当前终端可正常访问默认网关。
) else (
    echo 2. 当前终端无法正常访问默认网关，请检查网络连接或网络配置！
)
if !pingServerResult! EQU 0 (
    echo 3. 当前终端无法正常访问服务器，请检查网络连接或 DNS 配置！
) else (
    echo.
    echo 网络连通
    echo 若无法正常进入系统，请检查访问域名或其他配置。
)




:: 倒计时函数
echo.
echo ===================================================
echo Copyright (c) 2024  Version: 0.0.1
echo ===================================================
echo.
echo 检测程序将在【%countdown%】秒后自动关闭……
:countdown_loop
if %countdown% LEQ 0 (
    goto end_countdown
)

set /a countdown-=1
timeout /t 1 /nobreak >nul
goto countdown_loop

:end_countdown
echo 倒计时结束，关闭程序。
exit /b