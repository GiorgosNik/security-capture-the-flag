import os

secret = "bigtent"

for year in range(2020, 2023):
    for month in range(1, 13):
        for day in range(0, 32):
            toEncode = str(year) + "-" + str(month).zfill(2) + "-" + str(day).zfill(2) + " " + secret
            result = os.system("echo -n " + toEncode + " | openssl dgst -sha256 >> keys")

with open("keys") as file_in:
    for line in file_in:
        file = open("passphrase.key", "w") 
        file.write(line.split()[1]) 
        result = os.system("gpg --passphrase-file passphrase.key --output decrypted --decrypt signal.log.gpg > /dev/null 2>&1");
        if (result == 0):
            print("Success")
            break
        file.close() 