function cf_plotAmp(f,g,ii)
if nargin<3
    ii = 1:numel(f.rangeCoarse);
end
%plot the standard amplitude profile
fah = plot(f.rangeCoarse(ii),20*log10(abs(f.specCor(ii))),'r');
hold on
gah = plot(g.rangeCoarse(ii),20*log10(abs(g.specCor(ii))),'b');
ylabel('Vrms (dB)')
xlabel('range (m)')
legend([fah(1) gah(1)],{'f','g'},'Location','SouthWest')
ylim([-140 -20])