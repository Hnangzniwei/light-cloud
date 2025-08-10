#!/bin/bash
# 用于建立SSH隧道和访问云服务的脚本

# 默认值
CLOUD_IP=""
LOCAL_PORT=8080
SSH_USER="root"
SSH_KEY="~/.ssh/id_rsa"

# 帮助信息
function show_help {
  echo "用法: $0 <云实例IP> [本地端口] [SSH用户] [SSH密钥路径]"
  echo "  或: $0 [选项]"
  echo ""
  echo "位置参数:"
  echo "  <云实例IP>       云实例的IP地址（必需）"
  echo "  [本地端口]       本地转发端口 (默认: 8080)"
  echo "  [SSH用户]        SSH用户名 (默认: root)"
  echo "  [SSH密钥路径]    SSH密钥路径 (默认: ~/.ssh/id_rsa)"
  echo ""
  echo "选项:"
  echo "  -i, --ip IP       云实例的IP地址"
  echo "  -p, --port PORT   本地转发端口 (默认: 8080)"
  echo "  -u, --user USER   SSH用户名 (默认: root)"
  echo "  -k, --key KEY     SSH密钥路径 (默认: ~/.ssh/id_rsa)"
  echo "  -c, --cmd CMD     要发送的命令 (使用Unix套接字模式)"
  echo "  -h, --help        显示此帮助信息"
  exit 1
}

# 检查是否使用位置参数
if [[ $# -gt 0 && "$1" != -* ]]; then
  # 使用位置参数
  CLOUD_IP="$1"
  
  if [[ $# -gt 1 ]]; then
    LOCAL_PORT="$2"
  fi
  
  if [[ $# -gt 2 ]]; then
    SSH_USER="$3"
  fi
  
  if [[ $# -gt 3 ]]; then
    SSH_KEY="$4"
  fi
  
  # 端口转发模式
  PORT_FORWARD=true
  UNIX_SOCKET=false
else
  # 使用命名参数
  PORT_FORWARD=false
  UNIX_SOCKET=false
  COMMAND="status"
  
  # 解析参数
  while [[ $# -gt 0 ]]; do
    case $1 in
      -i|--ip)
        CLOUD_IP="$2"
        shift 2
        ;;
      -p|--port)
        LOCAL_PORT="$2"
        PORT_FORWARD=true
        shift 2
        ;;
      -u|--user)
        SSH_USER="$2"
        shift 2
        ;;
      -k|--key)
        SSH_KEY="$2"
        shift 2
        ;;
      -c|--cmd)
        COMMAND="$2"
        UNIX_SOCKET=true
        shift 2
        ;;
      -h|--help)
        show_help
        ;;
      *)
        echo "未知选项: $1"
        show_help
        ;;
    esac
  done
fi

# 检查必需参数
if [ -z "$CLOUD_IP" ]; then
  echo "错误: 必须提供云实例IP地址"
  show_help
fi

# 端口转发模式
if [ "$PORT_FORWARD" = true ]; then
  echo "建立SSH隧道到 $CLOUD_IP，端口转发 $LOCAL_PORT -> 80..."
  
  # 检查SSH密钥是否存在
  if [ ! -f "${SSH_KEY/#\~/$HOME}" ]; then
    echo "警告: SSH密钥文件 ${SSH_KEY} 不存在"
  fi
  
  # 建立SSH隧道
  ssh -o StrictHostKeyChecking=no -i "${SSH_KEY/#\~/$HOME}" -N -L "$LOCAL_PORT:localhost:80" "$SSH_USER@$CLOUD_IP" &
  SSH_PID=$!
  
  # 等待隧道建立
  echo "等待隧道建立..."
  sleep 3
  
  if kill -0 $SSH_PID 2>/dev/null; then
    echo "隧道已建立，服务可通过 http://localhost:$LOCAL_PORT 访问"
    echo "按 Ctrl+C 关闭隧道"
    
    # 保持脚本运行，直到用户按下Ctrl+C
    trap "echo '关闭SSH隧道'; kill $SSH_PID 2>/dev/null; exit 0" INT
    wait $SSH_PID
  else
    echo "错误: 无法建立SSH隧道"
    exit 1
  fi
fi

# Unix套接字模式
if [ "$UNIX_SOCKET" = true ]; then
  # 检查socat是否安装
  if ! command -v socat &> /dev/null; then
    echo "错误: 未找到socat命令。请安装socat:"
    echo "  macOS: brew install socat"
    echo "  Ubuntu/Debian: sudo apt install socat"
    echo "  CentOS/RHEL: sudo yum install socat"
    exit 1
  fi
  
  # 检查SSH隧道是否已经存在
  if [ ! -S /tmp/lcs.sock ]; then
    echo "建立SSH隧道到 $CLOUD_IP..."
    ssh -N -L /tmp/lcs.sock:/tmp/lcs.sock "$SSH_USER@$CLOUD_IP" &
    SSH_PID=$!
    
    # 等待套接字文件创建
    echo "等待隧道建立..."
    for i in {1..10}; do
      if [ -S /tmp/lcs.sock ]; then
        break
      fi
      sleep 1
    done
    
    if [ ! -S /tmp/lcs.sock ]; then
      echo "错误: 无法建立SSH隧道"
      kill $SSH_PID 2>/dev/null
      exit 1
    fi
    
    echo "隧道已建立"
    TUNNEL_CREATED=true
  else
    echo "使用现有SSH隧道"
    TUNNEL_CREATED=false
  fi
  
  # 发送命令
  echo "发送命令: $COMMAND"
  socat - UNIX-CONNECT:/tmp/lcs.sock <<< "{\"cmd\":\"$COMMAND\"}"
  
  # 如果我们创建了隧道，则关闭它
  if [ "$TUNNEL_CREATED" = true ]; then
    echo "关闭SSH隧道"
    kill $SSH_PID 2>/dev/null
  




