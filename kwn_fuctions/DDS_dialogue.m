% the purpose of this script is to produce the hex strings required to
% program the DDS on RMB1.
% The sequence of strings was specified by Lai Bun
% The strings are written to screen, along with a few diagnostic messages.
% Default values are offered.

% After the strings have been assembled, the script searches for a config
% file in the working directory. If it finds one, the strings are appended
% to the end of that file. If it fails to find a config file, the user can select one
% via a browser window.

fsysclk = 1e9;  %hardware defined
%No justification for Tstep is given - Fstep is defined by Tstep as (fsysclk/4)*Tstep

choice = questdlg('Choose a DDS MODE?','DDS MODE','RAMP', 'CW Tone','RAMP');

DDSregs012BCDE = {'00000008';'000C0820';'0D1F41C8';'6666666633333333';'0000431C0000431C';'13881388'};

switch choice
    case 'RAMP'
        startFreq = 200e6; %predefined
        stopFreq = 400e6; %predefined
        Tstep = 20e-6; %predefined
        
        Fstep = (stopFreq - startFreq)*Tstep;
        NoDwellHi = 1;
        promptTitle  = 'DDS RAMP setup';
        default = {num2str(startFreq),num2str(stopFreq),num2str(Fstep),num2str(Tstep),num2str(NoDwellHi)};
        prompt={'Enter START FREQ      ',...
            'Enter STOP FREQ       '...
            'Enter Fstep       '...
            'Enter Tstep       '...
            'Enter NoDwellHi       '...
            } ;
        lineNo  = 1;
        resize  = 'off';
        answer=inputdlg(prompt,promptTitle,lineNo,default,resize);
        startFreq= str2double(answer{1});
        stopFreq= str2double(answer{2});
        Fstep= str2double(answer{3});
        Tstep= str2double(answer{4});
        NoDwellHi= str2double(answer{5});
        
        %Control Function Register 1 (CFR1)—Address 0x00 Four bytes are assigned to this register.
        %Bit 3 External power-down control a 1 = auxiliary DAC clock signals and bias circuits are disabled.
        val = '00000008';
        fprintf(1,'Address 0x00, value = %s\n',val);
        DDSRegs012BCDE{1} = val;
        
        %Control Function Register 2 (CFR2)—Address 0x01 Four bytes
        %Bit 19 (Digital ramp enable)= 1 = Enables digital ramp generator functionality.
        %Bit 18 (Digital ramp no-dwell high) 1 = enables no-dwell high functionality.
        %a positive transition of the DRCTL pin initiates a positive slope ramp, which
        %continues uninterrupted (regardless of any further activity on the DRCTL pin)
        %until the upper limit is reached.
        %Bit 11 = 1 = the internal PDCLK signal appears at the PDCLK pin (default).
        %Bit 9 (TxEnable invert) = 0 = No inversion
        %Bit 5 (Sync timing validation disable)= 1 = the SYNC_SMP_ERR pin is forced to a static Logic 0 condition (default).
        val = '000C0820';  %dec2bin(hex2dec(val)) = 11000000100000100000
        fprintf(1,'Address 0x01, value = %s\n',val);
        DDSRegs012BCDE{2} = val;
        
        %Control Function Register 3 (CFR3)—Address 0x02 4 bytes
        %Bits 1 to 7 divide modulus of the REFCLK PLL feedback divider ?? Default is zero
        val = '0D1F41C8';  %dec2bin(hex2dec(val)) = 1101000111110100000111001000
        fprintf(1,'Address 0x02, value = %s\n',val);
        DDSRegs012BCDE{3} = val;
        
        %Phase offset word Register (POW)—Address 0x08. 2 Bytes dTheta = 360*POW/2^16.
        dTheta = 0;
        POW = dTheta*2^16/360;
        val = dec2hex(POW,4);
        %fprintf(1,'Address 0x08, value = %s\n',val);
        fprintf(1,'Phase offset word is not changed from default value.  Nor is the Auxiliary DAC Control Register—Address 0x03\n');
        
        %Digital Ramp Limit Register—Address 0x0B
        %63:32 Digital ramp upper limit 32-bit digital ramp upper limit value.
        %31:0 Digital ramp lower limit 32-bit digital ramp lower limit value.
        val = [dec2hex(round(stopFreq/1e9*2^32),8) dec2hex(round(startFreq/1e9*2^32),8)];
        fprintf(1,'Address 0x0B, value = %s\n',val);
        DDSRegs012BCDE{4} = val;
        
        %Digital Ramp Step Size Register—Address 0x0C
        %63:32 Digital ramp decrement step size 32-bit digital ramp decrement step size value.
        %31:0 Digital ramp increment step size 32-bit digital ramp increment step size value.
        M = Fstep*2^32/fsysclk;
        if(abs(M - round(M)))
            disp('warning Digital Ramp Step Size is NOT an integer')
            M = round(M);
        end
        val = [dec2hex(M,8) dec2hex(M,8)];
        fprintf(1,'Address 0x0C, value = %s\n',val);
        DDSRegs012BCDE{5} = val;
        
        %Digital Ramp Rate Register—Address 0x0D
        %31:16 Digital ramp negative slope rate 16-bit digital ramp negative slope value that defines the time interval between decrement values.
        %15:0 Digital ramp positive slope rate 16-bit digital ramp positive slope value that defines the time interval between increment values.
        P = round(Tstep*fsysclk/4);
        val = [dec2hex(P,4) dec2hex(P,4)];
        fprintf(1,'Address 0x0D, value = %s\n',val);
        DDSRegs012BCDE{6} = val;
        
        
    case 'CW Tone'
        cwFreq = 300e6;
        cwPhaseOffset = 0;
        cwAmpScale = 2229;% hex2dec('08B5')=  2229 ??
        promptTitle = 'DDS CW Mode';
        default = {num2str(cwFreq),num2str(cwPhaseOffset),num2str(cwAmpScale)};
        prompt={'Enter CW FREQ      '     ,...
            'Enter PhaseOffset       '...
            'Enter AmpScale 1 - 2^14      '} ;
        lineNo  = 1;
        resize  = 'off';
        answer=inputdlg(prompt,promptTitle,lineNo,default,resize);
        cwFreq= str2double(answer{1});
        cwPhaseOffset = str2double(answer{2});
        cwAmpScale = str2double(answer{3});
        
        %Control Function Register 1 (CFR1)—Address 0x00 Four bytes are assigned to this register.
        %Bit 3 External power-down control a 1 = auxiliary DAC clock signals and bias circuits are disabled.
        val = '00000008';
        fprintf(1,'Address 0x00, value = %s\n',val);
        DDSRegs012BCDE{1} = val;
        
        %Control Function Register 2 (CFR2)—Address 0x01 Four bytes
        %Bit 19 (Digital ramp enable)= 0 = disables digital ramp generator functionality (default).
        %Bit 18 (Digital ramp no-dwell high) 1 = enables no-dwell high functionality
        %Bit 11 = 1 = the internal PDCLK signal appears at the PDCLK pin (default).
        %Bit 9 (TxEnable invert) = 0 = No inversion
        %Bit 5 (Sync timing validation disable)= 1 = the SYNC_SMP_ERR pin is forced to a static Logic 0 condition (default).
        val = '00040820';  %dec2bin(hex2dec(val)) = 1000000100000100000
        fprintf(1,'Address 0x01, value = %s\n',val);
        DDSRegs012BCDE{2} = val;
        
        %Control Function Register 3 (CFR3)—Address 0x02 4 bytes
        %Bits 1 to 7 divide modulus of the REFCLK PLL feedback divider ?? Default is zero
        val = '0D1F41C8';  %dec2bin(hex2dec(val)) = 1101000111110100000111001000
        fprintf(1,'Address 0x02, value = %s\n',val);
        DDSRegs012BCDE{3} = val;
        
        % Single Tone Registers—Address 0x0E - Single tone profiles are in effect when CFR1[31] = 0, CFR2[19] = 0, and CFR2[4] = 0.
        % 63:62 Open
        % 61:48 Amplitude scale factor This 14-bit number controls the DDS output amplitude.
        % 47:32 Phase offset word This 16-bit number controls the DDS phase offset.
        % 31:0 Frequency tuning word This 32-bit number controls the DDS frequency.
        FTW = (cwFreq*2^32)/fsysclk;
        if(abs(FTW - round(FTW)))
            disp('warning Digital Ramp Step Size is NOT an integer')
            FTW = round(FTW);
        end
        val = [ dec2hex(cwAmpScale,4) dec2hex(cwPhaseOffset,4) dec2hex(FTW,8)];
        fprintf(1,'Address 0x0E, value = %s\n',val);
        DDSRegs012BCDE{7} = val;
end

if ~exist('config.ini','file')
    [filename, pathname] = uigetfile('config.ini');
    filename = [pathname,filename];
else
    filename = 'config_hexstrings.ini';
end

fid = fopen(filename,'a');
fprintf(fid,'\r\n; DDS programming strings\r\n');
fprintf(fid,'Reg00=%s\r\n',DDSRegs012BCDE{1});
fprintf(fid,'Reg01=%s\r\n',DDSRegs012BCDE{2});
fprintf(fid,'Reg02=%s\r\n',DDSRegs012BCDE{3});
if strcmp('RAMP',choice)
    fprintf(fid,'Reg0B=%s\r\n',DDSRegs012BCDE{4});
    fprintf(fid,'Reg0C=%s\r\n',DDSRegs012BCDE{5});
    fprintf(fid,'Reg0D=%s\r\n',DDSRegs012BCDE{6});
else
    fprintf(fid,'Reg0E=%s\r\n',DDSRegs012BCDE{7});
end
fclose(fid);

