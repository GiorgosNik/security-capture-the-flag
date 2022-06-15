import os

secret = "bigtent"

for year in range(2020, 2023):
    for month in range(1, 13):
        for day in range(0, 32):
            toEncode = str(year) + "-" + str(month).zfill(2) + "-" + str(day).zfill(2) + " " + secret
            result = os.system("echo -n " + toEncode + " | openssl dgst -sha256 | awk '{print $2}' >> ../output/keys")

file = open("../output/passphrase.key", "w") 
file_in =  open("../output/keys")
for line in file_in:
    file.seek(0)
    file.write(line) 
    result = os.system("gpg --pinentry-mode loopback --passphrase-file ../output/passphrase.key --output ../output/decrypted --decrypt ../signal.log.gpg > /dev/null 2>&1");
    if (result == 0):
        print("Success")
        result = os.system("gpg --pinentry-mode loopback --passphrase-file ../output/passphrase.key --output ../output/decrypted.gz --decrypt ../firefox.log.gz.gpg > /dev/null 2>&1");
        break
file_in.close()
file.close() 