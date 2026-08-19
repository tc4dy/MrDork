DATABASE="mr_dork.db"

init_db() {
    sqlite3 "$DATABASE" "CREATE TABLE IF NOT EXISTS favorites(id INTEGER PRIMARY KEY AUTOINCREMENT, category TEXT, name TEXT, query TEXT, example TEXT, description TEXT, date TIMESTAMP);" 2>/dev/null
    sqlite3 "$DATABASE" "CREATE TABLE IF NOT EXISTS history(id INTEGER PRIMARY KEY AUTOINCREMENT, query TEXT, category TEXT, date TIMESTAMP);" 2>/dev/null
    sqlite3 "$DATABASE" "CREATE TABLE IF NOT EXISTS custom(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, query TEXT, description TEXT, date TIMESTAMP);" 2>/dev/null
    sqlite3 "$DATABASE" "CREATE TABLE IF NOT EXISTS stats(id INTEGER PRIMARY KEY, total_searches INTEGER, fav_count INTEGER, last_date TIMESTAMP);" 2>/dev/null
    sqlite3 "$DATABASE" "INSERT OR IGNORE INTO stats(id, total_searches, fav_count) VALUES(1, 0, 0);" 2>/dev/null
}

update_stats() {
    total=$(sqlite3 "$DATABASE" "SELECT COUNT(*) FROM history;" 2>/dev/null)
    favs=$(sqlite3 "$DATABASE" "SELECT COUNT(*) FROM favorites;" 2>/dev/null)
    sqlite3 "$DATABASE" "UPDATE stats SET total_searches=$total, fav_count=$favs, last_date=datetime('now') WHERE id=1;" 2>/dev/null
}

open_url() {
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$1" >/dev/null 2>&1 &
    elif command -v open >/dev/null 2>&1; then
        open "$1" >/dev/null 2>&1 &
    elif command -v start >/dev/null 2>&1; then
        start "$1" >/dev/null 2>&1 &
    else
        echo "Cannot open browser. Manual URL: $1"
    fi
}

print_logo() {
    clear
    echo -e "\033[36;1m"
    echo '         _nnnn_                      '
    echo '        dGGGGMMb     ,""""""""""""""".'
    echo '       @p~qp~~qMb    | I Love Tc4dy [<3] |'
    echo '       M|@||@) M|   _;..............'
    echo '       @,----.JM| -'
    echo '      JS^\__/  qKL'
    echo '     dZP        qKRb'
    echo '    dZP          qKKb'
    echo '   fZP            SMMb'
    echo '   HZM            MMMM'
    echo '   FqM            MMMM'
    echo ' __| ".        |\dS"qML'
    echo ' |    `.       | `'"'"' \Zq'
    echo '_)      \.___,|     .'
    echo '\____   )MMMMMM|   .'
    echo '     `-'"'"'       `--'"'"''
    echo -e "\033[0m"
    echo -e "\033[36;1m"
    echo "[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]"
    echo "                            MR. DORK                               "
    echo "            The Advanced Dork Search Engine for Analysts          "
    echo "                                                                              "
    echo "                        Developer: @tc4dy                                       "
    echo "                                            "
    echo "  Total Dorks: 448  Google Dorks                                        "
    echo "  Categories: 28                                                         "
    echo "[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]"
    echo -e "\033[0m"
    echo -e "\033[33;1m[!] ETHICAL USE WARNING: This tool is for educational and legal testing only!\033[0m"
    echo -e "\033[31;1m[!] Unauthorized system access is illegal and can have serious consequences!\033[0m"
    echo ""
}

get_dorks_by_category() {
    case $1 in
        1) cat << EOF
filetype:pdf|PDF General|Find all PDF files|filetype:pdf site:edu.tr
filetype:pdf intext:confidential|PDF Confidential|Secret documents|filetype:pdf confidential site:gov
filetype:pdf intext:budget|PDF Budget|Budget reports|filetype:pdf budget 2024
filetype:pdf intext:contract|PDF Contract|Legal contracts|filetype:pdf contract
filetype:pdf intext:report|PDF Report|Annual reports|filetype:pdf report
filetype:pdf intext:invoice|PDF Invoice|Invoice documents|filetype:pdf invoice
filetype:pdf intext:technical|PDF Technical|Technical manuals|filetype:pdf technical
filetype:pdf intext:thesis|PDF Thesis|Academic thesis|filetype:pdf thesis site:edu
EOF
;;
        2) cat << EOF
