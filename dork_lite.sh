# "dork.sh" Lite Version

DATABASE="mr_dork.db"

init_db() {
    sqlite3 "$DATABASE" "CREATE TABLE IF NOT EXISTS favorites(id INTEGER PRIMARY KEY, category TEXT, name TEXT, query TEXT, example TEXT, description TEXT, date TIMESTAMP);"
    sqlite3 "$DATABASE" "CREATE TABLE IF NOT EXISTS history(id INTEGER PRIMARY KEY, query TEXT, category TEXT, date TIMESTAMP);"
    sqlite3 "$DATABASE" "CREATE TABLE IF NOT EXISTS custom(id INTEGER PRIMARY KEY, name TEXT, query TEXT, desc TEXT, date TIMESTAMP);"
}

open_url() {
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$1" >/dev/null 2>&1 &
    else
        open "$1" >/dev/null 2>&1 &
    fi
}

print_logo() {
    clear
    echo -e "\033[36;1m"
    echo '         _nnnn_                      '
    echo '        dGGGGMMb     ,""""""""""""""".'
    echo '       @p~qp~~qMb    | I Love Tc4dy <3 |'
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
    echo "══════════════════════════════════════════════════════════════════════════════"
    echo "                            MR. DORK                               "
    echo "            The Advanced Dork Search Engine for Analysts          "
    echo "                                                                              "
    echo "                        Developer: @tc4dy                                       "
    echo "                                            "                                                        "
    echo "══════════════════════════════════════════════════════════════════════════════"
    echo -e "\033[0m"
    echo -e "\033[33;1m⚠️  ETHICAL USE WARNING: This tool is for educational and legal testing only!\033[0m"
    echo -e "\033[31;1m⚠️  Unauthorized system access is illegal and can have serious consequences!\033[0m"
    echo ""
}

get_dorks() {
    case $1 in
        1) echo "filetype:pdf|PDF General|Find PDF files|filetype:pdf site:edu"
           echo "filetype:pdf intext:confidential|Confidential PDF|Secret PDFs|filetype:pdf confidential"
           echo "filetype:pdf intext:report|Report PDF|Annual reports|filetype:pdf report"
           echo "filetype:pdf intext:invoice|Invoice PDF|Invoice documents|filetype:pdf invoice"
           echo "filetype:pdf intext:contract|Contract PDF|Legal contracts|filetype:pdf contract"
           echo "filetype:pdf intext:thesis|Thesis PDF|Academic theses|filetype:pdf thesis"
           echo "filetype:pdf intext:budget|Budget PDF|Budget reports|filetype:pdf budget"
           echo "filetype:pdf intext:technical|Technical PDF|Technical docs|filetype:pdf technical";;
        2) echo "filetype:xls|Excel XLS|Excel files|filetype:xls"
           echo "filetype:xlsx|Excel XLSX|Modern Excel|filetype:xlsx"
           echo "filetype:xlsx intext:salary|Salary Sheet|Payroll data|filetype:xlsx salary"
           echo "filetype:xlsx intext:customer|Customer List|Client data|filetype:xlsx customer"
           echo "filetype:xls intext:financial|Financial Data|Finance sheets|filetype:xls financial"
           echo "filetype:csv|CSV Data|Comma separated|filetype:csv"
           echo "filetype:xlsx intext:inventory|Inventory List|Stock data|filetype:xlsx inventory"
           echo "filetype:xlsx intext:statistics|Statistics|Statistical data|filetype:xlsx statistics";;
        3) echo "filetype:doc|Word DOC|Old Word docs|filetype:doc"
           echo "filetype:docx|Word DOCX|Modern Word|filetype:docx"
           echo "filetype:docx intext:confidential|Confidential Doc|Secret Word|filetype:docx confidential"
           echo "filetype:doc intext:memo|Memo|Office memos|filetype:doc memo"
           echo "filetype:docx intext:resume|Resume|CV documents|filetype:docx resume"
           echo "filetype:doc intext:meeting|Meeting Notes|Minutes|filetype:doc meeting"
           echo "filetype:docx intext:policy|Policy Doc|Company policy|filetype:docx policy"
           echo "filetype:doc intext:procedure|Procedure|SOP docs|filetype:doc procedure";;
        4) echo "inurl:admin|Admin Panel|Admin login page|inurl:admin"
           echo "inurl:admin/login|Admin Login|Login form|inurl:admin/login"
           echo "intitle:admin dashboard|Admin Dashboard|Control panel|intitle:admin dashboard"
           echo "inurl:phpmyadmin|phpMyAdmin|MySQL admin|inurl:phpmyadmin"
           echo "intitle:phpMyAdmin|PMA Panel|Database admin|intitle:phpMyAdmin"
           echo "inurl:cpanel|cPanel|Hosting panel|inurl:cpanel"
           echo "intitle:cpanel login|cPanel Login|Hosting login|intitle:cpanel login"
           echo "inurl:webmail|Webmail|Email interface|inurl:webmail";;
        5) echo "inurl:login|Login Page|Generic login|inurl:login"
           echo "inurl:signin|Sign In|Authentication|inurl:signin"
           echo "inurl:auth/login|Auth Login|Authorization|inurl:auth/login"
           echo "intitle:login|Login Title|Page title login|intitle:login"
           echo "inurl:member/login|Member Login|User login|inurl:member/login"
           echo "inurl:customer/login|Customer Login|Client login|inurl:customer/login"
           echo "inurl:secure/login|Secure Login|HTTPS login|inurl:secure/login"
           echo "intitle:portal login|Portal Login|User portal|intitle:portal login";;
        6) echo "filetype:txt intext:password|Password TXT|Plain passwords|filetype:txt password"
           echo "filetype:txt intext:credentials|Credentials|Login info|filetype:txt credentials"
           echo "filetype:txt intext:username|Username List|User names|filetype:txt username"
           echo "intext:api_key|API Key|Developer key|intext:api_key"
           echo "intext:apikey|API Key Alt|API credential|intext:apikey"
           echo "intext:secret_key|Secret Key|Private key|intext:secret_key"
           echo "intext:access_token|Access Token|Auth token|intext:access_token"
           echo "intext:AIza|Google API|Google key|intext:AIza";;
        7) echo "intitle:index.of|Index Of|Directory listing|intitle:index.of"
           echo "intitle:index.of parent directory|Parent Dir|Root listing|intitle:index.of parent directory"
           echo "intitle:index.of uploads|Uploads Dir|File uploads|intitle:index.of uploads"
           echo "intitle:index.of config|Config Dir|Settings files|intitle:index.of config"
           echo "intitle:index.of backup|Backup Dir|Backup files|intitle:index.of backup"
           echo "intitle:index.of etc|etc Dir|System config|intitle:index.of etc"
           echo "intitle:index.of logs|Logs Dir|Log files|intitle:index.of logs"
           echo "intitle:index.of data|Data Dir|Data files|intitle:index.of data";;
        8) echo "filetype:log|Log File|System logs|filetype:log"
           echo "filetype:log intext:error|Error Log|Failure logs|filetype:log error"
           echo "filetype:log intext:access|Access Log|Visitor logs|filetype:log access"
           echo "filetype:log intext:apache|Apache Log|Web server|filetype:log apache"
           echo "filetype:sql|SQL Dump|Database backup|filetype:sql"
           echo "filetype:sql intext:INSERT INTO|SQL Insert|Data dump|filetype:sql INSERT"
           echo "filetype:env|ENV File|Environment vars|filetype:env"
           echo "filetype:json intext:config|JSON Config|App config|filetype:json config";;
    esac
}

