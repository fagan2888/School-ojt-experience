function cal_hist_show_so1(saveFigures, gNo, setNo)
% Show calibration history
% --------------------------------------

cS = const_so1(gNo, setNo);
[loadS, success] = var_load_so1(cS.vOptimHistory, cS);
if success == 0
   disp('Cannot load history');
   return;
end

iter = min(4000, loadS.iter);
resultV = loadS.resultV(1 : iter);


%% Plot deviations
if 1
   fig_new_so(saveFigures);
   plot(1:iter, cellfun(@(x) x.dev, resultV), '.');
   title('Deviation');
   save_fig_so('hist_dev', saveFigures, [], cS);
end



%% Plot theta
if 1
   fig_new_so(saveFigures);
   plot(1:iter, cellfun(@(x) x.paramS.theta, resultV), '.');
   title('Theta');
   save_fig_so('hist_theta', saveFigures, [], cS);
end



%% Plot h1 std
if 1
   fig_new_so(saveFigures);
   plot(1:iter, cellfun(@(x) x.paramS.h1Std, resultV), '.');
   title('h1 std');
   save_fig_so('hist_h1std', saveFigures, [], cS);
end


%% Plot alphas
if 1
   % Extract all alphas, by [iter, school]
   alphaM = cellfun(@(x) x.paramS.alphaV(:)', resultV, 'UniformOutput', 0);
   alphaM = cell2mat(alphaM);
   if ~v_check(alphaM, 'f', [iter, cS.nSchool], 0, 1, [])
      error_so1('Invalid');
   end
   
   fig_new_so(saveFigures);
   for iSchool = 1 : cS.nSchool
      subplot(2,2,iSchool);
      %hold on;
      plot(1:iter, alphaM(:,iSchool), '.', 'color', cS.colorM(1,:));
      %plot(1:iter, devV, 'b.');
      hold off;
      ylabel(['Alpha - ', cS.schoolLabelV{iSchool}]);
   end
   save_fig_so('hist_alpha', saveFigures, [], cS);
end



%% Plot deltas
if 1
   % Extract all alphas, by [iter, school]
   deltaM = cellfun(@(x) x.paramS.ddhV(:)', resultV, 'UniformOutput', 0);
   deltaM = cell2mat(deltaM);
   if ~v_check(deltaM, 'f', [iter, cS.nSchool], 0, 1, [])
      error_so1('Invalid');
   end
   
   fig_new_so(saveFigures);
   for iSchool = 1 : cS.nSchool
      subplot(2,2,iSchool);
      %hold on;
      plot(1:iter, deltaM(:,iSchool), '.', 'color', cS.colorM(1,:));
      %plot(1:iter, devV, 'b.');
      hold off;
      ylabel(['Delta - ', cS.schoolLabelV{iSchool}]);
   end
   save_fig_so('hist_delta', saveFigures, [], cS);
end



end