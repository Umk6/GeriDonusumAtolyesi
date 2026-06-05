# Xcode Kurulum Adımları

## Yeni dosyaları projeye eklemek için:

1. **Xcode'da projeyi açın** (GeriDonusumAtolyesi.xcodeproj)

2. **Sol panelde proje navigator'da "GeriDonusumAtolyesi" klasörüne sağ tıklayın**

3. **"Add Files to 'GeriDonusumAtolyesi'..." seçin**

4. **Şu klasörleri seçin:**
   - Models
   - Game  
   - UI (içindeki GameView.swift, LevelSelectView.swift)

5. **Önemli: Bu ayarların işaretli olduğundan emin olun:**
   - ✅ Copy items if needed
   - ✅ Create groups
   - ✅ Add to targets: GeriDonusumAtolyesi (main target)

6. **"Add" butonuna tıklayın**

7. **Build (⌘B) yapın**

8. **Hataları kontrol edin**

## Eğer hala hatalar varsa:

### "Cannot find type 'WasteItem'" hatası:
- Models/WasteType.swift dosyası eklenmiş mi kontrol edin
- Build Settings → Swift Compiler → Custom Flags kontrol edin

### "Cannot find 'UIColor'" hatası:
- UIKit import eksik olabilir
- Dosyanın başına `import UIKit` ekleyin

### Derlenmiyor:
1. Product → Clean Build Folder (⌘⇧K)
2. Derived Data'yı silin:
   - Xcode → Preferences → Locations → Derived Data → Ok işareti → Delete
3. Tekrar build edin (⌘B)

## Dosya Yapısı Şöyle Olmalı:

```
GeriDonusumAtolyesi/
├── GeriDonusumAtolyesiApp.swift
├── ContentView.swift
├── Item.swift
├── Models/
│   ├── WasteType.swift
│   ├── Level.swift
│   └── Player.swift
├── Game/
│   ├── GameScene.swift
│   └── WasteNode.swift
├── UI/
│   ├── MainMenuView.swift
│   ├── GameView.swift
│   └── LevelSelectView.swift
└── Assets.xcassets/
```

## Test Etmek İçin:

1. Simülatör seçin: iPhone 15 Pro
2. ⌘R ile çalıştırın
3. Ana menüde "OYNA" butonuna basın
4. Seviye 1'i seçin
5. Atıklar düşmeye başlamalı

## Sorun Devam Ederse:

Xcode'daki hata mesajlarının ekran görüntüsünü alın ve bana gönderin!
