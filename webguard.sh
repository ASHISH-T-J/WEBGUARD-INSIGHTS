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
  echo -e "\033[1;${webguard_color}m
  ███╗░░░███╗░█████╗░██████╗░██╗███████╗██╗░░░░░██╗░░░░░
  ████╗░████║██╔══██╗██╔══██╗██║██╔════╝██║░░░░░██║░░░░░
  ██╔████╔██║██║░░██║██║░░██║██║█████╗░░██║░░░░░██║░░░░░
  ██║╚██╔╝██║██║░░██║██║░░██║██║██╔══╝░░██║░░░░░██║░░░░░
  ██║░╚═╝░██║╚█████╔╝██████╔╝██║██║░░░░░███████╗███████╗
  ╚═╝░░░░░╚═╝░╚════╝░╚═════╝░╚═╝╚═╝░░░░░╚══════╝╚══════╝
  \033[0m"
}


webguard_banner
print_dynamic_color "WebGuard"
sleep 1
echo -n " "
loading_effect &  
loading_pid=$!    
sleep 2 
kill $loading_pid 
print_dynamic_color "Recon Framework"
echo -e "Enter target domain (example.com):"
read target


passive() {
  echo "Performing passive reconnaissance..."
  sleep 1

  # Passive reconnaissance
  nslookup "$target" | grep "Address:"
  sleep 1
  dig "$target" | grep "ANSWER SECTION"
  sleep 1
  whatweb "$target"
  sleep 1
  whois "$target" | grep "Registrant\|Registrar"
  sleep 1
  waybackurl "$target"
  sleep 1
  shodan "$target"
  sleep 2

  theHarvester -d "$target" -l 100 -b all
}


active() {
  echo "Performing active reconnaissance..."
  sleep 2

  # Active reconnaissance
  nmap "$target" | grep "open"
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
    passive
    active
  else
    echo -e "\nWrong choice...!!!!"
    attack_type
  fi
}

attack_type
