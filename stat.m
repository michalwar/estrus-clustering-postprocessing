% \multirow{2}{*}{0.1} & & & & & & \\
%                      & & & & & & \\ \midrule
instances = {'0.1', '0.3', '0.5', '1.0'};
util = Utility();

for i = 1:length(instances)
  fprintf('\\multirow{2}{*}{%s} &', instances{i});
  [mp, mr, md, sp, sr, sd] = util.aggregate_result('baseline', instances{i});
  fprintf('%0.2f & %0.2f & %0.2f & ', mp, mr, md);
  [mp, mr, md, sp, sr, sd] = util.aggregate_result('propose', instances{i});
  fprintf('%0.2f & %0.2f & %0.2f \\\\\n', mp, mr, md);
  [mp, mr, md, sp, sr, sd] = util.aggregate_result('baseline', instances{i});
  fprintf('& (%0.3f) & (%0.3f) & (%0.3f) & ', sp, sr, sd);
  [mp, mr, md, sp, sr, sd] = util.aggregate_result('propose', instances{i});
  fprintf('(%0.3f) & (%0.3f) & (%0.3f) \\\\ \\midrule\n', sp, sr, sd);
end