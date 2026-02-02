#Tool Owner - @tc4dy
#Premium Edition for Contact. (50+ Categories)
"""
╔══════════════════════════════════════════════════════════════════════════════
║                          🔥 MR. DORK ULTIMATE 🔥                             
║                       The Advanced Dork Search Engine               
║                                                                              
║  Developer: @tc4dy                                                   
║  Version: 3.0 ULTIMATE EDITION                                              
║  Description: Supreme power with Google Dorks across all categories you might need!      
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
    print("⚠️  Installing colorama module...")
    os.system(f"{sys.executable} -m pip install colorama")
    from colorama import init, Fore, Back, Style
    init(autoreset=True)


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


class DatabaseManager:
    """SQLite database management - Favorites, History, Statistics"""
    
    def __init__(self, db_path: str = "mr_dork_data.db"):
        self.db_path = db_path
        self.conn = None
        self.cursor = None
        self.initialize_database()
    
    def initialize_database(self):
        """Initialize database and create tables"""
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
            print(f"{Colors.ERROR}❌ Error adding favorite: {e}{Colors.RESET}")
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
        
        most_category = most_used[0] if most_used else "None"
        
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
        return {'total_searches': 0, 'favorite_count': 0, 'most_used_category': 'None', 'last_search_date': 'Not yet'}
    
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


class DorkDatabase:
    """Massive database containing 2000+ Google Dorks"""
    
    CATEGORIES = {
        "📁 PDF Documents": {
            "icon": "📄",
            "color": Fore.RED,
            "dorks": [
                ("PDF - General", "filetype:pdf", "Find all PDF files", "filetype:pdf site:edu.tr"),
                ("PDF - Confidential", "filetype:pdf intext:confidential", "Confidential PDF documents", "filetype:pdf intext:confidential site:gov.tr"),
                ("PDF - Budget", "filetype:pdf intext:budget", "Budget PDFs", "filetype:pdf intext:budget 2024"),
                ("PDF - Contract", "filetype:pdf intext:contract", "Contract documents", "filetype:pdf intext:contract"),
                ("PDF - Report", "filetype:pdf intext:report", "Report documents", "filetype:pdf intext:report annual"),
                ("PDF - Invoice", "filetype:pdf intext:invoice", "Invoice documents", "filetype:pdf intext:invoice"),
                ("PDF - Technical Doc", "filetype:pdf intext:technical", "Technical manuals", "filetype:pdf intext:technical manual"),
                ("PDF - Thesis", "filetype:pdf intext:thesis", "Thesis documents", "filetype:pdf intext:thesis site:edu"),
            ]
        },
        "📊 Excel & Spreadsheets": {
            "icon": "📈",
            "color": Fore.GREEN,
            "dorks": [
                ("Excel - XLS", "filetype:xls", "XLS files", "filetype:xls site:example.com"),
                ("Excel - XLSX", "filetype:xlsx", "XLSX files", "filetype:xlsx budget"),
                ("Excel - Salary", "filetype:xlsx intext:salary", "Salary sheets", "filetype:xlsx intext:salary 2024"),
                ("Excel - Customer", "filetype:xlsx intext:customer", "Customer lists", "filetype:xlsx intext:customer database"),
                ("Excel - Financial", "filetype:xls intext:financial", "Financial tables", "filetype:xls intext:financial"),
                ("CSV - Data", "filetype:csv", "CSV data files", "filetype:csv database"),
                ("Excel - Statistics", "filetype:xlsx intext:statistics", "Statistical sheets", "filetype:xlsx intext:statistics"),
                ("Excel - Inventory", "filetype:xls intext:inventory", "Inventory lists", "filetype:xls intext:inventory"),
            ]
        },
        "📝 Word Documents": {
            "icon": "📃",
            "color": Fore.BLUE,
            "dorks": [
                ("Word - DOC", "filetype:doc", "DOC documents", "filetype:doc"),
                ("Word - DOCX", "filetype:docx", "DOCX documents", "filetype:docx"),
                ("Word - Confidential", "filetype:docx intext:confidential", "Confidential Word docs", "filetype:docx intext:confidential"),
                ("Word - Memo", "filetype:doc intext:memo", "Notes and memos", "filetype:doc intext:memo"),
                ("Word - Resume", "filetype:docx intext:resume", "Resume documents", "filetype:docx intext:resume"),
                ("Word - Meeting", "filetype:doc intext:meeting", "Meeting notes", "filetype:doc intext:meeting minutes"),
                ("Word - Policy", "filetype:docx intext:policy", "Policy documents", "filetype:docx intext:policy"),
                ("Word - Procedure", "filetype:doc intext:procedure", "Procedure documents", "filetype:doc intext:procedure"),
            ]
        },
        "💾 Database Files": {
            "icon": "🗄️",
            "color": Fore.CYAN,
            "dorks": [
                ("SQL Dump", "filetype:sql", "SQL dump files", "filetype:sql intext:INSERT INTO"),
                ("SQL - MySQL", "filetype:sql intext:mysql", "MySQL dumps", "filetype:sql intext:mysql dump"),
                ("Database Backup", "filetype:sql intext:backup", "Database backups", "filetype:sql intext:backup"),
                ("MDB Access", "filetype:mdb", "MS Access databases", "filetype:mdb"),
                ("SQLite DB", "filetype:db", "SQLite databases", "filetype:db OR filetype:sqlite"),
                ("MongoDB", "filetype:json intext:mongodb", "MongoDB export", "filetype:json intext:mongodb"),
                ("Database Config", "filetype:sql intext:CREATE DATABASE", "DB configuration", "filetype:sql intext:CREATE DATABASE"),
                ("DB Credentials", "filetype:sql intext:password", "DB passwords", "filetype:sql intext:password"),
            ]
        },
        "📜 Log Files": {
            "icon": "📋",
            "color": Fore.YELLOW,
            "dorks": [
                ("Log - General", "filetype:log", "All log files", "filetype:log"),
                ("Error Logs", "filetype:log intext:error", "Error logs", "filetype:log intext:error"),
                ("Access Logs", "filetype:log intext:access", "Access logs", "filetype:log intext:access.log"),
                ("Apache Logs", "filetype:log intext:apache", "Apache logs", "filetype:log intext:apache"),
                ("System Logs", "filetype:log intext:system", "System logs", "filetype:log intext:system"),
                ("Debug Logs", "filetype:log intext:debug", "Debug logs", "filetype:log intext:debug"),
                ("Auth Logs", "filetype:log intext:auth", "Authentication logs", "filetype:log intext:auth"),
                ("FTP Logs", "filetype:log intext:ftp", "FTP logs", "filetype:log intext:ftp"),
            ]
        },
        "💼 Backup Files": {
            "icon": "💾",
            "color": Fore.MAGENTA,
            "dorks": [
                ("Backup - BAK", "filetype:bak", "BAK backup files", "filetype:bak"),
                ("Backup - BACKUP", "filetype:backup", "BACKUP files", "filetype:backup"),
                ("SQL Backup", "filetype:sql intext:backup", "SQL backups", "filetype:sql intext:backup"),
                ("Zip Backup", "filetype:zip intext:backup", "Zip backups", "filetype:zip intext:backup"),
                ("Tar Backup", "filetype:tar", "TAR archives", "filetype:tar"),
                ("Old Files", "filetype:old", "Old file versions", "filetype:old"),
                ("Backup Dir", "intitle:index.of backup", "Backup directories", "intitle:index.of backup"),
                ("Site Backup", "inurl:backup.zip", "Site backups", "inurl:backup.zip OR inurl:backup.tar"),
            ]
        },
        "🔐 Admin Panels": {
            "icon": "👑",
            "color": Fore.RED + Style.BRIGHT,
            "dorks": [
                ("Admin Panel", "inurl:admin", "Admin pages", "inurl:admin site:example.com"),
                ("Admin Login", "inurl:admin/login", "Admin login pages", "inurl:admin/login"),
                ("Admin Dashboard", "intitle:admin intitle:dashboard", "Admin dashboards", "intitle:admin intitle:dashboard"),
                ("Admin Index", "intitle:index.of admin", "Admin directories", "intitle:index.of admin"),
                ("Administration", "inurl:administration", "Management panels", "inurl:administration"),
                ("Admin Console", "intitle:admin console", "Admin consoles", "intitle:admin console"),
                ("Admin Area", "inurl:admin-area", "Admin areas", "inurl:admin-area"),
                ("Backend Admin", "inurl:backend/admin", "Backend admin", "inurl:backend/admin"),
            ]
        },
        "🔑 Login Pages": {
            "icon": "🚪",
            "color": Fore.YELLOW + Style.BRIGHT,
            "dorks": [
                ("Login Page", "inurl:login", "Login pages", "inurl:login"),
                ("Sign In", "inurl:signin", "Sign in pages", "inurl:signin"),
                ("User Login", "intitle:login intitle:user", "User login", "intitle:login intitle:user"),
                ("Member Login", "inurl:member/login", "Member login", "inurl:member/login"),
                ("Auth Login", "inurl:auth/login", "Auth login", "inurl:auth/login"),
                ("Customer Login", "inurl:customer/login", "Customer login", "inurl:customer/login"),
                ("Portal Login", "intitle:portal login", "Portal logins", "intitle:portal login"),
                ("Secure Login", "inurl:secure/login", "Secure login", "inurl:secure/login"),
            ]
        },
        "🗄️ phpMyAdmin": {
            "icon": "🐬",
            "color": Fore.CYAN + Style.BRIGHT,
            "dorks": [
                ("phpMyAdmin", "inurl:phpmyadmin", "phpMyAdmin panels", "inurl:phpmyadmin"),
                ("PMA", "intitle:phpMyAdmin", "Titled PMA", "intitle:phpMyAdmin"),
                ("phpMyAdmin Login", "inurl:phpmyadmin/index.php", "PMA login", "inurl:phpmyadmin/index.php"),
                ("MySQL Admin", "intitle:phpMyAdmin MySQL", "MySQL admin", "intitle:phpMyAdmin MySQL"),
                ("DB Admin", "inurl:db/phpmyadmin", "DB admin panels", "inurl:db/phpmyadmin"),
                ("PMA Setup", "inurl:phpmyadmin/setup", "PMA setup", "inurl:phpmyadmin/setup"),
                ("phpMyAdmin 4", "intitle:phpMyAdmin 4", "phpMyAdmin 4.x", "intitle:phpMyAdmin 4"),
                ("Adminer", "intitle:adminer", "Adminer (PMA alternative)", "intitle:adminer"),
            ]
        },
        "⚙️ cPanel & WHM": {
            "icon": "🎛️",
            "color": Fore.GREEN + Style.BRIGHT,
            "dorks": [
                ("cPanel", "inurl:cpanel", "cPanel panels", "inurl:cpanel"),
                ("cPanel Login", "intitle:cpanel login", "cPanel login", "intitle:cpanel login"),
                ("WHM", "inurl:whm", "WHM panels", "inurl:whm"),
                ("Webmail", "inurl:webmail", "Webmail interfaces", "inurl:webmail"),
                ("cPanel 2083", "inurl:2083", "cPanel port 2083", "inurl:2083"),
                ("Plesk", "intitle:plesk", "Plesk panels", "intitle:plesk"),
                ("DirectAdmin", "intitle:directadmin", "DirectAdmin", "intitle:directadmin"),
                ("ISPConfig", "intitle:ispconfig", "ISPConfig panels", "intitle:ispconfig"),
            ]
        },
        "📂 Open Directories": {
            "icon": "📁",
            "color": Fore.BLUE + Style.BRIGHT,
            "dorks": [
                ("Index Of", "intitle:index.of", "Directory listings", "intitle:index.of"),
                ("Parent Directory", "intitle:parent.directory", "Parent directories", "intitle:parent.directory"),
                ("Directory Listing", "intitle:directory listing", "Directory listing", "intitle:directory listing"),
                ("Index Of /", "intitle:index of /", "Root directories", "intitle:index of /"),
                ("Apache Index", "intitle:index.of apache", "Apache directories", "intitle:index.of apache"),
                ("Nginx Index", "intitle:index.of nginx", "Nginx directories", "intitle:index.of nginx"),
                ("IIS Index", "intitle:index.of iis", "IIS directories", "intitle:index.of iis"),
                ("Autoindex", "intitle:autoindex", "Auto index", "intitle:autoindex"),
            ]
        },
        "📤 Upload Directories": {
            "icon": "⬆️",
            "color": Fore.MAGENTA + Style.BRIGHT,
            "dorks": [
                ("Upload Dir", "intitle:index.of uploads", "Upload folders", "intitle:index.of uploads"),
                ("Files Dir", "intitle:index.of files", "Files directories", "intitle:index.of files"),
                ("Images Dir", "intitle:index.of images", "Image directories", "intitle:index.of images"),
                ("Media Dir", "intitle:index.of media", "Media directories", "intitle:index.of media"),
                ("Documents Dir", "intitle:index.of documents", "Document directories", "intitle:index.of documents"),
                ("Downloads", "intitle:index.of downloads", "Download directories", "intitle:index.of downloads"),
                ("Assets Dir", "intitle:index.of assets", "Asset directories", "intitle:index.of assets"),
                ("Public Dir", "intitle:index.of public", "Public directories", "intitle:index.of public"),
            ]
        },
        "⚙️ Config Directories": {
            "icon": "🔧",
            "color": Fore.YELLOW + Style.BRIGHT,
            "dorks": [
                ("Config Dir", "intitle:index.of config", "Config directories", "intitle:index.of config"),
                ("Settings Dir", "intitle:index.of settings", "Settings directories", "intitle:index.of settings"),
                ("Conf Dir", "intitle:index.of conf", "Conf directories", "intitle:index.of conf"),
                ("etc Dir", "intitle:index.of etc", "etc directories", "intitle:index.of etc"),
                ("Configuration", "intitle:index.of configuration", "Configuration directories", "intitle:index.of configuration"),
                ("Include Dir", "intitle:index.of include", "Include directories", "intitle:index.of include"),
                ("Lib Dir", "intitle:index.of lib", "Lib directories", "intitle:index.of lib"),
                ("Vendor Dir", "intitle:index.of vendor", "Vendor directories", "intitle:index.of vendor"),
            ]
        },
        "🔑 Passwords": {
            "icon": "🗝️",
            "color": Fore.RED + Style.BRIGHT,
            "dorks": [
                ("Password TXT", "filetype:txt intext:password", "Password txt files", "filetype:txt intext:password"),
                ("Credentials", "filetype:txt intext:credentials", "Identity credentials", "filetype:txt intext:credentials"),
                ("Login Info", "filetype:txt intext:username intext:password", "Login information", "filetype:txt intext:username intext:password"),
                ("Password List", "filetype:txt intext:password list", "Password lists", "filetype:txt intext:password list"),
                ("Admin Pass", "filetype:txt intext:admin password", "Admin passwords", "filetype:txt intext:admin password"),
                ("Root Pass", "filetype:txt intext:root password", "Root passwords", "filetype:txt intext:root password"),
                ("FTP Credentials", "filetype:txt intext:ftp password", "FTP passwords", "filetype:txt intext:ftp password"),
                ("Email Pass", "filetype:txt intext:email password", "Email passwords", "filetype:txt intext:email password"),
            ]
        },
        "🔐 API Keys": {
            "icon": "🔑",
            "color": Fore.YELLOW + Style.BRIGHT,
            "dorks": [
                ("API Key", "intext:api_key OR intext:apikey", "API keys", "intext:api_key filetype:json"),
                ("API Secret", "intext:api_secret", "API secrets", "intext:api_secret"),
                ("Access Token", "intext:access_token", "Access tokens", "intext:access_token"),
                ("Bearer Token", "intext:bearer", "Bearer tokens", "intext:bearer token"),
                ("AWS Key", "intext:aws_access_key_id", "AWS keys", "intext:aws_access_key_id"),
                ("Google API", "intext:AIza", "Google API keys", "intext:AIza"),
                ("Stripe Key", "intext:sk_live", "Stripe keys", "intext:sk_live OR intext:pk_live"),
                ("GitHub Token", "intext:ghp_", "GitHub tokens", "intext:ghp_ OR intext:gho_"),
            ]
        },
        "📋 Config Files": {
            "icon": "⚙️",
            "color": Fore.CYAN + Style.BRIGHT,
            "dorks": [
                ("ENV Files", "filetype:env", "Environment files", "filetype:env"),
                ("Config PHP", "filetype:php intext:config", "PHP configs", "filetype:php intext:config"),
                ("Database Config", "filetype:php intext:database", "Database config", "filetype:php intext:database"),
                ("WP Config", "filetype:php intext:wp-config", "WordPress config", "filetype:php intext:wp-config"),
                ("Settings.php", "filetype:php intext:settings", "Settings.php files", "filetype:php intext:settings"),
                ("Config.json", "filetype:json intext:config", "JSON configs", "filetype:json intext:config"),
                ("App Config", "filetype:yml intext:config", "App config (YAML)", "filetype:yml intext:config"),
                ("Nginx Config", "filetype:conf intext:nginx", "Nginx configuration", "filetype:conf intext:nginx"),
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


def print_logo():
    tux = f"""{Colors.LOGO}
         _nnnn_                      
        dGGGGMMb     ,"\"\"\"\"\"\"\"\"\"\"\"\""".
       @p~qp~~qMb    | I Love Tc4dy <3 |
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
║                   The World's Most Advanced Dork Search Engine               
║                                                                              
║  Developer: Tc4dy - Tuğra                                                   
║  Version: 3.0 ULTIMATE EDITION                                              
║  Total Dorks: {str(DorkDatabase.get_total_dorks()).ljust(5)} Google Dorks                                        
║  Categories: {str(len(DorkDatabase.CATEGORIES)).ljust(3)}                                                         
╚══════════════════════════════════════════════════════════════════════════════
{Colors.RESET}
{Colors.WARNING}⚠️  ETHICAL USE WARNING: This tool is for educational and legal testing only!{Colors.RESET}
{Colors.ERROR}⚠️  Unauthorized system access is illegal and can have serious consequences!{Colors.RESET}
"""
    print(tux)
    print(logo)


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
            
            print(f"{Colors.STATS}📊 STATS: Total Searches: {stats['total_searches']} | Favorites: {stats['favorite_count']}")
            print(f"─" * 80)
            print(f"{Colors.MENU}1. 📂 Browse Categories")
            print(f"{Colors.MENU}2. 🔍 Search Dorks")
            print(f"{Colors.MENU}3. ⭐ View Favorites")
            print(f"{Colors.MENU}4. 📜 Search History")
            print(f"{Colors.MENU}5. 🛠️  Custom Dorks")
            print(f"{Colors.MENU}0. ❌ Exit")
            print(f"─" * 80)
            
            choice = input(f"{Colors.INFO}Select an option: {Colors.RESET}")
            
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
                print(f"{Colors.SUCCESS}\nStay safe! Goodbye...{Colors.RESET}")
                self.running = False
            else:
                print(f"{Colors.ERROR}Invalid selection!{Colors.RESET}")
                time.sleep(1)

    def browse_categories(self):
        while True:
            self.clear_screen()
            print_logo()
            print(f"{Colors.HEADER}📂 CATEGORIES\n")
            
            categories = DorkDatabase.get_all_categories()
            for i, cat in enumerate(categories, 1):
                cat_data = DorkDatabase.get_category(cat)
                icon = cat_data["icon"]
                color = cat_data["color"]
                print(f"{Colors.MENU}{i}. {color}{icon} {cat}")
            
            print(f"\n{Colors.MENU}0. Back to Main Menu")
            
            choice = input(f"\n{Colors.INFO}Select category (or 0): {Colors.RESET}")
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
            print(f"{Colors.HEADER}📂 CATEGORY: {category_name}")
            print("═" * 80)
            
            for i, (name, query, desc, example) in enumerate(dorks, 1):
                print(f"{Colors.SUCCESS}{i}. {name}")
                print(f"   {Colors.INFO}Description: {desc}")
                print(f"   {Colors.DORK}Dork: {query}")
                print("-" * 40)
            
            print(f"{Colors.MENU}0. Back")
            
            choice = input(f"\n{Colors.INFO}Select a dork to use (or 0): {Colors.RESET}")
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
        print(f"{Colors.HEADER}🚀 EXECUTING: {name}")
        print("═" * 80)
        print(f"{Colors.INFO}Example usage: {example}")
        target = input(f"{Colors.QUERY}Enter target (e.g. site:com or keyword): {Colors.RESET}")
        
        final_query = f"{query} {target}".strip()
        print(f"\n{Colors.SUCCESS}Final Query: {final_query}")
        
        encoded_query = urllib.parse.quote(final_query)
        url = f"https://www.google.com/search?q={encoded_query}"
        
        print(f"\n{Colors.MENU}1. 🌐 Open in Browser")
        print(f"{Colors.MENU}2. ⭐ Save to Favorites")
        print(f"{Colors.MENU}0. Cancel")
        
        choice = input(f"\n{Colors.INFO}Selection: {Colors.RESET}")
        
        if choice == "1":
            webbrowser.open(url)
            self.db.add_to_history(final_query, category)
        elif choice == "2":
            if self.db.add_favorite(category, name, final_query, example, desc):
                print(f"{Colors.SUCCESS}Added to favorites!{Colors.RESET}")
                time.sleep(1)

    def search_screen(self):
        self.clear_screen()
        print(f"{Colors.HEADER}🔍 GLOBAL SEARCH")
        keyword = input(f"{Colors.INFO}Enter search term: {Colors.RESET}")
        
        results = DorkDatabase.search_dorks(keyword)
        if not results:
            print(f"{Colors.ERROR}No dorks found matching your search.{Colors.RESET}")
            time.sleep(1)
            return

        while True:
            self.clear_screen()
            print(f"{Colors.HEADER}🔎 SEARCH RESULTS for '{keyword}'")
            print("═" * 80)
            for i, (cat, name, query, desc, ex) in enumerate(results, 1):
                print(f"{Colors.SUCCESS}{i}. [{cat}] {name}")
                print(f"   {Colors.DORK}{query}")
            
            print(f"\n{Colors.MENU}0. Back")
            choice = input(f"\n{Colors.INFO}Selection: {Colors.RESET}")
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
            print(f"{Colors.HEADER}⭐ FAVORITE DORKS")
            print("═" * 80)
            if not favs:
                print(f"{Colors.ERROR}Your favorites list is empty.{Colors.RESET}")
                input(f"\n{Colors.INFO}Press Enter to return...{Colors.RESET}")
                break
            
            for i, f in enumerate(favs, 1):
                print(f"{Colors.SUCCESS}{i}. [{f[1]}] {f[2]}")
                print(f"   {Colors.DORK}{f[3]}")
            
            print(f"\n{Colors.MENU}0. Back")
            choice = input(f"\n{Colors.INFO}Select to run (or 0): {Colors.RESET}")
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
        print(f"{Colors.HEADER}📜 SEARCH HISTORY")
        print("═" * 80)
        if not history:
            print(f"{Colors.ERROR}History is empty.{Colors.RESET}")
        else:
            for h in history:
                print(f"{Colors.INFO}[{h[2]}] {Colors.SUCCESS}{h[1]} {Colors.RESET}>> {h[0]}")
        
        print(f"\n{Colors.MENU}1. Clear History")
        print(f"{Colors.MENU}0. Back")
        choice = input(f"\n{Colors.INFO}Selection: {Colors.RESET}")
        if choice == "1":
            self.db.clear_history()
            print(f"{Colors.SUCCESS}History cleared!{Colors.RESET}")
            time.sleep(1)

    def custom_dorks_menu(self):
        while True:
            self.clear_screen()
            print(f"{Colors.HEADER}🛠️  CUSTOM DORKS")
            print("═" * 80)
            print(f"{Colors.MENU}1. ➕ Add Custom Dork")
            print(f"{Colors.MENU}2. 📂 View Custom Dorks")
            print(f"{Colors.MENU}0. Back")
            
            choice = input(f"\n{Colors.INFO}Selection: {Colors.RESET}")
            if choice == "0": break
            
            if choice == "1":
                name = input(f"{Colors.QUERY}Dork Name: {Colors.RESET}")
                query = input(f"{Colors.QUERY}Dork Query: {Colors.RESET}")
                desc = input(f"{Colors.QUERY}Description: {Colors.RESET}")
                if self.db.add_custom_dork(name, query, desc):
                    print(f"{Colors.SUCCESS}Saved successfully!{Colors.RESET}")
                time.sleep(1)
            elif choice == "2":
                customs = self.db.get_custom_dorks()
                self.clear_screen()
                print(f"{Colors.HEADER}📂 YOUR CUSTOM DORKS")
                for c in customs:
                    print(f"{Colors.SUCCESS}{c[1]}: {Colors.DORK}{c[2]}")
                input(f"\n{Colors.INFO}Press Enter to return...{Colors.RESET}")

if __name__ == "__main__":
    app = MrDorkApp()
    try:
        app.main_menu()
    except KeyboardInterrupt:
        print(f"\n{Colors.ERROR}Process terminated by user.{Colors.RESET}")

        sys.exit()

