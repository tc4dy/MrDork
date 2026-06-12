DATABASE_FILE="mr_dork_data.db"
SEARCH_HISTORY_FILE="search_history.txt"
FAVORITES_FILE="favorites.txt"
CUSTOM_DORKS_FILE="custom_dorks.txt"

init_database() {
    sqlite3 "$DATABASE_FILE" "CREATE TABLE IF NOT EXISTS favorites (id INTEGER PRIMARY KEY AUTOINCREMENT, category TEXT NOT NULL, name TEXT NOT NULL, query TEXT NOT NULL UNIQUE, example TEXT, description TEXT, added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP);" 2>/dev/null
    sqlite3 "$DATABASE_FILE" "CREATE TABLE IF NOT EXISTS search_history (id INTEGER PRIMARY KEY AUTOINCREMENT, query TEXT NOT NULL, category TEXT, search_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP);" 2>/dev/null
    sqlite3 "$DATABASE_FILE" "CREATE TABLE IF NOT EXISTS statistics (id INTEGER PRIMARY KEY AUTOINCREMENT, total_searches INTEGER DEFAULT 0, favorite_count INTEGER DEFAULT 0, most_used_category TEXT, last_search_date TIMESTAMP);" 2>/dev/null
    sqlite3 "$DATABASE_FILE" "CREATE TABLE IF NOT EXISTS custom_dorks (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, query TEXT NOT NULL, description TEXT, created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP);" 2>/dev/null
}

open_url() {
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$1" >/dev/null 2>&1 &
    elif command -v open >/dev/null 2>&1; then
        open "$1" >/dev/null 2>&1 &
    else
        echo "Please open manually: $1"
    fi
}

print_logo() {
    clear
    echo -e "\033[36;1m"
    echo "         _nnnn_                      "
    echo "        dGGGGMMb     ,\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"."
    echo "       @p~qp~~qMb    | I Love Tc4dy <3 |"
    echo "       M|@||@) M|   _;..............'"
    echo "       @,----.JM| -'"
    echo "      JS^\\__/  qKL"
    echo "     dZP        qKRb"
    echo "    dZP          qKKb"
    echo "   fZP            SMMb"
    echo "   HZM            MMMM"
    echo "   FqM            MMMM"
    echo " __| \".        |\\dS\"qML"
    echo " |    \`.       | \`' \\Zq"
    echo "_)      \\.___.,|     .'"
    echo "\\____   )MMMMMM|   .'"
    echo "     \`-'       \`--'"
    echo -e "\033[0m"
    echo -e "\033[36;1m"
    echo "══════════════════════════════════════════════════════════════════════════════"
    echo "                            MR. DORK                               "
    echo "            The Advanced Dork Search Engine for Analysts          "
    echo "                                                                              "
    echo "                        Developer: @tc4dy                                                   "
    echo "                                            "
    echo "  Total Dorks: 448  Google Dorks                                        "
    echo "  Categories: 28                                                         "
    echo "══════════════════════════════════════════════════════════════════════════════"
    echo -e "\033[0m"
    echo -e "\033[33;1m⚠️  ETHICAL USE WARNING: This tool is for educational and legal testing only!\033[0m"
    echo -e "\033[31;1m⚠️  Unauthorized system access is illegal and can have serious consequences!\033[0m"
    echo ""
}

add_to_history() {
    sqlite3 "$DATABASE_FILE" "INSERT INTO search_history (query, category) VALUES ('$1', '$2');" 2>/dev/null
    sqlite3 "$DATABASE_FILE" "UPDATE statistics SET total_searches = total_searches + 1, last_search_date = CURRENT_TIMESTAMP WHERE id = 1;" 2>/dev/null
    sqlite3 "$DATABASE_FILE" "INSERT OR REPLACE INTO statistics (id, total_searches, favorite_count, most_used_category, last_search_date) SELECT 1, COALESCE((SELECT COUNT(*) FROM search_history), 0), COALESCE((SELECT COUNT(*) FROM favorites), 0), COALESCE((SELECT category FROM search_history WHERE category != '' GROUP BY category ORDER BY COUNT(*) DESC LIMIT 1), 'None'), CURRENT_TIMESTAMP;" 2>/dev/null
}

get_stats() {
    TOTAL=$(sqlite3 "$DATABASE_FILE" "SELECT total_searches FROM statistics WHERE id = 1;" 2>/dev/null)
    FAVS=$(sqlite3 "$DATABASE_FILE" "SELECT favorite_count FROM statistics WHERE id = 1;" 2>/dev/null)
    [ -z "$TOTAL" ] && TOTAL=0
    [ -z "$FAVS" ] && FAVS=0
    echo "📊 STATS: Total Searches: $TOTAL | Favorites: $FAVS"
}

add_favorite() {
    sqlite3 "$DATABASE_FILE" "INSERT OR IGNORE INTO favorites (category, name, query, example, description) VALUES ('$1', '$2', '$3', '$4', '$5');" 2>/dev/null
    sqlite3 "$DATABASE_FILE" "UPDATE statistics SET favorite_count = (SELECT COUNT(*) FROM favorites) WHERE id = 1;" 2>/dev/null
}

remove_favorite() {
    sqlite3 "$DATABASE_FILE" "DELETE FROM favorites WHERE query = '$1';" 2>/dev/null
}

add_custom_dork() {
    sqlite3 "$DATABASE_FILE" "INSERT INTO custom_dorks (name, query, description) VALUES ('$1', '$2', '$3');" 2>/dev/null
}

