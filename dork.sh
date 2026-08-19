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
    echo "       @p~qp~~qMb    | I Love Tc4dy [<3] |"
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
    echo "[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]"
    echo "                            MR. DORK                               "
    echo "            The Advanced Dork Search Engine for Analysts          "
    echo "                                                                              "
    echo "                        Developer: @tc4dy                                                   "
    echo "                                            "
    echo "  Total Dorks: 302  Google Dorks                                        "
    echo "  Categories: 52                                                         "
    echo "[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]"
    echo -e "\033[0m"
    echo -e "\033[33;1m[!] ETHICAL USE WARNING: This tool is for educational and legal testing only!\033[0m"
    echo -e "\033[31;1m[!] Unauthorized system access is illegal and can have serious consequences!\033[0m"
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
    echo "[+] STATS: Total Searches: $TOTAL | Favorites: $FAVS"
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
    echo -e "\033[35;1m[*] CATEGORIES [+]\n\033[0m"
    echo "1.  [*] PDF Documents"
    echo "2.  [&] Excel & Spreadsheets"
    echo "3.  [#] Word Documents"
    echo "4.  [$] Database Files"
    echo "5.  [+] Log Files"
    echo "6.  [%] Backup Files"
    echo "7.  [!] Admin Panels"
    echo "8.  [@] Login Pages"
    echo "9.  [?] phpMyAdmin"
    echo "10. [>] cPanel & WHM"
    echo "11. [<] Open Directories"
    echo "12. [/] Upload Directories"
    echo "13. [=] Config Directories"
    echo "14. [#] Passwords"
    echo "15. [$] API Keys"
    echo "16. [&] Config Files"
    echo "17. [+] IoT & Camera Feeds"
    echo "18. [*] Public Analytics & Stats"
    echo "19. [@] Git & Version Control"
    echo "20. [?] Geo-location & Maps"
    echo "21. [>] Network Devices"
    echo "22. [#] VPN & Proxy Configs"
    echo "23. [*] Email & Communication"
    echo "24. [+] E-commerce"
    echo "25. [?] Healthcare & Medical"
    echo "26. [$] File Sharing & Cloud Storage"
    echo "27. [&] Education & Academic"
    echo "28. [!] SCADA & Industrial Control"
    echo "29. [*] News & Media"
    echo "30. [%] Developer & Debugging"
    echo "31. [?] OSINT & People Search"
    echo "32. [@] Financial & Banking"
    echo "33. [+] API Endpoints & Swagger"
    echo "34. [!] Security & Vulnerability"
    echo "35. [&] Archives & Compressed Files"
    echo "36. [#] Mobile Apps & Configs"
    echo "37. [@] Source Code & Repositories"
    echo "38. [*] Server Status Pages"
    echo "39. [+] Dashboard & Monitoring"
    echo "40. [>] Network Shares & NAS"
    echo "41. [&] Corporate & Business"
    echo "42. [#] Legal & Compliance"
    echo "43. [%] Construction & Engineering"
    echo "44. [$] Automotive & Vehicles"
    echo "45. [*] Hospitality & Travel"
    echo "46. [!] Gaming & Entertainment"
    echo "47. [?] Libraries & Publishing"
    echo "48. [@] Government & Public Sector"
    echo "49. [+] Agriculture & Environment"
    echo "50. [&] Pharmaceuticals & Drugs"
    echo "51. [#] Science & Research"
    echo "52. [%] Real Estate & Property"
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
        28) echo "intitle:SCADA|SCADA|SCADA interfaces|intitle:SCADA"
            echo "intitle:PLC|PLC|PLC panels|intitle:PLC"
            echo "intitle:HMI|HMI|HMI interfaces|intitle:HMI"
            echo "intitle:Wonderware|Wonderware|Wonderware|intitle:Wonderware"
            echo "intitle:Siemens inurl:web|Siemens|Siemens controllers|intitle:Siemens inurl:web"
            echo "intitle:Rockwell inurl:web|Rockwell|Rockwell|intitle:Rockwell inurl:web"
            echo "intitle:Modbus|Modbus|Modbus devices|intitle:Modbus"
            echo "intitle:OPC|OPC|OPC servers|intitle:OPC"
            echo "intitle:Citect|Citect|Citect SCADA|intitle:Citect"
            echo "intitle:Proficy|GE Proficy|GE Proficy|intitle:Proficy";;
        29) echo "inurl:wp-json/wp/v2/posts|WordPress News|WordPress posts|inurl:wp-json/wp/v2/posts"
            echo "filetype:rss|RSS Feed|RSS feeds|filetype:rss"
            echo "filetype:atom|Atom Feed|Atom feeds|filetype:atom"
            echo "inurl:sitemap.xml|Sitemap|XML sitemaps|inurl:sitemap.xml"
            echo "intext:'newsapi.org'|News API|News API keys|intext:'newsapi.org'"
            echo "site:cnn.com inurl:news|CNN|CNN news|site:cnn.com inurl:news"
            echo "site:bbc.com inurl:news|BBC|BBC news|site:bbc.com inurl:news"
            echo "site:reuters.com inurl:article|Reuters|Reuters|site:reuters.com inurl:article"
            echo "site:apnews.com|AP News|AP News|site:apnews.com"
            echo "site:aljazeera.com|Al Jazeera|Al Jazeera|site:aljazeera.com";;
        30) echo "filetype:php intext:'phpinfo()'|PHPInfo|PHP info pages|filetype:php intext:'phpinfo()'"
            echo "intitle:'Debug Bar'|Debug Bar|Debug bars|intitle:'Debug Bar'"
            echo "inurl:_debugbar|Laravel Debug|Laravel debug|inurl:_debugbar"
            echo "inurl:debug_toolbar|Django Debug|Django debug|inurl:debug_toolbar"
            echo "inurl:debug/|Flask Debug|Flask debug|inurl:debug/"
            echo "inurl:actuator|Spring Boot Actuator|Spring Boot|inurl:actuator"
            echo "inurl:trace.axd|ASP.NET Trace|ASP.NET trace|inurl:trace.axd"
            echo "inurl:elasticsearch/_nodes|ElasticSearch|ElasticSearch nodes|inurl:elasticsearch/_nodes"
            echo "intitle:Kibana|Kibana|Kibana dashboards|intitle:Kibana"
            echo "intitle:Grafana|Grafana|Grafana dashboards|intitle:Grafana";;
        31) echo "site:linkedin.com/in/|LinkedIn|LinkedIn profiles|site:linkedin.com/in/"
            echo "site:twitter.com inurl:status|Twitter|Tweets|site:twitter.com inurl:status"
            echo "site:facebook.com inurl:profile.php|Facebook|FB profiles|site:facebook.com inurl:profile.php"
            echo "site:instagram.com/p/|Instagram|Instagram posts|site:instagram.com/p/"
            echo "site:github.com inurl:repositories|GitHub|GitHub repos|site:github.com inurl:repositories"
            echo "site:reddit.com inurl:comments|Reddit|Reddit comments|site:reddit.com inurl:comments"
            echo "site:youtube.com inurl:watch|YouTube|YouTube videos|site:youtube.com inurl:watch"
            echo "site:tiktok.com inurl:video|TikTok|TikTok videos|site:tiktok.com inurl:video"
            echo "site:t.me|Telegram|Telegram channels|site:t.me"
            echo "site:discord.com/channels|Discord|Discord invites|site:discord.com/channels";;
        32) echo "inurl:onlinebanking|Banking Login|Online banking portals|inurl:onlinebanking"
            echo "filetype:pdf intext:'credit card'|Credit Card|Credit card statements|filetype:pdf intext:'credit card'"
            echo "filetype:pdf intext:invoice|Invoice|Invoices|filetype:pdf intext:invoice"
            echo "filetype:xlsx intext:payroll|Payroll|Payroll sheets|filetype:xlsx intext:payroll"
            echo "filetype:pdf intext:'tax return'|Tax Return|Tax returns|filetype:pdf intext:'tax return'"
            echo "filetype:pdf intext:'loan application'|Loan Application|Loan apps|filetype:pdf intext:'loan application'"
            echo "filetype:pdf intext:'bank statement'|Bank Statement|Bank statements|filetype:pdf intext:'bank statement'"
            echo "filetype:pdf intext:investment|Investment|Investment docs|filetype:pdf intext:investment"
            echo "inurl:paypal.com|PayPal|PayPal links|inurl:paypal.com"
            echo "inurl:stripe.com|Stripe|Stripe links|inurl:stripe.com";;
        33) echo "inurl:swagger-ui.html|Swagger UI|Swagger interfaces|inurl:swagger-ui.html"
            echo "filetype:json intext:'swagger'|OpenAPI JSON|OpenAPI specs|filetype:json intext:'swagger'"
            echo "inurl:api/docs|API Docs|API documentation|inurl:api/docs"
            echo "filetype:json intext:'postman'|Postman Collection|Postman collections|filetype:json intext:'postman'"
            echo "inurl:graphql|GraphQL|GraphQL endpoints|inurl:graphql"
            echo "inurl:api/|REST API|REST API endpoints|inurl:api/"
            echo "intext:'application/json' inurl:api|JSON API|JSON APIs|intext:'application/json' inurl:api"
            echo "intext:'application/xml' inurl:api|XML API|XML APIs|intext:'application/xml' inurl:api"
            echo "inurl:wsdl|SOAP|SOAP WSDL|inurl:wsdl"
            echo "inurl:odata|OData|OData endpoints|inurl:odata";;
        34) echo "filetype:txt intext:CVE-202|CVE List|CVE files|filetype:txt intext:CVE-202"
            echo "filetype:pdf intext:Nessus|Nessus Report|Nessus reports|filetype:pdf intext:Nessus"
            echo "filetype:pdf intext:OpenVAS|OpenVAS Report|OpenVAS reports|filetype:pdf intext:OpenVAS"
            echo "inurl:burp|Burp Suite|Burp Suite reports|inurl:burp"
            echo "filetype:pdf intext:OWASP|OWASP|OWASP docs|filetype:pdf intext:OWASP"
            echo "filetype:pdf intext:'penetration test'|Penetration Test|Pentest reports|filetype:pdf intext:'penetration test'"
            echo "filetype:pdf intext:'vulnerability scan'|Vulnerability Scan|Vuln scans|filetype:pdf intext:'vulnerability scan'"
            echo "filetype:pdf intext:'security audit'|Security Audit|Audit reports|filetype:pdf intext:'security audit'"
            echo "filetype:txt intext:exploit|Exploit|Exploit code|filetype:txt intext:exploit"
            echo "filetype:txt intext:'Proof of Concept'|Proof of Concept|PoC files|filetype:txt intext:'Proof of Concept'";;
        35) echo "filetype:zip|ZIP Archive|ZIP files|filetype:zip"
            echo "filetype:rar|RAR Archive|RAR files|filetype:rar"
            echo "filetype:7z|7Z Archive|7Z files|filetype:7z"
            echo "filetype:gz|GZ Archive|GZ files|filetype:gz"
            echo "filetype:bz2|BZ2 Archive|BZ2 files|filetype:bz2"
            echo "filetype:tar.gz|TAR.GZ Archive|TAR.GZ files|filetype:tar.gz"
            echo "filetype:iso|ISO Image|ISO files|filetype:iso"
            echo "filetype:img|IMG Image|IMG files|filetype:img";;
        36) echo "filetype:apk|Android APK|Android apps|filetype:apk"
            echo "filetype:ipa|iOS IPA|iOS apps|filetype:ipa"
            echo "filetype:plist|iOS Plist|iOS configs|filetype:plist"
            echo "filetype:xml intext:manifest|Android Manifest|Android config|filetype:xml intext:manifest"
            echo "inurl:apple-app-site-association|Apple App Site|Apple association|inurl:apple-app-site-association"
            echo "inurl:.well-known/assetlinks.json|Android Asset Links|Android links|inurl:.well-known/assetlinks.json"
            echo "filetype:mobileconfig|Mobile Config|Mobile configs|filetype:mobileconfig"
            echo "filetype:ps1|PowerShell Script|PowerShell|filetype:ps1";;
        37) echo "filetype:java|Java Source|Java files|filetype:java"
            echo "filetype:py|Python Source|Python files|filetype:py"
            echo "filetype:js|JavaScript Source|JS files|filetype:js"
            echo "filetype:ts|TypeScript Source|TS files|filetype:ts"
            echo "filetype:go|Go Source|Go files|filetype:go"
            echo "filetype:rs|Rust Source|Rust files|filetype:rs"
            echo "filetype:swift|Swift Source|Swift files|filetype:swift"
            echo "filetype:rb|Ruby Source|Ruby files|filetype:rb";;
        38) echo "intitle:'Server Status'|Server Status|Server status pages|intitle:'Server Status'"
            echo "intitle:'Apache Status'|Apache Status|Apache status|intitle:'Apache Status'"
            echo "intitle:'Nginx Status'|Nginx Status|Nginx status|intitle:'Nginx Status'"
            echo "inurl:server-status|Server Status URL|Server status|inurl:server-status"
            echo "inurl:php-status|PHP Status|PHP status|inurl:php-status"
            echo "inurl:/proc/meminfo|Memory Info|Memory info|inurl:/proc/meminfo"
            echo "inurl:/proc/cpuinfo|CPU Info|CPU info|inurl:/proc/cpuinfo"
            echo "inurl:/etc/passwd|Passwd File|Passwd file|inurl:/etc/passwd";;
        39) echo "intitle:'Dashboard'|Dashboard|Dashboard pages|intitle:'Dashboard'"
            echo "intitle:'Monitoring'|Monitoring|Monitoring pages|intitle:'Monitoring'"
            echo "inurl:dashboard|Dashboard URL|Dashboard|inurl:dashboard"
            echo "inurl:monitoring|Monitoring URL|Monitoring|inurl:monitoring"
            echo "inurl:grafana|Grafana URL|Grafana|inurl:grafana"
            echo "inurl:kibana|Kibana URL|Kibana|inurl:kibana"
            echo "inurl:prometheus|Prometheus URL|Prometheus|inurl:prometheus"
            echo "inurl:zabbix|Zabbix URL|Zabbix|inurl:zabbix";;
        40) echo "inurl:smb|SMB Share|SMB shares|inurl:smb"
            echo "inurl:nfs|NFS Share|NFS shares|inurl:nfs"
            echo "inurl:nas|NAS Device|NAS devices|inurl:nas"
            echo "intitle:'Network Share'|Network Share|Network shares|intitle:'Network Share'"
            echo "inurl:shared|Shared Folder|Shared folders|inurl:shared"
            echo "inurl:public|Public Share|Public shares|inurl:public"
            echo "inurl:ftp|FTP Server|FTP servers|inurl:ftp"
            echo "inurl:sftp|SFTP Server|SFTP servers|inurl:sftp";;
        41) echo "filetype:pdf intext:'business plan'|Business Plan|Business plans|filetype:pdf intext:'business plan'"
            echo "filetype:pdf intext:'financial report'|Financial Report|Financial reports|filetype:pdf intext:'financial report'"
            echo "filetype:pdf intext:'annual report'|Annual Report|Annual reports|filetype:pdf intext:'annual report'"
            echo "filetype:pdf intext:'corporate'|Corporate|Corporate docs|filetype:pdf intext:'corporate'"
            echo "filetype:pdf intext:'strategy'|Strategy|Strategy docs|filetype:pdf intext:'strategy'"
            echo "filetype:pdf intext:'presentation'|Presentation|Presentations|filetype:pdf intext:'presentation'"
            echo "filetype:pdf intext:'organization'|Organization|Organization charts|filetype:pdf intext:'organization'"
            echo "filetype:pdf intext:'memorandum'|Memorandum|Memorandum docs|filetype:pdf intext:'memorandum'";;
        42) echo "filetype:pdf intext:'contract'|Contract|Contract documents|filetype:pdf intext:'contract'"
            echo "filetype:pdf intext:'agreement'|Agreement|Agreement docs|filetype:pdf intext:'agreement'"
            echo "filetype:pdf intext:'terms and conditions'|Terms and Conditions|T&C docs|filetype:pdf intext:'terms and conditions'"
            echo "filetype:pdf intext:'privacy policy'|Privacy Policy|Privacy docs|filetype:pdf intext:'privacy policy'"
            echo "filetype:pdf intext:'compliance'|Compliance|Compliance docs|filetype:pdf intext:'compliance'"
            echo "filetype:pdf intext:'regulatory'|Regulatory|Regulatory docs|filetype:pdf intext:'regulatory'"
            echo "filetype:pdf intext:'legal'|Legal|Legal docs|filetype:pdf intext:'legal'"
            echo "filetype:pdf intext:'lawsuit'|Lawsuit|Lawsuit docs|filetype:pdf intext:'lawsuit'";;
        43) echo "filetype:pdf intext:'construction'|Construction|Construction docs|filetype:pdf intext:'construction'"
            echo "filetype:pdf intext:'engineering'|Engineering|Engineering docs|filetype:pdf intext:'engineering'"
            echo "filetype:pdf intext:'blueprint'|Blueprint|Blueprints|filetype:pdf intext:'blueprint'"
            echo "filetype:pdf intext:'floor plan'|Floor Plan|Floor plans|filetype:pdf intext:'floor plan'"
            echo "filetype:pdf intext:'architect'|Architect|Architect docs|filetype:pdf intext:'architect'"
            echo "filetype:pdf intext:'structural'|Structural|Structural docs|filetype:pdf intext:'structural'"
            echo "filetype:pdf intext:'building'|Building|Building docs|filetype:pdf intext:'building'"
            echo "filetype:pdf intext:'renovation'|Renovation|Renovation docs|filetype:pdf intext:'renovation'";;
        44) echo "filetype:pdf intext:'car'|Car|Car docs|filetype:pdf intext:'car'"
            echo "filetype:pdf intext:'automotive'|Automotive|Automotive docs|filetype:pdf intext:'automotive'"
            echo "filetype:pdf intext:'vehicle'|Vehicle|Vehicle docs|filetype:pdf intext:'vehicle'"
            echo "filetype:pdf intext:'owner manual'|Owner Manual|Owner manuals|filetype:pdf intext:'owner manual'"
            echo "filetype:pdf intext:'service manual'|Service Manual|Service manuals|filetype:pdf intext:'service manual'"
            echo "filetype:pdf intext:'repair'|Repair|Repair docs|filetype:pdf intext:'repair'"
            echo "filetype:pdf intext:'engine'|Engine|Engine docs|filetype:pdf intext:'engine'"
            echo "filetype:pdf intext:'transmission'|Transmission|Transmission docs|filetype:pdf intext:'transmission'";;
        45) echo "filetype:pdf intext:'hotel'|Hotel|Hotel docs|filetype:pdf intext:'hotel'"
            echo "filetype:pdf intext:'resort'|Resort|Resort docs|filetype:pdf intext:'resort'"
            echo "filetype:pdf intext:'travel'|Travel|Travel docs|filetype:pdf intext:'travel'"
            echo "filetype:pdf intext:'booking'|Booking|Booking docs|filetype:pdf intext:'booking'"
            echo "filetype:pdf intext:'reservation'|Reservation|Reservation docs|filetype:pdf intext:'reservation'"
            echo "filetype:pdf intext:'guest'|Guest|Guest docs|filetype:pdf intext:'guest'"
            echo "filetype:pdf intext:'hospitality'|Hospitality|Hospitality docs|filetype:pdf intext:'hospitality'"
            echo "filetype:pdf intext:'tourist'|Tourist|Tourist docs|filetype:pdf intext:'tourist'";;
        46) echo "filetype:pdf intext:'game'|Game|Game docs|filetype:pdf intext:'game'"
            echo "filetype:pdf intext:'gaming'|Gaming|Gaming docs|filetype:pdf intext:'gaming'"
            echo "filetype:pdf intext:'entertainment'|Entertainment|Entertainment docs|filetype:pdf intext:'entertainment'"
            echo "filetype:pdf intext:'esports'|Esports|Esports docs|filetype:pdf intext:'esports'"
            echo "filetype:pdf intext:'playstation'|PlayStation|PlayStation docs|filetype:pdf intext:'playstation'"
            echo "filetype:pdf intext:'xbox'|Xbox|Xbox docs|filetype:pdf intext:'xbox'"
            echo "filetype:pdf intext:'nintendo'|Nintendo|Nintendo docs|filetype:pdf intext:'nintendo'"
            echo "filetype:pdf intext:'steam'|Steam|Steam docs|filetype:pdf intext:'steam'";;
        47) echo "filetype:pdf intext:'library'|Library|Library docs|filetype:pdf intext:'library'"
            echo "filetype:pdf intext:'publishing'|Publishing|Publishing docs|filetype:pdf intext:'publishing'"
            echo "filetype:pdf intext:'book'|Book|Book docs|filetype:pdf intext:'book'"
            echo "filetype:pdf intext:'journal'|Journal|Journal docs|filetype:pdf intext:'journal'"
            echo "filetype:pdf intext:'article'|Article|Article docs|filetype:pdf intext:'article'"
            echo "filetype:pdf intext:'publication'|Publication|Publication docs|filetype:pdf intext:'publication'"
            echo "filetype:pdf intext:'manuscript'|Manuscript|Manuscript docs|filetype:pdf intext:'manuscript'"
            echo "filetype:pdf intext:'periodical'|Periodical|Periodical docs|filetype:pdf intext:'periodical'";;
        48) echo "site:gov intext:'confidential'|Government|Government docs|site:gov intext:'confidential'"
            echo "site:gov filetype:pdf|Gov PDF|Government PDFs|site:gov filetype:pdf"
            echo "site:gov inurl:public|Public Records|Public records|site:gov inurl:public"
            echo "site:gov intext:'security'|Security|Security docs|site:gov intext:'security'"
            echo "site:gov intext:'defense'|Defense|Defense docs|site:gov intext:'defense'"
            echo "site:gov intext:'policy'|Policy|Policy docs|site:gov intext:'policy'"
            echo "site:gov intext:'regulation'|Regulation|Regulation docs|site:gov intext:'regulation'"
            echo "site:gov intext:'report'|Report|Government reports|site:gov intext:'report'";;
        49) echo "filetype:pdf intext:'agriculture'|Agriculture|Agriculture docs|filetype:pdf intext:'agriculture'"
            echo "filetype:pdf intext:'farming'|Farming|Farming docs|filetype:pdf intext:'farming'"
            echo "filetype:pdf intext:'environment'|Environment|Environment docs|filetype:pdf intext:'environment'"
            echo "filetype:pdf intext:'climate'|Climate|Climate docs|filetype:pdf intext:'climate'"
            echo "filetype:pdf intext:'sustainability'|Sustainability|Sustainability docs|filetype:pdf intext:'sustainability'"
            echo "filetype:pdf intext:'crop'|Crop|Crop docs|filetype:pdf intext:'crop'"
            echo "filetype:pdf intext:'livestock'|Livestock|Livestock docs|filetype:pdf intext:'livestock'"
            echo "filetype:pdf intext:'irrigation'|Irrigation|Irrigation docs|filetype:pdf intext:'irrigation'";;
        50) echo "filetype:pdf intext:'pharmaceutical'|Pharmaceutical|Pharmaceutical docs|filetype:pdf intext:'pharmaceutical'"
            echo "filetype:pdf intext:'drug'|Drug|Drug docs|filetype:pdf intext:'drug'"
            echo "filetype:pdf intext:'medicine'|Medicine|Medicine docs|filetype:pdf intext:'medicine'"
            echo "filetype:pdf intext:'clinical trial'|Clinical Trial|Clinical trial docs|filetype:pdf intext:'clinical trial'"
            echo "filetype:pdf intext:'prescription'|Prescription|Prescription docs|filetype:pdf intext:'prescription'"
            echo "filetype:pdf intext:'pharmacy'|Pharmacy|Pharmacy docs|filetype:pdf intext:'pharmacy'"
            echo "filetype:pdf intext:'vaccine'|Vaccine|Vaccine docs|filetype:pdf intext:'vaccine'"
            echo "filetype:pdf intext:'dosage'|Dosage|Dosage docs|filetype:pdf intext:'dosage'";;
        51) echo "filetype:pdf intext:'science'|Science|Science docs|filetype:pdf intext:'science'"
            echo "filetype:pdf intext:'research'|Research|Research docs|filetype:pdf intext:'research'"
            echo "filetype:pdf intext:'experiment'|Experiment|Experiment docs|filetype:pdf intext:'experiment'"
            echo "filetype:pdf intext:'laboratory'|Laboratory|Lab docs|filetype:pdf intext:'laboratory'"
            echo "filetype:pdf intext:'physics'|Physics|Physics docs|filetype:pdf intext:'physics'"
            echo "filetype:pdf intext:'chemistry'|Chemistry|Chemistry docs|filetype:pdf intext:'chemistry'"
            echo "filetype:pdf intext:'biology'|Biology|Biology docs|filetype:pdf intext:'biology'"
            echo "filetype:pdf intext:'astronomy'|Astronomy|Astronomy docs|filetype:pdf intext:'astronomy'";;
        52) echo "filetype:pdf intext:'real estate'|Real Estate|Real estate docs|filetype:pdf intext:'real estate'"
            echo "filetype:pdf intext:'property'|Property|Property docs|filetype:pdf intext:'property'"
            echo "filetype:pdf intext:'rental'|Rental|Rental docs|filetype:pdf intext:'rental'"
            echo "filetype:pdf intext:'mortgage'|Mortgage|Mortgage docs|filetype:pdf intext:'mortgage'"
            echo "filetype:pdf intext:'appraisal'|Appraisal|Appraisal docs|filetype:pdf intext:'appraisal'"
            echo "filetype:pdf intext:'listing'|Listing|Property listings|filetype:pdf intext:'listing'"
            echo "filetype:pdf intext:'broker'|Broker|Broker docs|filetype:pdf intext:'broker'"
            echo "filetype:pdf intext:'lease'|Lease|Lease docs|filetype:pdf intext:'lease'";;
    esac
}

