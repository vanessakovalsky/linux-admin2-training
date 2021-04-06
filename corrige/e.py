import sys
un_ch ="1"
for i in range(int(sys.argv[1])):
	un_ch = un_ch + "0"
un = int(un_ch)
e = un + un
n = 1
factorielle = 1
while 1:
	n = n + 1
	factorielle = factorielle * n
	e_old = e
	e = e + un/ factorielle
	if e == e_old : break
print("essai n : ", n, " e = ", e)

