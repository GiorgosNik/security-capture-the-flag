MODULUS = 0x73eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000001

def evaluate_poly(poly, x):
    result = 0
    for i, coeff in enumerate(poly):
        result += coeff * (x**i)
    return result % MODULUS

def inv(x):
    lm, hm = 1, 0
    low, high = x % MODULUS, MODULUS
    while low > 1:
        r = high // low
        nm, new = hm - lm * r, high - low * r
        lm, low, hm, high = nm, new, lm, low
    return lm % MODULUS

def div_polys(a, b):
    assert len(a) >= len(b)
    a = [x for x in a]
    o = []
    apos = len(a) - 1
    bpos = len(b) - 1
    diff = apos - bpos
    while diff >= 0:
        quot = a[apos] * inv(b[bpos]) % MODULUS
        o.insert(0, quot)
        for i in range(bpos, -1, -1):
            a[diff+i] -= b[i] * quot
        apos -= 1
        diff -= 1
    return [x % MODULUS for x in o]

def zpoly(xs):
    root = [1]
    for x in xs:
        root.insert(0, 0)
        for j in range(len(root)-1):
            root[j] -= root[j+1] * x
    return [x % MODULUS for x in root]

# Given p+1 y values and x values with no errors, recovers the original
# p+1 degree polynomial.
# Lagrange interpolation works roughly in the following way.
# 1. Suppose you have a set of points, eg. x = [1, 2, 3], y = [2, 5, 10]
# 2. For each x, generate a polynomial which equals its corresponding
#    y coordinate at that point and 0 at all other points provided.
# 3. Add these polynomials together.
def interpolate_polynomial(xs, ys):
    # Generate master numerator polynomial, eg. (x - x1) * (x - x2) * ... * (x - xn)
    root = zpoly(xs)
    assert len(root) == len(ys) + 1
    # print(root)
    # Generate per-value numerator polynomials, eg. for x=x2,
    # (x - x1) * (x - x3) * ... * (x - xn), by dividing the master
    # polynomial back by each x coordinate
    nums = [div_polys(root, [-x, 1]) for x in xs]
    # Generate denominators by evaluating numerator polys at each x
    denoms = [evaluate_poly(nums[i], xs[i]) for i in range(len(xs))]
    invdenoms = [inv(denom) for denom in denoms]
    # Generate output polynomial, which is the sum of the per-value numerator
    # polynomials rescaled to have the right y values
    b = [0 for y in ys]
    for i in range(len(xs)):
        yslice = ys[i] * invdenoms[i] % MODULUS
        for j in range(len(ys)):
            if nums[i][j] and ys[i]:
                b[j] += nums[i][j] * yslice
    return [x % MODULUS for x in b]

interpolation = interpolate_polynomial([1,2,3],[5007965719154398295316829646509289701874861709891808846734792385015541826201,20129353592886270223448727591627806607524309415930743719526720763604786378070,45364163628598845685938428155401936384627058279694842643445501229807995000756])
secret = interpolation[0]
secretText = secret.to_bytes(30, byteorder="big")
print(secretText)