filetype:xls|Excel XLS|Old Excel files|filetype:xls
filetype:xlsx|Excel XLSX|Modern Excel|filetype:xlsx
filetype:xlsx intext:salary|Salary Sheet|Payroll data|filetype:xlsx salary
filetype:xlsx intext:customer|Customer List|Client database|filetype:xlsx customer
filetype:xls intext:financial|Financial Data|Finance sheets|filetype:xls financial
filetype:csv|CSV Data|Comma separated|filetype:csv
filetype:xlsx intext:statistics|Statistics|Statistical data|filetype:xlsx statistics
filetype:xls intext:inventory|Inventory List|Stock data|filetype:xls inventory
EOF
;;
        3) cat << EOF
filetype:doc|Word DOC|Old Word format|filetype:doc
filetype:docx|Word DOCX|Modern Word|filetype:docx
filetype:docx intext:confidential|Confidential Doc|Secret documents|filetype:docx confidential
filetype:doc intext:memo|Memo|Office memos|filetype:doc memo
filetype:docx intext:resume|Resume|CV documents|filetype:docx resume
filetype:doc intext:meeting|Meeting Notes|Minutes|filetype:doc meeting
filetype:docx intext:policy|Policy Doc|Company policy|filetype:docx policy
filetype:doc intext:procedure|Procedure|SOP documents|filetype:doc procedure
EOF
;;
        4) cat << EOF
filetype:sql|SQL Dump|Database backup|filetype:sql
filetype:sql intext:mysql|MySQL Dump|MySQL backup|filetype:sql mysql
filetype:sql intext:backup|SQL Backup|Backup file|filetype:sql backup
filetype:mdb|MDB Access|Access database|filetype:mdb
filetype:db|SQLite DB|SQLite database|filetype:db
filetype:json intext:mongodb|MongoDB|NoSQL export|filetype:json mongodb
filetype:sql intext:CREATE DATABASE|DB Config|Database config|filetype:sql CREATE DATABASE
filetype:sql intext:password|DB Credentials|Passwords in SQL|filetype:sql password
EOF
;;
        5) cat << EOF
filetype:log|Log File|System logs|filetype:log
filetype:log intext:error|Error Log|Failure logs|filetype:log error
filetype:log intext:access|Access Log|Visitor logs|filetype:log access
filetype:log intext:apache|Apache Log|Web server|filetype:log apache
filetype:log intext:system|System Log|OS logs|filetype:log system
filetype:log intext:debug|Debug Log|Debug output|filetype:log debug
filetype:log intext:auth|Auth Log|Login attempts|filetype:log auth
filetype:log intext:ftp|FTP Log|File transfer|filetype:log ftp
EOF
;;
        6) cat << EOF
filetype:bak|BAK Backup|Backup file|filetype:bak
filetype:backup|BACKUP File|Generic backup|filetype:backup
filetype:zip intext:backup|ZIP Backup|Compressed backup|filetype:zip backup
filetype:tar|TAR Archive|Unix archive|filetype:tar
filetype:old|OLD File|Old version|filetype:old
intitle:index.of backup|Backup Dir|Directory listing|intitle:index.of backup
inurl:backup.zip|Site Backup|Website backup|inurl:backup.zip
inurl:backup.tar|Tar Backup|Tar site backup|inurl:backup.tar
EOF
;;
        7) cat << EOF
inurl:admin|Admin Panel|Admin page|inurl:admin
inurl:admin/login|Admin Login|Login form|inurl:admin/login
intitle:admin dashboard|Admin Dashboard|Control panel|intitle:admin dashboard
intitle:index.of admin|Admin Index|Directory listing|intitle:index.of admin
inurl:administration|Administration|Management panel|inurl:administration
intitle:admin console|Admin Console|Console panel|intitle:admin console
inurl:admin-area|Admin Area|Restricted area|inurl:admin-area
inurl:backend/admin|Backend Admin|Backend panel|inurl:backend/admin
EOF
;;
        8) cat << EOF
