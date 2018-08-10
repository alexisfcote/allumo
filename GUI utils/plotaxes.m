function [p1, p2, p3] = plotaxes(POS, Rot)

p1 = plot3([POS(1);POS(1)+Rot(1,1)*0.1],[POS(2);POS(2)+Rot(2,1)*0.1],[POS(3);POS(3)+Rot(3,1)*0.1],'b','LineWidth',1);
p2 = plot3([POS(1);POS(1)+Rot(1,2)*0.1],[POS(2);POS(2)+Rot(2,2)*0.1],[POS(3);POS(3)+Rot(3,2)*0.1],'g','LineWidth',1);
p3 = plot3([POS(1);POS(1)+Rot(1,3)*0.1],[POS(2);POS(2)+Rot(2,3)*0.1],[POS(3);POS(3)+Rot(3,3)*0.1],'r','LineWidth',1);