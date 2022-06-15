import math

N = 127670779
e = 7
cx = 32959265
cy = 47487400


def isPrime(n):
    if (n < 2):
        return False;
    sq = int(math.sqrt(n))
    for i in range(2, sq + 1):
        if (n % i == 0):
            return False
    return True

def findPrimes():
    factors = []
    for i in range(2, N):
        if (N % i == 0):
            factors.append(i)
    primes = []
    for f in factors:
        if (isPrime(f)):
            primes.append(f)
    p = primes[0]
    q = primes[1]
    return p,q

def main():
    p, q = findPrimes()
    print("p = " + str(p) + " q = " + str(q))
    phi = (p-1)*(q-1)
    d = pow(e, -1, phi)
    print(d)
    x = pow(cx, d, N)
    print(x)
    y = pow(cy, d, N)

    print("x = " + str(x) + " y = " + str(y))

if __name__ == '__main__':
    main()

    7419813371074198133710