show_categories() {
    echo -e "\033[35;1m📂 CATEGORIES\n\033[0m"
    echo "1.  📁 PDF Documents"
    echo "2.  📊 Excel & Spreadsheets"
    echo "3.  📝 Word Documents"
    echo "4.  💾 Database Files"
    echo "5.  📜 Log Files"
    echo "6.  💼 Backup Files"
    echo "7.  🔐 Admin Panels"
    echo "8.  🔑 Login Pages"
    echo "9.  🗄️ phpMyAdmin"
    echo "10. ⚙️ cPanel & WHM"
    echo "11. 📂 Open Directories"
    echo "12. 📤 Upload Directories"
    echo "13. ⚙️ Config Directories"
    echo "14. 🔑 Passwords"
    echo "15. 🔐 API Keys"
    echo "16. 📋 Config Files"
    echo "17. 📡 IoT & Camera Feeds"
    echo "18. 📊 Public Analytics & Stats"
    echo "19. 🔍 Git & Version Control"
    echo "20. 🌍 Geo-location & Maps"
    echo "21. 📡 Network Devices"
    echo "22. 🔐 VPN & Proxy Configs"
    echo "23. 📧 Email & Communication"
    echo "24. 🛒 E-commerce"
    echo "25. 🏥 Healthcare & Medical"
    echo "26. 📁 File Sharing"
    echo "27. 🎓 Education & Academic"
    echo "28. 🔧 Developer & Debugging"
    echo ""
    echo "0. Back to Main Menu"
}