inurl:login|Login Page|Generic login|inurl:login
inurl:signin|Sign In|Authentication|inurl:signin
intitle:login intitle:user|User Login|User auth|intitle:login user
inurl:member/login|Member Login|Members area|inurl:member/login
inurl:auth/login|Auth Login|Authorization|inurl:auth/login
inurl:customer/login|Customer Login|Client portal|inurl:customer/login
intitle:portal login|Portal Login|User portal|intitle:portal login
inurl:secure/login|Secure Login|HTTPS login|inurl:secure/login
EOF
;;
        9) cat << EOF
inurl:phpmyadmin|phpMyAdmin|MySQL admin|inurl:phpmyadmin
intitle:phpMyAdmin|PMA Panel|Database admin|intitle:phpMyAdmin
inurl:phpmyadmin/index.php|PMA Login|Login page|inurl:phpmyadmin/index.php
intitle:phpMyAdmin MySQL|MySQL Admin|Database manager|intitle:phpMyAdmin MySQL
inurl:db/phpmyadmin|DB Admin|Database panel|inurl:db/phpmyadmin
inurl:phpmyadmin/setup|PMA Setup|Installation|inurl:phpmyadmin/setup
intitle:phpMyAdmin 4|PMA v4|Version 4|intitle:phpMyAdmin 4
intitle:adminer|Adminer|Alternative PMA|intitle:adminer
EOF
;;
        10) cat << EOF
inurl:cpanel|cPanel|Hosting panel|inurl:cpanel
intitle:cpanel login|cPanel Login|Hosting login|intitle:cpanel login
inurl:whm|WHM|Web host manager|inurl:whm
inurl:webmail|Webmail|Email interface|inurl:webmail
inurl:2083|cPanel Port|cPanel alt port|inurl:2083
intitle:plesk|Plesk|Alternative panel|intitle:plesk
intitle:directadmin|DirectAdmin|Control panel|intitle:directadmin
intitle:ispconfig|ISPConfig|Server config|intitle:ispconfig
EOF
;;
        11) cat << EOF
intitle:index.of|Index Of|Directory listing|intitle:index.of
intitle:parent.directory|Parent Directory|Parent listing|intitle:parent.directory
intitle:directory listing|Directory Listing|Folder view|intitle:directory listing
intitle:index of /|Root Index|Root directory|intitle:index of /
intitle:index.of apache|Apache Index|Apache listing|intitle:index.of apache
intitle:index.of nginx|Nginx Index|Nginx listing|intitle:index.of nginx
intitle:index.of iis|IIS Index|Windows listing|intitle:index.of iis
intitle:autoindex|Autoindex|Auto directory|intitle:autoindex
EOF
;;
        12) cat << EOF
intitle:index.of uploads|Upload Dir|Upload folder|intitle:index.of uploads
intitle:index.of files|Files Dir|Files folder|intitle:index.of files
intitle:index.of images|Images Dir|Image folder|intitle:index.of images
intitle:index.of media|Media Dir|Media folder|intitle:index.of media
intitle:index.of documents|Documents Dir|Docs folder|intitle:index.of documents
intitle:index.of downloads|Downloads Dir|Download folder|intitle:index.of downloads
intitle:index.of assets|Assets Dir|Assets folder|intitle:index.of assets
intitle:index.of public|Public Dir|Public folder|intitle:index.of public
EOF
;;
        13) cat << EOF
intitle:index.of config|Config Dir|Config folder|intitle:index.of config
intitle:index.of settings|Settings Dir|Settings folder|intitle:index.of settings
intitle:index.of conf|Conf Dir|Conf folder|intitle:index.of conf
intitle:index.of etc|etc Dir|System config|intitle:index.of etc
intitle:index.of configuration|Configuration Dir|Config listing|intitle:index.of configuration
intitle:index.of include|Include Dir|Include folder|intitle:index.of include
intitle:index.of lib|Lib Dir|Library folder|intitle:index.of lib
intitle:index.of vendor|Vendor Dir|Vendor folder|intitle:index.of vendor
EOF
;;
        14) cat << EOF
filetype:txt intext:password|Password TXT|Plain passwords|filetype:txt password
filetype:txt intext:credentials|Credentials|Login info|filetype:txt credentials
filetype:txt intext:username intext:password|Login Info|User pass combo|filetype:txt username password
filetype:txt intext:password list|Password List|Password collection|filetype:txt password list
filetype:txt intext:admin password|Admin Pass|Admin password|filetype:txt admin password
filetype:txt intext:root password|Root Pass|Root password|filetype:txt root password
filetype:txt intext:ftp password|FTP Credentials|FTP login|filetype:txt ftp password
filetype:txt intext:email password|Email Pass|Email login|filetype:txt email password
EOF
;;
        15) cat << EOF
