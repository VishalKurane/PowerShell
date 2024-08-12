# TLS/SSL Certificate Information Collection Script

## Description

This PowerShell script is designed to collect TLS/SSL certificate information for a list of Fully Qualified Domain Names (FQDNs). It retrieves details such as the Certificate Issued date and Expiry date, Resource Name/ Ip Address on which the certificate us binded, Subject Alternative Names (SAN), SAN Count, Serial Number, Thumb Print/Fingerprint and Issuer. The collected data is then saved in a CSV file.

## Prerequisites

- **PowerShell**: Ensure you have PowerShell installed on your system.
- **OpenSSL**: The script relies on OpenSSL to extract SSL certificate details. Ensure OpenSSL is installed and accessible from your command line.
- **Input File**: A text file (`Input.txt`) containing the list of FQDNs.

## How to Use

1. **Prepare the Input File**:
   - Create a text file named `Input.txt` in the specified directory (e.g., `E:\DevOps\GitHub-Repositories\PowerShell\`).
   - List each FQDN on a new line in the `Input.txt` file.

2. **Run the Script**:
   - Execute the PowerShell script. The script will process each FQDN from the input file and retrieve the SSL certificate information.

3. **Output**:
   - The collected data will be saved in a CSV file named `SSL-Report.csv` in the same directory. Convert the data from text to column with Delimiter ';' in CSV file.

## Script Details

- **Input File**: `Input.txt` (Contains a list of FQDNs)
- **Output File**: `SSL-Report.csv` (Contains TLS/SSL certificate details)
- **Dependencies**: OpenSSL