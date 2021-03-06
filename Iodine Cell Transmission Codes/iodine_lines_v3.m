% Code to fit a Iodine cell transmission spectrum to a numerical obtained transmission
% spectrum
%
%First select a characteristic point on the scan, then on the numerical
%transmission spectrum, then use left and right arrow keys to shift and
%up and down to strech and compress the plot, press enter to continue
%
%2012/04/23
%Tobias Ecker
%ecker@vt.edu

clc
clear
close all

%% import forkey iodine cell data

if ismac()
    %mac
    path='/Volumes/STUDIUM/Projekte/2012_01_01_jet_noise/2012_04_15_entry/04_18/codes'; %path of numerical transmission spectrum
    path2='/Volumes/STUDIUM/Projekte/2012_01_01_jet_noise/2012_04_15_entry/04_18/04_18 PZT'; %path of measured spectrum
    
    sep='/';
    
else
    %win
    path='d:';
    path2='d:';
    sep='\';
end

oname='profile_10-3'; %outputfile name

voltage=25; %set voltage
v=sqrt(1.4*287*283)*1.1; %expected velocity

%files to process
filename='data80_45_12d7'; %numerical file
filename2='scan8.dat'; %scan

%velocity vector
lambda=532*10^-9;


%unit vectors
i=[1 0 0];
j=[0 1 0];
k=[0 0 1];

theta=143.130/180*pi; %angle of DGV system

o1=[cos(theta) -sin(theta) 0];

vr=1*(o1-i)/norm(o1-i)*v;

fdr=vr*(o1-i)'/lambda;




mkdir([path2 sep 'processed'])
outputfile=[path2 sep 'processed' sep oname '.pzt'];

[pathstr, name, ext] = fileparts([path2 sep filename2]);
[pathstr2, name2, ext2] = fileparts([path sep filename]);

scan1=load([path2 sep filename2]);
fid2=fopen([path sep filename]);

i=1;
offset=8;
while ~feof(fid2) ; % reads the original till last line
    tline=fgets(fid2) ; %

    

        string=regexp(tline, '([^ ][^ ]*)', 'match');
        if i>offset
            for a=1:2
                data(i-offset,a)=str2num(string{a});
            end
        end
        i=i+1;
 
    
end
fclose(fid2)

A=0.0041;
B=89.783;

%% rough alignment

xmin=18789-18700
xmax=18791-18700

% 


%scan(:,4)=scan1(:,4)./max(scan1(:,4));

scan(:,5)=scan1(:,5)./max(scan1(:,5))*max(scan1(:,4));

scan(:,3)=scan(:,5)./scan(:,4);

scan(:,3)=scan1(:,3)-min(scan1(:,3));

% plot(scan(:,3))
% hold on
% plot(scan(:,4),'xr')
scan(:,3)=scan1(:,3)./max(scan1(:,3));
% plot(scan(:,3),'o')
% hold off
% 
% pause


pztscan(:,2)=scan(:,3);
pztscan(:,1)=scan1(:,2)*A;

figure(1)
plot(pztscan(:,1),pztscan(:,2),'rx-')

h = msgbox('Select characteristic point in the PZT scan','Select position','help')
uiwait(h);

p1=impoint()
p1=getPosition(p1);

close 1

h = msgbox('Select characteristic point in the numerical transmission spectrum!','Select position','help')
uiwait(h);

figure(1)
plot(data(:,1)-18700,data(:,2),'x-')
xlim([xmin xmax]) 

p2=impoint()
p2=getPosition(p2);

close 1

B=p2(1)-p1(1);

%% optimisation loop

pztscan(:,1)=scan1(:,2)*A+B;

xmins=min(pztscan(:,1));
xmaxs=max(pztscan(:,1));

l=xmaxs-xmins;

ind=find(data(:,1)-18700>(xmins-l/2) & data(:,1)-18700<(xmaxs+l/2)); 
indr=find(data(:,1)-18700>(xmins) & data(:,1)-18700<(xmaxs)); 
xi=data(indr,1)-18700;


yi = interp1(pztscan(:,1),pztscan(:,2),xi)
Xi =data(ind,1)-18700;
Yi=data(ind,2);

f=figure(2)
plot(Xi,Yi,'-')
hold on
plot(xi,yi,'rx--')
hold off
AA=0.0001;
BB=0.001;
do=true;
while do==true
    
    
    pause
    current_key = double(get(f,'CurrentCharacter'))
    
    if current_key==30
        A=A+AA;
    elseif current_key==31
        A=A-AA;  
    elseif current_key==29
        B=B+BB; 
    elseif current_key==28
        B=B-BB; 
            elseif current_key=='a'
        BB=BB*5; 
            elseif current_key=='s'
        BB=BB/5; 
            elseif current_key=='z'
        AA=AA*5; 
            elseif current_key=='x'
        AA=AA/5; 
    else
        do=false;
    end
    

pztscan(:,1)=scan1(:,2)*A+B;

xmins=min(pztscan(:,1));
xmaxs=max(pztscan(:,1));

l=xmaxs-xmins;

ind=find(data(:,1)-18700>(xmins-l/2) & data(:,1)-18700<(xmaxs+l/2)); 
indr=find(data(:,1)-18700>(xmins) & data(:,1)-18700<(xmaxs)); 
xi=data(indr,1)-18700;


yi = interp1(pztscan(:,1),pztscan(:,2),xi)
Xi =data(ind,1)-18700;
Yi=data(ind,2);

f=figure(2)
plot(Xi,Yi,'-')
hold on
plot(xi,yi,'rx--')
hold off
title(['BB=' num2str(BB) ' ,AA=' num2str(AA)])

end

