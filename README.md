# AIME Proxy

将同花顺 AIME (AI 金融投顾) 的 Web API 封装为标准的 **OpenAI Chat Completions API**，支持流式(SSE)和非流式，可接入 LobeChat / NextChat / Codex 等任意 OpenAI 兼容客户端。

## 快速开始

```bash
npm install
node server.js
```

看到以下输出即启动成功：

```
╔══════════════════════════════════════════════════════════════╗
║   AIME → OpenAI Chat API 兼容代理  v1.1                      ║
║   端口: 3000          API Key: 未启用（开放访问）              ║
║   AIME: https://data.10jqka.com.cn/aime-front                ║
╚══════════════════════════════════════════════════════════════╝
✓ 已加载 3 个模型
  - deepseek-v4-pro (deepseek)
  - deepseek-v4-flash (deepseek)
  - glm-5.1 (glm)
```

## Docker 部署

```bash
docker build -t aime2api .
docker run -p 3000:3000 -d aime2api
```

## 客户端接入

| 配置项 | 值 |
|--------|-----|
| API Base URL | `http://localhost:3000/v1` |
| API Key | 任意值（如 `sk-123`） |
| 模型 | `deepseek-v4-pro` / `deepseek-v4-flash` / `glm-5.1` |

## API 端点

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/v1/models` | 可用模型列表 |
| POST | `/v1/chat/completions` | 对话（支持 `stream: true/false`） |
| GET | `/health` | 健康检查 + 清理统计 |
| GET | `/dashboard` | 统计仪表盘 |
| POST | `/admin/cleanup` | 手动触发孤儿 session 清理 |

## 配置

通过 `config.json` 或环境变量配置（环境变量优先）：

```json
{
  "aimeBaseUrl": "https://data.10jqka.com.cn/aime-front",
  "port": 3000,
  "apiKey": "",
  "defaultModel": "deepseek-v4-pro",
  "maxRetries": 2,
  "requestTimeoutMs": 300000
}
```

| 环境变量 | 说明 | 默认值 |
|----------|------|--------|
| `AIME_BASE_URL` | AIME 后端地址 | `https://data.10jqka.com.cn/aime-front` |
| `PORT` | 代理端口 | `3000` |
| `API_KEY` | API Key（设了则强制鉴权） | 空（不鉴权） |
| `DEFAULT_MODEL` | 默认模型 | `deepseek-v4-pro` |
| `MAX_RETRIES` | 网络失败重试次数 | `2` |
| `REQUEST_TIMEOUT` | 请求超时(ms) | `300000` |
| `DEBUG` | 调试日志 | `false` |

## 模型别名

以下别名均可使用，会自动映射到对应模型：

| 输入 | 映射到 |
|------|--------|
| `deepseek-chat` | deepseek-v4-pro |
| `deepseek-reasoner` | deepseek-v4-pro |
| `glm51` / `glm-4-flash` / `glm-4-plus` | glm-5.1 |

## 特性

- 非流式 + SSE 流式双模式
- 自动脱敏（过滤 AIME / 投顾 / 同花顺等身份关键词）
- 身份剥离 prompt 注入（让模型表现为通用 agent 而非投顾）
- 请求重试（指数退避）
- Session 自动创建与清理
- 孤儿 session 定时清理
- 统计仪表盘（请求量 / 成功率 / Token / 模型用量 / 时间线）

## 请求示例

```bash
# 非流式
curl -X POST http://localhost:3000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek-v4-pro","messages":[{"role":"user","content":"hello"}],"stream":false}'

# 流式
curl -N -X POST http://localhost:3000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek-v4-pro","messages":[{"role":"user","content":"hello"}],"stream":true}'
```
