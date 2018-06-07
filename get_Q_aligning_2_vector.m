function [ Q ] = get_Q_aligning_2_vector( A, B )
% Find the rotation matrix that project A onto B 

ssc = @(v) [0 -v(3) v(2); v(3) 0 -v(1); -v(2) v(1) 0];
RU = @(A,B) eye(3) + ssc(cross(A,B)) + ssc(cross(A,B))^2*(1-dot(A,B))/(norm(cross(A,B))^2);

Q = RU(A,B);
end

