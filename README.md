# 🌸 Flora – Information System for Florists

Flora je informacioni sistem za cvjećare koji omogućava **digitalizaciju procesa prodaje cvijeća**, personalizaciju narudžbi, rezervacije i edukativni sadržaj kroz blog.  
Sistem obuhvata **desktop i mobilnu aplikaciju**, te backend razvijen u **ASP.NET Core**.

---

## 🚀 Upute za pokretanje

### 🔹 Backend setup
1. Klonirati **Flora** repozitorij.  
2. Izvršiti extract `.env` fajla koristeći šifru `fit` u root direktoriju **FloraApp_RS2**  
3. Otvoriti folder **`FloraBackend`**  
4. Locirati `env.zip` arhivu unutar **`Flora backend\FloraAPI`** foldera  
   - Izvršiti extract `.env` fajla koristeći šifru `fit`  
   - `.env` fajl se mora nalaziti u `Flora backend\FloraAPI` folderu  
5. Locirati `env.zip` arhivu unutar **`Flora backend\FloraApp.Subscriber`** foldera  
   - Izvršiti extract `.env` fajla koristeći šifru `fit`  
   - `.env` fajl se mora nalaziti u `Flora backend\FloraApp.Subscriber` folderu  

🌼 **Ukupno 3 `.env` fajla se moraju unzipovati!**

6. Vratiti se u **`Flora backend`** folder, otvoriti terminal i pokrenuti komandu:

```bash
docker compose up --build

Sačekati da se sve uspješno build-a.⏳

Frontend aplikacije
Vratiti se u FloraApp_RS2 root folder i locirati fit-build-2025-8-24.zip arhivu.

Extract arhive daje dva foldera: Release i flutter-apk.

U Release folderu pokrenuti:
flora_desktop.exe

U flutter-apk folderu nalazi se fajl:
app-release.apk
Prenijeti ga na Android emulator ili fizički uređaj.

⚠️ Deinstalirati staru verziju aplikacije ukoliko je već instalirana.

Nakon instalacije obje aplikacije, prijaviti se pomoću test kredencijala.

🔐 Kredencijali za prijavu
🌼 Administrator

Korisničko ime: desktop

Lozinka: test

🌸 Korisnik

Korisničko ime: mobile

Lozinka: test


💳 PayPal integracija

Plaćanje narudžbi omogućeno je kroz PayPal sandbox integraciju u mobilnoj aplikaciji.
Test kartice se mogu koristiti za simulaciju plaćanja.

👉 Kredencijali za prijavu na PayPal sandbox:

Email: kupac@example.com

Lozinka: 12345678

🔧 Mikroservis funkcionalnosti

Aplikacija koristi RabbitMQ mikroservis za automatsko slanje email obavještenja u sljedećim slučajevima:

🌷 Potvrda plaćanja i kreiranje narudžbe

🌹 Promjene statusa narudžbi

🛠️ Tehnologije

🌸 Backend: ASP.NET Core (C#), EF Core

🌼 Frontend: Flutter (desktop i mobilna aplikacija)

🌺 Baza podataka: SQL Server

🌻 Message Broker: RabbitMQ

💳 Plaćanje: PayPal

🐳 Containerization: Docker

☁️ Cloud Storage: Azure Blob Storage

📌 Projekt razvijen u sklopu predmeta Razvoj softvera 2 na Fakultetu informacijskih tehnologija Mostar.