execute_dork() {
    IFS='|' read -r QUERY NAME DESC EXAMPLE <<< "$1"
    
    clear
    echo -e "\033[35;1m[+] EXECUTING: $NAME\033[0m"
    echo "[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]"
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
    echo -e "\033[37;1m1. [*] Open in Browser\033[0m"
    echo -e "\033[37;1m2. [$] Save to Favorites\033[0m"
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
        echo "[-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-]"
        show_categories
        
        echo -n -e "\n\033[34;1mSelect category (or 0): \033[0m"
        read CAT_CHOICE
        
        [ "$CAT_CHOICE" = "0" ] && break
        
        if [ "$CAT_CHOICE" -ge 1 ] && [ "$CAT_CHOICE" -le 52 ] 2>/dev/null; then
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
        CAT_NAMES=("PDF Documents" "Excel & Spreadsheets" "Word Documents" "Database Files" "Log Files" "Backup Files" "Admin Panels" "Login Pages" "phpMyAdmin" "cPanel & WHM" "Open Directories" "Upload Directories" "Config Directories" "Passwords" "API Keys" "Config Files" "IoT & Camera Feeds" "Public Analytics & Stats" "Git & Version Control" "Geo-location & Maps" "Network Devices" "VPN & Proxy Configs" "Email & Communication" "E-commerce" "Healthcare & Medical" "File Sharing & Cloud Storage" "Education & Academic" "SCADA & Industrial Control" "News & Media" "Developer & Debugging" "OSINT & People Search" "Financial & Banking" "API Endpoints & Swagger" "Security & Vulnerability" "Archives & Compressed Files" "Mobile Apps & Configs" "Source Code & Repositories" "Server Status Pages" "Dashboard & Monitoring" "Network Shares & NAS" "Corporate & Business" "Legal & Compliance" "Construction & Engineering" "Automotive & Vehicles" "Hospitality & Travel" "Gaming & Entertainment" "Libraries & Publishing" "Government & Public Sector" "Agriculture & Environment" "Pharmaceuticals & Drugs" "Science & Research" "Real Estate & Property")
        CATEGORY_NAME="${CAT_NAMES[$((CAT_NUM-1))]}"
        
        echo -e "\033[35;1m[*] CATEGORY: $CATEGORY_NAME\033[0m"
        echo "[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]"
        
        IFS=$'\n'
        IDX=1
        for DORK in $DORKS; do
            IFS='|' read -r Q N D E <<< "$DORK"
            echo -e "\033[32;1m$IDX. $N\033[0m"
            echo "   \033[34;1mDescription: $D\033[0m"
            echo "   \033[36;1mDork: $Q\033[0m"
            echo "[-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-]"
            IDX=$((IDX+1))
        done
        
        echo -e "\033[33;1m[+] Type 'all' to run EVERY dork in this category (sequential)\033[0m"
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
                echo -e "\033[32;1m[+] All $DORK_COUNT dorks executed!\033[0m"
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
    echo -e "\033[35;1m[?] GLOBAL SEARCH\033[0m"
    echo -n -e "\033[34;1mEnter search term: \033[0m"
    read KEYWORD
    
    RESULTS=""
    for CAT in $(seq 1 52); do
        DORKS=$(get_dorks_by_category $CAT)
        IFS=$'\n'
        for DORK in $DORKS; do
            IFS='|' read -r Q N D E <<< "$DORK"
            if echo "$N $Q $D" | grep -iq "$KEYWORD"; then
                CAT_NAMES=("PDF Documents" "Excel & Spreadsheets" "Word Documents" "Database Files" "Log Files" "Backup Files" "Admin Panels" "Login Pages" "phpMyAdmin" "cPanel & WHM" "Open Directories" "Upload Directories" "Config Directories" "Passwords" "API Keys" "Config Files" "IoT & Camera Feeds" "Public Analytics & Stats" "Git & Version Control" "Geo-location & Maps" "Network Devices" "VPN & Proxy Configs" "Email & Communication" "E-commerce" "Healthcare & Medical" "File Sharing & Cloud Storage" "Education & Academic" "SCADA & Industrial Control" "News & Media" "Developer & Debugging" "OSINT & People Search" "Financial & Banking" "API Endpoints & Swagger" "Security & Vulnerability" "Archives & Compressed Files" "Mobile Apps & Configs" "Source Code & Repositories" "Server Status Pages" "Dashboard & Monitoring" "Network Shares & NAS" "Corporate & Business" "Legal & Compliance" "Construction & Engineering" "Automotive & Vehicles" "Hospitality & Travel" "Gaming & Entertainment" "Libraries & Publishing" "Government & Public Sector" "Agriculture & Environment" "Pharmaceuticals & Drugs" "Science & Research" "Real Estate & Property")
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
        echo -e "\033[35;1m[?] SEARCH RESULTS for '$KEYWORD'\033[0m"
        echo "[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]"
        
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
        echo -e "\033[35;1m[$] FAVORITE DORKS\033[0m"
        echo "[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]"
        
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
    echo -e "\033[35;1m[&] SEARCH HISTORY\033[0m"
    echo "[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]"
    
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
        echo -e "\033[35;1m[%] CUSTOM DORKS\033[0m"
        echo "[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]"
        echo -e "\033[37;1m1. [+] Add Custom Dork\033[0m"
        echo -e "\033[37;1m2. [*] View Custom Dorks\033[0m"
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
            echo -e "\033[35;1m[*] YOUR CUSTOM DORKS\033[0m"
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
        echo "[-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-]"
        echo -e "\033[37;1m1. [*] Browse Categories\033[0m"
        echo -e "\033[37;1m2. [?] Search Dorks\033[0m"
        echo -e "\033[37;1m3. [$] View Favorites\033[0m"
        echo -e "\033[37;1m4. [&] Search History\033[0m"
        echo -e "\033[37;1m5. [%] Custom Dorks\033[0m"
        echo -e "\033[37;1m0. [!] Exit\033[0m"
        echo "[-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-]"
        
        echo -n -e "\n\033[34;1mSelect an option: \033[0m"
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
