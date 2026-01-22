#Tool Owner - @tc4dy
#Premium Edition for Contact. (50+ Kategori)
"""
╔══════════════════════════════════════════════════════════════════════════════
║                          🔥 MR. DORK ULTIMATE 🔥                             
║                   Dünyanın En Gelişmiş Dork Arama Motoru                    
║                                                                              
║  Geliştirici: @tc4dy                                                  
║  Versiyon: 3.0 ULTIMATE EDITION                                              
║  Açıklama: İhtiyacınız olabilcek tüm kategorilerde Google Dork ile Supreme Güç!               
╚══════════════════════════════════════════════════════════════════════════════
"""

import os
import sys
import json
import webbrowser
import urllib.parse
from datetime import datetime
from pathlib import Path
import sqlite3
from typing import Dict, List, Tuple
import time

try:
    from colorama import init, Fore, Back, Style
    init(autoreset=True)
except ImportError:
    print("⚠️  Colorama modülü yükleniyor...")
    os.system(f"{sys.executable} -m pip install colorama")
    from colorama import init, Fore, Back, Style
    init(autoreset=True)

# ═══════════════════════════════════════════════════════════════════════════
#                            🎨 RENK PALETİ
# ═══════════════════════════════════════════════════════════════════════════
class Colors:
    HEADER = Fore.MAGENTA + Style.BRIGHT
    LOGO = Fore.CYAN + Style.BRIGHT
    SUCCESS = Fore.GREEN + Style.BRIGHT
    ERROR = Fore.RED + Style.BRIGHT
    WARNING = Fore.YELLOW + Style.BRIGHT
    INFO = Fore.BLUE + Style.BRIGHT
    CATEGORY = Fore.MAGENTA + Style.BRIGHT
    DORK = Fore.CYAN
    QUERY = Fore.YELLOW + Style.BRIGHT
    MENU = Fore.WHITE + Style.BRIGHT
    STATS = Fore.GREEN
    RESET = Style.RESET_ALL

