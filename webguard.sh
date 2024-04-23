#!/bin/bash


current_date=$(date +"%Y-%m-%d")


random_color() {
  echo $(( RANDOM % 7 + 30 ))
}


webguard_color=$(random_color)
recon_framework_color=$(random_color)


print_dynamic_color() {
  local text="$1"
  local color=$(random_color)
  echo -e "\033[1;${color}m$text\033[0m"
}


loading_effect() {
  local loading_text="Loading...!!!!"
  local loading_length=${#loading_text}
  local loading_animation="⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
  
  while true; do
    for ((i=0; i<loading_length; i++)); do
      echo -ne "\033[1;${loading_color}m${loading_animation:$i:1}\033[0m"
      sleep 0.1
    done
    echo -ne "\r\033[K"  
  done
}

webguard_banner() {
  echo -e "\033[1;${webguard_color}m$(cat banner.txt)\033[0m"
}

active_subdomain() {
echo "Performing Subdomain Enumuration on $target "
  subfinder  -all  -d "$target" -silent > sub.txt
sublist3r  -d "$target" | grep "$target" >> sub.txt
cat sub.txt | sort | uniq > sublist.txt
cat sublist.txt
}

passive() {
  echo "Performing passive reconnaissance..."
  sleep 2

  # Passive reconnaissance
  nslookup "$target" | grep "Address:"
  sleep 1
  dig "$target" | grep "ANSWER SECTION"
  sleep 1
  whatweb "$target"
  sleep 1
  whois "$target" | grep "Registrant\|Registrar"
  sleep 1

active_subdomain

 echo "Gathering public archives..."
waybackurls -dates -get-versions  "$target"



  theHarvester -d "$target" -l 100 -b all  | grep "cek.ac.in"
}


active() {
  echo "Performing active reconnaissance..."
  sleep 2

  # Active reconnaissance
 
active_subdomain

echo "Performing Port Scanning And Service   Enumuration on $target "
 nmap -A "$target" | grep -e "open" -w -e "OS" -w
  sleep 2
  wafw00f -a "$target"
  sleep 2
  nikto -host "$target"
}

attack_type() {
  echo "Select attack type:"
  echo -e "*  Passive\n*  Active\n"
  read attack

  if [ "$attack" == "passive" ] || [ "$attack" == "Passive" ] || [ "$attack" == "PASSIVE" ]; then
    passive
  elif [ "$attack" == "active" ] || [ "$attack" == "Active" ] || [ "$attack" == "ACTIVE" ]; then
    
    active
  else
    echo -e "\nWrong choice...!!!!"
    attack_type
  fi
}

tor() {
if ! command -v tor &> /dev/null
then
    echo "Tor could not be found. Please install Tor and try again."
    exit
fi

# Ask the user if they want to use Tor
read -p "Do you want to use Tor for anonymity? (y/n): " use_tor

if [[ "$use_tor" =~ ^[Yy]$ ]]
then
    echo "Starting Tor service..."
    # Start the Tor service
    service tor start
    # Set the proxy environment variables
    export http_proxy='socks5://127.0.0.1:9050'
    export https_proxy='socks5://127.0.0.1:9050'
fi
}



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
echo -e "Enter target domain (example.com):"
read target

tor
attack_type
service tor stop
