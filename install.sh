#!/bin/bash


install_dependencies() {
  declare -a dependencies=("nmap" "whatweb" "whois" "shodan" "theharvester" "wafw00f" "nikto" "dnsutils" "python3" "python3-pip" "gcc" "g++" "make" "git" "curl")


  if command -v apt &> /dev/null; then
    package_manager="apt"
  elif command -v yum &> /dev/null; then
    package_manager="yum"
  else
    echo "Unsupported package manager. Please install the required dependencies manually."
    exit 1
  fi

  echo "Installing required dependencies using $package_manager..."


  for dependency in "${dependencies[@]}"; do
    echo "Installing $dependency..."
    sudo "$package_manager" install -y "$dependency"
  done

  echo "Dependencies installed successfully."
}

# Main script
install_dependencies

