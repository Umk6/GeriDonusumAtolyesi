# 🔧 Xcode Kurulum Rehberi

Bu rehber projeyi Xcode'da kurmanız ve test etmeniz için adım adım talimatlar içerir.

---

## 📋 Gereksinimler

- **Xcode**: 15.0 veya üzeri
- **iOS**: 17.0 veya üzeri
- **macOS**: Monterey veya üzeri
- **Git**: Yüklü ve yapılandırılmış

---

## 🚀 Adım Adım Kurulum

### 1. Xcode Projesi Oluşturma

```bash
# Proje klasörüne git
cd "/Users/umk/Library/Mobile Documents/com~apple~CloudDocs/GeriDonusumAtolyesi/GeriDonusumAtolyesi"

# Xcode'u aç (proje zaten oluşturulmuş olmalı)
open GeriDonusumAtolyesi.xcodeproj
```

### 2. Dosyaları Projeye Ekleme

Xcode'da **Project Navigator** (⌘+1) açık olmalı.

#### Tüm .swift Dosyalarını Kontrol Et

Aşağıdaki dosyaların **Compile Sources** listesinde olduğundan emin ol:

**Models/** (6 dosya)
- [ ] WasteType.swift
- [ ] Level.swift
- [ ] Player.swift
- [ ] Booster.swift
- [ ] Statistics.swift
- [ ] ModelIndex.swift

**Game/** (5 dosya)
- [ ] GameScene.swift
- [ ] WasteNode.swift
- [ ] CleaningStation.swift
- [ ] ConveyorBelt.swift
- [ ] EndlessMode.swift

**UI/** (11 dosya)
- [ ] MainMenuView.swift
- [ ] LevelSelectView.swift
- [ ] GameView.swift
- [ ] EndlessModeView.swift
- [ ] FactoryUpgradeView.swift
- [ ] BoosterBarView.swift
- [ ] PauseMenuView.swift
- [ ] SettingsView.swift
- [ ] StatisticsView.swift
- [ ] TutorialOverlay.swift

**Core/** (2 dosya)
- [ ] AudioManager.swift
- [ ] ObjectPool.swift

**Root/** (3 dosya)
- [ ] GeriDonusumAtolyesiApp.swift
- [ ] ContentView.swift
- [ ] Item.swift

**Toplam: 26 .swift dosyası**

#### Dosyaları Ekleme

Eğer eksik dosya varsa:

1. Sağ tık → **Add Files to "GeriDonusumAtolyesi"**
2. Dosyaları seç
3. ✅ **Copy items if needed** işaretle
4. ✅ **Create groups** seçili olsun
5. ✅ **Add to targets: GeriDonusumAtolyesi** işaretle
6. **Add** butonuna tıkla

### 3. Build Settings Kontrol

**Project Navigator** → **GeriDonusumAtolyesi** → **Build Settings**

#### Önemli Ayarlar:

```
Deployment Target: iOS 17.0
Swift Language Version: Swift 5
Code Signing: Otomatik (Development Team seç)
```

### 4. Info.plist Kontrol (Gerekirse)

Eğer ses/haptic izinleri gerekirse:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Ses efektleri için gerekli</string>
```

### 5. Build ve Çalıştır

1. **Product** → **Clean Build Folder** (⇧+⌘+K)
2. **Product** → **Build** (⌘+B)
3. Simulator seç (iPhone 15 Pro önerilir)
4. **Product** → **Run** (⌘+R)

---

## 🐛 Olası Hatalar ve Çözümler

### Hata: "Cannot find type 'X' in scope"

**Çözüm**: Dosya projeye eklenmemiş
- Project Navigator'da dosyanın olup olmadığını kontrol et
- Build Phases → Compile Sources'da olmalı

### Hata: "Duplicate symbol"

**Çözüm**: Dosya iki kez eklenmiş
- Build Phases → Compile Sources'da tekrar eden dosyayı sil

### Hata: "Module compiled with Swift X cannot be imported"

**Çözüm**: Swift version uyumsuzluğu
- Build Settings → Swift Language Version → Swift 5 seç
- Clean build ve tekrar dene

### Hata: "@main" attribute error

**Çözüm**: Birden fazla @main var
- Sadece GeriDonusumAtolyesiApp.swift'te @main olmalı
- ContentView.swift'teki @main'i sil

---

## ✅ Test Checklist

Oyunu çalıştırdıktan sonra:

### Ana Menü
- [ ] Ana menü açılıyor mu?
- [ ] Butonlar çalışıyor mu?
- [ ] Yeşil puan gösteriliyor mu?

### Seviye Seçimi
- [ ] 30 seviye görünüyor mu?
- [ ] Seviye 1 açık mı?
- [ ] Diğer seviyeler kilitli mi?

### Oyun (Seviye 1)
- [ ] Oyun ekranı açılıyor mu?
- [ ] Tutorial görünüyor mu?
- [ ] Atıklar düşüyor mu?
- [ ] Sürükle-bırak çalışıyor mu?
- [ ] Birleştirme yapılabiliyor mu?
- [ ] Combo görünüyor mu?
- [ ] Skor artıyor mu?
- [ ] Ses efektleri duyuluyor mu?
- [ ] Haptic feedback var mı?

### Bant Sistemi
- [ ] Bantlar görünüyor mu?
- [ ] Bantlar hareket ediyor mu?
- [ ] Atıklar bant üzerinde kayıyor mu?
- [ ] Animasyonlar smooth mu?

### Temizleme İstasyonu
- [ ] İstasyon görünüyor mu?
- [ ] Kirli atık var mı?
- [ ] Temizleme çalışıyor mu?
- [ ] Su damlaları animasyonu var mı?

### Booster'lar
- [ ] Booster barı görünüyor mu?
- [ ] Her booster çalışıyor mu?
  - [ ] Mıknatıs
  - [ ] Temizlik spreyi
  - [ ] Süper pres
  - [ ] Zaman yavaşlatma
  - [ ] Robot kol
- [ ] Cooldown çalışıyor mu?

### Pause Menüsü
- [ ] Pause butonu çalışıyor mu?
- [ ] Oyun duruyor mu?
- [ ] Devam Et çalışıyor mu?
- [ ] Yeniden Başlat çalışıyor mu?
- [ ] Ana Menü çalışıyor mu?

### Sonuç Ekranı
- [ ] Seviye bittiğinde sonuç gösteriliyor mu?
- [ ] Yıldızlar görünüyor mu?
- [ ] Puan doğru mu?
- [ ] Yeşil puan kazanılıyor mu?

### Sonsuz Mod
- [ ] ∞ buton çalışıyor mu?
- [ ] Endless ekranı açılıyor mu?
- [ ] Dalga sistemi çalışıyor mu?
- [ ] Zorluk artıyor mu?
- [ ] Rekor kaydediliyor mu?

### Fabrika
- [ ] Fabrika ekranı açılıyor mu?
- [ ] 4 yükseltme görünüyor mu?
- [ ] Satın alma çalışıyor mu?
- [ ] Yeşil puan azalıyor mu?
- [ ] Progress bar'lar doğru mu?

### Ayarlar
- [ ] Ayarlar açılıyor mu?
- [ ] Ses toggle çalışıyor mu?
- [ ] Haptic toggle çalışıyor mu?
- [ ] İstatistikler açılıyor mu?

### İstatistikler
- [ ] İstatistikler görünüyor mu?
- [ ] Sayılar doğru mu?
- [ ] Grafikler çalışıyor mu?

---

## 🎯 Performance Test

### FPS Kontrolü

Oyun sırasında:
1. Xcode → **Debug Navigator** (⌘+7)
2. **CPU** ve **Memory** kullanımına bak
3. FPS **60'ta** olmalı
4. Memory leaks var mı kontrol et

### Hedefler:
- **FPS**: 60 (stabil)
- **Memory**: <100 MB
- **CPU**: <%50 (idle)
- **Leaks**: 0

---

## 📱 Device Test

Simulator'de çalıştıktan sonra:

1. **Gerçek iPhone'da test et**
   - iPhone 12 veya üzeri önerilir
   - iOS 17.0+ gerekli

2. **Farklı ekran boyutları**
   - iPhone SE (küçük)
   - iPhone 15 Pro (orta)
   - iPhone 15 Pro Max (büyük)

---

## 🚀 Release Build

Test başarılı olursa:

1. **Scheme** → **Edit Scheme** → **Run**
2. **Build Configuration** → **Release** seç
3. Performans tekrar test et
4. Archive oluştur (**Product** → **Archive**)

---

## 📝 Notlar

### Bilinen SourceKit Uyarıları

Xcode'da bazı "Cannot find type" uyarıları görebilirsiniz. Bunlar:

- Dosyalar target'a eklenmemişse gerçek hata
- Dosyalar ekliyse ama uyarı varsa: Clean Build (⇧+⌘+K) + Build (⌘+B)

### SwiftData İlk Çalıştırma

İlk çalıştırmada:
- PlayerData otomatik oluşturulur (0 yeşil puan)
- Sadece Seviye 1 açık
- Diğer seviyeler kilitli

---

## ✅ Başarı Kriterleri

Proje **test edilmeye hazır** demek:

- ✅ Build başarılı (0 hata)
- ✅ Ana menü açılıyor
- ✅ Seviye 1 oynanabiliyor
- ✅ Birleştirme çalışıyor
- ✅ Sonsuz mod açılıyor
- ✅ 60 FPS
- ✅ Ses/haptic çalışıyor

---

## 🆘 Yardım

Sorun yaşarsanız:

1. Clean Build Folder (⇧+⌘+K)
2. Derived Data sil
3. Xcode'u yeniden başlat
4. README.md ve FINAL_SUMMARY.md'ye bakın

---

**Başarılar! 🎉**

Herhangi bir sorunla karşılaşırsanız, hata mesajını ve hangi adımda olduğunuzu bildirin.
