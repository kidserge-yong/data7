function qt = koikefilter(raw,freq)
rectraw = abs(raw);

a = 6.44;
b = 10.80;
c = 16.52;

T = freq;
t = 0:T:0.5-T;
h = a*(exp(-b*t) - exp(-c*t)) / freq;

qt = filter(h/sum(h), 1, rectraw);