get_dorks_by_category() {
    case $1 in
        1) echo "filetype:pdf|PDF - General|Find all PDF files|filetype:pdf site:edu.tr"
           echo "filetype:pdf intext:confidential|PDF - Confidential|Confidential PDF documents|filetype:pdf intext:confidential site:gov.tr"
           echo "filetype:pdf intext:budget|PDF - Budget|Budget PDFs|filetype:pdf intext:budget 2024"
           echo "filetype:pdf intext:contract|PDF - Contract|Contract documents|filetype:pdf intext:contract"
           echo "filetype:pdf intext:report|PDF - Report|Report documents|filetype:pdf intext:report annual"
           echo "filetype:pdf intext:invoice|PDF - Invoice|Invoice documents|filetype:pdf intext:invoice"
           echo "filetype:pdf intext:technical|PDF - Technical Doc|Technical manuals|filetype:pdf intext:technical manual"
           echo "filetype:pdf intext:thesis|PDF - Thesis|Thesis documents|filetype:pdf intext:thesis site:edu";;
        2) echo "filetype:xls|Excel - XLS|XLS files|filetype:xls site:example.com"
           echo "filetype:xlsx|Excel - XLSX|XLSX files|filetype:xlsx budget"
           echo "filetype:xlsx intext:salary|Excel - Salary|Salary sheets|filetype:xlsx intext:salary 2024"
           echo "filetype:xlsx intext:customer|Excel - Customer|Customer lists|filetype:xlsx intext:customer database"
           echo "filetype:xls intext:financial|Excel - Financial|Financial tables|filetype:xls intext:financial"
           echo "filetype:csv|CSV - Data|CSV data files|filetype:csv database"
           echo "filetype:xlsx intext:statistics|Excel - Statistics|Statistical sheets|filetype:xlsx intext:statistics"
           echo "filetype:xls intext:inventory|Excel - Inventory|Inventory lists|filetype:xls intext:inventory";;
        3) echo "filetype:doc|Word - DOC|DOC documents|filetype:doc"
           echo "filetype:docx|Word - DOCX|DOCX documents|filetype:docx"
           echo "filetype:docx intext:confidential|Word - Confidential|Confidential Word docs|filetype:docx intext:confidential"
           echo "filetype:doc intext:memo|Word - Memo|Notes and memos|filetype:doc intext:memo"
           echo "filetype:docx intext:resume|Word - Resume|Resume documents|filetype:docx intext:resume"
           echo "filetype:doc intext:meeting|Word - Meeting|Meeting notes|filetype:doc intext:meeting minutes"
           echo "filetype:docx intext:policy|Word - Policy|Policy documents|filetype:docx intext:policy"
           echo "filetype:doc intext:procedure|Word - Procedure|Procedure documents|filetype:doc intext:procedure";;
        4) echo "filetype:sql|SQL Dump|SQL dump files|filetype:sql intext:INSERT INTO"
           echo "filetype:sql intext:mysql|SQL - MySQL|MySQL dumps|filetype:sql intext:mysql dump"
           echo "filetype:sql intext:backup|Database Backup|Database backups|filetype:sql intext:backup"
           echo "filetype:mdb|MDB Access|MS Access databases|filetype:mdb"
           echo "filetype:db|SQLite DB|SQLite databases|filetype:db OR filetype:sqlite"
           echo "filetype:json intext:mongodb|MongoDB|MongoDB export|filetype:json intext:mongodb"
           echo "filetype:sql intext:CREATE DATABASE|Database Config|DB configuration|filetype:sql intext:CREATE DATABASE"
           echo "filetype:sql intext:password|DB Credentials|DB passwords|filetype:sql intext:password";;
        5) echo "filetype:log|Log - General|All log files|filetype:log"
           echo "filetype:log intext:error|Error Logs|Error logs|filetype:log intext:error"
           echo "filetype:log intext:access|Access Logs|Access logs|filetype:log intext:access.log"
           echo "filetype:log intext:apache|Apache Logs|Apache logs|filetype:log intext:apache"
           echo "filetype:log intext:system|System Logs|System logs|filetype:log intext:system"
           echo "filetype:log intext:debug|Debug Logs|Debug logs|filetype:log intext:debug"
           echo "filetype:log intext:auth|Auth Logs|Authentication logs|filetype:log intext:auth"
           echo "filetype:log intext:ftp|FTP Logs|FTP logs|filetype:log intext:ftp";;
        6) echo "filetype:bak|Backup - BAK|BAK backup files|filetype:bak"
           echo "filetype:backup|Backup - BACKUP|BACKUP files|filetype:backup"
           echo "filetype:sql intext:backup|SQL Backup|SQL backups|filetype:sql intext:backup"
           echo "filetype:zip intext:backup|Zip Backup|Zip backups|filetype:zip intext:backup"
           echo "filetype:tar|Tar Backup|TAR archives|filetype:tar"
           echo "filetype:old|Old Files|Old file versions|filetype:old"
           echo "intitle:index.of backup|Backup Dir|Backup directories|intitle:index.of backup"
           echo "inurl:backup.zip|Site Backup|Site backups|inurl:backup.zip OR inurl:backup.tar";;
        7) echo "inurl:admin|Admin Panel|Admin pages|inurl:admin site:example.com"
           echo "inurl:admin/login|Admin Login|Admin login pages|inurl:admin/login"
           echo "intitle:admin intitle:dashboard|Admin Dashboard|Admin dashboards|intitle:admin intitle:dashboard"
           echo "intitle:index.of admin|Admin Index|Admin directories|intitle:index.of admin"
           echo "inurl:administration|Administration|Management panels|inurl:administration"
           echo "intitle:admin console|Admin Console|Admin consoles|intitle:admin console"
           echo "inurl:admin-area|Admin Area|Admin areas|inurl:admin-area"
           echo "inurl:backend/admin|Backend Admin|Backend admin|inurl:backend/admin";;
        8) echo "inurl:login|Login Page|Login pages|inurl:login"
           echo "inurl:signin|Sign In|Sign in pages|inurl:signin"
           echo "intitle:login intitle:user|User Login|User login|intitle:login intitle:user"
           echo "inurl:member/login|Member Login|Member login|inurl:member/login"
           echo "inurl:auth/login|Auth Login|Auth login|inurl:auth/login"
           echo "inurl:customer/login|Customer Login|Customer login|inurl:customer/login"
           echo "intitle:portal login|Portal Login|Portal logins|intitle:portal login"
           echo "inurl:secure/login|Secure Login|Secure login|inurl:secure/login";;
        9) echo "inurl:phpmyadmin|phpMyAdmin|phpMyAdmin panels|inurl:phpmyadmin"
           echo "intitle:phpMyAdmin|PMA|Titled PMA|intitle:phpMyAdmin"
           echo "inurl:phpmyadmin/index.php|phpMyAdmin Login|PMA login|inurl:phpmyadmin/index.php"
           echo "intitle:phpMyAdmin MySQL|MySQL Admin|MySQL admin|intitle:phpMyAdmin MySQL"
           echo "inurl:db/phpmyadmin|DB Admin|DB admin panels|inurl:db/phpmyadmin"
           echo "inurl:phpmyadmin/setup|PMA Setup|PMA setup|inurl:phpmyadmin/setup"
           echo "intitle:phpMyAdmin 4|phpMyAdmin 4|phpMyAdmin 4.x|intitle:phpMyAdmin 4"
           echo "intitle:adminer|Adminer|Adminer (PMA alternative)|intitle:adminer";;
        10) echo "inurl:cpanel|cPanel|cPanel panels|inurl:cpanel"
            echo "intitle:cpanel login|cPanel Login|cPanel login|intitle:cpanel login"
            echo "inurl:whm|WHM|WHM panels|inurl:whm"
            echo "inurl:webmail|Webmail|Webmail interfaces|inurl:webmail"
            echo "inurl:2083|cPanel 2083|cPanel port 2083|inurl:2083"
            echo "intitle:plesk|Plesk|Plesk panels|intitle:plesk"
            echo "intitle:directadmin|DirectAdmin|DirectAdmin|intitle:directadmin"
            echo "intitle:ispconfig|ISPConfig|ISPConfig panels|intitle:ispconfig";;
        11) echo "intitle:index.of|Index Of|Directory listings|intitle:index.of"
            echo "intitle:parent.directory|Parent Directory|Parent directories|intitle:parent.directory"
            echo "intitle:directory listing|Directory Listing|Directory listing|intitle:directory listing"
            echo "intitle:index of /|Index Of /|Root directories|intitle:index of /"
            echo "intitle:index.of apache|Apache Index|Apache directories|intitle:index.of apache"
            echo "intitle:index.of nginx|Nginx Index|Nginx directories|intitle:index.of nginx"
            echo "intitle:index.of iis|IIS Index|IIS directories|intitle:index.of iis"
            echo "intitle:autoindex|Autoindex|Auto index|intitle:autoindex";;
        12) echo "intitle:index.of uploads|Upload Dir|Upload folders|intitle:index.of uploads"
            echo "intitle:index.of files|Files Dir|Files directories|intitle:index.of files"
            echo "intitle:index.of images|Images Dir|Image directories|intitle:index.of images"
            echo "intitle:index.of media|Media Dir|Media directories|intitle:index.of media"
            echo "intitle:index.of documents|Documents Dir|Document directories|intitle:index.of documents"
            echo "intitle:index.of downloads|Downloads|Download directories|intitle:index.of downloads"
            echo "intitle:index.of assets|Assets Dir|Asset directories|intitle:index.of assets"
            echo "intitle:index.of public|Public Dir|Public directories|intitle:index.of public";;
        13) echo "intitle:index.of config|Config Dir|Config directories|intitle:index.of config"
            echo "intitle:index.of settings|Settings Dir|Settings directories|intitle:index.of settings"
            echo "intitle:index.of conf|Conf Dir|Conf directories|intitle:index.of conf"
            echo "intitle:index.of etc|etc Dir|etc directories|intitle:index.of etc"
            echo "intitle:index.of configuration|Configuration|Configuration directories|intitle:index.of configuration"
            echo "intitle:index.of include|Include Dir|Include directories|intitle:index.of include"
            echo "intitle:index.of lib|Lib Dir|Lib directories|intitle:index.of lib"
            echo "intitle:index.of vendor|Vendor Dir|Vendor directories|intitle:index.of vendor";;
        14) echo "filetype:txt intext:password|Password TXT|Password txt files|filetype:txt intext:password"
            echo "filetype:txt intext:credentials|Credentials|Identity credentials|filetype:txt intext:credentials"
            echo "filetype:txt intext:username intext:password|Login Info|Login information|filetype:txt intext:username intext:password"
            echo "filetype:txt intext:password list|Password List|Password lists|filetype:txt intext:password list"
            echo "filetype:txt intext:admin password|Admin Pass|Admin passwords|filetype:txt intext:admin password"
            echo "filetype:txt intext:root password|Root Pass|Root passwords|filetype:txt intext:root password"
            echo "filetype:txt intext:ftp password|FTP Credentials|FTP passwords|filetype:txt intext:ftp password"
            echo "filetype:txt intext:email password|Email Pass|Email passwords|filetype:txt intext:email password";;
        15) echo "intext:api_key OR intext:apikey|API Key|API keys|intext:api_key filetype:json"
            echo "intext:api_secret|API Secret|API secrets|intext:api_secret"
            echo "intext:access_token|Access Token|Access tokens|intext:access_token"
            echo "intext:bearer|Bearer Token|Bearer tokens|intext:bearer token"
            echo "intext:aws_access_key_id|AWS Key|AWS keys|intext:aws_access_key_id"
            echo "intext:AIza|Google API|Google API keys|intext:AIza"
            echo "intext:sk_live|Stripe Key|Stripe keys|intext:sk_live OR intext:pk_live"
            echo "intext:ghp_|GitHub Token|GitHub tokens|intext:ghp_ OR intext:gho_";;
        16) echo "filetype:env|ENV Files|Environment files|filetype:env"
            echo "filetype:php intext:config|Config PHP|PHP configs|filetype:php intext:config"
            echo "filetype:php intext:database|Database Config|Database config|filetype:php intext:database"
            echo "filetype:php intext:wp-config|WP Config|WordPress config|filetype:php intext:wp-config"
            echo "filetype:php intext:settings|Settings.php|Settings.php files|filetype:php intext:settings"
            echo "filetype:json intext:config|Config.json|JSON configs|filetype:json intext:config"
            echo "filetype:yml intext:config|App Config|App config (YAML)|filetype:yml intext:config"
            echo "filetype:conf intext:nginx|Nginx Config|Nginx configuration|filetype:conf intext:nginx";;
        17) echo "inurl:axis-cgi/mjpg|Camera - Axis MJPG|Axis camera live feed|inurl:axis-cgi/mjpg"
            echo "inurl:netcam.jpg|Camera - Netcam|Network camera image|inurl:netcam.jpg"
            echo "intitle:webcamXP|Camera - WebcamXP|WebcamXP interface|intitle:webcamXP"
            echo "intitle:'IP Camera Viewer'|Camera - IP Viewer|IP camera viewer|intitle:'IP Camera Viewer'"
            echo "intitle:D-Link inurl:webcam|Camera - D-Link|D-Link webcams|intitle:D-Link inurl:webcam"
            echo "intitle:TRENDnet inurl:webcam|Camera - Trendnet|Trendnet cameras|intitle:TRENDnet inurl:webcam"
            echo "intitle:Foscam inurl:webcam|Camera - Foscam|Foscam cameras|intitle:Foscam inurl:webcam"
            echo "intitle:Panasonic inurl:view|Camera - Panasonic|Panasonic cameras|intitle:Panasonic inurl:view"
            echo "intitle:Sony inurl:webcam|Camera - Sony|Sony cameras|intitle:Sony inurl:webcam"
            echo "intitle:Hikvision inurl:doc/page/login|Camera - Hikvision|Hikvision login|intitle:Hikvision inurl:doc/page/login";;
        18) echo "filetype:awstats|Analytics - Awstats|AWStats files|filetype:awstats"
            echo "filetype:webalizer|Analytics - Webalizer|Webalizer stats|filetype:webalizer"
            echo "inurl:piwik|Analytics - Piwik|Piwik analytics|inurl:piwik"
            echo "inurl:matomo|Analytics - Matomo|Matomo analytics|inurl:matomo"
            echo "intext:'UA-' intext:'ga.js'|Analytics - Google Analytics|Google Analytics ID|intext:'UA-' intext:'ga.js'"
            echo "intext:'cliky' inurl:stats|Analytics - Clicky|Clicky stats|intext:'cliky' inurl:stats"
            echo "inurl:statcounter|Analytics - Statcounter|Statcounter|inurl:statcounter"
            echo "inurl:owa|Analytics - Open Web Analytics|OWA analytics|inurl:owa"
            echo "inurl:countly|Analytics - Countly|Countly analytics|inurl:countly"
            echo "inurl:umami|Analytics - Umami|Umami analytics|inurl:umami";;
        19) echo "inurl:.git/config|Git - Config|Git config file|inurl:.git/config"
            echo "inurl:.git/HEAD|Git - HEAD|Git HEAD|inurl:.git/HEAD"
            echo "inurl:.git/index|Git - Index|Git index|inurl:.git/index"
            echo "inurl:.git/logs|Git - Logs|Git logs|inurl:.git/logs"
            echo "inurl:.git/refs|Git - Ref|Git refs|inurl:.git/refs"
            echo "inurl:.git/objects|Git - Objects|Git objects|inurl:.git/objects"
            echo "inurl:.svn/entries|SVN - Entries|SVN entries|inurl:.svn/entries"
            echo "inurl:.svn/wc.db|SVN - WC|SVN working copy|inurl:.svn/wc.db"
            echo "inurl:.hg/requires|HG - Requires|Mercurial requires|inurl:.hg/requires"
            echo "inurl:.hg/store|HG - Store|Mercurial store|inurl:.hg/store";;
        20) echo "filetype:gpx|GPS - GPX|GPS exchange files|filetype:gpx"
            echo "filetype:kml|GPS - KML|Google Earth KML|filetype:kml"
            echo "filetype:kmz|GPS - KMZ|Google Earth KMZ|filetype:kmz"
            echo "filetype:loc|GPS - LOC|GPS location files|filetype:loc"
            echo "intitle:'static map'|Maps - Static|Static maps|intitle:'static map'"
            echo "intext:'AIza' inurl:maps|Maps - API Key|Google Maps API keys|intext:'AIza' inurl:maps"
            echo "filetype:geojson|GeoJSON|GeoJSON data|filetype:geojson"
            echo "filetype:shp|Shapefile|Shapefile|filetype:shp"
            echo "inurl:openstreetmap|OpenStreetMap|OSM data|inurl:openstreetmap"
            echo "intitle:MapServer|MapServer|MapServer interface|intitle:MapServer";;
        21) echo "intitle:Cisco inurl:home|Router - Cisco|Cisco routers|intitle:Cisco inurl:home"
            echo "intitle:MikroTik|Router - MikroTik|MikroTik routers|intitle:MikroTik"
            echo "intitle:TP-Link inurl:web|Router - TP-Link|TP-Link routers|intitle:TP-Link inurl:web"
            echo "intitle:D-Link inurl:login|Router - D-Link|D-Link routers|intitle:D-Link inurl:login"
            echo "intitle:HP Switch|Switch - HP|HP switches|intitle:HP Switch"
            echo "intitle:Netgear inurl:switch|Switch - Netgear|Netgear switches|intitle:Netgear inurl:switch"
            echo "intitle:pfsense|Firewall - pfSense|pfSense firewalls|intitle:pfsense"
            echo "intitle:Sophos|Firewall - Sophos|Sophos firewalls|intitle:Sophos"
            echo "intitle:Ubiquiti inurl:unifi|Access Point - Ubiquiti|Ubiquiti AP|intitle:Ubiquiti inurl:unifi"
            echo "intitle:Arris|Modem - Arris|Arris modems|intitle:Arris";;
        22) echo "filetype:ovpn|OpenVPN Config|OpenVPN configs|filetype:ovpn"
            echo "filetype:conf intext:'[Interface]'|WireGuard Config|WireGuard configs|filetype:conf intext:'[Interface]'"
            echo "filetype:pptp|PPTP Config|PPTP configs|filetype:pptp"
            echo "filetype:l2tp|L2TP Config|L2TP configs|filetype:l2tp"
            echo "filetype:txt intext:socks|Socks Proxy|SOCKS proxy lists|filetype:txt intext:socks"
            echo "filetype:txt intext:'http proxy'|HTTP Proxy|HTTP proxy lists|filetype:txt intext:'http proxy'"
            echo "inurl:vpnbook|VPN Book|VPN book configs|inurl:vpnbook"
            echo "inurl:protonvpn|ProtonVPN|ProtonVPN configs|inurl:protonvpn"
            echo "inurl:nordvpn|NordVPN|NordVPN configs|inurl:nordvpn"
            echo "inurl:expressvpn|ExpressVPN|ExpressVPN configs|inurl:expressvpn";;
        23) echo "inurl:owa|Email - Outlook|Outlook Web Access|inurl:owa"
            echo "intitle:Roundcube|Email - Roundcube|Roundcube webmail|intitle:Roundcube"
            echo "intitle:SquirrelMail|Email - SquirrelMail|SquirrelMail|intitle:SquirrelMail"
            echo "inurl:mailcow|Email - Mailcow|Mailcow UI|inurl:mailcow"
            echo "intitle:Zimbra|Email - Zimbra|Zimbra webmail|intitle:Zimbra"
            echo "intitle:Horde|Email - Horde|Horde webmail|intitle:Horde"
            echo "intitle:Atmail|Email - Atmail|Atmail webmail|intitle:Atmail"
            echo "intitle:RainLoop|Email - RainLoop|RainLoop webmail|intitle:RainLoop"
            echo "intitle:Mailpile|Email - Mailpile|Mailpile|intitle:Mailpile"
            echo "intitle:Modoboa|Email - Modoboa|Modoboa|intitle:Modoboa";;
        24) echo "inurl:wp-content/plugins/woocommerce|WooCommerce|WooCommerce sites|inurl:wp-content/plugins/woocommerce"
            echo "inurl:app/code/core/Mage|Magento|Magento sites|inurl:app/code/core/Mage"
            echo "inurl:modules/prestashop|PrestaShop|PrestaShop sites|inurl:modules/prestashop"
            echo "intext:'Shopify' inurl:product|Shopify|Shopify sites|intext:'Shopify' inurl:product"
            echo "inurl:index.php?route=common/home|OpenCart|OpenCart sites|inurl:index.php?route=common/home"
            echo "intitle:Zen Cart|Zen Cart|Zen Cart sites|intitle:Zen Cart"
            echo "inurl:bigcommerce|BigCommerce|BigCommerce sites|inurl:bigcommerce"
            echo "inurl:sfcc|Salesforce Commerce|Salesforce Commerce|inurl:sfcc"
            echo "inurl:wixstores|Wix Stores|Wix stores|inurl:wixstores"
            echo "inurl:weebly.com/store|Weebly Store|Weebly stores|inurl:weebly.com/store";;
        25) echo "filetype:pdf intext:'patient name'|Patient Records|Patient PDFs|filetype:pdf intext:'patient name'"
            echo "filetype:pdf intext:'medical report'|Medical Reports|Medical reports|filetype:pdf intext:'medical report'"
            echo "filetype:pdf intext:prescription|Prescriptions|Prescriptions|filetype:pdf intext:prescription"
            echo "filetype:pdf intext:'lab result'|Lab Results|Lab results|filetype:pdf intext:'lab result'"
            echo "intitle:hospital inurl:patient|Hospital Info|Hospital patient portals|intitle:hospital inurl:patient"
            echo "inurl:epic|EPIC Systems|EPIC healthcare|inurl:epic"
            echo "inurl:cerner|Cerner|Cerner portals|inurl:cerner"
            echo "inurl:allscripts|Allscripts|Allscripts|inurl:allscripts"
            echo "inurl:mckesson|McKesson|McKesson|inurl:mckesson"
            echo "inurl:meditech|Meditech|Meditech|inurl:meditech";;
        26) echo "inurl:dropbox.com/s/|Dropbox|Dropbox shared files|inurl:dropbox.com/s/"
            echo "inurl:drive.google.com/file/d/|Google Drive|Google Drive files|inurl:drive.google.com/file/d/"
            echo "inurl:onedrive.live.com|OneDrive|OneDrive files|inurl:onedrive.live.com"
            echo "inurl:box.com/s/|Box|Box shared files|inurl:box.com/s/"
            echo "inurl:mediafire.com|MediaFire|MediaFire files|inurl:mediafire.com"
            echo "inurl:mega.nz|Mega|Mega files|inurl:mega.nz"
            echo "inurl:wetransfer.com|WeTransfer|WeTransfer|inurl:wetransfer.com"
            echo "inurl:sendspace.com|SendSpace|SendSpace|inurl:sendspace.com"
            echo "inurl:file.io|File.io|File.io|inurl:file.io"
            echo "inurl:tresorit.com|Tresorit|Tresorit|inurl:tresorit.com";;
        27) echo "filetype:pdf intext:'lecture notes'|Lecture Notes|Lecture PDFs|filetype:pdf intext:'lecture notes'"
            echo "filetype:pdf intext:syllabus|Syllabus|Course syllabi|filetype:pdf intext:syllabus"
            echo "filetype:pdf intext:'exam' site:edu|Exam Papers|Exam papers|filetype:pdf intext:'exam' site:edu"
            echo "filetype:pdf intext:thesis site:edu|Thesis|Thesis papers|filetype:pdf intext:thesis site:edu"
            echo "filetype:pdf intext:dissertation|Dissertation|Dissertations|filetype:pdf intext:dissertation"
            echo "filetype:pdf intext:'research paper'|Research Papers|Research papers|filetype:pdf intext:'research paper'"
            echo "filetype:pdf intext:'white paper'|White Papers|White papers|filetype:pdf intext:'white paper'"
            echo "intitle:Moodle inurl:login|Moodle|Moodle LMS|intitle:Moodle inurl:login"
            echo "intitle:Canvas inurl:login|Canvas LMS|Canvas LMS|intitle:Canvas inurl:login"
            echo "intitle:Blackboard inurl:login|Blackboard|Blackboard|intitle:Blackboard inurl:login";;
        28) echo "filetype:php intext:'phpinfo()'|PHPInfo|PHP info pages|filetype:php intext:'phpinfo()'"
            echo "intitle:'Debug Bar'|Debug Bar|Debug bars|intitle:'Debug Bar'"
            echo "inurl:_debugbar|Laravel Debug|Laravel debug|inurl:_debugbar"
            echo "inurl:debug_toolbar|Django Debug|Django debug|inurl:debug_toolbar"
            echo "inurl:debug/|Flask Debug|Flask debug|inurl:debug/"
            echo "inurl:actuator|Spring Boot Actuator|Spring Boot|inurl:actuator"
            echo "inurl:trace.axd|ASP.NET Trace|ASP.NET trace|inurl:trace.axd"
            echo "inurl:elasticsearch/_nodes|ElasticSearch|ElasticSearch nodes|inurl:elasticsearch/_nodes"
            echo "intitle:Kibana|Kibana|Kibana dashboards|intitle:Kibana"
            echo "intitle:Grafana|Grafana|Grafana dashboards|intitle:Grafana";;
    esac
}