intext:api_key|API Key|Developer key|intext:api_key
intext:apikey|API Key Alt|API credential|intext:apikey
intext:api_secret|API Secret|Secret key|intext:api_secret
intext:access_token|Access Token|Auth token|intext:access_token
intext:bearer|Bearer Token|Bearer auth|intext:bearer token
intext:aws_access_key_id|AWS Key|Amazon key|intext:aws_access_key_id
intext:AIza|Google API|Google key|intext:AIza
intext:sk_live|Stripe Key|Live Stripe|intext:sk_live
EOF
;;
        16) cat << EOF
filetype:env|ENV File|Environment vars|filetype:env
filetype:php intext:config|PHP Config|PHP config file|filetype:php config
filetype:php intext:database|DB Config|Database config|filetype:php database
filetype:php intext:wp-config|WP Config|WordPress config|filetype:php wp-config
filetype:php intext:settings|Settings PHP|PHP settings|filetype:php settings
filetype:json intext:config|JSON Config|App config|filetype:json config
filetype:yml intext:config|YAML Config|YAML config|filetype:yml config
filetype:conf intext:nginx|Nginx Config|Web server config|filetype:conf nginx
EOF
;;
    esac
}

browse_categories() {
    while true; do
        print_logo
        update_stats
        stats=$(sqlite3 "$DATABASE" "SELECT total_searches, fav_count FROM stats WHERE id=1;" 2>/dev/null)
        echo -e "\033[32;1m[+] STATS: Total Searches: $(echo $stats | cut -d'|' -f1) | Favorites: $(echo $stats | cut -d'|' -f2)\033[0m"
        echo "[-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-]"
        echo -e "\033[35;1m[*] CATEGORIES\033[0m"
        echo ""
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
        echo "0.  Back to Main Menu"
        echo ""
        echo -n -e "\033[34;1mSelect category: \033[0m"
        read cat_choice
        [ "$cat_choice" = "0" ] && break
        if [ "$cat_choice" -ge 1 ] && [ "$cat_choice" -le 16 ] 2>/dev/null; then
            view_dorks "$cat_choice"
        else
            echo -e "\033[31;1mInvalid selection!\033[0m"
            sleep 1
        fi
    done
}

