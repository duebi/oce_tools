<<<<<<< HEAD
% Function to calculate air-sea bubble flux
%
% USAGE:-------------------------------------------------------------------
%  
% [Fi Fe] = Fbub_N11(8,35,20,1,'O2')
%
%  > Fi = 9.8910e-08
%  > Fe = 2.3665e-08
%
% DESCRIPTION:-------------------------------------------------------------
%
% Calculates the equilibrium concentration of gases as a function of
% temperature and salinity (equilibrium concentration is at 1 atm including
% atmospheric pressure
%
% Finj = Ainj * slp * Xg * u3
% Fex = Aex * slp * Geq * D^n * u3
%
% where u3 = (u-2.27)^3 (and zero for  u < 2.27)
%
% INPUTS:------------------------------------------------------------------
% 
% C:    gas concentration in mol m-3
% u10:  10 m wind speed (m/s)
% S:    Sea surface salinity
% T:    Sea surface temperature (deg C)
% slp:  sea level pressure (atm)
%
% gas:  two letter code for gas
%
%       Code    Gas name        Reference
%       ----   ----------       -----------
%       He      Helium          Weiss 1971
%       Ne      Neon            Hamme and Emerson 2004
%       Ar      Argon           Hamme and Emerson 2004
%       Kr      Krypton         Weiss and Keiser 1978
%       Xe      Xenon           Wood and Caputi 1966
%       N2      Nitrogen        Hamme and Emerson 2004   
%       O2      Oxygen          Garcia and Gordon 1992    
%
% OUTPUTS:------------------------------------------------------------------
%
% Finj and Fex,  Injection and exchange bubble flux in mol m-2 s-1
% Fas: surface air-sea flux based on Sweeney et al. 2007
% Deq: steady-state supersaturation
% REFERENCE:---------------------------------------------------------------
%
% Nicholson, D., S. Emerson, S. Khatiwala, R. C. Hamme. (2011)
%   An inverse approach to estimate bubble-mediated air-sea gas flux from 
%   inert gas measurements.  Proceedings on the 6th International Symposium
%   on Gas Transfer at Water Surfaces.  Kyoto University Press.
%
% AUTHOR:---------------------------------------------------------------
% David Nicholson dnicholson@whoi.edu
% Woods Hole Oceanographic Institution
% Version: September 2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Fas, Finj, Fex, Deq, k] = fas_N11(C,u10,S,T,slp,gas,varargin)

if nargin > 6
    rhum = varargin{1};
else
    rhum = 0.8;
end
ph2oveq = vpress(S,T);
ph2ov = rhum.*ph2oveq;
Ainj = 2.357e-9;
Aex = 1.848e-5;

u3 = (u10-2.27).^3;
u3(u3 < 0) = 0;

[D,Sc] = gasmoldiff(S,T,gas);
Geq = gasmoleq(S,T,gas);

