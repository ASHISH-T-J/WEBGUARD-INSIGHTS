#!/bin/bash

# Function to get a random color
random_color() {
  echo $(( RANDOM % 7 + 30 ))
}

# Function to print text with dynamic color
print_dynamic_color() {
  local text="$1"
  local color=$(random_color)
  echo -e "\033[1;${color}m$text\033[0m"
}

# Function to display the webguard banner
webguard_banner() {
  echo -e "\033[1;$(random_color)m$(cat banner.txt)\033[0m"
}

# Function for loading effect
loading_effect() {
  local loading_text="Loading...!!!!"
  local loading_length=${#loading_text}
  local loading_animation="⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"

  while true; do
    for ((i=0; i<loading_length; i++)); do
      echo -ne "\033[1;$(random_color)m${loading_animation:$i:1}\033[0m"
      sleep 0.1
    done
    echo -ne "\r\033[K"
  done
}

# Function to perform subdomain enumeration
subdomain() {
  echo -e "\e[1;34m$(echo "Performing Subdomain Enumeration on $target" | tr '[:lower:]' '[:upper:]')\e[0m" | tee -a "$1"
  subfinder -d "$target" --silent -all | grep "$target" > sublist.txt
  cat sublist.txt | tee -a "$1"
}

# Function to perform passive reconnaissance
passive() {
  local output_file="$1"
  echo -e "\e[1;34m$(echo 'Performing passive reconnaissance...' | tr '[:lower:]' '[:upper:]')\e[0m" | tee -a "$output_file"

  sleep 2

  {
    echo -e "\n--- NSLOOKUP Results ---"
    nslookup "$target" | grep "Address:"

    echo -e "\n--- DIG Results ---"
    dig "$target" | grep "ANSWER SECTION"

    echo -e "\n--- WhatWeb Results ---"
    whatweb "$target"

    echo -e "\n--- WHOIS Results ---"
    whois "$target" | grep "Registrant\|Registrar"

    echo -e "\n--- Subdomain Enumeration Results ---"
    subdomain "$output_file"

    echo -e "\n--- Wayback URLs Results ---"
    echo -e "\e[1;34m$(echo 'Gathering public archives...' | tr '[:lower:]' '[:upper:]')\e[0m"
    waybackurls -dates -get-versions "$target"

    echo -e "\n--- TheHarvester Results ---"
    theHarvester -d "$target" -l 100 -b all | grep "$target"
  } | tee -a "$output_file"
}

# Function to perform directory enumeration
directory_enum() {
  local output_file="$1"
  echo -e "\e[1;34m$(echo "Performing directory and file enumeration on $target" | tr '[:lower:]' '[:upper:]')\e[0m" | tee -a "$output_file"
  gobuster dir -u "$surl" -w common.txt -t 30 -q --no-error | tee -a "$output_file"
}

# Function to scrape admin page, phpMyAdmin page, and robots.txt from a Joomla site
scrape() {
  local target_url="$1"
  local output_file="$2"
  local NC=$'\e[0m'  # Reset color
  local found_result=false

  # Clear the output file
  #> "$output_file"

  # Function to highlight and echo specific results
  highlight_result() {
    local result="$1"
    local color=$'\e[1;31m'  # Red color for highlighting
    echo -e "${color}${result}${NC}" | tee -a "$output_file"
  }

  # Fetch robots.txt
  robots_url="${target_url%/}/robots.txt"
  robots_output=$(curl -s "$robots_url")

  # Check if robots.txt is found
  if [ -n "$robots_output" ]; then
    highlight_result "Robots.txt entries:"
    echo "$robots_output" | tee -a "$output_file"
    found_result=true
  else
    echo "No robots.txt found at $robots_url." | tee -a "$output_file"
  fi

  # Potential admin pages to check
  admin_pages=("administrator" "admin" "admin/login" "admin/index.php" "administrator/index.php")

  # Check for admin page discovery
  for admin_page in "${admin_pages[@]}"; do
    admin_url="${target_url%/}/$admin_page"
    response_code=$(curl -s -o /dev/null -w "%{http_code}" "$admin_url")

    if [ "$response_code" == "200" ]; then
      highlight_result "Admin page found: $admin_url"
      found_result=true
      break
    fi
  done

  # Potential phpMyAdmin pages to check
  phpmyadmin_pages=("phpmyadmin" "pma" "phpMyAdmin" "phpmyadmin/index.php")

  # Check for phpMyAdmin page discovery
  for phpmyadmin_page in "${phpmyadmin_pages[@]}"; do
    phpmyadmin_url="${target_url%/}/$phpmyadmin_page"
    response_code=$(curl -s -o /dev/null -w "%{http_code}" "$phpmyadmin_url")

    if [ "$response_code" == "200" ]; then
      highlight_result "phpMyAdmin page found: $phpmyadmin_url"
      found_result=true
      break
    fi
  done

  # Display message if no result was found
  if ! $found_result; then
    echo "No specific results found." | tee -a "$output_file"
  fi
}

web_server_enum_and_tech_profile() {
  local target=$1
  local output_file=$2

  
  sleep 2

  echo -e "\e[1;34m$(echo "Performing Technology Profiling on $target" | tr '[:lower:]' '[:upper:]')\e[0m" | tee -a "$output_file"
  whatweb "$target" | tee -a "$output_file"
}

# Function to perform active reconnaissance
active() {
  local output_file="$1"
  echo -e "\e[1;34m$(echo "Checking the domain live status..." | tr '[:lower:]' '[:upper:]')\e[0m" | tee -a "$output_file"

  if ping -c 1 -W 1 "$target" > /dev/null 2>&1; then
    echo -e "\e[1;32m$(echo "The domain is live. Proceeding with the scan..." | tr '[:lower:]' '[:upper:]')\e[0m" | tee -a "$output_file"
  else
    echo -e "\e[1;31m$(echo "Error: The domain is not live. Exiting scan..." | tr '[:lower:]' '[:upper:]')\e[0m" | tee -a "$output_file"
    exit 1
  fi

  echo -e "\e[1;34m$(echo 'Performing active reconnaissance...' | tr '[:lower:]' '[:upper:]')\e[0m" | tee -a "$output_file"
  
  sleep 2

  {
    echo -e "\n--- Subdomain Enumeration ---"
    subdomain "$output_file"

    echo -e "\n--- Directory Enumeration ---"
    directory_enum "$output_file"

    echo -e "\n--- Port Scanning and Service Enumeration ---"
    nmap -A "$target" | grep -e "open" -w -e "OS" -w

    echo -e "\n--- WAF Detection ---"
    python3 waf.py "$target"

    echo -e "\n--- Admin Panel Identification and robots.txt Enumeration ---"
    scrape "$surl" "$output_file"

    echo -e "\n--- Web Server Enumeration and Technology Profiling ---"
    web_server_enum_and_tech_profile "$target" "$output_file"
  } | tee -a "$output_file"
}

# Function to create target folder and related directories
create_target_folder() {
  local target_folder="targets/$1"
  local attack_type="$2"
  local targets_dir="targets"
  local current_dir=$(pwd)

  # Check if targets directory exists, create it if it doesn't
  if [ ! -d "$targets_dir" ]; then
    mkdir "$targets_dir" >/dev/null 2>&1  # Suppress output
  fi

  # Check if target folder exists, create it if it doesn't
  if [ ! -d "$target_folder" ]; then
    mkdir "$target_folder" >/dev/null 2>&1  # Suppress output
  fi

  # Change directory to the target folder if it exists
  if [ -d "$target_folder" ]; then
    cd "$target_folder" >/dev/null 2>&1  # Suppress output

    # Determine directory choice based on attack type
    case "$attack_type" in
      [pP]assive)
        directory_choice="passive"
        ;;
      [aA]ctive)
        directory_choice="active"
        ;;
      *)
        return 1  # Invalid attack type
        ;;
    esac

    # Create 'active' or 'passive' directory if it doesn't exist
    if [ ! -d "$directory_choice" ]; then
      mkdir "$directory_choice" >/dev/null 2>&1  # Suppress output
    fi

    # Move into the selected directory
    if [ -d "$directory_choice" ]; then
      cd "$directory_choice" >/dev/null 2>&1  # Suppress output

      # Create a text file with current date and time
      current_time=$(date +"%Y-%m-%d_%H-%M-%S")
      touch "scanning_${current_time}.txt"

      # Return to the initial directory
      cd "$current_dir" >/dev/null 2>&1  # Suppress output
      return 0  # Return success
    else
      cd "$current_dir" >/dev/null 2>&1  # Return to initial directory
      return 1  # Failed to create or change to directory_choice directory
    fi
  else
    cd "$current_dir" >/dev/null 2>&1  # Return to initial directory
    return 1  # Failed to create or change directory for target
  fi
}

