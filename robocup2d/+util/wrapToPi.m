function a = wrapToPi(a)
%UTIL.WRAPTOPI  Wrap angle(s) to the interval (-pi, pi].
a = mod(a + pi, 2*pi) - pi;
a(a == -pi) = pi;
end
