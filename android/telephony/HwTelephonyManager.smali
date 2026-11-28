.class public Landroid/telephony/HwTelephonyManager;
.super Ljava/lang/Object;

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

.method public static getDefault()Landroid/telephony/HwTelephonyManager;
    .locals 1
    new-instance v0, Landroid/telephony/HwTelephonyManager;
    invoke-direct {v0}, Landroid/telephony/HwTelephonyManager;-><init>()V
    return-object v0
.end method

.method public getDefault4GSlotId()I
    .locals 1
    const/4 v0, 0x1
    return v0
.end method

.method public getCardType(I)I
    .locals 1
    const/4 v0, 0x1
    return v0
.end method

.method public getImsDomain(I)I
    .locals 1
    const/4 v0, 0x1
    return v0
.end method

.method public getDataRegisteredState(I)I
    .locals 1
    const/4 v0, 0x0
    return v0
.end method

.method public isCTSimCard(I)Z
    .locals 1
    const/4 v0, 0x0
    return v0
.end method