browse_categories() {
    while true; do
        print_logo
        echo -e "\033[35;1m📂 CATEGORIES\033[0m"
        echo ""
        echo "1. 📁 PDF Documents"
        echo "2. 📊 Excel Files"
        echo "3. 📝 Word Documents"
        echo "4. 🔐 Admin Panels"
        echo "5. 🔑 Login Pages"
        echo "6. 🔑 Passwords & API Keys"
        echo "7. 📂 Open Directories"
        echo "8. 📜 Logs & Configs"
        echo "0. Back"
        echo ""
        echo -n -e "\033[34;1mSelect: \033[0m"
        read cat_choice
        [ "$cat_choice" = "0" ] && break
        if [ "$cat_choice" -ge 1 ] && [ "$cat_choice" -le 8 ] 2>/dev/null; then
            view_dorks "$cat_choice"
        fi
    done
}

view_dorks() {
    cat_num=$1
    dorks=$(get_dorks "$cat_num")
    cat_names=("PDF Documents" "Excel Files" "Word Documents" "Admin Panels" "Login Pages" "Passwords & API Keys" "Open Directories" "Logs & Configs")
    cat_name="${cat_names[$((cat_num-1))]}"
    
    while true; do
        print_logo
        echo -e "\033[35;1m📂 $cat_name\033[0m"
        echo "══════════════════════════════════════════════════════════════════════════════"
        
        idx=1
        IFS=$'\n'
        for dork in $dorks; do
            IFS='|' read -r query name desc example <<< "$dork"
            echo -e "\033[32;1m$idx. $name\033[0m"
            echo "   \033[34;1m$desc\033[0m"
            echo "   \033[36;1m$query\033[0m"
            echo "----------------------------------------"
            idx=$((idx+1))
        done
        
        echo -e "\033[37;1m0. Back\033[0m"
        echo -n -e "\n\033[34;1mSelect dork: \033[0m"
        read dork_choice
        [ "$dork_choice" = "0" ] && break
        
        if [ "$dork_choice" -ge 1 ] && [ "$dork_choice" -lt "$idx" ] 2>/dev/null; then
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
    echo -e "\033[35;1m🚀 $name\033[0m"
    echo "══════════════════════════════════════════════════════════════════════════════"
    echo -e "\033[34;1mExample: $example\033[0m"
    echo -n -e "\033[33;1mTarget (site:com or keyword): \033[0m"
    read target
    
    final="$query $target"
    final=$(echo "$final" | xargs)
    echo -e "\n\033[32;1mQuery: $final\033[0m"
    
    encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$final'''))" 2>/dev/null || echo "$final" | sed 's/ /%20/g')
    url="https://www.google.com/search?q=$encoded"
    
    echo ""
    echo "1. Open in Browser"
    echo "2. Save to Favorites"
    echo "0. Cancel"
    echo -n -e "\n\033[34;1mChoice: \033[0m"
    read choice
    
    case $choice in
        1)
            open_url "$url"
            sqlite3 "$DATABASE" "INSERT INTO history (query, category, date) VALUES ('$final', '$category', datetime('now'));"
            echo -e "\033[32;1mOpened!\033[0m"
            sleep 1
            ;;
        2)
            sqlite3 "$DATABASE" "INSERT INTO favorites (category, name, query, example, description, date) VALUES ('$category', '$name', '$final', '$example', '$desc', datetime('now'));"
            echo -e "\033[32;1mSaved to favorites!\033[0m"
            sleep 1
            ;;
    esac
}

view_favorites() {
    while true; do
        print_logo
        echo -e "\033[35;1m⭐ FAVORITES\033[0m"
        echo "══════════════════════════════════════════════════════════════════════════════"
        
        favs=$(sqlite3 "$DATABASE" "SELECT id, name, query, category FROM favorites ORDER BY date DESC;" 2>/dev/null)
        
        if [ -z "$favs" ]; then
            echo -e "\033[31;1mNo favorites\033[0m"
            echo -n -e "\n\033[34;1mPress Enter: \033[0m"
            read
            break
        fi
        
        idx=1
        IFS=$'\n'
        for fav in $favs; do
            IFS='|' read -r id name query category <<< "$fav"
            echo -e "\033[32;1m$idx. [$category] $name\033[0m"
            echo "   \033[36;1m$query\033[0m"
            idx=$((idx+1))
        done
        
        echo ""
        echo "0. Back"
        echo -n -e "\n\033[34;1mSelect to run: \033[0m"
        read fav_choice
        [ "$fav_choice" = "0" ] && break
        
        if [ "$fav_choice" -ge 1 ] && [ "$fav_choice" -lt "$idx" ] 2>/dev/null; then
            selected=$(echo "$favs" | sed -n "${fav_choice}p")
            IFS='|' read -r id name query category <<< "$selected"
            encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$query'''))" 2>/dev/null || echo "$query" | sed 's/ /%20/g')
            open_url "https://www.google.com/search?q=$encoded"
            sqlite3 "$DATABASE" "INSERT INTO history (query, category, date) VALUES ('$query', '$category', datetime('now'));"
        fi
    done
}

