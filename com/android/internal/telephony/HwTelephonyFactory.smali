.class public Lcom/android/internal/telephony/HwTelephonyFactory;
.super Ljava/lang/Object;

.method public static getHwChrServiceManager()Lcom/android/internal/telephony/HwChrServiceManager;
    .locals 1
    new-instance v0, Lcom/android/internal/telephony/HwChrServiceManagerImpl;
    invoke-direct {v0}, Lcom/android/internal/telephony/HwChrServiceManagerImpl;-><init>()V
    return-object v0
.end method

.method public static getHwVolteChrManager()Lcom/android/internal/telephony/HwVolteChrManager;
    .locals 1
    new-instance v0, Lcom/android/internal/telephony/HwVolteChrManagerImpl;
    invoke-direct {v0}, Lcom/android/internal/telephony/HwVolteChrManagerImpl;-><init>()V
    return-object v0
.end method

.method public static getHwTelephonyChrManager()Lcom/android/internal/telephony/HwTelephonyChrManager;
    .locals 1
    new-instance v0, Lcom/android/internal/telephony/HwTelephonyChrManagerImpl;
    invoke-direct {v0}, Lcom/android/internal/telephony/HwTelephonyChrManagerImpl;-><init>()V
    return-object v0
.end method
