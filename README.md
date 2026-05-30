
<img width="534" height="77" alt="image" src="https://github.com/user-attachments/assets/003994b8-6ff0-488e-9e5d-0a54c1173d88" />




# NotchPromter

> A MacBook notch-hugging teleprompter — scrolling text right above your screen's notch, always visible, never in the way.

**🇬🇧 English** · [🇹🇷 Türkçe](#-türkçe)

---

## 🇬🇧 English

### What is NotchPromter?

NotchPromter is a lightweight macOS menu bar app that turns the dead space around your MacBook's notch into a live, upward-scrolling teleprompter. Whether you're on a video call, doing a presentation, or just need a reminder on screen — NotchPromter keeps your text floating right at the top of your display.

![macOS](https://img.shields.io/badge/macOS-15%20Sequoia%2B-black?logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.10%2B-orange?logo=swift)
![License](https://img.shields.io/badge/license-MIT-blue)

---

### Features

- 🎯 **Notch-aware positioning** — sits precisely above the built-in display notch
- ⬆️ **Smooth upward scrolling** — continuous ticker with configurable speed
- 📄 **Multiple content sources** — plain text file, URL, or RSS feed
- 🔧 **JSON path parsing** — extract specific fields from JSON APIs
- 🎨 **Customizable appearance** — adjustable font size and scroll speed
- ⏱️ **Auto-refresh** — configurable polling interval (30 s – 60 min)
- 🖥️ **Always on top** — floats above all windows, never steals focus
- 🌑 **Non-intrusive** — ignores mouse events, hides from app switcher

---

### Requirements

| Requirement | Minimum |
|---|---|
| macOS | 15 Sequoia |
| Device | MacBook with notch (2021 or later) |
| Swift | 5.10+ |
| Xcode | 16+ |

---

### Installation

#### Build from Source

```bash
git clone https://github.com/yourusername/NotchPromter.git
cd NotchPromter
open NotchPromter.xcodeproj
```

Then press **⌘R** in Xcode to build and run.

#### Quick Start with a Text File

1. Create a `ticker.txt` file next to the app bundle (or in your Documents folder)
2. Add your text content — each line becomes a paragraph
3. Launch NotchPromter — it will find the file automatically

---

### Configuration

Click the **menu bar icon → Ayarlar** (Settings) to configure:

#### Content Sources

| Type | Description |
|---|---|
| **File** | A local `.txt`, `.json`, or `.xml` file |
| **URL** | Any HTTP/HTTPS endpoint returning text or JSON |
| **RSS** | An RSS feed — displays the latest 10 item titles |

#### JSON Parsing Modes

| Mode | Behavior |
|---|---|
| **Plain Text** | Displays raw response as-is |
| **Lines** | Each non-empty line becomes a paragraph |
| **JSON Path** | Dot-notation path into JSON (e.g. `items.0.title`) |

#### Display Settings

| Setting | Range | Default |
|---|---|---|
| Font Size | 22 – 48 pt | 31 pt |
| Scroll Speed | 1 – 12 | 5 |
| Refresh Interval | 30 s – 60 min | 5 min |

---

### How It Works

NotchPromter creates a borderless, click-through `NSWindow` positioned just above the notch area of the built-in display. It uses `TimelineView(.animation)` for butter-smooth scrolling driven by elapsed time rather than frame-by-frame state, ensuring consistent speed regardless of system load.

```
Screen
┌─────────────────────────────┐
│  ┌──────┬──────────┬──────┐ │  ← menu bar
│  │      │  notch   │      │ │
│  └──────┴──┤▓▓▓▓▓├─┴──────┘ │  ← NotchPromter window
│            │ text │          │
│            └──────┘          │
│                               │
│      (rest of desktop)        │
└─────────────────────────────┘
```

---

### Project Structure

```
NotchPromter/
└── NotchPromterApp.swift      # Single-file app
    ├── NotchPromterApp        # @main SwiftUI entry point
    ├── AppDelegate            # Menu bar setup & window lifecycle
    ├── NotchOverlayWindowController  # Screen positioning logic
    ├── NotchOverlayWindow     # Borderless, click-through NSWindow
    ├── PrompterTickerView     # SwiftUI root view with styling
    ├── VerticalPrompterText   # Scrolling animation engine
    ├── SettingsView           # Settings UI (SwiftUI Form)
    ├── TickerViewModel        # Data fetching & refresh logic
    └── ContentSource          # URL / File / RSS fetcher & parser
```

---

### License

MIT © 2025 — see [LICENSE](LICENSE) for details.

---
---

## 🇹🇷 Türkçe

### NotchPromter Nedir?

NotchPromter, MacBook'unuzun ekran çentik (notch) alanının hemen üstünde, yukarıya kayan canlı bir prompter (metin akıcısı) oluşturan hafif bir macOS menü çubuğu uygulamasıdır. Video görüşmesi, sunum veya sadece ekranda hatırlatıcı bulundurmak istediğinizde — NotchPromter metninizi ekranın en üstünde sessizce kaydırır.

![macOS](https://img.shields.io/badge/macOS-15%20Sequoia%2B-black?logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.10%2B-orange?logo=swift)
![Lisans](https://img.shields.io/badge/lisans-MIT-blue)

---

### Özellikler

- 🎯 **Notch'a duyarlı konumlandırma** — dahili ekrandaki çentiğin tam üstüne oturur
- ⬆️ **Akıcı yukarı kaydırma** — ayarlanabilir hızda kesintisiz ticker
- 📄 **Birden fazla içerik kaynağı** — düz metin dosyası, URL veya RSS beslemesi
- 🔧 **JSON yol ayrıştırma** — JSON API'lerinden belirli alanları çeker
- 🎨 **Özelleştirilebilir görünüm** — yazı boyutu ve kaydırma hızı ayarlanabilir
- ⏱️ **Otomatik yenileme** — 30 saniyeden 60 dakikaya kadar yapılandırılabilir aralık
- 🖥️ **Her zaman üstte** — tüm pencerelerin üzerinde yüzer, odağı çalmaz
- 🌑 **Müdahale etmez** — fare olaylarını yoksayar, uygulama değiştiricide gizlenir

---

### Gereksinimler

| Gereksinim | Minimum |
|---|---|
| macOS | 15 Sequoia |
| Cihaz | Notch'lu MacBook (2021 veya sonrası) |
| Swift | 5.10+ |
| Xcode | 16+ |

---

### Kurulum

#### Kaynak Koddan Derleme

```bash
git clone https://github.com/yourusername/NotchPromter.git
cd NotchPromter
open NotchPromter.xcodeproj
```

Ardından Xcode'da **⌘R** ile derleyip çalıştırın.

#### Metin Dosyasıyla Hızlı Başlangıç

1. Uygulama paketinin yanına veya Documents klasörünüze bir `ticker.txt` dosyası oluşturun
2. Metin içeriğinizi ekleyin — her satır ayrı bir paragraf olur
3. NotchPromter'ı başlatın — dosyayı otomatik olarak bulur

---

### Yapılandırma

**Menü çubuğu simgesi → Ayarlar** kısmından yapılandırabilirsiniz:

#### İçerik Kaynakları

| Tür | Açıklama |
|---|---|
| **Dosya** | Yerel `.txt`, `.json` veya `.xml` dosyası |
| **URL** | Metin veya JSON döndüren herhangi bir HTTP/HTTPS uç noktası |
| **RSS** | RSS beslemesi — son 10 öğe başlığını gösterir |

#### JSON Ayrıştırma Modları

| Mod | Davranış |
|---|---|
| **Düz Metin** | Ham yanıtı olduğu gibi gösterir |
| **Satırlar** | Boş olmayan her satır bir paragraf olur |
| **JSON Path** | JSON içine nokta gösterimiyle yol (örn. `items.0.title`) |

#### Görünüm Ayarları

| Ayar | Aralık | Varsayılan |
|---|---|---|
| Yazı Boyutu | 22 – 48 pt | 31 pt |
| Kaydırma Hızı | 1 – 12 | 5 |
| Yenileme Aralığı | 30 sn – 60 dk | 5 dk |

---

### Nasıl Çalışır?

NotchPromter, dahili ekranın notch alanının hemen üstüne konumlandırılmış, kenarsız ve tıklamayı geçiren bir `NSWindow` oluşturur. Sistem yüküne bakılmaksızın tutarlı kaydırma hızı sağlamak için kare-kare durum yerine geçen süreye dayalı `TimelineView(.animation)` kullanır.

---

### Proje Yapısı

```
NotchPromter/
└── NotchPromterApp.swift      # Tek dosya uygulama
    ├── NotchPromterApp        # @main SwiftUI giriş noktası
    ├── AppDelegate            # Menü çubuğu kurulumu & pencere yaşam döngüsü
    ├── NotchOverlayWindowController  # Ekran konumlandırma mantığı
    ├── NotchOverlayWindow     # Kenarsız, tıklamayı geçiren NSWindow
    ├── PrompterTickerView     # Stillendirilmiş SwiftUI kök görünümü
    ├── VerticalPrompterText   # Kaydırma animasyon motoru
    ├── SettingsView           # Ayarlar arayüzü (SwiftUI Form)
    ├── TickerViewModel        # Veri çekme & yenileme mantığı
    └── ContentSource          # URL / Dosya / RSS çekici & ayrıştırıcı
```
