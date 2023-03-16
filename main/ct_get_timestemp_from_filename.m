function tstemp = ct_get_timestemp_from_filename(fname)
% Get timestemp from an ApRES filename of the format
% "DATAYYYY-MM-DD-hhmm.DAT", e.g. "DATA2016-12-10-1631.DAT"

YY = str2double(fname(5:8));
MM = str2double(fname(10:11));
DD = str2double(fname(13:14));
hh = str2double(fname(16:17));
mm = str2double(fname(18:19));
tstemp = datenum(YY,MM,DD,hh,mm,0);