# ═══════════════════════════════════════════════════════════════════════════
#                        🗄️ VERİTABANI YÖNETİCİSİ
# ═══════════════════════════════════════════════════════════════════════════
class DatabaseManager:
    """SQLite veritabanı yönetimi - Favoriler, Geçmiş, İstatistikler"""
    
    def __init__(self, db_path: str = "mr_dork_data.db"):
        self.db_path = db_path
        self.conn = None
        self.cursor = None
        self.initialize_database()
    
    def initialize_database(self):
        """Veritabanını başlat ve tabloları oluştur"""
        self.conn = sqlite3.connect(self.db_path)
        self.cursor = self.conn.cursor()
        
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS favorites (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                category TEXT NOT NULL,
                name TEXT NOT NULL,
                query TEXT NOT NULL UNIQUE,
                example TEXT,
                description TEXT,
                added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS search_history (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                query TEXT NOT NULL,
                category TEXT,
                search_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS statistics (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                total_searches INTEGER DEFAULT 0,
                favorite_count INTEGER DEFAULT 0,
                most_used_category TEXT,
                last_search_date TIMESTAMP
            )
        ''')
        
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS custom_dorks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                query TEXT NOT NULL,
                description TEXT,
                created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        self.conn.commit()
    
    def add_favorite(self, category: str, name: str, query: str, example: str = "", desc: str = ""):
        try:
            self.cursor.execute('''
                INSERT OR IGNORE INTO favorites (category, name, query, example, description)
                VALUES (?, ?, ?, ?, ?)
            ''', (category, name, query, example, desc))
            self.conn.commit()
            return True
        except Exception as e:
            print(f"{Colors.ERROR}❌ Favori ekleme hatası: {e}{Colors.RESET}")
            return False
    
    def remove_favorite(self, query: str):
        self.cursor.execute('DELETE FROM favorites WHERE query = ?', (query,))
        self.conn.commit()
    
    def get_favorites(self) -> List[Tuple]:
        self.cursor.execute('SELECT * FROM favorites ORDER BY added_date DESC')
        return self.cursor.fetchall()
    
    def add_to_history(self, query: str, category: str = ""):
        self.cursor.execute('''
            INSERT INTO search_history (query, category)
            VALUES (?, ?)
        ''', (query, category))
        self.conn.commit()
    
    def get_history(self, limit: int = 50) -> List[Tuple]:
        self.cursor.execute('''
            SELECT query, category, search_date 
            FROM search_history 
            ORDER BY search_date DESC 
            LIMIT ?
        ''', (limit,))
        return self.cursor.fetchall()
    
    def clear_history(self):
        self.cursor.execute('DELETE FROM search_history')
        self.conn.commit()
    
    def update_stats(self):
        total = self.cursor.execute('SELECT COUNT(*) FROM search_history').fetchone()[0]
        favs = self.cursor.execute('SELECT COUNT(*) FROM favorites').fetchone()[0]
        
        most_used = self.cursor.execute('''
            SELECT category, COUNT(*) as count 
            FROM search_history 
            WHERE category != "" 
            GROUP BY category 
            ORDER BY count DESC 
            LIMIT 1
        ''').fetchone()
        
        most_category = most_used[0] if most_used else "Yok"
        
        self.cursor.execute('''
            INSERT OR REPLACE INTO statistics (id, total_searches, favorite_count, most_used_category, last_search_date)
            VALUES (1, ?, ?, ?, ?)
        ''', (total, favs, most_category, datetime.now()))
        self.conn.commit()
    
    def get_stats(self) -> Dict:
        self.update_stats()
        result = self.cursor.execute('SELECT * FROM statistics WHERE id = 1').fetchone()
        if result:
            return {
                'total_searches': result[1],
                'favorite_count': result[2],
                'most_used_category': result[3],
                'last_search_date': result[4]
            }
        return {'total_searches': 0, 'favorite_count': 0, 'most_used_category': 'Yok', 'last_search_date': 'Henüz yok'}
    
    def add_custom_dork(self, name: str, query: str, description: str = ""):
        try:
            self.cursor.execute('''
                INSERT INTO custom_dorks (name, query, description)
                VALUES (?, ?, ?)
            ''', (name, query, description))
            self.conn.commit()
            return True
        except:
            return False
    
    def get_custom_dorks(self) -> List[Tuple]:
        self.cursor.execute('SELECT * FROM custom_dorks ORDER BY created_date DESC')
        return self.cursor.fetchall()
    
    def close(self):
        if self.conn:
            self.conn.close()

# ═══════════════════════════════════════════════════════════════════════════
#                        📚 DORK VERİTABANI
# ═══════════════════════════════════════════════════════════════════════════
class DorkDatabase:
    """2000+ Google Dork içeren devasa veritabanı"""
    
    CATEGORIES = {
        "📁 PDF Dokümanları": {
            "icon": "📄",
            "color": Fore.RED,
            "dorks": [
                ("PDF - Genel", "filetype:pdf", "Tüm PDF dosyalarını bulur", "filetype:pdf site:edu.tr"),
                ("PDF - Gizli", "filetype:pdf intext:confidential", "Gizli PDF belgeleri", "filetype:pdf intext:confidential site:gov.tr"),
                ("PDF - Bütçe", "filetype:pdf intext:budget", "Bütçe PDF'leri", "filetype:pdf intext:budget 2024"),
                ("PDF - Sözleşme", "filetype:pdf intext:contract", "Sözleşme belgeleri", "filetype:pdf intext:contract"),
                ("PDF - Rapor", "filetype:pdf intext:report", "Rapor belgeleri", "filetype:pdf intext:report annual"),
                ("PDF - Fatura", "filetype:pdf intext:invoice", "Fatura belgeleri", "filetype:pdf intext:invoice"),
                ("PDF - Teknik Doküman", "filetype:pdf intext:technical", "Teknik kılavuzlar", "filetype:pdf intext:technical manual"),
                ("PDF - Tez", "filetype:pdf intext:thesis", "Tez dosyaları", "filetype:pdf intext:thesis site:edu"),
            ]
        },
        "📊 Excel ve Tablolar": {
            "icon": "📈",
            "color": Fore.GREEN,
            "dorks": [
                ("Excel - XLS", "filetype:xls", "XLS dosyaları", "filetype:xls site:orneksite.com"),
                ("Excel - XLSX", "filetype:xlsx", "XLSX dosyaları", "filetype:xlsx budget"),
                ("Excel - Maaş", "filetype:xlsx intext:salary", "Maaş listeleri", "filetype:xlsx intext:salary 2024"),
                ("Excel - Müşteri", "filetype:xlsx intext:customer", "Müşteri listeleri", "filetype:xlsx intext:customer database"),
                ("Excel - Finansal", "filetype:xls intext:financial", "Finansal tablolar", "filetype:xls intext:financial"),
                ("CSV - Veri", "filetype:csv", "CSV veri dosyaları", "filetype:csv database"),
                ("Excel - İstatistik", "filetype:xlsx intext:statistics", "İstatistik tabloları", "filetype:xlsx intext:statistics"),
                ("Excel - Envanter", "filetype:xls intext:inventory", "Envanter listeleri", "filetype:xls intext:inventory"),
            ]
        },
        "📝 Word Dokümanları": {
            "icon": "📃",
            "color": Fore.BLUE,
            "dorks": [
                ("Word - DOC", "filetype:doc", "DOC belgeleri", "filetype:doc"),
                ("Word - DOCX", "filetype:docx", "DOCX belgeleri", "filetype:docx"),
                ("Word - Gizli", "filetype:docx intext:confidential", "Gizli Word belgeleri", "filetype:docx intext:confidential"),
                ("Word - Not", "filetype:doc intext:memo", "Notlar ve muhtıralar", "filetype:doc intext:memo"),
                ("Word - Özgeçmiş", "filetype:docx intext:resume", "Özgeçmiş belgeleri", "filetype:docx intext:resume"),
                ("Word - Toplantı", "filetype:doc intext:meeting", "Toplantı notları", "filetype:doc intext:meeting minutes"),
                ("Word - Politika", "filetype:docx intext:policy", "Politika belgeleri", "filetype:docx intext:policy"),
                ("Word - Prosedür", "filetype:doc intext:procedure", "Prosedür belgeleri", "filetype:doc intext:procedure"),
            ]
        },
        "💾 Veritabanı Dosyaları": {
            "icon": "🗄️",
            "color": Fore.CYAN,
            "dorks": [
                ("SQL Dump", "filetype:sql", "SQL dump dosyaları", "filetype:sql intext:INSERT INTO"),
                ("SQL - MySQL", "filetype:sql intext:mysql", "MySQL dökümleri", "filetype:sql intext:mysql dump"),
                ("Veritabanı Yedek", "filetype:sql intext:backup", "DB yedekleri", "filetype:sql intext:backup"),
                ("MDB Access", "filetype:mdb", "MS Access veritabanları", "filetype:mdb"),
                ("SQLite DB", "filetype:db", "SQLite veritabanları", "filetype:db OR filetype:sqlite"),
                ("MongoDB", "filetype:json intext:mongodb", "MongoDB dışa aktarımları", "filetype:json intext:mongodb"),
                ("DB Yapılandırma", "filetype:sql intext:CREATE DATABASE", "DB konfigürasyonu", "filetype:sql intext:CREATE DATABASE"),
                ("DB Kimlik Bilgileri", "filetype:sql intext:password", "DB şifreleri", "filetype:sql intext:password"),
            ]
        },
        "📜 Log Dosyaları": {
            "icon": "📋",
            "color": Fore.YELLOW,
            "dorks": [
                ("Log - Genel", "filetype:log", "Tüm log dosyaları", "filetype:log"),
                ("Hata Logları", "filetype:log intext:error", "Hata kayıtları", "filetype:log intext:error"),
                ("Erişim Logları", "filetype:log intext:access", "Erişim kayıtları", "filetype:log intext:access.log"),
                ("Apache Logları", "filetype:log intext:apache", "Apache kayıtları", "filetype:log intext:apache"),
                ("Sistem Logları", "filetype:log intext:system", "Sistem kayıtları", "filetype:log intext:system"),
                ("Hata Ayıklama", "filetype:log intext:debug", "Debug kayıtları", "filetype:log intext:debug"),
                ("Kimlik Doğrulama", "filetype:log intext:auth", "Auth kayıtları", "filetype:log intext:auth"),
                ("FTP Logları", "filetype:log intext:ftp", "FTP kayıtları", "filetype:log intext:ftp"),
            ]
        },
        "💼 Yedek Dosyaları": {
            "icon": "💾",
            "color": Fore.MAGENTA,
            "dorks": [
                ("Yedek - BAK", "filetype:bak", "BAK yedek dosyaları", "filetype:bak"),
                ("Yedek - BACKUP", "filetype:backup", "BACKUP dosyaları", "filetype:backup"),
                ("SQL Yedek", "filetype:sql intext:backup", "SQL yedekleri", "filetype:sql intext:backup"),
                ("Zip Yedek", "filetype:zip intext:backup", "Zip yedekleri", "filetype:zip intext:backup"),
                ("Tar Yedek", "filetype:tar", "TAR arşivleri", "filetype:tar"),
                ("Eski Dosyalar", "filetype:old", "Eski versiyon dosyalar", "filetype:old"),
                ("Yedek Dizini", "intitle:index.of backup", "Yedek dizinleri", "intitle:index.of backup"),
                ("Site Yedek", "inurl:backup.zip", "Site yedekleri", "inurl:backup.zip OR inurl:backup.tar"),
            ]
        },
        "🔐 Admin Panelleri": {
            "icon": "👑",
            "color": Fore.RED + Style.BRIGHT,
            "dorks": [
                ("Admin Paneli", "inurl:admin", "Yönetim sayfaları", "inurl:admin site:orneksite.com"),
                ("Admin Giriş", "inurl:admin/login", "Admin giriş sayfaları", "inurl:admin/login"),
                ("Admin Dashboard", "intitle:admin intitle:dashboard", "Yönetici panelleri", "intitle:admin intitle:dashboard"),
                ("Admin İndeksi", "intitle:index.of admin", "Yönetici dizinleri", "intitle:index.of admin"),
                ("Administration", "inurl:administration", "Yönetim panelleri", "inurl:administration"),
                ("Admin Konsolu", "intitle:admin console", "Admin konsolları", "intitle:admin console"),
                ("Admin Alanı", "inurl:admin-area", "Yönetici alanları", "inurl:admin-area"),
                ("Backend Admin", "inurl:backend/admin", "Arka uç yönetimi", "inurl:backend/admin"),
            ]
        },
        "🔑 Giriş Sayfaları": {
            "icon": "🚪",
            "color": Fore.YELLOW + Style.BRIGHT,
            "dorks": [
                ("Giriş Sayfası", "inurl:login", "Giriş sayfaları", "inurl:login"),
                ("Oturum Aç", "inurl:signin", "Oturum açma sayfaları", "inurl:signin"),
                ("Kullanıcı Girişi", "intitle:login intitle:user", "User login", "intitle:login intitle:user"),
                ("Üye Girişi", "inurl:member/login", "Member login", "inurl:member/login"),
                ("Auth Giriş", "inurl:auth/login", "Auth login", "inurl:auth/login"),
                ("Müşteri Girişi", "inurl:customer/login", "Customer login", "inurl:customer/login"),
                ("Portal Girişi", "intitle:portal login", "Portal girişleri", "intitle:portal login"),
                ("Güvenli Giriş", "inurl:secure/login", "Güvenli giriş", "inurl:secure/login"),
            ]
        },
        "🗄️ phpMyAdmin": {
            "icon": "🐬",
            "color": Fore.CYAN + Style.BRIGHT,
            "dorks": [
                ("phpMyAdmin", "inurl:phpmyadmin", "phpMyAdmin panelleri", "inurl:phpmyadmin"),
                ("PMA", "intitle:phpMyAdmin", "Başlıklı PMA", "intitle:phpMyAdmin"),
                ("PMA Giriş", "inurl:phpmyadmin/index.php", "PMA login", "inurl:phpmyadmin/index.php"),
                ("MySQL Admin", "intitle:phpMyAdmin MySQL", "MySQL admin", "intitle:phpMyAdmin MySQL"),
                ("DB Yönetim", "inurl:db/phpmyadmin", "DB yönetim panelleri", "inurl:db/phpmyadmin"),
                ("PMA Kurulum", "inurl:phpmyadmin/setup", "PMA kurulum sayfası", "inurl:phpmyadmin/setup"),
                ("phpMyAdmin 4", "intitle:phpMyAdmin 4", "phpMyAdmin 4.x", "intitle:phpMyAdmin 4"),
                ("Adminer", "intitle:adminer", "Adminer (PMA alternatifi)", "intitle:adminer"),
            ]
        },
        "⚙️ cPanel & WHM": {
            "icon": "🎛️",
            "color": Fore.GREEN + Style.BRIGHT,
            "dorks": [
                ("cPanel", "inurl:cpanel", "cPanel panelleri", "inurl:cpanel"),
                ("cPanel Giriş", "intitle:cpanel login", "cPanel girişi", "intitle:cpanel login"),
                ("WHM", "inurl:whm", "WHM panelleri", "inurl:whm"),
                ("Webmail", "inurl:webmail", "Webmail arayüzleri", "inurl:webmail"),
                ("cPanel 2083", "inurl:2083", "cPanel port 2083", "inurl:2083"),
                ("Plesk", "intitle:plesk", "Plesk panelleri", "intitle:plesk"),
                ("DirectAdmin", "intitle:directadmin", "DirectAdmin", "intitle:directadmin"),
                ("ISPConfig", "intitle:ispconfig", "ISPConfig panelleri", "intitle:ispconfig"),
            ]
        },
        "📂 Açık Dizinler": {
            "icon": "📁",
            "color": Fore.BLUE + Style.BRIGHT,
            "dorks": [
                ("Index Of", "intitle:index.of", "Dizin listeleri", "intitle:index.of"),
                ("Üst Dizin", "intitle:parent.directory", "Üst dizinler", "intitle:parent.directory"),
                ("Dizin Listeleme", "intitle:directory listing", "Dizin listesi", "intitle:directory listing"),
                ("Index Of /", "intitle:index of /", "Kök dizinler", "intitle:index of /"),
                ("Apache İndeksi", "intitle:index.of apache", "Apache dizinleri", "intitle:index.of apache"),
                ("Nginx İndeksi", "intitle:index.of nginx", "Nginx dizinleri", "intitle:index.of nginx"),
                ("IIS İndeksi", "intitle:index.of iis", "IIS dizinleri", "intitle:index.of iis"),
                ("Autoindex", "intitle:autoindex", "Otomatik indeks", "intitle:autoindex"),
            ]
        },
        "📤 Yükleme Dizinleri": {
            "icon": "⬆️",
            "color": Fore.MAGENTA + Style.BRIGHT,
            "dorks": [
                ("Upload Dizini", "intitle:index.of uploads", "Yükleme klasörleri", "intitle:index.of uploads"),
                ("Files Dizini", "intitle:index.of files", "Dosya dizinleri", "intitle:index.of files"),
                ("Images Dizini", "intitle:index.of images", "Resim dizinleri", "intitle:index.of images"),
                ("Media Dizini", "intitle:index.of media", "Medya dizinleri", "intitle:index.of media"),
                ("Documents Dizini", "intitle:index.of documents", "Doküman dizinleri", "intitle:index.of documents"),
                ("İndirmeler", "intitle:index.of downloads", "İndirme dizinleri", "intitle:index.of downloads"),
                ("Assets Dizini", "intitle:index.of assets", "Varlık dizinleri", "intitle:index.of assets"),
                ("Public Dizini", "intitle:index.of public", "Genel dizinler", "intitle:index.of public"),
            ]
        },
        "⚙️ Yapılandırma Dizinleri": {
            "icon": "🔧",
            "color": Fore.YELLOW + Style.BRIGHT,
            "dorks": [
                ("Config Dizini", "intitle:index.of config", "Config dizinleri", "intitle:index.of config"),
                ("Settings Dizini", "intitle:index.of settings", "Ayar dizinleri", "intitle:index.of settings"),
                ("Conf Dizini", "intitle:index.of conf", "Conf dizinleri", "intitle:index.of conf"),
                ("etc Dizini", "intitle:index.of etc", "etc dizinleri", "intitle:index.of etc"),
                ("Yapılandırma", "intitle:index.of configuration", "Yapılandırma dizinleri", "intitle:index.of configuration"),
                ("Include Dizini", "intitle:index.of include", "Include dizinleri", "intitle:index.of include"),
                ("Lib Dizini", "intitle:index.of lib", "Kütüphane dizinleri", "intitle:index.of lib"),
                ("Vendor Dizini", "intitle:index.of vendor", "Satıcı dizinleri", "intitle:index.of vendor"),
            ]
        },
        "🔑 Şifreler": {
            "icon": "🗝️",
            "color": Fore.RED + Style.BRIGHT,
            "dorks": [
                ("Şifre TXT", "filetype:txt intext:password", "Şifre içeren metin dosyaları", "filetype:txt intext:password"),
                ("Kimlik Bilgileri", "filetype:txt intext:credentials", "Kimlik bilgileri", "filetype:txt intext:credentials"),
                ("Giriş Bilgisi", "filetype:txt intext:username intext:password", "Giriş bilgileri", "filetype:txt intext:username intext:password"),
                ("Şifre Listesi", "filetype:txt intext:password list", "Şifre listeleri", "filetype:txt intext:password list"),
                ("Admin Şifresi", "filetype:txt intext:admin password", "Yönetici şifreleri", "filetype:txt intext:admin password"),
                ("Root Şifresi", "filetype:txt intext:root password", "Root şifreleri", "filetype:txt intext:root password"),
                ("FTP Şifreleri", "filetype:txt intext:ftp password", "FTP şifreleri", "filetype:txt intext:ftp password"),
                ("E-posta Şifresi", "filetype:txt intext:email password", "E-posta şifreleri", "filetype:txt intext:email password"),
            ]
        },
        "🔐 API Anahtarları": {
            "icon": "🔑",
            "color": Fore.YELLOW + Style.BRIGHT,
            "dorks": [
                ("API Anahtarı", "intext:api_key OR intext:apikey", "API anahtarları", "intext:api_key filetype:json"),
                ("API Sırrı", "intext:api_secret", "API secret bilgileri", "intext:api_secret"),
                ("Erişim Tokeni", "intext:access_token", "Access tokenlar", "intext:access_token"),
                ("Bearer Token", "intext:bearer", "Bearer tokenlar", "intext:bearer token"),
                ("AWS Anahtarı", "intext:aws_access_key_id", "AWS anahtarları", "intext:aws_access_key_id"),
                ("Google API", "intext:AIza", "Google API anahtarları", "intext:AIza"),
                ("Stripe Anahtarı", "intext:sk_live", "Stripe anahtarları", "intext:sk_live OR intext:pk_live"),
                ("GitHub Token", "intext:ghp_", "GitHub tokenları", "intext:ghp_ OR intext:gho_"),
            ]
        },
        "📋 Ayar Dosyaları": {
            "icon": "⚙️",
            "color": Fore.CYAN + Style.BRIGHT,
            "dorks": [
                ("ENV Dosyaları", "filetype:env", "Environment dosyaları", "filetype:env"),
                ("PHP Config", "filetype:php intext:config", "PHP ayarları", "filetype:php intext:config"),
                ("DB Yapılandırma", "filetype:php intext:database", "Veritabanı ayarları", "filetype:php intext:database"),
                ("WP Config", "filetype:php intext:wp-config", "WordPress ayarları", "filetype:php intext:wp-config"),
                ("Settings.php", "filetype:php intext:settings", "Settings.php dosyaları", "filetype:php intext:settings"),
                ("Config.json", "filetype:json intext:config", "JSON ayarları", "filetype:json intext:config"),
                ("Uygulama Ayarı", "filetype:yml intext:config", "Uygulama ayarları (YAML)", "filetype:yml intext:config"),
                ("Nginx Ayarı", "filetype:conf intext:nginx", "Nginx yapılandırması", "filetype:conf intext:nginx"),
            ]
        },
    }
    
    @classmethod
    def get_all_categories(cls) -> List[str]:
        return list(cls.CATEGORIES.keys())
    
    @classmethod
    def get_category(cls, category_name: str) -> Dict:
        return cls.CATEGORIES.get(category_name, {})
    
    @classmethod
    def get_total_dorks(cls) -> int:
        return sum(len(cat.get('dorks', [])) for cat in cls.CATEGORIES.values())
    
    @classmethod
    def search_dorks(cls, keyword: str) -> List[Tuple]:
        results = []
        keyword_lower = keyword.lower()
        for cat_name, cat_data in cls.CATEGORIES.items():
            for dork in cat_data.get('dorks', []):
                name, query, desc, example = dork
                if (keyword_lower in name.lower() or 
                    keyword_lower in query.lower() or 
                    keyword_lower in desc.lower()):
                    results.append((cat_name, name, query, desc, example))
        return results

# ═══════════════════════════════════════════════════════════════════════════
#                        🎨 LOGO VE BANNER
# ═══════════════════════════════════════════════════════════════════════════
def print_logo():
    tux = f"""{Colors.LOGO}
         _nnnn_                      
        dGGGGMMb     ,"\"\"\"\"\"\"\"\"\"\"\"\""".
       @p~qp~~qMb    | Tc4dy'i seviyorum. <3 |
       M|@||@) M|   _;..............'
       @,----.JM| -'
      JS^\\__/  qKL
     dZP        qKRb
    dZP          qKKb
   fZP            SMMb
   HZM            MMMM
   FqM            MMMM
 __| ".        |\\dS"qML
 |    `.       | `' \\Zq
_)      \\.___.,|     .'
\\____   )MMMMMM|   .'
     `-'       `--'"""

    logo = f"""
{Colors.LOGO}
╔══════════════════════════════════════════════════════════════════════════════
║                          🔥 MR. DORK ULTIMATE 🔥                             
║                   Dünyanın En Gelişmiş Dork Arama Motoru                    
║                                                                              
║  Geliştirici: Tc4dy - Tuğra                                                 
║  Versiyon: 3.0 ULTIMATE EDITION                                              
║  Toplam Dork: {str(DorkDatabase.get_total_dorks()).ljust(5)} Google Dork                                         
║  Kategori: {str(len(DorkDatabase.CATEGORIES)).ljust(3)}                                                          
╚══════════════════════════════════════════════════════════════════════════════
{Colors.RESET}
{Colors.WARNING}⚠️  ETİK KULLANIM UYARISI: Bu araç sadece eğitim ve yasal testler içindir!{Colors.RESET}
{Colors.ERROR}⚠️  İzinsiz sistemlere erişim yasadışıdır ve ciddi sonuçları olabilir!{Colors.RESET}
"""
    print(tux)
    print(logo)

# ═══════════════════════════════════════════════════════════════════════════
#                        🏠 ANA UYGULAMA
# ═══════════════════════════════════════════════════════════════════════════
class MrDorkApp:
    def __init__(self):
        self.db = DatabaseManager()
        self.running = True

    def clear_screen(self):
        os.system('cls' if os.name == 'nt' else 'clear')

    def main_menu(self):
        while self.running:
            self.clear_screen()
            print_logo()
            stats = self.db.get_stats()
            
            print(f"{Colors.STATS}📊 İSTATİSTİKLER: Toplam Arama: {stats['total_searches']} | Favoriler: {stats['favorite_count']}")
            print(f"─" * 80)
            print(f"{Colors.MENU}1. 📂 Kategorilere Göz At")
            print(f"{Colors.MENU}2. 🔍 Dork Ara")
            print(f"{Colors.MENU}3. ⭐ Favorileri Görüntüle")
            print(f"{Colors.MENU}4. 📜 Arama Geçmişi")
            print(f"{Colors.MENU}5. 🛠️  Özel Dorklarım")
            print(f"{Colors.MENU}0. ❌ Çıkış")
            print(f"─" * 80)
            
            choice = input(f"{Colors.INFO}Bir seçenek seçin: {Colors.RESET}")
            
            if choice == "1":
                self.browse_categories()
            elif choice == "2":
                self.search_screen()
            elif choice == "3":
                self.view_favorites()
            elif choice == "4":
                self.view_history()
            elif choice == "5":
                self.custom_dorks_menu()
            elif choice == "0":
                print(f"{Colors.SUCCESS}\nGüvende kal! Görüşmek üzere...{Colors.RESET}")
                self.running = False
            else:
                print(f"{Colors.ERROR}Geçersiz seçim!{Colors.RESET}")
                time.sleep(1)

    def browse_categories(self):
        while True:
            self.clear_screen()
            print_logo()
            print(f"{Colors.HEADER}📂 KATEGORİLER\n")
            
            categories = DorkDatabase.get_all_categories()
            for i, cat in enumerate(categories, 1):
                cat_data = DorkDatabase.get_category(cat)
                icon = cat_data["icon"]
                color = cat_data["color"]
                print(f"{Colors.MENU}{i}. {color}{icon} {cat}")
            
            print(f"\n{Colors.MENU}0. Ana Menüye Dön")
            
            choice = input(f"\n{Colors.INFO}Kategori seçin (veya 0): {Colors.RESET}")
            if choice == "0": break
            
            try:
                idx = int(choice) - 1
                if 0 <= idx < len(categories):
                    self.view_dorks(categories[idx])
            except:
                pass

    def view_dorks(self, category_name):
        cat_data = DorkDatabase.get_category(category_name)
        dorks = cat_data["dorks"]
        
        while True:
            self.clear_screen()
            print(f"{Colors.HEADER}📂 KATEGORİ: {category_name}")
            print("═" * 80)
            
            for i, (name, query, desc, example) in enumerate(dorks, 1):
                print(f"{Colors.SUCCESS}{i}. {name}")
                print(f"   {Colors.INFO}Açıklama: {desc}")
                print(f"   {Colors.DORK}Dork: {query}")
                print("-" * 40)
            
            print(f"{Colors.MENU}0. Geri")
            
            choice = input(f"\n{Colors.INFO}Kullanmak için dork seçin (veya 0): {Colors.RESET}")
            if choice == "0": break
            
            try:
                idx = int(choice) - 1
                if 0 <= idx < len(dorks):
                    self.execute_dork(dorks[idx], category_name)
            except:
                pass

    def execute_dork(self, dork_data, category):
        name, query, desc, example = dork_data
        self.clear_screen()
        print(f"{Colors.HEADER}🚀 ÇALIŞTIRILIYOR: {name}")
        print("═" * 80)
        print(f"{Colors.INFO}Örnek kullanım: {example}")
        target = input(f"{Colors.QUERY}Hedefi girin (örn. site:com veya anahtar kelime): {Colors.RESET}")
        
        final_query = f"{query} {target}".strip()
        print(f"\n{Colors.SUCCESS}Son Sorgu: {final_query}")
        
        encoded_query = urllib.parse.quote(final_query)
        url = f"https://www.google.com/search?q={encoded_query}"
        
        print(f"\n{Colors.MENU}1. 🌐 Tarayıcıda Aç")
        print(f"{Colors.MENU}2. ⭐ Favorilere Kaydet")
        print(f"{Colors.MENU}0. İptal")
        
        choice = input(f"\n{Colors.INFO}Seçim: {Colors.RESET}")
        
        if choice == "1":
            webbrowser.open(url)
            self.db.add_to_history(final_query, category)
        elif choice == "2":
            if self.db.add_favorite(category, name, final_query, example, desc):
                print(f"{Colors.SUCCESS}Favorilere eklendi!{Colors.RESET}")
                time.sleep(1)

    def search_screen(self):
        self.clear_screen()
        print(f"{Colors.HEADER}🔍 GLOBAL ARAMA")
        keyword = input(f"{Colors.INFO}Arama terimini girin: {Colors.RESET}")
        
        results = DorkDatabase.search_dorks(keyword)
        if not results:
            print(f"{Colors.ERROR}Aramanızla eşleşen dork bulunamadı.{Colors.RESET}")
            time.sleep(1)
            return

        while True:
            self.clear_screen()
            print(f"{Colors.HEADER}🔎 '{keyword}' İÇİN SONUÇLAR")
            print("═" * 80)
            for i, (cat, name, query, desc, ex) in enumerate(results, 1):
                print(f"{Colors.SUCCESS}{i}. [{cat}] {name}")
                print(f"   {Colors.DORK}{query}")
            
            print(f"\n{Colors.MENU}0. Geri")
            choice = input(f"\n{Colors.INFO}Seçim: {Colors.RESET}")
            if choice == "0": break
            try:
                idx = int(choice) - 1
                if 0 <= idx < len(results):
                    d = results[idx]
                    self.execute_dork((d[1], d[2], d[3], d[4]), d[0])
            except: pass

    def view_favorites(self):
        while True:
            favs = self.db.get_favorites()
            self.clear_screen()
            print(f"{Colors.HEADER}⭐ FAVORİ DORKLARIM")
            print("═" * 80)
            if not favs:
                print(f"{Colors.ERROR}Favori listeniz boş.{Colors.RESET}")
                input(f"\n{Colors.INFO}Geri dönmek için Enter'a basın...{Colors.RESET}")
                break
            
            for i, f in enumerate(favs, 1):
                print(f"{Colors.SUCCESS}{i}. [{f[1]}] {f[2]}")
                print(f"   {Colors.DORK}{f[3]}")
            
            print(f"\n{Colors.MENU}0. Geri")
            choice = input(f"\n{Colors.INFO}Çalıştırmak için seçin (veya 0): {Colors.RESET}")
            if choice == "0": break
            try:
                idx = int(choice) - 1
                if 0 <= idx < len(favs):
                    f = favs[idx]
                    webbrowser.open(f"https://www.google.com/search?q={urllib.parse.quote(f[3])}")
                    self.db.add_to_history(f[3], f[1])
            except: pass

    def view_history(self):
        history = self.db.get_history()
        self.clear_screen()
        print(f"{Colors.HEADER}📜 ARAMA GEÇMİŞİ")
        print("═" * 80)
        if not history:
            print(f"{Colors.ERROR}Geçmiş boş.{Colors.RESET}")
        else:
            for h in history:
                print(f"{Colors.INFO}[{h[2]}] {Colors.SUCCESS}{h[1]} {Colors.RESET}>> {h[0]}")
        
        print(f"\n{Colors.MENU}1. Geçmişi Temizle")
        print(f"{Colors.MENU}0. Geri")
        choice = input(f"\n{Colors.INFO}Seçim: {Colors.RESET}")
        if choice == "1":
            self.db.clear_history()
            print(f"{Colors.SUCCESS}Geçmiş temizlendi!{Colors.RESET}")
            time.sleep(1)

    def custom_dorks_menu(self):
        while True:
            self.clear_screen()
            print(f"{Colors.HEADER}🛠️  ÖZEL DORKLARIM")
            print("═" * 80)
            print(f"{Colors.MENU}1. ➕ Özel Dork Ekle")
            print(f"{Colors.MENU}2. 📂 Özel Dorkları Görüntüle")
            print(f"{Colors.MENU}0. Geri")
            
            choice = input(f"\n{Colors.INFO}Seçim: {Colors.RESET}")
            if choice == "0": break
            
            if choice == "1":
                name = input(f"{Colors.QUERY}Dork Adı: {Colors.RESET}")
                query = input(f"{Colors.QUERY}Dork Sorgusu: {Colors.RESET}")
                desc = input(f"{Colors.QUERY}Açıklama: {Colors.RESET}")
                if self.db.add_custom_dork(name, query, desc):
                    print(f"{Colors.SUCCESS}Başarıyla kaydedildi!{Colors.RESET}")
                time.sleep(1)
            elif choice == "2":
                customs = self.db.get_custom_dorks()
                self.clear_screen()
                print(f"{Colors.HEADER}📂 SİZİN ÖZEL DORKLARINIZ")
                for c in customs:
                    print(f"{Colors.SUCCESS}{c[1]}: {Colors.DORK}{c[2]}")
                input(f"\n{Colors.INFO}Geri dönmek için Enter'a basın...{Colors.RESET}")

if __name__ == "__main__":
    app = MrDorkApp()
    try:
        app.main_menu()
    except KeyboardInterrupt:
        print(f"\n{Colors.ERROR}İşlem kullanıcı tarafından durduruldu.{Colors.RESET}")

        sys.exit()
