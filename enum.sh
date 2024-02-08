echo "WEB INSIGHTS"
sleep 1
echo "Loading...!!!!"
sleep 2
clear
echo "WEB INSIGHTS"
echo -e "WEB APPLICATION RECON, ENUMERATION, FOOTPRINTING FRAMEWORK\n under development...!!!!"
echo "Enter target domain (example.com):"
read target

passive() {
  echo "Performing passive reconnaissance..."
  sleep 1
  # Passive reconnaissance
  nslookup $target | grep "Address:"
  sleep 1
  dig $target | grep "ANSWER SECTION"
  sleep 1
  whatweb $target
  sleep 1
  whois $target | grep "Registrant\|Registrar"
  sleep 1
}

active() {
  echo "Performing active reconnaissance..."
  sleep 2
  # Active reconnaissance
  nmap $target | grep "open"
  sleep 2
  nikto -host $target
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

