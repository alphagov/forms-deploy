locals {

  vpn_ip_addresses = [
    "212.38.169.64/27",  #Temp: Pentest Partners For Testing
    "78.129.217.224/27", #Temp: Pentest Partners For Testing
    "91.238.238.0/25",   #Temp: Pentest Partners For Testing
    "217.196.229.77/32", # GovWifi
    "217.196.229.79/32", # Brattain (Whitechapel Building Wifi)
    "217.196.229.80/32", # BYOD VPN
    "217.196.229.81/32", # Managed device VPN
    "51.149.8.0/25",     # Managed device VPN
    "51.149.8.128/29"    # BYOD VPN
  ]
}
