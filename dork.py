# Minimum: Python 3.8
# Recommended: Python 3.10 or 3.11
# Works fine with: 3.12, 3.13
#Tool Owner - @tc4dy | github.com/tc4dy

"""
╔══════════════════════════════════════════════════════════════════════════════
║                          🔥 MR. DORK 🔥                             
║          The Most Advanced Dork Search Engine for Analysts               
║                                                                              
║  Developer: @tc4dy                                                   
║  Version: 3.0                                              
║  Description: Supreme power with Google Dorks across all categories you might need!      
╚══════════════════════════════════════════════════════════════════════════════
"""

import os
import sys
import json
import webbrowser
import urllib.parse
import subprocess
from datetime import datetime
from pathlib import Path
import sqlite3
from typing import Dict, List, Tuple
import time

try:
    from colorama import init, Fore, Back, Style
    init(autoreset=True)
except ImportError:
    import subprocess
    subprocess.run([sys.executable, "-m", "pip", "install", "colorama"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    from colorama import init, Fore, Back, Style
    init(autoreset=True)

def open_url_silent(url):
    if sys.platform == "linux":
        try:
            subprocess.Popen(['xdg-open', url], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except:
            webbrowser.open(url)
    else:
        webbrowser.open(url)

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
        sqlite3.register_adapter(datetime, lambda dt: dt.isoformat())
        sqlite3.register_converter("timestamp", lambda b: datetime.fromisoformat(b.decode()))
        self.conn = sqlite3.connect(self.db_path, detect_types=sqlite3.PARSE_DECLTYPES)
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
        "📡 IoT & Camera Feeds": {
            "icon": "📷",
            "color": Fore.CYAN,
            "dorks": [
                ("Camera - Axis MJPG", "inurl:axis-cgi/mjpg", "Axis camera live feed", "inurl:axis-cgi/mjpg"),
                ("Camera - Netcam", "inurl:netcam.jpg", "Network camera image", "inurl:netcam.jpg"),
                ("Camera - WebcamXP", "intitle:webcamXP", "WebcamXP interface", "intitle:webcamXP"),
                ("Camera - IP Viewer", "intitle:'IP Camera Viewer'", "IP camera viewer", "intitle:'IP Camera Viewer'"),
                ("Camera - D-Link", "intitle:D-Link inurl:webcam", "D-Link webcams", "intitle:D-Link inurl:webcam"),
                ("Camera - Trendnet", "intitle:TRENDnet inurl:webcam", "Trendnet cameras", "intitle:TRENDnet inurl:webcam"),
                ("Camera - Foscam", "intitle:Foscam inurl:webcam", "Foscam cameras", "intitle:Foscam inurl:webcam"),
                ("Camera - Panasonic", "intitle:Panasonic inurl:view", "Panasonic cameras", "intitle:Panasonic inurl:view"),
                ("Camera - Sony", "intitle:Sony inurl:webcam", "Sony cameras", "intitle:Sony inurl:webcam"),
                ("Camera - Hikvision", "intitle:Hikvision inurl:doc/page/login", "Hikvision login", "intitle:Hikvision inurl:doc/page/login"),
            ]
        },
        "📊 Public Analytics & Stats": {
            "icon": "📈",
            "color": Fore.GREEN,
            "dorks": [
                ("Analytics - Awstats", "filetype:awstats", "AWStats files", "filetype:awstats"),
                ("Analytics - Webalizer", "filetype:webalizer", "Webalizer stats", "filetype:webalizer"),
                ("Analytics - Piwik", "inurl:piwik", "Piwik analytics", "inurl:piwik"),
                ("Analytics - Matomo", "inurl:matomo", "Matomo analytics", "inurl:matomo"),
                ("Analytics - Google Analytics", "intext:'UA-' intext:'ga.js'", "Google Analytics ID", "intext:'UA-' intext:'ga.js'"),
                ("Analytics - Clicky", "intext:'cliky' inurl:stats", "Clicky stats", "intext:'cliky' inurl:stats"),
                ("Analytics - Statcounter", "inurl:statcounter", "Statcounter", "inurl:statcounter"),
                ("Analytics - Open Web Analytics", "inurl:owa", "OWA analytics", "inurl:owa"),
                ("Analytics - Countly", "inurl:countly", "Countly analytics", "inurl:countly"),
                ("Analytics - Umami", "inurl:umami", "Umami analytics", "inurl:umami"),
            ]
        },
        "🔍 Git & Version Control": {
            "icon": "🐙",
            "color": Fore.RED,
            "dorks": [
                ("Git - Config", "inurl:.git/config", "Git config file", "inurl:.git/config"),
                ("Git - HEAD", "inurl:.git/HEAD", "Git HEAD", "inurl:.git/HEAD"),
                ("Git - Index", "inurl:.git/index", "Git index", "inurl:.git/index"),
                ("Git - Logs", "inurl:.git/logs", "Git logs", "inurl:.git/logs"),
                ("Git - Ref", "inurl:.git/refs", "Git refs", "inurl:.git/refs"),
                ("Git - Objects", "inurl:.git/objects", "Git objects", "inurl:.git/objects"),
                ("SVN - Entries", "inurl:.svn/entries", "SVN entries", "inurl:.svn/entries"),
                ("SVN - WC", "inurl:.svn/wc.db", "SVN working copy", "inurl:.svn/wc.db"),
                ("HG - Requires", "inurl:.hg/requires", "Mercurial requires", "inurl:.hg/requires"),
                ("HG - Store", "inurl:.hg/store", "Mercurial store", "inurl:.hg/store"),
            ]
        },
        "🌍 Geo-location & Maps": {
            "icon": "🗺️",
            "color": Fore.BLUE,
            "dorks": [
                ("GPS - GPX", "filetype:gpx", "GPS exchange files", "filetype:gpx"),
                ("GPS - KML", "filetype:kml", "Google Earth KML", "filetype:kml"),
                ("GPS - KMZ", "filetype:kmz", "Google Earth KMZ", "filetype:kmz"),
                ("GPS - LOC", "filetype:loc", "GPS location files", "filetype:loc"),
                ("Maps - Static", "intitle:'static map'", "Static maps", "intitle:'static map'"),
                ("Maps - API Key", "intext:'AIza' inurl:maps", "Google Maps API keys", "intext:'AIza' inurl:maps"),
                ("GeoJSON", "filetype:geojson", "GeoJSON data", "filetype:geojson"),
                ("Shapefile", "filetype:shp", "Shapefile", "filetype:shp"),
                ("OpenStreetMap", "inurl:openstreetmap", "OSM data", "inurl:openstreetmap"),
                ("MapServer", "intitle:MapServer", "MapServer interface", "intitle:MapServer"),
            ]
        },
        "📡 Network Devices (Routers, Switches)": {
            "icon": "🌐",
            "color": Fore.MAGENTA,
            "dorks": [
                ("Router - Cisco", "intitle:Cisco inurl:home", "Cisco routers", "intitle:Cisco inurl:home"),
                ("Router - MikroTik", "intitle:MikroTik", "MikroTik routers", "intitle:MikroTik"),
                ("Router - TP-Link", "intitle:TP-Link inurl:web", "TP-Link routers", "intitle:TP-Link inurl:web"),
                ("Router - D-Link", "intitle:D-Link inurl:login", "D-Link routers", "intitle:D-Link inurl:login"),
                ("Switch - HP", "intitle:HP Switch", "HP switches", "intitle:HP Switch"),
                ("Switch - Netgear", "intitle:Netgear inurl:switch", "Netgear switches", "intitle:Netgear inurl:switch"),
                ("Firewall - pfSense", "intitle:pfsense", "pfSense firewalls", "intitle:pfsense"),
                ("Firewall - Sophos", "intitle:Sophos", "Sophos firewalls", "intitle:Sophos"),
                ("Access Point - Ubiquiti", "intitle:Ubiquiti inurl:unifi", "Ubiquiti AP", "intitle:Ubiquiti inurl:unifi"),
                ("Modem - Arris", "intitle:Arris", "Arris modems", "intitle:Arris"),
            ]
        },
        "🔐 VPN & Proxy Configs": {
            "icon": "🔒",
            "color": Fore.YELLOW,
            "dorks": [
                ("OpenVPN Config", "filetype:ovpn", "OpenVPN configs", "filetype:ovpn"),
                ("WireGuard Config", "filetype:conf intext:'[Interface]'", "WireGuard configs", "filetype:conf intext:'[Interface]'"),
                ("PPTP Config", "filetype:pptp", "PPTP configs", "filetype:pptp"),
                ("L2TP Config", "filetype:l2tp", "L2TP configs", "filetype:l2tp"),
                ("Socks Proxy", "filetype:txt intext:socks", "SOCKS proxy lists", "filetype:txt intext:socks"),
                ("HTTP Proxy", "filetype:txt intext:'http proxy'", "HTTP proxy lists", "filetype:txt intext:'http proxy'"),
                ("VPN Book", "inurl:vpnbook", "VPN book configs", "inurl:vpnbook"),
                ("ProtonVPN", "inurl:protonvpn", "ProtonVPN configs", "inurl:protonvpn"),
                ("NordVPN", "inurl:nordvpn", "NordVPN configs", "inurl:nordvpn"),
                ("ExpressVPN", "inurl:expressvpn", "ExpressVPN configs", "inurl:expressvpn"),
            ]
        },
        "📧 Email & Communication": {
            "icon": "✉️",
            "color": Fore.RED,
            "dorks": [
                ("Email - Outlook", "inurl:owa", "Outlook Web Access", "inurl:owa"),
                ("Email - Roundcube", "intitle:Roundcube", "Roundcube webmail", "intitle:Roundcube"),
                ("Email - SquirrelMail", "intitle:SquirrelMail", "SquirrelMail", "intitle:SquirrelMail"),
                ("Email - Mailcow", "inurl:mailcow", "Mailcow UI", "inurl:mailcow"),
                ("Email - Zimbra", "intitle:Zimbra", "Zimbra webmail", "intitle:Zimbra"),
                ("Email - Horde", "intitle:Horde", "Horde webmail", "intitle:Horde"),
                ("Email - Atmail", "intitle:Atmail", "Atmail webmail", "intitle:Atmail"),
                ("Email - RainLoop", "intitle:RainLoop", "RainLoop webmail", "intitle:RainLoop"),
                ("Email - Mailpile", "intitle:Mailpile", "Mailpile", "intitle:Mailpile"),
                ("Email - Modoboa", "intitle:Modoboa", "Modoboa", "intitle:Modoboa"),
            ]
        },
        "🛒 E-commerce & Shopping Carts": {
            "icon": "🛍️",
            "color": Fore.GREEN,
            "dorks": [
                ("WooCommerce", "inurl:wp-content/plugins/woocommerce", "WooCommerce sites", "inurl:wp-content/plugins/woocommerce"),
                ("Magento", "inurl:app/code/core/Mage", "Magento sites", "inurl:app/code/core/Mage"),
                ("PrestaShop", "inurl:modules/prestashop", "PrestaShop sites", "inurl:modules/prestashop"),
                ("Shopify", "intext:'Shopify' inurl:product", "Shopify sites", "intext:'Shopify' inurl:product"),
                ("OpenCart", "inurl:index.php?route=common/home", "OpenCart sites", "inurl:index.php?route=common/home"),
                ("Zen Cart", "intitle:Zen Cart", "Zen Cart sites", "intitle:Zen Cart"),
                ("BigCommerce", "inurl:bigcommerce", "BigCommerce sites", "inurl:bigcommerce"),
                ("Salesforce Commerce", "inurl:sfcc", "Salesforce Commerce", "inurl:sfcc"),
                ("Wix Stores", "inurl:wixstores", "Wix stores", "inurl:wixstores"),
                ("Weebly Store", "inurl:weebly.com/store", "Weebly stores", "inurl:weebly.com/store"),
            ]
        },
        "🏥 Healthcare & Medical": {
            "icon": "🏥",
            "color": Fore.MAGENTA,
            "dorks": [
                ("Patient Records", "filetype:pdf intext:'patient name'", "Patient PDFs", "filetype:pdf intext:'patient name'"),
                ("Medical Reports", "filetype:pdf intext:'medical report'", "Medical reports", "filetype:pdf intext:'medical report'"),
                ("Prescriptions", "filetype:pdf intext:prescription", "Prescriptions", "filetype:pdf intext:prescription"),
                ("Lab Results", "filetype:pdf intext:'lab result'", "Lab results", "filetype:pdf intext:'lab result'"),
                ("Hospital Info", "intitle:hospital inurl:patient", "Hospital patient portals", "intitle:hospital inurl:patient"),
                ("EPIC Systems", "inurl:epic", "EPIC healthcare", "inurl:epic"),
                ("Cerner", "inurl:cerner", "Cerner portals", "inurl:cerner"),
                ("Allscripts", "inurl:allscripts", "Allscripts", "inurl:allscripts"),
                ("McKesson", "inurl:mckesson", "McKesson", "inurl:mckesson"),
                ("Meditech", "inurl:meditech", "Meditech", "inurl:meditech"),
            ]
        },
        "📁 File Sharing & Cloud Storage": {
            "icon": "☁️",
            "color": Fore.CYAN,
            "dorks": [
                ("Dropbox", "inurl:dropbox.com/s/", "Dropbox shared files", "inurl:dropbox.com/s/"),
                ("Google Drive", "inurl:drive.google.com/file/d/", "Google Drive files", "inurl:drive.google.com/file/d/"),
                ("OneDrive", "inurl:onedrive.live.com", "OneDrive files", "inurl:onedrive.live.com"),
                ("Box", "inurl:box.com/s/", "Box shared files", "inurl:box.com/s/"),
                ("MediaFire", "inurl:mediafire.com", "MediaFire files", "inurl:mediafire.com"),
                ("Mega", "inurl:mega.nz", "Mega files", "inurl:mega.nz"),
                ("WeTransfer", "inurl:wetransfer.com", "WeTransfer", "inurl:wetransfer.com"),
                ("SendSpace", "inurl:sendspace.com", "SendSpace", "inurl:sendspace.com"),
                ("File.io", "inurl:file.io", "File.io", "inurl:file.io"),
                ("Tresorit", "inurl:tresorit.com", "Tresorit", "inurl:tresorit.com"),
            ]
        },
        "🎓 Education & Academic": {
            "icon": "🎓",
            "color": Fore.BLUE,
            "dorks": [
                ("Lecture Notes", "filetype:pdf intext:'lecture notes'", "Lecture PDFs", "filetype:pdf intext:'lecture notes'"),
                ("Syllabus", "filetype:pdf intext:syllabus", "Course syllabi", "filetype:pdf intext:syllabus"),
                ("Exam Papers", "filetype:pdf intext:'exam' site:edu", "Exam papers", "filetype:pdf intext:'exam' site:edu"),
                ("Thesis", "filetype:pdf intext:thesis site:edu", "Thesis papers", "filetype:pdf intext:thesis site:edu"),
                ("Dissertation", "filetype:pdf intext:dissertation", "Dissertations", "filetype:pdf intext:dissertation"),
                ("Research Papers", "filetype:pdf intext:'research paper'", "Research papers", "filetype:pdf intext:'research paper'"),
                ("White Papers", "filetype:pdf intext:'white paper'", "White papers", "filetype:pdf intext:'white paper'"),
                ("Moodle", "intitle:Moodle inurl:login", "Moodle LMS", "intitle:Moodle inurl:login"),
                ("Canvas LMS", "intitle:Canvas inurl:login", "Canvas LMS", "intitle:Canvas inurl:login"),
                ("Blackboard", "intitle:Blackboard inurl:login", "Blackboard", "intitle:Blackboard inurl:login"),
            ]
        },
        "⚡ SCADA & Industrial Control": {
            "icon": "🏭",
            "color": Fore.RED,
            "dorks": [
                ("SCADA", "intitle:SCADA", "SCADA interfaces", "intitle:SCADA"),
                ("PLC", "intitle:PLC", "PLC panels", "intitle:PLC"),
                ("HMI", "intitle:HMI", "HMI interfaces", "intitle:HMI"),
                ("Wonderware", "intitle:Wonderware", "Wonderware", "intitle:Wonderware"),
                ("Siemens", "intitle:Siemens inurl:web", "Siemens controllers", "intitle:Siemens inurl:web"),
                ("Rockwell", "intitle:Rockwell inurl:web", "Rockwell", "intitle:Rockwell inurl:web"),
                ("Modbus", "intitle:Modbus", "Modbus devices", "intitle:Modbus"),
                ("OPC", "intitle:OPC", "OPC servers", "intitle:OPC"),
                ("Citect", "intitle:Citect", "Citect SCADA", "intitle:Citect"),
                ("GE Proficy", "intitle:Proficy", "GE Proficy", "intitle:Proficy"),
            ]
        },
        "📰 News & Media": {
            "icon": "📰",
            "color": Fore.YELLOW,
            "dorks": [
                ("WordPress News", "inurl:wp-json/wp/v2/posts", "WordPress posts", "inurl:wp-json/wp/v2/posts"),
                ("RSS Feed", "filetype:rss", "RSS feeds", "filetype:rss"),
                ("Atom Feed", "filetype:atom", "Atom feeds", "filetype:atom"),
                ("Sitemap", "inurl:sitemap.xml", "XML sitemaps", "inurl:sitemap.xml"),
                ("News API", "intext:'newsapi.org'", "News API keys", "intext:'newsapi.org'"),
                ("CNN", "site:cnn.com inurl:news", "CNN news", "site:cnn.com inurl:news"),
                ("BBC", "site:bbc.com inurl:news", "BBC news", "site:bbc.com inurl:news"),
                ("Reuters", "site:reuters.com inurl:article", "Reuters", "site:reuters.com inurl:article"),
                ("AP News", "site:apnews.com", "AP News", "site:apnews.com"),
                ("Al Jazeera", "site:aljazeera.com", "Al Jazeera", "site:aljazeera.com"),
            ]
        },
        "🔧 Developer & Debugging": {
            "icon": "🛠️",
            "color": Fore.GREEN,
            "dorks": [
                ("PHPInfo", "filetype:php intext:'phpinfo()'", "PHP info pages", "filetype:php intext:'phpinfo()'"),
                ("Debug Bar", "intitle:'Debug Bar'", "Debug bars", "intitle:'Debug Bar'"),
                ("Laravel Debug", "inurl:_debugbar", "Laravel debug", "inurl:_debugbar"),
                ("Django Debug", "inurl:debug_toolbar", "Django debug", "inurl:debug_toolbar"),
                ("Flask Debug", "inurl:debug/", "Flask debug", "inurl:debug/"),
                ("Spring Boot Actuator", "inurl:actuator", "Spring Boot", "inurl:actuator"),
                ("ASP.NET Trace", "inurl:trace.axd", "ASP.NET trace", "inurl:trace.axd"),
                ("ElasticSearch", "inurl:elasticsearch/_nodes", "ElasticSearch nodes", "inurl:elasticsearch/_nodes"),
                ("Kibana", "intitle:Kibana", "Kibana dashboards", "intitle:Kibana"),
                ("Grafana", "intitle:Grafana", "Grafana dashboards", "intitle:Grafana"),
            ]
        },
        "🕵️ OSINT & People Search": {
            "icon": "🔍",
            "color": Fore.CYAN,
            "dorks": [
                ("LinkedIn", "site:linkedin.com/in/", "LinkedIn profiles", "site:linkedin.com/in/"),
                ("Twitter", "site:twitter.com inurl:status", "Tweets", "site:twitter.com inurl:status"),
                ("Facebook", "site:facebook.com inurl:profile.php", "FB profiles", "site:facebook.com inurl:profile.php"),
                ("Instagram", "site:instagram.com/p/", "Instagram posts", "site:instagram.com/p/"),
                ("GitHub", "site:github.com inurl:repositories", "GitHub repos", "site:github.com inurl:repositories"),
                ("Reddit", "site:reddit.com inurl:comments", "Reddit comments", "site:reddit.com inurl:comments"),
                ("YouTube", "site:youtube.com inurl:watch", "YouTube videos", "site:youtube.com inurl:watch"),
                ("TikTok", "site:tiktok.com inurl:video", "TikTok videos", "site:tiktok.com inurl:video"),
                ("Telegram", "site:t.me", "Telegram channels", "site:t.me"),
                ("Discord", "site:discord.com/channels", "Discord invites", "site:discord.com/channels"),
            ]
        },
        "💰 Financial & Banking": {
            "icon": "💰",
            "color": Fore.MAGENTA,
            "dorks": [
                ("Banking Login", "inurl:onlinebanking", "Online banking portals", "inurl:onlinebanking"),
                ("Credit Card", "filetype:pdf intext:'credit card'", "Credit card statements", "filetype:pdf intext:'credit card'"),
                ("Invoice", "filetype:pdf intext:invoice", "Invoices", "filetype:pdf intext:invoice"),
                ("Payroll", "filetype:xlsx intext:payroll", "Payroll sheets", "filetype:xlsx intext:payroll"),
                ("Tax Return", "filetype:pdf intext:'tax return'", "Tax returns", "filetype:pdf intext:'tax return'"),
                ("Loan Application", "filetype:pdf intext:'loan application'", "Loan apps", "filetype:pdf intext:'loan application'"),
                ("Bank Statement", "filetype:pdf intext:'bank statement'", "Bank statements", "filetype:pdf intext:'bank statement'"),
                ("Investment", "filetype:pdf intext:investment", "Investment docs", "filetype:pdf intext:investment"),
                ("PayPal", "inurl:paypal.com", "PayPal links", "inurl:paypal.com"),
                ("Stripe", "inurl:stripe.com", "Stripe links", "inurl:stripe.com"),
            ]
        },
        "🔌 API Endpoints & Swagger": {
            "icon": "🔌",
            "color": Fore.BLUE,
            "dorks": [
                ("Swagger UI", "inurl:swagger-ui.html", "Swagger interfaces", "inurl:swagger-ui.html"),
                ("OpenAPI JSON", "filetype:json intext:'swagger'", "OpenAPI specs", "filetype:json intext:'swagger'"),
                ("API Docs", "inurl:api/docs", "API documentation", "inurl:api/docs"),
                ("Postman Collection", "filetype:json intext:'postman'", "Postman collections", "filetype:json intext:'postman'"),
                ("GraphQL", "inurl:graphql", "GraphQL endpoints", "inurl:graphql"),
                ("REST API", "inurl:api/", "REST API endpoints", "inurl:api/"),
                ("JSON API", "intext:'application/json' inurl:api", "JSON APIs", "intext:'application/json' inurl:api"),
                ("XML API", "intext:'application/xml' inurl:api", "XML APIs", "intext:'application/xml' inurl:api"),
                ("SOAP", "inurl:wsdl", "SOAP WSDL", "inurl:wsdl"),
                ("OData", "inurl:odata", "OData endpoints", "inurl:odata"),
            ]
        },
        "🛡️ Security & Vulnerability": {
            "icon": "🛡️",
            "color": Fore.RED,
            "dorks": [
                ("CVE List", "filetype:txt intext:CVE-202", "CVE files", "filetype:txt intext:CVE-202"),
                ("Nessus Report", "filetype:pdf intext:Nessus", "Nessus reports", "filetype:pdf intext:Nessus"),
                ("OpenVAS Report", "filetype:pdf intext:OpenVAS", "OpenVAS reports", "filetype:pdf intext:OpenVAS"),
                ("Burp Suite", "inurl:burp", "Burp Suite reports", "inurl:burp"),
                ("OWASP", "filetype:pdf intext:OWASP", "OWASP docs", "filetype:pdf intext:OWASP"),
                ("Penetration Test", "filetype:pdf intext:'penetration test'", "Pentest reports", "filetype:pdf intext:'penetration test'"),
                ("Vulnerability Scan", "filetype:pdf intext:'vulnerability scan'", "Vuln scans", "filetype:pdf intext:'vulnerability scan'"),
                ("Security Audit", "filetype:pdf intext:'security audit'", "Audit reports", "filetype:pdf intext:'security audit'"),
                ("Exploit", "filetype:txt intext:exploit", "Exploit code", "filetype:txt intext:exploit"),
                ("Proof of Concept", "filetype:txt intext:'Proof of Concept'", "PoC files", "filetype:txt intext:'Proof of Concept'"),
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
║                          🔥 MR. DORK  🔥                             
║            The Most Advanced Dork Search Engine for Analysts          
║                                                                              
║  Developer: Tc4dy                                                   
║  Version: 3.0                                              
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
            
            print(f"{Colors.WARNING}⚡ Type 'all' to run EVERY dork in this category (sequential){Colors.RESET}")
            print(f"{Colors.MENU}0. Back")
            
            choice = input(f"\n{Colors.INFO}Select a dork number, 'all', or 0: {Colors.RESET}").strip().lower()
            
            if choice == "0":
                break
            elif choice == "all":
                self.execute_all_dorks(dorks, category_name)
            else:
                try:
                    idx = int(choice) - 1
                    if 0 <= idx < len(dorks):
                        self.execute_dork(dorks[idx], category_name)
                except ValueError:
                    print(f"{Colors.ERROR}Invalid input. Please enter a number, 'all', or 0.{Colors.RESET}")
                    time.sleep(1)

    def execute_all_dorks(self, dorks: List[Tuple], category: str):
        """Run all dorks in the current category sequentially"""
        self.clear_screen()
        print(f"{Colors.HEADER}⚡ RUNNING ALL DORKS IN: {category}")
        print("═" * 80)
        print(f"{Colors.WARNING}This will open {len(dorks)} Google searches one after another.{Colors.RESET}")
        print(f"{Colors.WARNING}You can close the browser tabs as they open, or let them run.{Colors.RESET}")
        confirm = input(f"{Colors.INFO}Type 'yes' to continue, anything else to cancel: {Colors.RESET}").strip().lower()
        
        if confirm != "yes":
            print(f"{Colors.ERROR}Cancelled.{Colors.RESET}")
            time.sleep(1)
            return
        
        target = input(f"{Colors.QUERY}Enter target (e.g. site:com or keyword) for ALL dorks: {Colors.RESET}")
        
        for idx, (name, query, desc, example) in enumerate(dorks, 1):
            final_query = f"{query} {target}".strip()
            encoded_query = urllib.parse.quote(final_query)
            url = f"https://www.google.com/search?q={encoded_query}"
            print(f"{Colors.SUCCESS}[{idx}/{len(dorks)}] Opening: {name}{Colors.RESET}")
            open_url_silent(url)
            self.db.add_to_history(final_query, category)
            time.sleep(0.5)
        
        print(f"{Colors.SUCCESS}\n✅ All {len(dorks)} dorks executed!{Colors.RESET}")
        input(f"{Colors.INFO}Press Enter to return...{Colors.RESET}")

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
            open_url_silent(url)
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
                    open_url_silent(f"https://www.google.com/search?q={urllib.parse.quote(f[3])}")
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
