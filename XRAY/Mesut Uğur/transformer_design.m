%% EE564 - Design of Electrical Machines
%% Project-1: Transformer Design for X-Rays
%%
% Mesut U�ur
% ID: 1626753

%%
% Specifications

%%
% X-ray transformer
%% 
% Single-phase, high frequency, high voltage
%% 
% Primary Winding Voltage � 417 V (peak to peak 834 V for pulsing)
%%
% Secondary Winding Voltage � 12.5 kV (peak to peak 25 kV for pulsing)
%%
% Rated Power 30 kW (for maximum 100 millisecond)
%%
% Switching Frequency Minimum 100 kHz
%%
% Ambient Temperature 0-40 �C


%%
% Inputs

Vin_peak = 417;
Vpri_peak = Vin_peak*4/pi;
Vpri_rms = Vpri_peak/sqrt(2);
Vout_peak = 12500;
Vsec_peak = Vout_peak*4/pi;
Vsec_rms = Vsec_peak/sqrt(2);
Pout = 30000;
Ipri_rms = Pout/Vpri_rms;
Isec_rms = Pout/Vsec_rms;


%% OBSOLETE
% Area product calculation
% c = 2.82e-3; % cm^2/Amps
% efficiency = 0.98;
% B = 0.5;
% frequency = 100e3;
% K = 0.7;
% area_product = Pin*c*1e8/(4*efficiency*B*frequency*K)


%%
% Core material selection
% FERRITE
%%
% Core shape selection
% Double E
%%
% Core geometry selection
% 49928
%%
% Core Type (material)
% P type

%%
% Core Data
AL = 6773; % nH/turn
le = 274; % mm
Ac = 738; % mm^2
Ve = 202e3; % mm^3
WaAc = 90.6; % cm^4
Wa = WaAc*1e4/Ac; % mm^2

%%
% Winding Data
% AWG#26 for 100 kHz

conductor_diameter = 0.40386; % mm
conductor_area = (conductor_diameter/2)^2*pi; % mm^2
ohms_per_km =  	133.8568; % ohm/km
current_rating = 0.361; % Amps

strand_primary = ceil(Ipri_rms/current_rating);
strand_secondary = ceil(Isec_rms/current_rating);

%%
% Skin Depth Calculation

mu_r = 0.999994;
mu_0 = 4*pi*1e-7;
resistivity = 1.68e-8;
w = 2*pi*frequency;
delta = 1000*sqrt(2*resistivity/(w*mu_r*mu_0)); % mm

% Conductor radius is less than the skin depth => No skin effect


%%
% Proximity Effect
% Neglected for now...


%%
% turn number calculation

flux_density = 0.3; % Tesla
flux = flux_density*Ac/1e6; % Weber
frequency = 100e3;
Npri = round(Vpri_rms/(4.44*frequency*flux));
Nsec = round(Vsec_rms/(4.44*frequency*flux));

%%
% winding areas
area_pri_winding = Npri*strand_primary*conductor_area; % mm^2
area_sec_winding = Nsec*strand_secondary*conductor_area; % mm^2

fill_factor = (area_sec_winding + area_sec_winding)/Wa;

%%
% Core loss

% specific_core_loss = 1; % W/cm^3
% core_loss = specific_core_loss*Ve/1e3; % Watts

%%
% Using curve fitting
% P material @80 Cdegrees
a = 0.0434;
c = 1.63;
d = 2.62;
f = 100;
B = 0.3*10; % kilogtauss
PL = a*f^c*B^d; % mW/cm^3
core_loss = PL*Ve/1e6; % Watts


%%
% Copper loss
mean_length_turn = 11*1.2; % cm
length_pri = Npri*mean_length_turn; % cm
ohms_km_pri = ohms_per_km/strand_primary;
resistance_pri = ohms_km_pri*length_pri/1000; % ohms

length_sec = Nsec*mean_length_turn; % cm
ohms_km_sec = ohms_per_km/strand_secondary;
resistance_sec = ohms_km_sec*length_sec/1000; % ohms

copper_loss_pri = Ipri_rms^2*resistance_pri;
copper_loss_sec = Isec_rms^2*resistance_sec;
copper_loss = copper_loss_pri+copper_loss_sec;


%%
% Total loss
total_loss = core_loss + copper_loss;
efficiency = 100*Pout/(total_loss+Pout);


%%
% Mass calculation

core_mass = 980; % grams

copper_volume_pri = length_pri*strand_primary*conductor_area*1e-2; % cm^3
copper_volume_sec = length_sec*strand_secondary*conductor_area*1e-2; % cm^3
copper_density = 8.96; % g/cm^3
copper_mass_pri = copper_volume_pri*copper_density; % grams
copper_mass_sec = copper_volume_sec*copper_density; % grams
copper_mass = copper_mass_pri + copper_mass_sec; % grams


%%
% Magnetizing inductance
% AL = 6773; % nH/turn
% Lpri = 1e-3*AL*Npri; % uH
% Lsec = 1e-3*AL*Nsec; % uH
% 

%%
% Magnetic field intensity calculation
% mur = 4000;
% mu0 = 4*pi*1e-7;
% mu = mur*mu0;
% H = flux_density/mu; % Amperes
% drop = H*le/1000;
% MMFpri = Npri*Ipri_rms*sqrt(2);
% MMFsec = Nsec*Isec_rms*sqrt(2);


%%
% Flux density of harmonic components
harmonic = 1:2:31;
total = numel(harmonic);
voltage_rms = zeros(1,total);
flux_density_harmonic = zeros(1,total);

for k = 1:total
    voltage_rms(k) = (4/pi)*(1/sqrt(2))*Vin_peak/harmonic(k);
    flux_density_harmonic(k) = voltage_rms(k)/(4.44*Npri*frequency*harmonic(k)*Ac/1e6);
end


%%
% Core loss for harmonics
% Using curve fitting

PL = zeros(1,total);
core_harmonic_loss = zeros(1,total);

for k = 1:total
    PL(k) = a*(f*harmonic(k))^c*flux_density_harmonic(k)^d; % mW/cm^3
    core_harmonic_loss(k) = PL(k)*Ve/1e6; % Watts
end




