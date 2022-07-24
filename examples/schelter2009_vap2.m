% Schelter, Timmer, Eichler. 
% Assessing the strength of directed influences among neural signals using
% renormalized PDC. J Neurosci Methods, 179:121-130, 2009.
%   [http://dx.doi.org/10.1016/j.jneumeth.2009.01.006]
% 
% 3.1 Vector autoregressive process II (Eqs. 16-20, page 124)

clear; clc

nDiscard = 1000;    % number of points discarded at beginning of simulation
nPoints  = 3000;   % number of analyzed samples points

u = fschelter2009_vap2(nPoints, nDiscard);
%chLabels = []; % or 
chLabels = {'x_1';'x_2';'x_3';'x_4';'x_5'};
fs =1;

%%
% Data pre-processing: detrending and normalization options
flgDetrend = 1;     % Detrending the data set
flgStandardize = 0; % No standardization

[nChannels,nSegLength]=size(u);
if nChannels > nSegLength, u=u.'; 
   [nChannels,nSegLength]=size(u);
end;

if flgDetrend,
   for i=1:nChannels, u(i,:)=detrend(u(i,:)); end;
   disp('Time series were detrended.');
end;

if flgStandardize,
   for i=1:nChannels, u(i,:)=u(i,:)/std(u(i,:)); end;
   disp('Time series were scale-standardized.');
end;

%%
% MVAR model estimation

maxIP = 30;         % maximum model order to consider.
alg = 1;            % 1: Nutall-Strand MVAR estimation algorithm;
%                   % 2: minimum least squares methods;
%                   % 3: Vieira Morf algorithm;
%                   % 4: QR ARfit algorith.

criterion = 1;      % Criterion for order choice:
%                   % 1: AIC, Akaike Information Criteria; 
%                   % 2: Hanna-Quinn;
%                   % 3: Schwarz;
%                   % 4: FPE;
%                   % 5: fixed order given by maxIP value.

disp('Running MVAR estimation routine...')

[IP,pf,A,pb,B,ef,eb,vaic,Vaicv] = mvar(u,maxIP,alg,criterion);

disp(['Number of channels = ' int2str(nChannels) ' with ' ...
    int2str(nSegLength) ' data points; MAR model order = ' int2str(IP) '.']);

%==========================================================================
%    Testing for adequacy of MAR model fitting through Portmanteau test
%==========================================================================
h = 20; % testing lag
MVARadequacy_signif = 0.05; % VAR model estimation adequacy significance
                            % level
aValueMVAR = 1 - MVARadequacy_signif;
flgPrintResults = 1;
[Pass,Portmanteau,st,ths] = mvarresidue(ef,nSegLength,IP,aValueMVAR,h,...
                                           flgPrintResults);

%%
% Granger causality test (GCT) and instantaneous GCT

gct_signif  = 0.01;  % Granger causality test significance level
igct_signif = 0.01;  % Instantaneous GCT significance level
flgPrintResults = 1; % Flag to control printing gct_alg.m results on command window.
[Tr_gct, pValue_gct, Tr_igct, pValue_igct] = gct_alg(u,A,pf,gct_signif, ...
                                              igct_signif,flgPrintResults);
%% Original PDC estimation
%
% PDC analysis results are saved in *c* structure.
% See asymp_dtf.m or issue 
%
%   >> help asymp_pdc 
%
% command for more detail.

nFreqs = 128;
metric = 'info';  % euc  = original PDC or DTF;
                 % diag = generalized PDC (gPDC) or DC;
                 % info = information PDC (iPDC) or iDTF.
alpha = 0.001;

c=asymp_pdc(u,A,pf,nFreqs,metric,alpha);


%%
% PDCn Matrix Layout Plotting

flgPrinting = [1 1 1 2 2 0 2]; % overriding default setting
flgColor = 1;
w_max=fs/2;
alphastr = int2str(100*alpha);
   
for kflgColor = flgColor,
%    h=figure;
%    set(h,'NumberTitle','off','MenuBar','none', ...
%          'Name', 'Schelter et al. (2009)')
   strID = 'Schelter et al. (2009)';
   [hxlabel hylabel] = xplot(strID,c,...
                               flgPrinting,fs,w_max,chLabels,kflgColor,2,'pdc');
%    [ax,hT]=suplabel(['Schelter et al. (2009) linear model: ' ...
%       int2str(nPoints) ' data points.'],'t');
%    set(hT,'FontSize',10); % Title font size
   strTitle = ['Schelter et al. (2009) linear model: ' ...
                                              int2str(nPoints) ' data points.'];
   xplot_title(alpha,metric,'pdc',strTitle);
end;

%% Result from Schelter et al.(2009) 
% Figure 1, page 124.
%
% <<fig_schelter2009_vap2_result.png>>
% 


%% Remarks:
%
% * Note that for linear model the mean amplitude of PDC estimates is')
% roughly proportional to  relative coefficient values of ')
% the autoregressive model.')
