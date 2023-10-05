function batchAndrea

% [trackedLinks,flow]=andreaTest(dirName,dist,m,n,s,nbDir,rate,pixelS,name)

% andreaTest('/mnt/alex10/AlexData/Andrea/Actin_01/tack/cands/',6,1,64,2);
% andreaTest('/mnt/alex10/AlexData/Andrea/Actin_02/tack/cands/',6,1,64,2);

% andreaTest('/mnt/alex10/AlexData/Steph/s365/tack/cands/',6,4,64,2);
% andreaTest('/mnt/alex10/AlexData/Dylan/first_movie/tack/cands/',6,55,58,2); % should be 58 (1-7)

% TORSTEN
% andreaTest('/mnt/alex10/AlexData/Torsten/Rac/Analized_Data/Cell1/tack/cands/',6,98,119,3,1,5,67,'ACTIVERAC1_',2.8);  
% andreaTest('/mnt/alex10/AlexData/Torsten/Rac_with_Pakinhibitor/Analized_Data/Cell1/tack/cands',6,1,98,3,2,5,67,'PAKINH1_',0);  
% andreaTest('/mnt/alex10/AlexData/Torsten/Rac/Analized_Data/Cell2/tack/cands/',6,1,119,3,1,5,67,'ACTIVERAC2_',4.3);  
% andreaTest('/mnt/alex10/AlexData/Torsten/Rac_with_Pakinhibitor/Analized_Data/Cell2/tack/cands',6,1,98,3,2,5,67,'PAKINH2_',0);  
% andreaTest('/mnt/alex10/AlexData/Torsten/Rac/Analized_Data/Cell3/tack/cands/',6,1,119,3,1,5,67,'ACTIVERAC3_',4.7);  
% andreaTest('/mnt/alex10/AlexData/Torsten/Rac_with_Pakinhibitor/Analized_Data/Cell3/tack/cands',6,1,98,3,2,5,67,'PAKINH3_',0); 

% andreaTest('F:\AlexData\Torsten\Rac_with_Pakinhibitor\Analized_data\Cell3\tack\cands',6,1,98,3,2,5,67,'PAKINH3_',0); 
% andreaTest('C:\matov\data\IFTA\Torsten\Cell3\tack\cands',6,1,98,3,2,5,67,'PAKINH3_',0);
% andreaTest('C:\matov\data\IFTA\Spindle2polar\tack\cands',6,1,65,2,2,10,110,'RedRawAligned',0);  % cost 0.45,0.63,0.4 WORKS OCT 2012
%%%%andreaTest('A:\Matlab\Cell Tracking\cand',10,1,4,2,2,5,67,'S365ACTIN',0);
%andreaTest('E:\Dropbox\Matlab\Cell Tracking\cand',10,1,41,2,2,5,67,'crop_default',0); 

prompt = {'Enter mat files directory:' , 'Enter cropped tif files directory:', 'Searching Radius','Number of frames'};
dlg_title = 'Input Options';
num_lines = 1;
%def = {'E:\Dropbox\Matlab\Cell Tracking\Detection_Code\testInputs\cands', 'E:\Dropbox\Matlab\Cell Tracking\Detection_Code\testInputs','3','1'};
def = {'E:\MATLAB\Cell Tracking\2_droplet_diameter_47um_7_beads\2_droplet_diameter_47um_7_beads\images\cands', 'E:\MATLAB\Cell Tracking\2_droplet_diameter_47um_7_beads\2_droplet_diameter_47um_7_beads\images','3','1'};
inputsFromDlg = inputdlg(prompt, dlg_title, num_lines, def);

%andreaTest_v3_readsFromFeat_cleaned_MultiDirection(inputsFromDlg{1},inputsFromDlg{2},str2double(inputsFromDlg{3}),1,str2double(inputsFromDlg{4}),2,3,5,67,'S365ACTIN',0,2);
andreaTest_v3_readsFromFeat_cleaned_MultiDirection(inputsFromDlg{1},inputsFromDlg{2},str2double(inputsFromDlg{3}),220001,220001+str2double(inputsFromDlg{4})-1,2,3,5,67,'S365ACTIN',0,2);

%CVIU
% andreaTest('/mnt/alex10/CVIU-paper/Spindle2polar/tack/cands/',6,1,65,2,2,10,110,'RedRawAligned',0);  % cost 0.45,0.63,0.4
% andreaTest('/mnt/alex10/CVIU-paper/Spindle3polar/tack/cands',4,1,48,2,3,10,67,'crop_xjul8_r15',0);  

% andreaTest('/mnt/alex10/AlexData/Dylan/Blebbistatin_Gactin_Spinning_Disk/Bleb1/G-actin/tack/cands/',6,1,22,2,2,10,133,'G-actin1');  
% andreaTest('/mnt/alex10/AlexData/Dylan/Blebbistatin_Gactin_Spinning_Disk/Bleb1/G-actin_Blebbistatin/tack/cands/',6,1,20,2,2,5,133,'G-actin1-Bleb');  
% andreaTest('/mnt/alex10/AlexData/Dylan/Blebbistatin_Gactin_Spinning_Disk/Bleb2/G-actin/tack/cands/',6,1,58,2,2,5,133,'G-actin2');  
% andreaTest('/mnt/alex10/AlexData/Dylan/Blebbistatin_Gactin_Spinning_Disk/Bleb2/G-actin_Blebbistatin/tack/cands/',6,1,42,2,2,5,133,'G-actin2-Bleb');

