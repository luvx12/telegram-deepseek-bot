### 自定义链式命令文档

#### 📌 **概述**
本文档介绍如何使用自定义链式命令，通过 `crontab` 定时任务执行一系列任务，包括 HTTP 请求和 AI 计算，并最终给出投资建议。
如果你想使用这个特性，你需要更改./config/command.json 文件。
---

## **📖 配置字段说明**
| 字段名       | 类型      | 说明 |
|-------------|----------|------|
| `crontab`   | `string` | 定时任务的 Cron 表达式，例如 `"0 */1 * * * *"` 表示每分钟执行一次 |
| `command`   | `string` | 任务名称，例如 `"currency"` |
| `send_user` | `string` | 发送任务的用户（可为空） |
| `send_group`| `string` | 发送任务的群组（可为空） |
| `param`     | `object` | 任务的全局参数，例如 `currency_pair: "BTCUSDT"` |
| `chains`    | `array`  | 任务链，包含多个子任务 |

### **📌 任务链（chains）**
任务链 (`chains`) 由多个 `type` 组成，每个 `type` 里包含 `tasks` 任务列表。

#### **任务类型**
| 类型名称  | 说明 |
|----------|------|
| `http`   | 进行 HTTP 请求，获取外部 API 数据 |
| `deepseek` | AI 计算，根据前序任务结果生成建议 |

---

## **📖 配置示例**
下面是一个示例 JSON 配置：
```json
[
  {
    "crontab": "0 */1 * * * *",
    "command": "currency",
    "send_user": "",
    "send_group": "",
    "param": {
      "currency_pair": "BTCUSDT"
    },
    "chains": [
      {
        "type": "http",
        "tasks": [
          {
            "name": "task1",
            "http_param": {
              "url": "https://api.binance.com/api/v3/ticker/price?symbol={{.currency_pair}}",
              "method": "GET",
              "headers": {},
              "body": ""
            },
            "proxy": ""
          },
          {
            "name": "task2",
            "http_param": {
              "url": "https://api.binance.com/api/v3/ticker/price?symbol=DOGEUSDT",
              "method": "GET",
              "headers": {},
              "body": ""
            },
            "proxy": ""
          }
        ]
      },
      {
        "type": "deepseek",
        "tasks": [
          {
            "name": "task3",
            "template": "BTC price is {{.task1.price}}, Doge price is {{.task2.price}}, give me some advice about investment.",
            "proxy": ""
          }
        ]
      }
    ]
  }
]
```

---

## **📖 任务执行流程**
1. **定时触发**
   - 任务按照 `crontab: "0 */1 * * * *"` 配置，每 1 分钟执行一次。
   - 通过任务名称`/currency`自动化执行

2. **执行 HTTP 任务 (`task1`)**
   - 访问 `https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT`
   - 获取当前 BTC/USDT 价格，返回格式如下：
     ```json
     {
       "symbol": "BTCUSDT",
       "price": "45000.00"
     }
     ```
   - 返回结果被存储为：
     ```json
     {
      "task1": {
        "price": "45000.00", 
        "symbol": "BTCUSDT"
      }
     }
      ```

3. **执行 AI 分析任务 (`task2`)**
   - `task1.price` 值被动态填充，例如 `"BTC price is 45000.00, give me some advice about investment."`
   - AI 解析该模板并返回投资建议。

---

## **📖 Cron 表达式解析**
| 表达式           | 说明 |
|-----------------|------|
| `0 */1 * * * *` | 每 1 分钟执行一次 |
| `0 0 * * * *`   | 每小时执行一次 |
| `0 0 9 * * *`   | 每天早上 9 点执行一次 |
| `0 0 0 1 * *`   | 每月 1 号执行一次 |

---

## **📖 总结**
1. **定时任务** (`crontab`) 每分钟触发
2. **获取币价** (`http` 任务)
3. **分析投资建议** (`deepseek` 任务)
4. **扩展能力**（支持多个币种 & 消息推送）

🚀 这样，你就可以用 deepseek 执行自动化投资分析了！