view_dorks() {
    cat_num=$1
    dorks=$(get_dorks_by_category "$cat_num")
    cat_names=("PDF Documents" "Excel & Spreadsheets" "Word Documents" "Database Files" "Log Files" "Backup Files" "Admin Panels" "Login Pages" "phpMyAdmin" "cPanel & WHM" "Open Directories" "Upload Directories" "Config Directories" "Passwords" "API Keys" "Config Files")
    cat_name="${cat_names[$((cat_num-1))]}"
    dork_count=$(echo "$dorks" | wc -l)
    
    while true; do
        print_logo
        echo -e "\033[35;1m[*] CATEGORY: $cat_name\033[0m"
        echo "[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]"
        
        idx=1
        IFS=$'\n'
        for dork in $dorks; do
            IFS='|' read -r query name desc example <<< "$dork"
            echo -e "\033[32;1m$idx. $name\033[0m"
            echo "   \033[34;1mDescription: $desc\033[0m"
            echo "   \033[36;1mDork: $query\033[0m"
            echo "[-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-]"
            idx=$((idx+1))
        done
        
        echo -e "\033[33;1m[!] Type 'all' to run every dork in this category\033[0m"
        echo -e "\033[37;1m0. Back\033[0m"
        echo -n -e "\n\033[34;1mSelect dork number, 'all', or 0: \033[0m"
        read dork_choice
        
        [ "$dork_choice" = "0" ] && break
        
        if [ "$dork_choice" = "all" ]; then
            echo -n -e "\033[33;1mThis will open $dork_count searches. Type 'yes' to continue: \033[0m"
            read confirm
            if [ "$confirm" = "yes" ]; then
                echo -n -e "\033[33;1mEnter target for ALL dorks: \033[0m"
                read target
                idx=1
                IFS=$'\n'
                for dork in $dorks; do
                    IFS='|' read -r query name desc example <<< "$dork"
                    final="$query $target"
                    final=$(echo "$final" | xargs)
                    encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$final'''))" 2>/dev/null || echo "$final" | sed 's/ /%20/g')
                    echo -e "\033[32;1m[$idx/$dork_count] Opening: $name\033[0m"
                    open_url "https://www.google.com/search?q=$encoded"
                    sqlite3 "$DATABASE" "INSERT INTO history (query, category, date) VALUES ('$final', '$cat_name', datetime('now'));" 2>/dev/null
                    idx=$((idx+1))
                    sleep 0.5
                done
                update_stats
                echo -e "\033[32;1m[+] All $dork_count dorks executed!\033[0m"
                echo -n -e "\033[34;1mPress Enter to continue...\033[0m"
                read
            fi
        elif [ "$dork_choice" -ge 1 ] && [ "$dork_choice" -lt "$idx" ] 2>/dev/null; then
            selected=$(echo "$dorks" | sed -n "${dork_choice}p")
            IFS='|' read -r query name desc example <<< "$selected"
            execute_dork "$query" "$name" "$desc" "$example" "$cat_name"
        fi
    done
}

execute_dork() {
    query=$1
    name=$2
    desc=$3
    example=$4
    category=$5
    
    print_logo
    echo -e "\033[35;1m[+] EXECUTING: $name\033[0m"
    echo "[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]"
    echo -e "\033[34;1mDescription: $desc\033[0m"
    echo -e "\033[34;1mExample usage: $example\033[0m"
    echo ""
    echo -n -e "\033[33;1mEnter target (e.g. site:com or keyword): \033[0m"
    read target
    
    final_query="$query $target"
    final_query=$(echo "$final_query" | xargs)
    echo -e "\n\033[32;1mFinal Query: $final_query\033[0m"
    
    encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$final_query'''))" 2>/dev/null || echo "$final_query" | sed 's/ /%20/g')
    url="https://www.google.com/search?q=$encoded"
    
    echo ""
    echo -e "\033[37;1m1. [*] Open in Browser\033[0m"
    echo -e "\033[37;1m2. [$] Save to Favorites\033[0m"
    echo -e "\033[37;1m0. Cancel\033[0m"
    echo -n -e "\n\033[34;1mSelection: \033[0m"
    read choice
    
    case $choice in
        1)
            open_url "$url"
            sqlite3 "$DATABASE" "INSERT INTO history (query, category, date) VALUES ('$final_query', '$category', datetime('now'));" 2>/dev/null
            update_stats
            echo -e "\033[32;1m[+] Opened in browser!\033[0m"
            sleep 1
            ;;
        2)
            sqlite3 "$DATABASE" "INSERT INTO favorites (category, name, query, example, description, date) VALUES ('$category', '$name', '$final_query', '$example', '$desc', datetime('now'));" 2>/dev/null
            update_stats
            echo -e "\033[32;1m[+] Saved to favorites!\033[0m"
            sleep 1
            ;;
    esac
}

