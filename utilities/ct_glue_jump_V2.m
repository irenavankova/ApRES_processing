function y2 = ct_glue_jump_V2(y,ijump,nan_before,nan_after)
%ijump is the location before jump
nb = nan_before; %how many points BEFORE jump location to make nan and use fill gap on
na = nan_after; %how many points AFTER jump location to make nan and use fill gap on
y2 = y;

% Move to location after jump until where want to extrapolate
ijump = ijump + na;
% Extrapolation/fill gaps
yleft = y(1:ijump);
yleft(end-nb-na+1:end) = NaN;
%ttemp = ct.dts_xcor.time(1:ijump-1);
yextrap = fillgaps(yleft);
y2(1:ijump) = yextrap;

yshft = yextrap(end);

y2(ijump:end) = y(ijump:end) - y(ijump) + yshft;