execute_dork() {
    IFS='|' read -r QUERY NAME DESC EXAMPLE <<< "$1"
    
    clear
    echo -e "\033[35;1m🚀 EXECUTING: $NAME\033[0m"
    echo "══════════════════════════════════════════════════════════════════════════════"
    echo -e "\033[34;1mExample usage: $EXAMPLE\033[0m"
    echo -n -e "\033[33;1mEnter target (e.g. site:com or keyword): \033[0m"
    read TARGET
    
    FINAL_QUERY="$QUERY $TARGET"
    FINAL_QUERY=$(echo "$FINAL_QUERY" | xargs)
    echo -e "\n\033[32;1mFinal Query: $FINAL_QUERY\033[0m"
    
    ENC_QUERY=$(printf "%s" "$FINAL_QUERY" | od -An -tx1 | tr ' ' '%' | tr -d '\n' | sed 's/%$//' | sed 's/%/%%/g')
    ENC_QUERY=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$FINAL_QUERY'''))" 2>/dev/null || echo "$FINAL_QUERY" | sed 's/ /%20/g')
    URL="https://www.google.com/search?q=$ENC_QUERY"
    
    echo ""
    echo -e "\033[37;1m1. 🌐 Open in Browser\033[0m"
    echo -e "\033[37;1m2. ⭐ Save to Favorites\033[0m"
    echo -e "\033[37;1m0. Cancel\033[0m"
    
    echo -n -e "\n\033[34;1mSelection: \033[0m"
    read CHOICE
    
    case $CHOICE in
        1)
            open_url "$URL"
            add_to_history "$FINAL_QUERY" "$CATEGORY_NAME"
            ;;
        2)
            add_favorite "$CATEGORY_NAME" "$NAME" "$FINAL_QUERY" "$EXAMPLE" "$DESC"
            echo -e "\033[32;1mAdded to favorites!\033[0m"
            sleep 1
            ;;
    esac
}

browse_categories() {
    while true; do
        clear
        print_logo
        get_stats
        echo "────────────────────────────────────────────────────────────────────────────────"
        show_categories
        
        echo -n -e "\n\033[34;1mSelect category (or 0): \033[0m"
        read CAT_CHOICE
        
        [ "$CAT_CHOICE" = "0" ] && break
        
        if [ "$CAT_CHOICE" -ge 1 ] && [ "$CAT_CHOICE" -le 28 ] 2>/dev/null; then
            view_dorks "$CAT_CHOICE"
        else
            echo -e "\033[31;1mInvalid selection!\033[0m"
            sleep 1
        fi
    done
}

view_dorks() {
    CAT_NUM=$1
    DORKS=$(get_dorks_by_category $CAT_NUM)
    DORK_COUNT=$(echo "$DORKS" | grep -c '^')
    
    while true; do
        clear
        CAT_NAMES=("PDF Documents" "Excel & Spreadsheets" "Word Documents" "Database Files" "Log Files" "Backup Files" "Admin Panels" "Login Pages" "phpMyAdmin" "cPanel & WHM" "Open Directories" "Upload Directories" "Config Directories" "Passwords" "API Keys" "Config Files" "IoT & Camera Feeds" "Public Analytics & Stats" "Git & Version Control" "Geo-location & Maps" "Network Devices" "VPN & Proxy Configs" "Email & Communication" "E-commerce" "Healthcare & Medical" "File Sharing" "Education & Academic" "Developer & Debugging")
        CATEGORY_NAME="${CAT_NAMES[$((CAT_NUM-1))]}"
        
        echo -e "\033[35;1m📂 CATEGORY: $CATEGORY_NAME\033[0m"
        echo "══════════════════════════════════════════════════════════════════════════════"
        
        IFS=$'\n'
        IDX=1
        for DORK in $DORKS; do
            IFS='|' read -r Q N D E <<< "$DORK"
            echo -e "\033[32;1m$IDX. $N\033[0m"
            echo "   \033[34;1mDescription: $D\033[0m"
            echo "   \033[36;1mDork: $Q\033[0m"
            echo "----------------------------------------"
            IDX=$((IDX+1))
        done
        
        echo -e "\033[33;1m⚡ Type 'all' to run EVERY dork in this category (sequential)\033[0m"
        echo -e "\033[37;1m0. Back\033[0m"
        
        echo -n -e "\n\033[34;1mSelect a dork number, 'all', or 0: \033[0m"
        read DORK_CHOICE
        
        [ "$DORK_CHOICE" = "0" ] && break
        
        if [ "$DORK_CHOICE" = "all" ]; then
            echo -n -e "\033[33;1mThis will open $DORK_COUNT Google searches. Type 'yes' to continue: \033[0m"
            read CONFIRM
            if [ "$CONFIRM" = "yes" ]; then
                echo -n -e "\033[33;1mEnter target for ALL dorks: \033[0m"
                read TARGET
                IDX=1
                IFS=$'\n'
                for DORK in $DORKS; do
                    IFS='|' read -r Q N D E <<< "$DORK"
                    FINAL_Q="$Q $TARGET"
                    FINAL_Q=$(echo "$FINAL_Q" | xargs)
                    ENC=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$FINAL_Q'''))" 2>/dev/null || echo "$FINAL_Q" | sed 's/ /%20/g')
                    echo -e "\033[32;1m[$IDX/$DORK_COUNT] Opening: $N\033[0m"
                    open_url "https://www.google.com/search?q=$ENC"
                    add_to_history "$FINAL_Q" "$CATEGORY_NAME"
                    IDX=$((IDX+1))
                    sleep 0.5
                done
                echo -e "\033[32;1m✅ All $DORK_COUNT dorks executed!\033[0m"
                echo -n -e "\033[34;1mPress Enter to return...\033[0m"
                read
            fi
        elif [ "$DORK_CHOICE" -ge 1 ] && [ "$DORK_CHOICE" -le "$DORK_COUNT" ] 2>/dev/null; then
            SELECTED_DORK=$(echo "$DORKS" | sed -n "${DORK_CHOICE}p")
            execute_dork "$SELECTED_DORK"
        fi
    done
}

