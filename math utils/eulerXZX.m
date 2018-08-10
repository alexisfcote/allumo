function Q = eulerXZX( theta, psi, phi )

c1 = cos(theta);
s1 = sin(theta);
c2 = cos(psi);
s2 = sin(psi);
c3 = cos(phi);
s3 = sin(phi);

% Euler XZX
Q = [c2 -c3*s2 s2*s3;
     c1*s2 c1*c2*c3-s1*s3  -c3*s1-c1*c2*s3;
     s1*s2 c1*s3+c2*c3*s1 c1*c3-c2*s1*s3];
end

