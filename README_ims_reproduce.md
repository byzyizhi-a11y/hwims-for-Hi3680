# IMS 复现脚本说明（Mate 20 Pro / LYA-AL10 / GSI）

`ims_reproduce.sh` 把 2026-11-28 傍晚 IMS 成功注册（17:04、17:22）前后的所有步骤集中成一个幂等脚本。

## 成功时的关键序列

```
1. AT^IMSSWITCH=1   （两个 modem，IRadio@2.0 setImsSwitch）
2. AT^IMSDOMAINCFG=1（两个 modem，IHisiRadio setImsDomain）
3. 飞行模式 开 -> 关（重新附着）
4. 等待约 50 秒
5. ImsRegState: ims_state: 1  +  Phone: isImsRegistered =true
```

## 前提（APK 不在脚本内，需已安装）

| 组件 | 说明 |
|---|---|
| `com.huawei.ims` | HwIms **v17**（开机自动发 `AT^IMSSWITCH` 的版本） |
| `com.dsh.imsfix` | ImsFix（carrier config 覆盖 IMS 包名，v1 或 v2） |
| `/data/local/tmp/imssw.dex` | `com.test.ImsSwitch`（IRadio@2.0 setImsSwitch） |
| `/data/local/tmp/imsdom.dex` | `com.test.ImsDomain`（IHisiRadio setImsDomain） |

如果缺 dex，可从工作区重建：

```
smali.jar a hisiradio\src4 -o imssw.dex      # com.test.ImsSwitch
smali.jar a hisiradio\src5 -o imsdom.dex     # com.test.ImsDomain
adb push imssw.dex imsdom.dex /data/local/tmp/
```

## 用法

```bash
adb push ims_reproduce.sh /data/local/tmp/
adb shell su -c 'sh /data/local/tmp/ims_reproduce.sh'                 # 完整流程（约 5 分钟）
adb shell su -c 'sh /data/local/tmp/ims_reproduce.sh --setup-only'    # 只做配置，不碰网络
adb shell su -c 'sh /data/local/tmp/ims_reproduce.sh --tries 5'       # 多试几轮
```

## 脚本做了什么（全部幂等）

1. **前置检查**：root、dex、HwIms、ImsFix 是否就绪；
2. **SELinux**（`/vendor/etc/selinux/vendor_sepolicy.cil`）：
   - `allow radio default_hisi_hwservice`（hwservice_manager find + binder call/transfer）
   - `allow rild system_prop`（避免 balong_modem0 死循环导致信号丢失）
3. **`/system/build.prop`**：确保 `ro.config.hw_support_omadm=true`；
4. **APN**：确保 `中国移动 IMS`（apn=ims, mcc=460, mnc=02, carrier_id=1435）存在且启用；
5. **设置**：`hw_volte_user_switch=1`、`volte_vt_enabled=1`、`persist.telephony.mpdn=1`；
6. **运行时**：`setImsSwitch(1)` → `setImsDomain(1)` → 飞行模式 开/关 → 最多等 90 秒，最多 3 轮；
7. **报告**：写入 `/data/local/tmp/ims_report_<时间>.txt`（信号、IMS 状态、开关日志、P-CSCF、数据连接）。

## 期望输出

成功时：

```
[ims]   >>> 注册成功（等待 50s）<<<
[ims] ===== 结果: IMS REGISTERED =====
```

失败时报告里会看到：

```
ImsRegState: ims_state: 0
^IMSSRVSTATUS: 0,0,2,0,0,0,0,0
pcscf=[]
```

## 修改的文件

| 文件 | 改动 |
|---|---|
| `/vendor/etc/selinux/vendor_sepolicy.cil` | 追加 3 条 allow（带 `imsfix-*` 标记，可 grep 定位） |
| `/system/build.prop` | 追加 `ro.config.hw_support_omadm=true`（一次性） |
| telephony.db `carriers` | 插入/启用 IMS APN（不删除数据） |
| Settings | 3 个 VoLTE/IMS 开关 |

## 回退

```bash
# 移除 SELinux 规则
adb shell su -c "sed -i '/imsfix-/d' /vendor/etc/selinux/vendor_sepolicy.cil"

# 移除 build.prop 行
adb shell su -c "sed -i '/ro.config.hw_support_omadm/d' /system/build.prop"

# 禁用 IMS APN
adb shell su -c "sqlite3 /data/user_de/0/com.android.providers.telephony/databases/telephony.db \
  \"update carriers set carrier_enabled=0 where _id=3040;\""
```

## 已知限制

- 脚本**不能**解决 P-CSCF 获取问题（modem 的 `AT^IMSPCSCF` 返回 `+CME ERROR: 50`，DM facility 未开通）；
- 成功与否取决于 modem 自己的 IMS PDN（cid 9）能否建立并收到网络 PCO 下发的 P-CSCF；
- 17:04 成功后 modem 复位丢失了该状态，脚本只能复刻操作序列，不能保证必然重现。