k = kgas(u10,Sc,'Sw07');
Fas = k.*(Geq.*(slp-ph2ov)./(1-ph2oveq)-C);
Finj = Ainj.*slp.*gas_mole_fract(gas).*u3;
Fex = Aex.*slp.*Geq.*D.^0.5.*u3;
Deq = ((Finj+Fex)./k)./Geq;
=======
% Function to calculate air-sea gas exchange flux using Nicholson 11
% parameterization
%
% USAGE:-------------------------------------------------------------------
%  
% [Fd, Fc, Fp, Deq] = fas_N11(C,u10,S,T,slp,gas,rh)
% [Fd, Fc, Fp, Deq] = fas_N11(0.01410,5,35,10,1,'Ar',0.9)
%
% > Fd = -4.4860e-09
% > Fc = 3.1432e-10
% > Fp = 9.0980e-11
% > Deq = 1.6882e-03
%
% DESCRIPTION:-------------------------------------------------------------
%
% Calculate air-sea fluxes and steady-state supersaturation based on:
% Nicholson, D., S. Emerson, S. Khatiwala, R. C. Hamme. (in press) 
%   An inverse approach to estimate bubble-mediated air-sea gas flux from 
%   inert gas measurements.  Proceedings on the 6th International Symposium
%   on Gas Transfer at Water Surfaces.  Kyoto University Press.
%
% Fc = Ainj * slpc * Xg * u3
% Fp = Aex * slpc * Geq * D^n * u3
%
% where u3 = (u-2.27)^3 (and zero for  u < 2.27)
%
% Explanation of slpc:
%      slpc = (observed dry air pressure)/(reference dry air pressure)
% slpc is a pressure correction factor to convert from reference to
% observed conditions. Equilibrium gas concentration in gasmoleq is
% referenced to 1 atm total air pressure, including saturated water vapor
% (RH=1), but observed sea level pressure is usually different from 1 atm,
% and humidity in the marine boundary layer is usually less than
% saturation. Thus, the observed sea level pressure of each gas will
% usually be different from the reference.
%
% INPUTS:------------------------------------------------------------------
% 
% C:    gas concentration in mol m-3
% u10:  10 m wind speed (m/s)
% S:    Sea surface salinity (PSS)
% T:    Sea surface temperature (deg C)
% slp:  sea level pressure (atm)
%
% gas:  two letter code for gas
%       Code    Gas name        Reference
%       ----   ----------       -----------
%       He      Helium          Weiss 1971
%       Ne      Neon            Hamme and Emerson 2004
%       Ar      Argon           Hamme and Emerson 2004
%       Kr      Krypton         Weiss and Keiser 1978
%       Xe      Xenon           Wood and Caputi 1966
%       N2      Nitrogen        Hamme and Emerson 2004   
%       O2      Oxygen          Garcia and Gordon 1992   
%
% varargin: optional but recommended arguments
%       rhum: relative humidity as a fraction of saturation (0.5 = 50% RH).
%               If not provided, it will be automatically set to 0.8.
%
% OUTPUTS:-----------------------------------------------------------------
% Fd:   Surface air-sea diffusive flux based on 
%       Sweeney et al. 2007                           [mol m-2 s-1]
% Fc:   Injection bubble flux (complete trapping)     [mol m-2 s-1]
% Fp:   Exchange bubble flux (partial trapping)       [mol m-2 s-1]
% Deq:  Steady-state supersaturation                  [unitless (%sat/100)]
%
% REFERENCE:---------------------------------------------------------------
% Nicholson, D., S. Emerson, S. Khatiwala, R. C. Hamme. (in press) 
%   An inverse approach to estimate bubble-mediated air-sea gas flux from 
%   inert gas measurements.  Proceedings on the 6th International Symposium
%   on Gas Transfer at Water Surfaces.  Kyoto University Press.
%
% AUTHORS:-----------------------------------------------------------------
% David Nicholson dnicholson@whoi.edu
% Cara Manning cmanning@whoi.edu
% Woods Hole Oceanographic Institution
% Version 2.0 September 2015
%
% COPYRIGHT:---------------------------------------------------------------
%
% Copyright 2015 David Nicholson and Cara Manning 
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License, which 
% is available at http://www.apache.org/licenses/LICENSE-2.0
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Fd, Fc, Fp, Deq] = fas_N11(C,u10,S,T,slp,gas,varargin)

% 1.5 factor converts from average winds to instantaneous - see N11 ref.
Ainj = 2.51e-9./1.5;
Aex = 1.15e-5./1.5;


% if humidity is not provided, set to 0.8 for all values
if nargin > 6
    rhum = varargin{1};
else
    rhum = 0.8;
end

% slpc = (observed dry air pressure)/(reference dry air pressure)
% see Description section in header
ph2oveq = vpress(S,T);
ph2ov = rhum.*ph2oveq;
slpc = (slp-ph2ov)./(1-ph2oveq);
slpd = slp-ph2ov;

[D,Sc] = gasmoldiff(S,T,gas);
Geq = gasmoleq(S,T,gas);

% calculate wind speed term for bubble flux
u3 = (u10-2.27).^3;
u3(u3 < 0) = 0;

k = kgas(u10,Sc,'Sw07');
Fd = -k.*(C-slpc.*Geq);
Fc = Ainj.*slpd.*gasmolfract(gas).*u3;
Fp = Aex.*slpc.*Geq.*D.^0.5.*u3;
Deq = ((Fp+Fc)./k)./Geq;
>>>>>>> cara-gtws
