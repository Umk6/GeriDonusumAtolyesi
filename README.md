# ♻️ Geri Dönüşüm Fabrikası

2D puzzle oyunu - Atıkları birleştir, fabrikayı yükselt, çevreyi koru!

## 🎮 Özellikler

### Oyun Mekaniği
- ✅ Sürükle-bırak kontrolleri
- ✅ 5 seviyeli birleştirme sistemi
- ✅ Combo sistemi (10x'e kadar)
- ✅ Kontaminasyon sistemi
- ✅ Kirli atık temizleme
- ✅ Fizik motoru

### Atık Türleri
- 🧴 Plastik
- 📄 Kağıt
- 🥫 Metal
- 🍾 Cam
- 🔋 Pil (planlı)
- 🍎 Organik (planlı)
- 📱 Elektronik (planlı)

### Booster'lar
- 🧲 **Mıknatıs**: Tüm metal atıkları toplar
- 💧 **Temizlik Spreyi**: Kirli atıkları temizler
- ⚡ **Süper Pres**: Aynı türleri birleştirir
- ⏰ **Zaman Yavaşlatıcı**: Atıkları yavaşlatır
- 🤖 **Robot Kol**: Hatayı geri alır

### İlerleme Sistemi
- 🎯 30 özel tasarlanmış seviye
- ⭐ 1-3 yıldız sistemi
- 🏭 Fabrika yükseltmeleri (4 tip)
- 💚 Yeşil puan ekonomisi
- 📊 Detaylı istatistikler

### Görsel & Ses
- ✨ Gelişmiş animasyonlar
- 🎆 Partiküler efektler
- 🔊 Programatik ses efektleri (7 farklı)
- 📳 Haptic feedback (iOS)
- 🌈 Glow efektleri

### UI/UX
- 📱 Tutorial sistemi (3 adım)
- ⚙️ Ayarlar ekranı
- 📊 İstatistik takibi
- 🏆 Başarım sistemi
- 💧 Temizleme istasyonu

## 🏗️ Mimari

### Teknoloji
- **SwiftUI**: UI ve ekranlar
- **SpriteKit**: Oyun sahnesi, fizik, animasyonlar
- **SwiftData**: Veri persistence
- **AVFoundation**: Ses sistemi

### Klasör Yapısı
```
GeriDonusumAtolyesi/
├── Core/
│   └── AudioManager.swift
├── Models/
│   ├── WasteType.swift
│   ├── Level.swift
│   ├── Player.swift
│   ├── Booster.swift
│   └── Statistics.swift
├── Game/
│   ├── GameScene.swift
│   ├── WasteNode.swift
│   └── CleaningStation.swift
├── UI/
│   ├── MainMenuView.swift
│   ├── LevelSelectView.swift
│   ├── GameView.swift
│   ├── FactoryUpgradeView.swift
│   ├── BoosterBarView.swift
│   ├── TutorialOverlay.swift
│   ├── SettingsView.swift
│   └── StatisticsView.swift
└── Resources/
    ├── Sounds/
    └── Sprites/
```

## 🎯 Oyun Döngüsü

1. **Ana Menü** → Seviye Seç / Fabrika / Ayarlar
2. **Tutorial** (ilk seferinde)
3. **Oyun Oyna**
   - Atıkları sürükle
   - Aynı türleri birleştir
   - Combo yap (bonus puan)
   - Kirli atıkları temizle
   - Booster kullan
4. **Sonuç Ekranı** → Yeşil puan kazan
5. **Fabrika** → Yükseltme yap
6. **Tekrar oyna!**

## 📈 Seviye Tasarımı

### Seviye 1-5: Tutorial
- Sadece plastik
- Düşük spawn rate
- Temel mekanikler

### Seviye 6-12: İlerleme
- Kağıt, metal eklenir
- Zorluk artışı
- Yeni kombinasyonlar

### Seviye 13-15: Hız
- Yüksek spawn rate
- Refleks testi
- Az hata hakkı

### Seviye 16-25: Master
- Tüm atık türleri
- Karışık hedefler
- Strateji gerekli

### Seviye 26-30: Expert
- Maksimum zorluk
- En yüksek skorlar
- Perfect oynama gerekli

## 🔧 Geliştirme Notları

### Tamamlanan
- ✅ Core game loop
- ✅ Birleştirme sistemi
- ✅ Combo sistemi
- ✅ Ses ve animasyonlar
- ✅ 30 seviye
- ✅ Fabrika sistemi
- ✅ Booster'lar
- ✅ Temizleme istasyonu
- ✅ Tutorial
- ✅ İstatistikler
- ✅ Ayarlar

### Planlanan (Gelecek Güncellemeler)
- ⏳ Bant sistemi
- ⏳ Daha fazla atık türü (pil, organik, elektronik)
- ⏳ Sonsuz mod
- ⏳ Günlük görevler
- ⏳ Koleksiyon sistemi
- ⏳ Online liderlik tablosu
- ⏳ Başarımlar (achievements)
- ⏳ Arka plan müziği
- ⏳ Daha fazla booster
- ⏳ Özel seviyeler

### Bilinen Sorunlar
- Import hataları (tip tanınmama) - Xcode'da dosyaları projeye ekle
- Beyaz ekran (düzeltildi - loading indicator eklendi)

## 🎨 Tasarım Prensipleri

### Renk Paleti
- **Plastik**: Mavi tonları
- **Kağıt**: Kahverengi/Krem
- **Metal**: Gri/Gümüş
- **Cam**: Turkuaz/Yeşil
- **UI**: Temiz, modern gradient'ler

### Animasyon İlkeleri
- Yumuşak easing
- 60 FPS hedef
- Tatmin edici feedback
- Aşırı olmayan efektler

### Ses Tasarımı
- Programatik ton üretimi
- Rahatlatıcı tonlar
- Abartısız efektler
- Kapatılabilir

## 📱 Performans

### Optimizasyonlar
- Object pooling için hazır
- Efficient particle systems
- Lazy loading
- SwiftData caching
- Minimal draw calls

### Hedef
- iPhone 12 ve üzeri
- 60 FPS
- < 100MB boyut
- Düşük batarya tüketimi

## 🎓 Eğitici Yönü

Oyun eğlenceli olsa da aynı zamanda:
- ♻️ Geri dönüşüm bilinci
- 🌍 Çevre duyarlılığı
- 📚 Atık ayrıştırma bilgisi
- 🧠 Problem çözme becerisi

## 👨‍💻 Geliştirici

**Umut Mert Kırmızıtaş**
- Email: umutmertkirmizitas97@gmail.com
- Versiyon: 1.0.0
- Son Güncelleme: 2026-06-05

## 📄 Lisans

© 2026 UMK Games. Tüm hakları saklıdır.

---

**🎮 İyi Oyunlar!**