% TM4 3-dir
% andreaTest('/mnt/alex10/AlexData/Andrea/Actin_TM4_07/tack/cands',6,23,25,3,3,10,67,'actin-TM4'); % 3-r

% % Jay 8 spindles
% andreaTest('/mnt/alex10/AlexData/Jay/ConfocalSpindlesSept09/spindle1/tack/cands',6,1,119,3,2,5,129,'needleSpindle');  
% andreaTest('/mnt/alex10/AlexData/Jay/ConfocalSpindlesSept09/spindle3/tack/cands',6,1,119,3,2,5,129,'needleSpindle');  
% andreaTest('/mnt/alex10/AlexData/Jay/ConfocalSpindlesSept09/spindle4/tack/cands',6,1,119,3,2,5,129,'needleSpindle');  
% andreaTest('/mnt/alex10/AlexData/Jay/ConfocalSpindlesSept09/spindle6/tack/cands',6,76,119,3,2,5,129,'needleSpindle');  
% andreaTest('/mnt/alex10/AlexData/Jay/ConfocalSpindlesSept09/spindle7/tack/cands',6,1,119,3,2,5,129,'needleSpindle');  
% andreaTest('/mnt/alex10/AlexData/Jay/ConfocalSpindlesSept09/spindle2/tack/cands',6,1,63,2,2,5,129,'needleSpindle');  
% andreaTest('/mnt/alex10/AlexData/Jay/ConfocalSpindlesSept09/spindle5/tack/cands',6,1,119,3,2,5,129,'needleSpindle');  
% andreaTest('/mnt/alex10/AlexData/Jay/ConfocalSpindlesSept09/spindle8/tack/cands',6,1,119,3,2,5,129,'needleSpindle');  
% andreaTest('/mnt/alex10/spindle9/tack/cands',6,1,119,3,2,5,129,'crop_default');  

% andreaTest('/mnt/alex10/AlexData/Andrea/Actin_TM1_01/tack/cands/',6,1,88,2);
% andreaTest('/mnt/alex10/AlexData/Andrea/Actin_TM1_03/tack/cands/',6,61,118,3);  
% andreaTest('/mnt/alex10/AlexData/Andrea/Actin_TM1_04/tack/cands',6,10,82,2);
% andreaTest('/mnt/alex10/AlexData/Andrea/Actin_TM1_05/tack/cands',6,10,82,2); 
% andreaTest('/mnt/alex10/AlexData/Andrea/Actin_TM1_06/tack/cands',6,1,118,3); % should be 118 ? nothing so far
% andreaTest('/mnt/alex10/AlexData/Andrea/Actin_TM1_07/tack/cands',6,1,112,3); % 
% andreaTest('/mnt/alex10/AlexData/Andrea/Actin_TM1_08/tack/cands',6,1,112,3); % 
% 
% andreaTest('/mnt/alex10/AlexData/Andrea/Actin_TM4_01/tack/cands/',6,76,118,3); %  
% andreaTest('/mnt/alex10/AlexData/Andrea/Actin_TM4_04/tack/cands',6,10,53,2); % 
% andreaTest('/mnt/alex10/AlexData/Andrea/Actin_TM4_06/tack/cands',6,79,112,3); % not finished as of 79 til 112
% andreaTest('/mnt/alex10/AlexData/Andrea/Actin_TM4_07/tack/cands',6,10,112,3); % should be 118 (1-7, 115-)

% andreaTest('/mnt/alex10/AlexData/LaFountain/images/lafountain2/10-10-03m3/test_1/cands',9,01,01,2); 
% andreaTest('/mnt/alex10/AlexData/LaFountain/images/lafountain2/10-10-03m3/test_1/cands',12,22,22,2);
% andreaTest('/mnt/alex10/AlexData/LaFountain/images/lafountain3/07-19-05m2/test_1/cands',5,01,01,4);

% andreaTest('/mnt/alex10/AlexData/Andrea/Actin_TM1_09/tack/cands',6,1,22,3); % TM1_08
% andreaTest('/mnt/alex10/AlexData/Andrea/Actin_TM1_09/tack/cands',6,98,119,3); % 

% [trackedLinks,flow]=andreaTest(dirName,dist,m,n,s,nbDir,rate,pixelS,name)
% andreaTest('/mnt/alex10/AlexData/Andrea/Actin_TM1_10/tack/cands',6,1,119,3,4,10,67,'actinTM2');  

% andreaTest('/mnt/alex10/AlexData/Jay/ConfocalSpindlesSept09/spindle5/tack/cands2',4,1,119,3,2,5,129,'crop_default');%SR4/MaxSp6.2um/min/ANIS12/5

% andreaTest('/mnt/alex10/AlexData/Jay/ConfocalSpindlesSept09/spindle7/tack/cands',6,1,1,3,4,5,129,'crop_default',0);%SR4/MaxSp6.2um/min/ANIS12/5