%% plot wavenumber 

close all

figure1 = figure('visible','on');

% Create axes
axes1 = axes('Parent',figure1,'YMinorTick','on','XMinorTick','on',...
    'LineWidth',2,...
    'FontSize',16,...
    'FontName','Times New Roman');
box(axes1,'on');


hold(axes1,'all');
plot(Xi,Yi,'k-','LineWidth',1.5)
hold on
plot(scan1(:,2)*A+B,scan1(:,3),'rx-','LineWidth',1.5)
hold off

% Create xlabel
XL=xlabel(['wavenumber 18700 + ... [1/cm]'],'FontSize',20,'FontName','times');
set(XL,'Interpreter','latex');

% % Create ylabel
YL=ylabel(['transmission'],'FontSize',20,'FontName','times','Rotation',90);
set(YL,'Interpreter','latex');

set(gca,'FontName','times')
%legend('vertial forward distribution','Location','NorthEast')

set(figure1,'Units','normalized')
set(figure1, 'Position', [0.2 0.2 0.8 0.8 ] );
set(figure1, 'OuterPosition', [0 0 1 1 ]);
xlim([min(xi) max(xi)])
%ylim([Limits(3) Limits(4)])
ylim([0 1.0])
print('-depsc','-f1','-r300 ', [path2 sep 'processed' sep 'resultplot_transmission_k' oname ]);


%%

forkey_t=interp1(Xi,Yi,scan1(:,2)*A+B);

c=299792458;  %m/s speed of light
A=A*100*c;
B=(B+18700)*100*c;

set_t=interp1(scan1(:,2),scan(:,3),voltage);
set_t_f=voltage*A+B;

%% write file
pfile=mfilename;
 header=['PZT scan Fit \nDate: ' datestr(now) '\n\nFiles:\n' filename '\n' filename2 '\nCode:\n' pfile '\nSet Voltage:\n' num2str(voltage) '\nConversion [Hz/V]\n' num2str(A,'%-12.14f') '\nOffset [Hz]\n' num2str(B,'%-12.14f') '\n' ];
    
    fid=fopen(outputfile, 'w');

    fprintf(fid,[header '\n' 'voltage[V] \tfreq[Hz] \tdelta freq[Hz] \ttransmission measurement\t transmission numerical (Foreky)\n']);

    disp(['writing file']);
    for iii=1:length(scan(:,1))
        
     fprintf(fid,[num2str(scan1(iii,2),'%-12.14f') '\t' num2str(scan1(iii,2)*A+B,'%-12.14f') '\t' num2str( scan1(iii,2)*A+B-set_t_f*A+B,'%-12.14f') '\t' num2str(scan1(iii,3),'%-12.14f') '\t' num2str(forkey_t(iii),'%-12.14f') '\n']);
 
    end
    disp(['finished writing']);

fclose(fid);


%% plot freq.
close all

figure1 = figure('visible','on');

% Create axes
axes1 = axes('Parent',figure1,'YMinorTick','on','XMinorTick','on',...
    'LineWidth',2,...
    'FontSize',16,...
    'FontName','Times New Roman');
box(axes1,'on');


hold(axes1,'all');
plot(scan1(:,2)*A+B,forkey_t,'k-','LineWidth',1.5)
hold on
plot(scan1(:,2)*A+B,scan1(:,3),'rx-','LineWidth',1.5)
hold off

% Create xlabel
XL=xlabel(['frequency [Hz]'],'FontSize',20,'FontName','times');
set(XL,'Interpreter','latex');

% % Create ylabel
YL=ylabel(['transmission'],'FontSize',20,'FontName','times','Rotation',90);
set(YL,'Interpreter','latex');

set(gca,'FontName','times')
%legend('vertial forward distribution','Location','NorthEast')

set(figure1,'Units','normalized')
set(figure1, 'Position', [0.2 0.2 0.8 0.8 ] );
set(figure1, 'OuterPosition', [0 0 1 1 ]);
%xlim([min(xi) max(xi)])
%ylim([Limits(3) Limits(4)])
ylim([0 1.0])
print('-depsc','-f1','-r300 ', [path2 sep 'processed' sep 'resultplot_transmission_f_non_norm' oname ]);

close all

figure1 = figure('visible','on');

% Create axes
axes1 = axes('Parent',figure1,'YMinorTick','on','XMinorTick','on',...
    'LineWidth',2,...
    'FontSize',16,...
    'FontName','Times New Roman');
box(axes1,'on');


hold(axes1,'all');
plot(scan1(:,2)*A+B-set_t_f,forkey_t,'k-','LineWidth',1.5)
hold on
plot(scan1(:,2)*A+B-set_t_f,scan1(:,3),'rx-','LineWidth',1.5)
plot([0 0],[0 1],'b-','LineWidth',1.5)
plot([fdr fdr],[0 1],'b--','LineWidth',1.5)
hold off

% Create xlabel
XL=xlabel(['frequency shift $$\Delta$$f [Hz]'],'FontSize',20,'FontName','times');
set(XL,'Interpreter','latex');

% % Create ylabel
YL=ylabel(['transmission'],'FontSize',20,'FontName','times','Rotation',90);
set(YL,'Interpreter','latex');

set(gca,'FontName','times')
%legend('vertial forward distribution','Location','NorthEast')

set(figure1,'Units','normalized')
set(figure1, 'Position', [0.2 0.2 0.8 0.8 ] );
set(figure1, 'OuterPosition', [0 0 1 1 ]);
%xlim([min(xi) max(xi)])
ylim([0 1.0])

print('-depsc','-f1','-r300 ', [path2 sep 'processed' sep 'resultplot_transmission_delta_f_non_norm' oname]);
