view_favorites() {
    while true; do
        print_logo
        echo -e "\033[35;1m[$] FAVORITE DORKS\033[0m"
        echo "[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]"
        
        favs=$(sqlite3 "$DATABASE" "SELECT id, category, name, query FROM favorites ORDER BY date DESC;" 2>/dev/null)
        
        if [ -z "$favs" ]; then
            echo -e "\033[31;1mYour favorites list is empty.\033[0m"
            echo -n -e "\n\033[34;1mPress Enter to return...\033[0m"
            read
            break
        fi
        
        idx=1
        IFS=$'\n'
        for fav in $favs; do
            IFS='|' read -r id category name query <<< "$fav"
            echo -e "\033[32;1m$idx. [$category] $name\033[0m"
            echo "   \033[36;1m$query\033[0m"
            idx=$((idx+1))
        done
        
        echo ""
        echo -e "\033[37;1m0. Back\033[0m"
        echo -e "\033[37;1mD. Delete All Favorites\033[0m"
        echo -n -e "\n\033[34;1mSelect to run (or 0): \033[0m"
        read fav_choice
        
        [ "$fav_choice" = "0" ] && break
        
        if [ "$fav_choice" = "D" ] || [ "$fav_choice" = "d" ]; then
            echo -n -e "\033[31;1mDelete all favorites? (yes/no): \033[0m"
            read confirm
            [ "$confirm" = "yes" ] && sqlite3 "$DATABASE" "DELETE FROM favorites;" 2>/dev/null && echo -e "\033[32;1mAll favorites deleted!\033[0m"
            sleep 1
        elif [ "$fav_choice" -ge 1 ] && [ "$fav_choice" -lt "$idx" ] 2>/dev/null; then
            selected=$(echo "$favs" | sed -n "${fav_choice}p")
            IFS='|' read -r id category name query <<< "$selected"
            encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$query'''))" 2>/dev/null || echo "$query" | sed 's/ /%20/g')
            open_url "https://www.google.com/search?q=$encoded"
            sqlite3 "$DATABASE" "INSERT INTO history (query, category, date) VALUES ('$query', '$category', datetime('now'));" 2>/dev/null
            update_stats
            echo -e "\033[32;1m[+] Opened in browser!\033[0m"
            sleep 1
        fi
    done
}

view_history() {
    print_logo
    echo -e "\033[35;1m[&] SEARCH HISTORY\033[0m"
    echo "[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]"
    
    history=$(sqlite3 "$DATABASE" "SELECT query, category, date FROM history ORDER BY date DESC LIMIT 50;" 2>/dev/null)
    
    if [ -z "$history" ]; then
        echo -e "\033[31;1mHistory is empty.\033[0m"
    else
        IFS=$'\n'
        for h in $history; do
            IFS='|' read -r query category date <<< "$h"
            echo -e "\033[34;1m[$date]\033[0m \033[32;1m$category\033[0m"
            echo "   \033[36;1m$query\033[0m"
            echo ""
        done
    fi
    
    echo "[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]"
    echo -e "\033[37;1m1. Clear History\033[0m"
    echo -e "\033[37;1m0. Back\033[0m"
    echo -n -e "\n\033[34;1mSelection: \033[0m"
    read hist_choice
    
    if [ "$hist_choice" = "1" ]; then
        sqlite3 "$DATABASE" "DELETE FROM history;" 2>/dev/null
        update_stats
        echo -e "\033[32;1mHistory cleared!\033[0m"
        sleep 1
    fi
}

custom_dorks_menu() {
    while true; do
        print_logo
        echo -e "\033[35;1m[%] CUSTOM DORKS\033[0m"
        echo "[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]"
        echo -e "\033[37;1m1. [+] Add Custom Dork\033[0m"
        echo -e "\033[37;1m2. [*] View Custom Dorks\033[0m"
        echo -e "\033[37;1m3. [-] Delete Custom Dork\033[0m"
        echo -e "\033[37;1m0. Back\033[0m"
        echo ""
        echo -n -e "\033[34;1mSelection: \033[0m"
        read choice
        
        case $choice in
            0) break ;;
            1)
                echo -n -e "\033[33;1mDork Name: \033[0m"
                read name
                echo -n -e "\033[33;1mDork Query: \033[0m"
                read query
                echo -n -e "\033[33;1mDescription: \033[0m"
                read desc
                sqlite3 "$DATABASE" "INSERT INTO custom (name, query, description, date) VALUES ('$name', '$query', '$desc', datetime('now'));" 2>/dev/null
                echo -e "\033[32;1m[+] Custom dork saved!\033[0m"
                sleep 1
                ;;
            2)
                print_logo
                echo -e "\033[35;1m[*] YOUR CUSTOM DORKS\033[0m"
                echo "[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]"
                customs=$(sqlite3 "$DATABASE" "SELECT id, name, query, description, date FROM custom ORDER BY date DESC;" 2>/dev/null)
                if [ -z "$customs" ]; then
                    echo -e "\033[31;1mNo custom dorks found.\033[0m"
                else
                    IFS=$'\n'
                    for c in $customs; do
                        IFS='|' read -r id name query desc date <<< "$c"
                        echo -e "\033[32;1m[$id] $name\033[0m"
                        echo "   \033[36;1m$query\033[0m"
                        echo "   \033[34;1m$desc\033[0m"
                        echo "   \033[33;1mAdded: $date\033[0m"
                        echo ""
                    done
                fi
                echo -n -e "\033[34;1mPress Enter to return...\033[0m"
                read
                ;;
            3)
                echo -n -e "\033[31;1mEnter custom dork ID to delete: \033[0m"
                read del_id
                sqlite3 "$DATABASE" "DELETE FROM custom WHERE id=$del_id;" 2>/dev/null
                echo -e "\033[32;1mDeleted if existed.\033[0m"
                sleep 1
                ;;
        esac
    done
}

search_global() {
    print_logo
    echo -e "\033[35;1m[?] GLOBAL SEARCH\033[0m"
    echo "[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]"
    echo -n -e "\033[34;1mEnter search term: \033[0m"
    read keyword
    
    results=""
    for cat in $(seq 1 16); do
        dorks=$(get_dorks_by_category "$cat")
        cat_names=("PDF Documents" "Excel & Spreadsheets" "Word Documents" "Database Files" "Log Files" "Backup Files" "Admin Panels" "Login Pages" "phpMyAdmin" "cPanel & WHM" "Open Directories" "Upload Directories" "Config Directories" "Passwords" "API Keys" "Config Files")
        cat_name="${cat_names[$((cat-1))]}"
        
        IFS=$'\n'
        for dork in $dorks; do
            IFS='|' read -r query name desc example <<< "$dork"
            if echo "$name $desc $query" | grep -iq "$keyword"; then
                results="$results$cat_name|$name|$query|$desc|$example\n"
            fi
        done
    done
    
    customs=$(sqlite3 "$DATABASE" "SELECT name, query, description FROM custom;" 2>/dev/null)
    if [ -n "$customs" ]; then
        IFS=$'\n'
        for c in $customs; do
            IFS='|' read -r name query desc <<< "$c"
            if echo "$name $desc $query" | grep -iq "$keyword"; then
                results="$results[CUSTOM]|$name|$query|$desc|\n"
            fi
        done
    fi
    
    if [ -z "$results" ]; then
        echo -e "\033[31;1mNo dorks found matching '$keyword'.\033[0m"
        sleep 1
        return
    fi
    
    while true; do
        print_logo
        echo -e "\033[35;1m[?] SEARCH RESULTS for '$keyword'\033[0m"
        echo "[*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*][*]"
        
        idx=1
        IFS=$'\n'
        for res in $(echo -e "$results" | head -50); do
            IFS='|' read -r cat name query desc example <<< "$res"
            echo -e "\033[32;1m$idx. [$cat] $name\033[0m"
            echo "   \033[36;1m$query\033[0m"
            idx=$((idx+1))
        done
        
        echo ""
        echo -e "\033[37;1m0. Back\033[0m"
        echo -n -e "\n\033[34;1mSelect dork to execute: \033[0m"
        read sel
        
        [ "$sel" = "0" ] && break
        
        if [ "$sel" -ge 1 ] && [ "$sel" -lt "$idx" ] 2>/dev/null; then
            selected=$(echo -e "$results" | sed -n "${sel}p")
            IFS='|' read -r cat name query desc example <<< "$selected"
            [ "$cat" = "[CUSTOM]" ] && cat="Custom Dorks"
            execute_dork "$query" "$name" "$desc" "$example" "$cat"
        fi
    done
}

main_menu() {
    while true; do
        print_logo
        update_stats
        stats=$(sqlite3 "$DATABASE" "SELECT total_searches, fav_count FROM stats WHERE id=1;" 2>/dev/null)
        echo -e "\033[32;1m[+] STATS: Total Searches: $(echo $stats | cut -d'|' -f1) | Favorites: $(echo $stats | cut -d'|' -f2)\033[0m"
        echo "[-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-]"
        echo -e "\033[37;1m1. [*] Browse Categories\033[0m"
        echo -e "\033[37;1m2. [?] Search Dorks\033[0m"
        echo -e "\033[37;1m3. [$] View Favorites\033[0m"
        echo -e "\033[37;1m4. [&] Search History\033[0m"
        echo -e "\033[37;1m5. [%] Custom Dorks\033[0m"
        echo -e "\033[37;1m0. [!] Exit\033[0m"
        echo "[-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-][-]"
        echo -n -e "\033[34;1mSelect an option: \033[0m"
        read choice
        
        case $choice in
            1) browse_categories ;;
            2) search_global ;;
            3) view_favorites ;;
            4) view_history ;;
            5) custom_dorks_menu ;;
            0) echo -e "\033[32;1m\nStay safe! Goodbye...\033[0m"; exit 0 ;;
            *) echo -e "\033[31;1mInvalid selection!\033[0m"; sleep 1 ;;
        esac
    done
}

main_menu
