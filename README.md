# security-capture-the-flag

### Team Members

- Giorgos Nikolaou
- Nefeli Tavoulari

### Description
This project comprises our participation in the capture the flag challenge for YS13 "Protection and Security of Information Systems" during the academic year of 2021-22. The task we were given was to find awnsers to the following 6 questions, given only the photograph bellow as a starting point. In order to complete the series of challenges we faced, we had to apply, ammong other things, web security principles, cryptographic algorithms, buffer overflows and the tools to exploit them.

![](logo.png)

### Questions:
1. Where is Giorgos?
1. What did Giorgos find?
1. What is the time on "Plan X"?
1. Where are the "Plan X" files located?
1. What are the results of "Plan Y"?
1. What is the code of "Plan Z"?

Upon completing each question, we were presented with a "FLAG". Submiting this flag signified the completion of the specified step.


## Capture the Flag
### Part 1: Breaking RSA
- First of all, we searched the given url in tor browser. Then, looking through the source code of the page we found a suspicious comment with a url. This led us to a guide on how to preserve .onion anonymity, which at some point gave instructions on how to disable server-info and server-status endpoints. As it turned out, only the latter has been actually disabled. So, in the current configuration section of the server-info endpoint we found another .onion url, where we had to fill in a field to get authenticated. Again, searching through the source code of this new page, we saw that the post request of this "form" was handled in a file named "access.php".
- Trying to reach this endpoint we got a "bad user" message. But looking through the Server configuration, we noticed that phps files are enabled and so we got access to the file. There, it said in a comment that the username is the 48th multiple of 7 that contains a 7 in its decimal representation, which is 0001337. As far as the password is concerned, exploiting the php strcmp vulnerability, we injected an array in the comparison and strcmp returned 0(http://flffeyo7q6zllfse2sgwh7i5b5apn73g6upedyihqvaarhq5wrkkn7ad.onion/access.php?user=0001337&password[]=%27%27). There we were given an endpoint (blogposts7589109238/) where we found another url (/blogposts/diary.html) and then another one(/blogposts/diary2.html) and then we finally found https://github.com/chatziko/pico and xtfbiszfeilgi672ted7hmuq5v7v3zbitdrzvveg2qvtz4ar5jndnxad.onion, which asked for credentials. 
- When we accessed the /blogposts endpoint we were able to see the two html files we had accessed before, plus one more (post3.html). There we we got a couple of useful information, Giorgos Komninos is a customer and #834472 visitor will be able to access some important info. So, we tried to change the visitor cookie in the developer's console. Decrypting the cookie found in the console we got the current visitor number (204) and some random characters. So we figured that only one part of this cookie corresponds to the visitor number(MjA0O). In this way we found the encryption of the visitor #834472 (ODM0NDcy) but then we had to find the meaning of the rest of the cookie. Remembering an error we had previously seen in the home page that said "Bad sha256" we realized that the rest of the cookie had to be the sha256 encoding hash of this number. Using another tool, we got 27c3af7ef2bee1af527dbf8c05b3db6cca63589941b8d49572aa64b5cd8c5b97, and then encoding 834472:27c3af7ef2bee1af527dbf8c05b3db6cca63589941b8d49572aa64b5cd8c5b97 to base64 we got ODM0NDcyOjI3YzNhZjdlZjJiZWUxYWY1MjdkYmY4YzA1YjNkYjZjY2E2MzU4OTk0MWI4ZDQ5NTcyYWE2NGI1Y2Q4YzViOTc=. Adding this new cookie to the browser we managed to access /sekritbackup7547 as this user. 
- First of all, we googled the last line of the file and we found this: https://ropsten.etherscan.io/tx/0xdcf1bfb1207e9b22c77de191570d46617fe4cdf4dbc195ade273485dddc16783, where the word "bigtent" is displayed. So, we assumed that maybe this is the secret string we should use. Therefore, we created a simple python script to try some dates with the specific word and we managed to decrypt the files. When we saw the content of the files, we noticed some git references and a string that resembled a commit id(eafb2886b8732d638a3c44a8882d309ae11fa19d). So, by running a "cat | grep git" in the other decrypted file, we expected to find a repo url, as we did(https://github.com/asn-d6/tor/commit/eafb2886b8732d638a3c44a8882d309ae11fa19d). 
- In a comment we found some RSA parameters and 2 encrypted numbers, which we decrypted following the RSA algorithm. We did this finding the primes, the product of which is equal to N, and used them to find the public key. Then, calculating the modular multiplicative inverse of e and the public key, we found the private key and then we deciphered the two numbers(x = 133710, y = 74198). So, we found out that Giorgos is at the Gilman's Point on the Kilimanjaro (http://aqwlvm4ms72zriryeunpo3uk7myqjvatba4ikl3wy6etdrrblbezlfqd.onion/7419813371074198133710.txt).

-FLAG={GilmansPointKilimanjaro}

#### Script for Part 1
- `decipherRSA.py`

### Part 2: Shamir's Secret Sharing Algorithm
In his last message, Giorgos pointed out that he had saved an image of "his favourite Kilimanjaro newspaper" at http://aqwlvm4ms72zriryeunpo3uk7myqjvatba4ikl3wy6etdrrblbezlfqd.onion/kilimanjarotimes4818.jpg. There, we read about a missing Greek hiker (presumably Giorgos) and the items he left behind, a book about version control systems and a USB drive, labeled "sss491020.tar.gr". We can download this archive at http://aqwlvm4ms72zriryeunpo3uk7myqjvatba4ikl3wy6etdrrblbezlfqd.onion/sss491020.tar.gz. Initially, the archive is "corrupted", and cannot be extracted. To fix this, we had to edit the archive using a hex editor, and remove text characters that were placed at its beginning to corrupt it. After fixing and extracting the archive, we are faced with a folder titled "sss". Inside is a .git folder. Using `git reset HEAD~1 --hard` we were able to restore two files that had been previously deleted, "notes.txt" and "sss.py". The notes reveal that Giorgos made a discovery while studying polynomials, and to conceal it, he split the information in 3 shares. Knowing this and taking note of the name and contents of "sss.py" we realised he used Shamir's Secret Sharing algorithm to split the secret he discovered. After further examination of the project directory, we discovered some temporarily stashed changes, which we restored using `git stash pop`. This restored a file named "polywork.py", that in addition to the contents of "sss.py", contained the code needed to connect the shares of Shamir's Secret Sharing algorithm and restore the secret. After further examination of the project, we found the shares were stored in the name of a tag. Inputting the shares in a slightly modified version of "polywork.py", named "decryptSSS.py", we found that Giorgos discovered that time travel was possible.

-FLAG={TimeTravelPossible!!?}

#### Script for Part 2
- `decryptSSS.py`

### Part 3: Exploiting missing format arguments
We tried to make use of the leads we had collected during the previous steps. Specifically, we attempted to access Yvoni's server, connection to which required credentials. We knew that the server was based on the pico repo, a link to which we had previously found. We cloned the repo, compiled the program and in doing so, we noticed a warning, telling as that a printf call, used to print the user-provided username was missing format arguments. We attempted to exploit this mistake, by providing a number of type arguments. We did this using an automated script to provide a number of %x type arguments followed by one %s type argument. In doing this we hoped to force the server to output sensitive information on the HTTP response, which we could then use. We found that by using `%x %x %x %x %x %x %s` as the username, we could make the server output the username:hashed-password combination of the admin. We used an online tool to retrieve the original password (hammertime) from the hash, and used it to login to the server. There, we found that the Project-X files had been moved to a new location, and we got a new clue.

-FLAG={Stop! Hammer Time}

#### Script for Part 3
- `serverLogin.sh`


### Part 4: Padding Oracle Attack on AES
The clue came in the form of an encrypted message, which when decrypted would reveal the location the files had been moved to. In the same page, we had access to a form that could be used to verify the encrypted message was in fact correct. After experimenting with filing out the form we found we got the following messages:

- "secret ok": when filing the form with the provided ciphertext
- "invalid size": when filing the form with a message of a size not divisible by 16
- "invalid padding" or "wrong secret": seemingly at random in any other case

We noticed that similarly to a previous problem, the webpage was based on a pico server, so we examined the pico repository again. We deduced that the data submitted by the form were provided as input to the program "check-secret", which is part of the pico repository. The program receives an encrypted text, decrypts it using the key it reads from a file, checks and then removes the padding, and finally compares the resulting text with a text stored on a different local file. We thought of ways to use to use this system to our advantage, and came across an algorithm called "The Padding Oracle Attack". This attack is based on the information returned from the target regarding the correctness of the padding, and allows us to decrypt the message without having any knowledge of the key. In order to do this, we have to create a "zeroing initialization vector", a structure that holds the values of the intermediate representation of the cipher text, after the ciphertext has been decoded but before it has been XORed with the initialization vector. This is done by trying random values in the range of [0-255], until we get a message other than "invalid padding", meaning the padding is interpreted as correct. For the last value of the Zeroing IV, this correct padding value is 0x01, for the second value is has to be 0x02 0x02 (all padding bytes share the same value, that being the size of the padding). After calculationg the zeroing IV, we can compute the XOR of each one of its elements with the actual IV, retreiving the cleartext as a result. We created a script titled "aesOracle.sh" to perform this calculation. This way, we found out the Project X files have been moved to "/secet/x".

-FLAG={/secet/x}

#### Script for Part 4
- `aesOracle.sh`


### Part 5: Buffer Overflow Part #1
We revealed the new location of the files, we now had to retrieve them. After further examining the code, we decided this would be done using the `send_file()` function. This function takes a filename as input, and transmits the file to the client. In order to call the function using `\secet\x` as the argument, we needed to perform a buffer overflow attack, by abusing the use of `strcpy()` under the function `post_param`, a vulnerability we had taken note of earlier. The server uses `strcpy()` to copy the contents of the user-made POST request to a buffer for further processing. The buffer is created dynamically based on the size of the data of the request. This data is normally calculated on the client side based on the input (by the browser, the `curl` command etc.), it is however possible to provide it manually, thus forcing the buffer to have a certain size. By adding `-H 'Content-Length: 0'` as an argument to our curl command, we can force the buffer to take a size of 0.

We now have to figure out what to overflow the buffer with. To gather information on the internal workings of the program, and specifically the contents of the stack, we used the vulnerable `printf()` function from an earlier problem. By providing a number of `08x` as arguments, we could leak the contents of the stack. After examining our local version of the server under `gdb`, we determined that we needed to leak at least 31 words of the memory, to gather all the information we need. This task is performed by `leakAddr.sh`, which prints a string that contains 31 words of the server's memory under the `check_auth()` function. Among these are
- The stack canary: We need to include it in our payload, to avoid stack smashing errors
- The saved ebp register: We need to include it in our payload before the return address, and also to calculate some offsets
- The return address of `check_auth`: We can use it to calculate offsets.

After gathering this information, we had to craft our payload by testing our local server with `gdb`: We found that the payload must have the following format:
 - 40 random bytes
 - The address of the given argument of `post_param()`. We determined that address of this argument was calculated as the return address of `check_auth` plus 4885. 
 - 56 more random bytes
 - The address to the start of the buffer (calculated as the leaked ebp from earlier -136), followed by 8 random bytes
 - The 16 bytes of the canary, followed by 8 random bytes
 - The ebp register we leaked earlier
 - The return address. To calculate the return address, we used `info address send_file` under gdb, and calculated the offset to the return address we leaked earlier.
 - 8 random bytes, followed by the argument we wanted to provide. The argument came in the form of a pointer, which we wanted to point to data we provided. We determined that the pointer should point to the address directly after itself, which after experimentation with gdb, we set to the leaked ebp value - 48. The file we wanted was `\secet\x`, so we provided the hexadecimal encoding of this string, that being `2F73656365742F7900`. Note the 00 we added at the end of the string.

After creating this payload, we store it in binary format in a file, and send the file as the contents of a post request using `curl`.
After receiving `/secet/x`, we are told the results are stored in a different file, `/secet/y`. In `/secet/y`, we find the flag for part 5, as well as a clue for the next step.
````
Plan Y results: Computing, approximate answer: FLAG={41.99299141232}
...

Plan Z: troll humans who ask stupid questions (real fun).
I told them I need 7.5 million years to compute this XD

In the meanwhile I'm travelling through time trolling humans of the past.
Currently playing this clever dude using primitive hardware, he's good but the
next move is crushing...

1.e4 c6 2.d4 d5 3.Nc3 dxe4 4.Nxe4 Nd7 5.Ng5 Ngf6 6.Bd3 e6 7.N1f3 h6 8.Nxe6 Qe7 9.0-0 fxe6 10.Bg6+ Kd8 11.Bf4 b5 12.a4 Bb7 13.Re1 Nd5 14.Bg3 Kc8 15.axb5 cxb5 16.Qd3 Bc6 17.Bf5 exf5 18.Rxe7 Bxe7

PS. To reach me in the past use the code: FLAG={}
````

-FLAG={41.99299141232}

### Part 6: Buffer Overflow Part #2
The flag for this part was split in two parts, the first one being the "next move" of the sequence of characters and letters given above, and the second part being the public IP of the server. For the first part, we discovered that the sequence of characters represented chess moves, specifically the chess moves of the famous game "Deep Blue versus Garry Kasparov". The next and final move of the game was c4.

To find the public IP of the server we had to find a way to execute a command on the shell, and have the result sent to us as a response. The command we selected was `dig +short myip.opendns.com @resolver1.opendns.com`. In order to execute the command on the server we had to perform the same steps as above, only returning to the function `system()` instead of `send_file()`. We took note of the fact that since the program was compiled on `linux02.di.uoa.gr`, in order to calculate the correct offset to `system()`, we had to compile on the same machine. After doing this, using `gdb` we found the address of `system()` to be `0xf7b5e3d0`. We observed a similar value was returned by `leakAddr.sh`. We named this value `libc` and calculated the offset of the actual system address based on it. The rest of the attack followed the pattern described in part 5. Doing this we found the IP of the server to be `54.210.15.244`.

-FLAG={c454.210.15.244}

#### Scripts for Part 5 and Part 6
In order to automate the attack, we used 3 different scripts:

- `createBin.py`: This python script acts as the base for the attack. It calls `leakAddr.sh` to gather information on the memory, calculates the relevant offsets, performs cleanup etc. and converts them to a form suitable form use later. It then creates both payloads, using the address of both `send_file` and `system` as well as the relevant arguments. The results are stored in binary format in `part5.bin` and `part6.bin`. The script then calls `apply.sh` and prints the result.
- `leakAddr.sh`: This script is used to leak information on the memory of the server, which `createBin.py` uses to calculate the offsets. This information is returned to the form of a string, which `createBin.py` then splits into the relevant parts
- `apply.sh`: This script is used to send the binary file containing the input to the server, as input for the `check_secret` form. The script takes as input a number, either 5 or 6, which specifies which bin file to send, and prints the results.
