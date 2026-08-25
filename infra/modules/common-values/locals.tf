locals {

  vpn_ip_addresses = [
    "51.149.11.24/29",    # New GovWifi and Brattain (Whitechapel Building Wifi) active 15 September 2025
    "217.196.229.77/32",  # GovWifi
    "217.196.229.79/32",  # Brattain (Whitechapel Building Wifi)
    "217.196.229.80/32",  # BYOD VPN
    "217.196.229.81/32",  # Managed device VPN
    "51.149.8.0/25",      # Managed device VPN
    "51.149.8.128/29",    # BYOD VPN
    "159.254.101.107/32", # DSIT ZScaler
    "159.254.101.75/32",  # DSIT ZScaler
    "164.137.3.121/32",   # DSIT ZScaler
    "164.137.3.89/32"     # DSIT ZScaler
  ]
}