# Function to select attack type
attack_type() {
  echo "Select attack type:"
  echo -e "*  Passive\n*  Active\n"
  read -r attack

  case "$attack" in
    [pP]assive)
      if create_target_folder "$target" "$attack"; then
        echo -e "\nStarting passive reconnaissance..."
        passive "targets/${target}/passive/scanning_$(date +"%Y-%m-%d_%H-%M-%S").txt"
      else
        echo -e "\nFailed to create target folder. Exiting."
      fi
      ;;
    [aA]ctive)
      if create_target_folder "$target" "$attack"; then
        echo -e "\nStarting active reconnaissance..."
        active "targets/${target}/active/scanning_$(date +"%Y-%m-%d_%H-%M-%S").txt"
      else
        echo -e "\nFailed to create target folder. Exiting."
      fi
      ;;
    *)
      echo -e "\nWrong choice...!!!!"
      attack_type
      ;;
  esac
}

# Function to configure Tor
tor() {
  if ! command -v tor &> /dev/null; then
    echo "Tor could not be found. Please install Tor and try again."
    exit
  fi
  
  echo -e "\e[1;31m$(echo 'Warning: Errors and slow scan may be experienced when using Tor' | tr '[:lower:]' '[:upper:]')\e[0m"

  read -p "Do you want to use Tor for anonymity? (y/n): " use_tor

  if [[ "$use_tor" =~ ^[Yy]$ ]]; then
    echo "Starting Tor service..."
    sudo service privoxy restart
    sudo service tor restart
    
    sudo service tor start
    sudo service privoxy start

    export http_proxy='http://127.0.0.1:8118'
    export https_proxy='http://127.0.0.1:8118'
  fi
}

# Main script execution
webguard_banner
print_dynamic_color "\t ▌║█║▌│║▌│║▌║▌█║WebGuard ▌│║▌║▌│║║▌█║▌║█"
print_dynamic_color "\t\t\t𝚃𝙴𝙰𝙼 𝙰𝙴𝚂"
sleep 1
echo -n " "
loading_effect &  
loading_pid=$!    
sleep 2 
kill $loading_pid 
print_dynamic_color "Recon Framework"
echo -e "\e[1;31m$(echo 'Ethical Consideration Notice: Ensure you have explicit permission to scan and test the target. Unauthorized scanning is illegal and unethical.' | tr '[:lower:]' '[:upper:]')\e[0m"
sleep 5
echo -e "Enter target domain (example.com):"
read target
url=http://"$target"
surl=https://"$target"
tor

attack_type
sudo service privoxy stop
sudo service tor stop