view_history() {
    print_logo
    echo -e "\033[35;1m📜 HISTORY\033[0m"
    echo "══════════════════════════════════════════════════════════════════════════════"
    
    history=$(sqlite3 "$DATABASE" "SELECT query, category, date FROM history ORDER BY date DESC LIMIT 30;" 2>/dev/null)
    
    if [ -z "$history" ]; then
        echo -e "\033[31;1mNo history\033[0m"
    else
        IFS=$'\n'
        for h in $history; do
            IFS='|' read -r query category date <<< "$h"
            echo -e "\033[34;1m[$date]\033[0m \033[32;1m$category\033[0m"
            echo "   \033[36;1m$query\033[0m"
        done
    fi
    
    echo ""
    echo "1. Clear History"
    echo "0. Back"
    echo -n -e "\n\033[34;1mChoice: \033[0m"
    read hist_choice
    [ "$hist_choice" = "1" ] && sqlite3 "$DATABASE" "DELETE FROM history;"
}

main() {
    init_db
    while true; do
        print_logo
        total=$(sqlite3 "$DATABASE" "SELECT COUNT(*) FROM history;" 2>/dev/null)
        favs=$(sqlite3 "$DATABASE" "SELECT COUNT(*) FROM favorites;" 2>/dev/null)
        echo -e "\033[32;1m📊 Searches: ${total:-0} | Favorites: ${favs:-0}\033[0m"
        echo "────────────────────────────────────────────────────────────────────────────────"
        echo "1. Browse Categories"
        echo "2. View Favorites"
        echo "3. View History"
        echo "0. Exit"
        echo "────────────────────────────────────────────────────────────────────────────────"
        echo -n -e "\033[34;1mSelect: \033[0m"
        read choice
        case $choice in
            1) browse_categories ;;
            2) view_favorites ;;
            3) view_history ;;
            0) echo -e "\033[32;1mGoodbye!\033[0m"; exit 0 ;;
        esac
    done
}

main