search_dorks() {
    clear
    echo -e "\033[35;1m🔍 GLOBAL SEARCH\033[0m"
    echo -n -e "\033[34;1mEnter search term: \033[0m"
    read KEYWORD
    
    RESULTS=""
    for CAT in $(seq 1 28); do
        DORKS=$(get_dorks_by_category $CAT)
        IFS=$'\n'
        for DORK in $DORKS; do
            IFS='|' read -r Q N D E <<< "$DORK"
            if echo "$N $Q $D" | grep -iq "$KEYWORD"; then
                CAT_NAMES=("PDF Documents" "Excel & Spreadsheets" "Word Documents" "Database Files" "Log Files" "Backup Files" "Admin Panels" "Login Pages" "phpMyAdmin" "cPanel & WHM" "Open Directories" "Upload Directories" "Config Directories" "Passwords" "API Keys" "Config Files" "IoT & Camera Feeds" "Public Analytics & Stats" "Git & Version Control" "Geo-location & Maps" "Network Devices" "VPN & Proxy Configs" "Email & Communication" "E-commerce" "Healthcare & Medical" "File Sharing" "Education & Academic" "Developer & Debugging")
                RESULTS="$RESULTS${CAT_NAMES[$((CAT-1))]}|$N|$Q|$D|$E\n"
            fi
        done
    done
    
    if [ -z "$RESULTS" ]; then
        echo -e "\033[31;1mNo dorks found matching your search.\033[0m"
        sleep 1
        return
    fi
    
    while true; do
        clear
        echo -e "\033[35;1m🔎 SEARCH RESULTS for '$KEYWORD'\033[0m"
        echo "══════════════════════════════════════════════════════════════════════════════"
        
        IFS=$'\n'
        IDX=1
        for RES in $(echo -e "$RESULTS" | head -n 50); do
            IFS='|' read -r CAT N Q D E <<< "$RES"
            echo -e "\033[32;1m$IDX. [$CAT] $N\033[0m"
            echo "   \033[36;1m$Q\033[0m"
            IDX=$((IDX+1))
        done
        
        echo -e "\n\033[37;1m0. Back\033[0m"
        echo -n -e "\n\033[34;1mSelection: \033[0m"
        read SEL
        
        [ "$SEL" = "0" ] && break
        
        if [ "$SEL" -ge 1 ] && [ "$SEL" -lt "$IDX" ] 2>/dev/null; then
            SELECTED=$(echo -e "$RESULTS" | sed -n "${SEL}p")
            IFS='|' read -r CAT N Q D E <<< "$SELECTED"
            execute_dork "$Q|$N|$D|$E"
        fi
    done
}

