# ⚔️ Fan Warfield

**Fan Warfield**, taraftarların ülkelerini savaş meydanında temsil ettiği, rekabetçi ve modern bir mobil/web oyun projesidir. Proje, **Flutter** ve **Supabase** altyapısı üzerine inşa edilmiştir.

Sürükleyici karanlık tema (dark mode) tasarımı, akıcı animasyonları ve güçlü veri katmanı entegrasyonu ile modern bir kullanıcı deneyimi sunar.

---

## 🚀 Projenin Şu Anki Durumu & Özellikleri

Şu ana kadar projenin temel altyapısı, kimlik doğrulama akışları ve profil oluşturma süreçleri eksiksiz bir şekilde tamamlanmıştır:

### 1. 🛡️ Güçlü Kimlik Doğrulama Katmanı (`AuthService`)
Supabase Auth kullanılarak geliştirilmiş, farklı giriş tiplerini destekleyen bir yapı kurulmuştur:
*   **E-posta & Şifre:** Güvenli kayıt (`signUpWithEmail`) ve giriş (`signInWithEmail`) işlemleri.
*   **Google OAuth:** Google ile hızlı giriş desteği (`io.supabase.fanwarfield://login-callback/` yönlendirmesiyle).
*   **Misafir Girişi (Anonymous Sign-In):** Hesapsız oynamak isteyenler için geçici oturum desteği.
*   **Çıkış Yapma:** Oturumu güvenli bir şekilde kapatma entegrasyonu.

### 2. 🚦 Akıllı Yönlendirme Geçidi (`AuthGate`)
Uygulama açılışında kullanıcının durumunu dinamik olarak kontrol eden bir mekanizma:
*   Kullanıcı giriş yapmamışsa otomatik olarak **Giriş Ekranı (AuthScreen)** gösterilir.
*   Kullanıcı giriş yapmışsa, arka planda Supabase veritabanında bir profilinin olup olmadığı kontrol edilir (`isReturningUser`).
    *   **Profil var ise:** Doğrudan **Ana Uygulama Ekranına (Dashboard)** yönlendirilir.
    *   **Profil yok ise (Yeni kayıt):** Kullanıcıyı **Ülke Seçim Ekranı'na (CountrySelectionScreen)** yönlendirir.

### 3. 🗺️ Ülke Seçim Akışı (`CountrySelectionScreen`)
Kullanıcının profil oluştururken temsil etmek istediği ülkeyi seçtiği modern arayüz:
*   Emoji bayrakları eşliğinde 20 farklı popüler ülke seçeneği.
*   Gelişmiş arama/filtreleme çubuğu.
*   Yumuşak animasyonlu kart seçimi ve onaylama butonu.
*   Seçim onaylandığında arka planda otomatik olarak Supabase üzerinde profil kaydı oluşturulması (`createProfile`).

### 4. 📊 Profil Veri Modeli & Servisi (`ProfileModel` & `SupabaseService`)
Veritabanı ilişkileri ve kullanıcı verilerinin yönetimi:
*   **Kullanıcı Bilgileri:** `id`, `username`, `country`, `avatarUrl`.
*   **Oyun İstatistikleri:** Puan (`points`), Galibiyet (`wins`), Mağlubiyet (`losses`).
*   **Supabase Veri Katmanı:** `profiles` tablosuna doğrudan `upsert` (oluşturma/güncelleme) ve `select` sorguları hazırlığı.

### 5. 🎨 Modern & Premium Tasarım Sistemi (`AppTheme`)
Tamamen özelleştirilmiş, modern oyun estetiğine uygun karanlık mod (Dark Mode) tasarımı:
*   **Renk Paleti:** Gece siyahı arka plan (`0xFF0A0A0C`), koyu gri kartlar, mavi (`teamA`) ve kırmızı (`teamB`) takım renkleri.
*   **Tipografi:** Modern `SF Pro Display` font desteği.
*   **Görseller:** Gradyanlar (`primaryGradient`, `accentGradient`, `warmGradient`) ve yumuşak gölgelerle zenginleştirilmiş UI bileşenleri.

---

## 📂 Proje Yapısı

```text
lib/
├── main.dart                 # Uygulama başlangıcı, Supabase init ve AuthGate yönlendirme akışı
├── app_theme.dart            # Renkler, gradyanlar, input decoration ve darkTheme tanımları
├── models/
│   └── profile_model.dart    # Kullanıcı profili veri modeli (JSON serileştirme dahil)
├── services/
│   ├── auth_service.dart     # Supabase authentication servis katmanı
│   └── supabase_service.dart # Supabase database (profiles) servis katmanı
└── screens/
    ├── auth_screen.dart      # Giriş yap / Kayıt ol / Misafir Girişi ekranı
    └── country_selection.dart# Ülke seçimi, arama ve profil kaydı tamamlama ekranı
```

---

## 🛠️ Kurulum ve Çalıştırma

Projeyi yeni bir bilgisayarda çalıştırmak için aşağıdaki adımları izleyebilirsiniz:

1.  **Bağımlılıkları Yükleyin:**
    ```bash
    flutter pub get
    ```

2.  **Supabase Bağlantısını Yapılandırın:**
    Proje, Supabase URL ve Anon Key değerlerini derleme esnasında alacak şekilde yapılandırılmıştır. Uygulamayı çalıştırırken terminalden bu parametreleri göndermeniz gerekir:
    ```bash
    flutter run \
      --dart-define=SUPABASE_URL=https://your-project.supabase.co \
      --dart-define=SUPABASE_ANON_KEY=your-anon-key
    ```
    *(Veya IDE ayarlarınızdaki `toolArgs` ya da `environment` bölümüne bu parametreleri ekleyebilirsiniz.)*

3.  **Supabase Veritabanı Tablosu:**
    Supabase projenizde aşağıdaki şemaya sahip bir `profiles` tablosunun kurulu olduğundan emin olun:
    ```sql
    create table public.profiles (
      id uuid references auth.users not null primary key,
      username text not null,
      country text not null,
      avatar_url text,
      points integer default 0,
      wins integer default 0,
      losses integer default 0,
      created_at timestamp with time zone default timezone('utc'::text, now()) not null
    );
    ```

---

## 🚀 Sonraki Adımlar (Yapılacaklar)

Projeyi devraldıktan sonra sırasıyla yapılması önerilen geliştirmeler:
- [ ] **Ana Ekran (Dashboard):** Şu an placeholder olan `_MainAppPlaceholder` widget'ı yerine kullanıcının profil detaylarını, takım skorlarını ve güncel savaş durumunu görebileceği ana ekran tasarımı yapılacak.
- [ ] **Savaş/Rekabet Mekanizmaları:** Kullanıcıların tıklamalarla veya mini oyunlarla puan kazanıp kendi ülkesini liderlik tablosunda yükseltebileceği oyun mekaniğinin kurulması.
- [ ] **Liderlik Tablosu (Leaderboard):** Ülkelerin ve bireysel kullanıcıların toplam puanlarına göre sıralandığı Supabase tabanlı bir sıralama ekranı.