view_favorites() {
    while true; do
        FAVS=$(sqlite3 "$DATABASE_FILE" "SELECT category, name, query FROM favorites ORDER BY added_date DESC;" 2>/dev/null)
        
        clear
        echo -e "\033[35;1m⭐ FAVORITE DORKS\033[0m"
        echo "══════════════════════════════════════════════════════════════════════════════"
        
        if [ -z "$FAVS" ]; then
            echo -e "\033[31;1mYour favorites list is empty.\033[0m"
            echo -n -e "\n\033[34;1mPress Enter to return...\033[0m"
            read
            break
        fi
        
        IFS=$'\n'
        IDX=1
        for FAV in $FAVS; do
            IFS='|' read -r CAT NAME QUERY <<< "$FAV"
            echo -e "\033[32;1m$IDX. [$CAT] $NAME\033[0m"
            echo "   \033[36;1m$QUERY\033[0m"
            IDX=$((IDX+1))
        done
        
        echo -e "\n\033[37;1m0. Back\033[0m"
        echo -n -e "\n\033[34;1mSelect to run (or 0): \033[0m"
        read CHOICE
        
        [ "$CHOICE" = "0" ] && break
        
        if [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -lt "$IDX" ] 2>/dev/null; then
            SELECTED=$(echo "$FAVS" | sed -n "${CHOICE}p")
            IFS='|' read -r CAT NAME QUERY <<< "$SELECTED"
            ENC=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$QUERY'''))" 2>/dev/null || echo "$QUERY" | sed 's/ /%20/g')
            open_url "https://www.google.com/search?q=$ENC"
            add_to_history "$QUERY" "$CAT"
        fi
    done
}

view_history() {
    HISTORY=$(sqlite3 "$DATABASE_FILE" "SELECT query, category, search_date FROM search_history ORDER BY search_date DESC LIMIT 50;" 2>/dev/null)
    
    clear
    echo -e "\033[35;1m📜 SEARCH HISTORY\033[0m"
    echo "══════════════════════════════════════════════════════════════════════════════"
    
    if [ -z "$HISTORY" ]; then
        echo -e "\033[31;1mHistory is empty.\033[0m"
    else
        IFS=$'\n'
        for H in $HISTORY; do
            IFS='|' read -r Q C D <<< "$H"
            echo -e "\033[34;1m[$D] \033[32;1m$C \033[0m>> $Q"
        done
    fi
    
    echo -e "\n\033[37;1m1. Clear History\033[0m"
    echo -e "\033[37;1m0. Back\033[0m"
    
    echo -n -e "\n\033[34;1mSelection: \033[0m"
    read CHOICE
    
    if [ "$CHOICE" = "1" ]; then
        sqlite3 "$DATABASE_FILE" "DELETE FROM search_history;" 2>/dev/null
        echo -e "\033[32;1mHistory cleared!\033[0m"
        sleep 1
    fi
}

custom_dorks_menu() {
    while true; do
        clear
        echo -e "\033[35;1m🛠️  CUSTOM DORKS\033[0m"
        echo "══════════════════════════════════════════════════════════════════════════════"
        echo -e "\033[37;1m1. ➕ Add Custom Dork\033[0m"
        echo -e "\033[37;1m2. 📂 View Custom Dorks\033[0m"
        echo -e "\033[37;1m0. Back\033[0m"
        
        echo -n -e "\n\033[34;1mSelection: \033[0m"
        read CHOICE
        
        [ "$CHOICE" = "0" ] && break
        
        if [ "$CHOICE" = "1" ]; then
            echo -n -e "\033[33;1mDork Name: \033[0m"
            read NAME
            echo -n -e "\033[33;1mDork Query: \033[0m"
            read QUERY
            echo -n -e "\033[33;1mDescription: \033[0m"
            read DESC
            add_custom_dork "$NAME" "$QUERY" "$DESC"
            echo -e "\033[32;1mSaved successfully!\033[0m"
            sleep 1
        elif [ "$CHOICE" = "2" ]; then
            CUSTOMS=$(sqlite3 "$DATABASE_FILE" "SELECT name, query, description FROM custom_dorks ORDER BY created_date DESC;" 2>/dev/null)
            clear
            echo -e "\033[35;1m📂 YOUR CUSTOM DORKS\033[0m"
            if [ -z "$CUSTOMS" ]; then
                echo -e "\033[31;1mNo custom dorks found.\033[0m"
            else
                IFS=$'\n'
                for C in $CUSTOMS; do
                    IFS='|' read -r N Q D <<< "$C"
                    echo -e "\033[32;1m$N: \033[36;1m$Q\033[0m"
                    [ -n "$D" ] && echo "   \033[34;1m$D\033[0m"
                done
            fi
            echo -n -e "\n\033[34;1mPress Enter to return...\033[0m"
            read
        fi
    done
}

main_menu() {
    init_database
    
    while true; do
        print_logo
        get_stats
        echo "────────────────────────────────────────────────────────────────────────────────"
        echo -e "\033[37;1m1. 📂 Browse Categories\033[0m"
        echo -e "\033[37;1m2. 🔍 Search Dorks\033[0m"
        echo -e "\033[37;1m3. ⭐ View Favorites\033[0m"
        echo -e "\033[37;1m4. 📜 Search History\033[0m"
        echo -e "\033[37;1m5. 🛠️  Custom Dorks\033[0m"
        echo -e "\033[37;1m0. ❌ Exit\033[0m"
        echo "────────────────────────────────────────────────────────────────────────────────"
        
        echo -n -e "\033[34;1mSelect an option: \033[0m"
        read MAIN_CHOICE
        
        case $MAIN_CHOICE in
            1) browse_categories ;;
            2) search_dorks ;;
            3) view_favorites ;;
            4) view_history ;;
            5) custom_dorks_menu ;;
            0) echo -e "\033[32;1m\nStay safe! Goodbye...\033[0m"; exit 0 ;;
            *) echo -e "\033[31;1mInvalid selection!\033[0m"; sleep 1 ;;
        esac
    done
}

main_menu
